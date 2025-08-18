#!/bin/bash -eux

echo "Testing:"
echo "DEVICE_IP = $DEVICE_IP"
echo "SNAP_NAME = $SNAP_NAME"
echo "SNAP_CHANNEL = $SNAP_CHANNEL"

# retrieve the tools installer
curl -Ls -o install_tools.sh https://raw.githubusercontent.com/canonical/hwcert-jenkins-tools/main/install_tools.sh
# install the scriptlets and other tools on the agent and the device, as necessary
export TOOLS_PATH=tools
source install_tools.sh $TOOLS_PATH
[ ! "$?" -eq 0 ] && echo "Error: Failed to run installer" && exit 1

# ensure device is available before continuing
wait_for_ssh || exit 1

# Don't refresh snaps automatically
_run sudo snap refresh --hold=3h --no-wait

# On UC22, the kernel, core, snapd snaps get refreshed right after first boot,
# causing unexpected errors and triggering a reboot
# On UC24, the auto refresh starts after a delay while testing
echo "Force refresh snaps for consistency"
_run sudo snap refresh --no-wait
wait_for_snap_changes

echo "Installing dependencies"
_run sudo apt-get install --yes git
_run sudo snap install go --classic --no-wait
_run sudo snap install jq --no-wait

echo "Remove $SNAP_NAME if already installed"
_run sudo snap remove "$SNAP_NAME" --no-wait
wait_for_snap_changes
echo "Installing $SNAP_NAME from $SNAP_CHANNEL"
_run sudo snap install "$SNAP_NAME" --channel "$SNAP_CHANNEL" --no-wait
wait_for_snap_changes

selected_stack=$(_run sudo snap get deepseek-r1 stack)
echo "Auto selected stack: $selected_stack"

if [ "$EXPECTED_STACK" != "$selected_stack" ]; then
  echo "WARNING: Expected stack not selected"
  # exit 1
fi

# If the model name option is set, use it when talking to api
model_name=$(_run sudo snap get deepseek-r1 model-name || echo "")

_run sudo snap start "$SNAP_NAME".server
sleep 5
_run snap run --shell "$SNAP_NAME" "/snap/$SNAP_NAME/current/bin/wait-for-server.sh"

_run git clone https://github.com/jpm-canonical/llmapibenchmark.git
benchmark_result=$(_run "cd llmapibenchmark/cmd && DEBUG=true go run . --base-url=http://localhost:8080/v1 --model=$model_name --concurrency=1 --format=json")
echo "$benchmark_result"

result_tps=$(echo "$benchmark_result" | jq .results[0].generation_speed)

if (( $(echo "$result_tps < $EXPECTED_TPS" | bc -l) )); then
  echo "ERROR: Performance lower than expected: $result_tps < $EXPECTED_TPS"
  exit 1
fi
