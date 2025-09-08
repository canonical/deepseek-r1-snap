#!/bin/bash -eux

echo "Testing:"
echo "DEVICE_IP = $DEVICE_IP"
echo "SNAP_NAME = $SNAP_NAME"
echo "SNAP_CHANNEL = $SNAP_CHANNEL"

echo "Installing hwcert tools"
curl -Ls -o install_tools.sh https://raw.githubusercontent.com/canonical/hwcert-jenkins-tools/main/install_tools.sh
# install the scriptlets and other tools on the agent and the device, as necessary
export TOOLS_PATH=tools
source install_tools.sh $TOOLS_PATH
[ ! "$?" -eq 0 ] && echo "Error: Failed to run installer" && exit 1

echo "Installing agent dependencies"
sudo apt-get install --yes bc
#sudo snap install jq # Can't install snaps on agent, but it is already available.

# ensure device is available before continuing
wait_for_ssh --allow-degraded || exit 1

# Don't refresh snaps automatically
_run sudo snap refresh --hold=3h --no-wait

# On UC22, the kernel, core, snapd snaps get refreshed right after first boot,
# causing unexpected errors and triggering a reboot
# On UC24, the auto refresh starts after a delay while testing
echo "Force refresh snaps for consistency"
_run sudo snap refresh --no-wait
wait_for_snap_changes

echo "Installing device dependencies"
_run sudo apt-get install --yes git
_run sudo snap install go --classic --no-wait

if [[ "${INSTALL_NVIDIA_DRIVERS}" == "true" ]]; then
  echo "Installing NVIDIA drivers, CUDA and utils on device"
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
fi

echo "Remove $SNAP_NAME if already installed"
_run sudo snap remove "$SNAP_NAME" --no-wait
wait_for_snap_changes
echo "Installing $SNAP_NAME from $SNAP_CHANNEL"
_run sudo snap install "$SNAP_NAME" --channel "$SNAP_CHANNEL" --no-wait
wait_for_snap_changes

# Force select an engine if variable is set
if [[ -n "${SELECT_engine}" ]]; then
  _run sudo "$SNAP_NAME" use "$SELECT_engine"
  wait_for_snap_changes
  # engine might install two large components. If the first one times out, try again to trigger the second one.
  _run sudo "$SNAP_NAME" use "$SELECT_engine"
  wait_for_snap_changes
fi

selected_engine=$(_run sudo snap get deepseek-r1 engine)
echo "Auto selected engine: $selected_engine"

if [ "$EXPECTED_engine" != "$selected_engine" ]; then
  echo "::error::Incorrect engine selected: $EXPECTED_engine != $selected_engine"
  exit 1
fi

# Start the server. While we wait, clone the benchmark tools. Then check if server has started.
_run sudo snap start "$SNAP_NAME".server
_run "git clone https://github.com/jpm-canonical/llmapibenchmark.git && cd llmapibenchmark && git checkout ea5d6bc"
_run snap run --shell "$SNAP_NAME" "/snap/$SNAP_NAME/current/bin/wait-for-server.sh"

# If the model name option is set, use it when talking to the api
model_name=$(_run sudo snap get deepseek-r1 model-name || echo "")
benchmark_result=$(_run "cd llmapibenchmark/cmd && DEBUG=true go run . --base-url=http://localhost:8080/v1 --model=$model_name --concurrency=1 --format=json")
echo "$benchmark_result"

result_tps=$(echo "$benchmark_result" | jq .results[0].generation_speed)
too_slow=$(echo "$result_tps < $EXPECTED_TPS" | bc -l)

if [ "$too_slow" -eq 1 ]; then
  echo "::error::Performance lower than expected: $result_tps < $EXPECTED_TPS"
  exit 1
fi
