#!/bin/bash -eu

# The outer testflinger action uses groups for logging. Close its existing one, so we can use our own.
echo "::endgroup::"

echo "::group::Installing hwcert tools"
curl -Ls -o install_tools.sh https://raw.githubusercontent.com/canonical/hwcert-jenkins-tools/main/install_tools.sh
# install the scriptlets and other tools on the agent and the device, as necessary
export TOOLS_PATH=tools
source install_tools.sh $TOOLS_PATH
[ ! "$?" -eq 0 ] && echo "::error::Failed to run tools installer" && exit 1
echo "::endgroup::"

echo "::group::Installing agent dependencies"
sudo apt-get install --yes bc
#sudo snap install jq # Can't install snaps on agent, but it is already available.
echo "::endgroup::"

echo "::group::Target machine"
# ensure machine is available before continuing
wait_for_ssh --allow-degraded || exit 1
# Store machine hostname for logging
dut_hostname=$(_run hostname)
echo "Test machine: $dut_hostname"
echo "::endgroup::"

echo "::group::Snapd refresh"
# Don't refresh snaps automatically
_run sudo snap refresh --hold=3h --no-wait
# On UC22, the kernel, core, snapd snaps get refreshed right after first boot,
# causing unexpected errors and triggering a reboot
# On UC24, the auto refresh starts after a delay while testing
echo "Force refresh snaps for consistency"
_run sudo snap refresh --no-wait
wait_for_snap_changes
echo "::endgroup::"

echo "::group::Installing device dependencies"
_run sudo apt-get install --yes git
_run sudo snap install go --classic --no-wait
echo "::endgroup::"

if [[ "${INSTALL_NVIDIA_DRIVERS}" == "true" ]]; then
  echo "::group::Installing NVIDIA drivers, CUDA and utils on device"
  _run sudo apt-get update
  _run sudo apt-get install -y nvidia-driver-$NVIDIA_DRIVERS_VERSION nvidia-cuda-toolkit

  # Reboot the device to load NVIDIA drivers
  # In background to avoid breaking the SSH connection prematurely
  echo "Rebooting the device"
  ssh ubuntu@$DEVICE_IP "(sleep 3 && sudo reboot) &"

  # Wait for shutdown to happen
  sleep 10

  # Wait for reboot
  wait_for_ssh --allow-degraded || exit 1
  echo "::endgroup::"
fi

echo "::group::Installing snap"
echo "Remove $SNAP_NAME if already installed"
_run sudo snap remove "$SNAP_NAME" --no-wait
wait_for_snap_changes
echo "Installing $SNAP_NAME from $SNAP_CHANNEL"
_run sudo snap install "$SNAP_NAME" --channel "$SNAP_CHANNEL" --no-wait
wait_for_snap_changes
echo "::endgroup::"

# Force select an engine if variable is set
if [[ -n "${SELECT_ENGINE}" ]]; then
  echo "::group::Manually selecting engine"
  _run sudo "$SNAP_NAME" use-engine "$SELECT_ENGINE"
  wait_for_snap_changes
  # engine might install two large components. If the first one times out, try again to trigger the second one.
  _run sudo "$SNAP_NAME" use-engine "$SELECT_ENGINE"
  wait_for_snap_changes
  echo "::endgroup::"
fi

echo "::group::Checking selected engine"
selected_engine=$(_run "$SNAP_NAME" status --format=json | jq -r .engine)
echo "Selected engine: $selected_engine"

if [ "$EXPECTED_ENGINE" != "$selected_engine" ]; then
  echo "::error::Machine: $dut_hostname, incorrect engine selected: $selected_engine"
  exit 1
fi
echo "::endgroup::"

echo "::group::Start server and clone benchmark"
# Start the server. While we wait, clone the benchmark tools. Then check if server has started.
_run sudo snap start "$SNAP_NAME".server
_run "git clone --depth 1 --branch v1.0.5 https://github.com/Yoosu-L/llmapibenchmark.git"
_run snap run --shell "$SNAP_NAME" "/snap/$SNAP_NAME/current/bin/wait-for-server.sh"
echo "::endgroup::"

echo "::group::Running benchmark"
benchmark_result=$(_run "cd llmapibenchmark/cmd && DEBUG=true go run . --base-url=http://localhost:8080/v1 --concurrency=1 --format=json")
echo "$benchmark_result"

result_tps=$(echo "$benchmark_result" | jq .results[0].generation_speed)
too_low=$(echo "$result_tps < $EXPECTED_TPS" | bc -l)
echo "::endgroup::"

echo "::notice::Machine: $dut_hostname, Engine: $selected_engine, TPS: $result_tps"

if [ "$too_low" -eq 1 ]; then
  echo "::error::Machine: $dut_hostname, TPS too low: $result_tps"
  exit 1
fi

echo "::group::Testflinger cleanup"