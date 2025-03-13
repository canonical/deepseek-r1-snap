#!/bin/bash -x

echo "Testing:"
echo "DEVICE_IP = $DEVICE_IP"
echo "SNAP_NAME = $SNAP_NAME"
echo "SNAP_CHANNEL = $SNAP_CHANNEL"
echo "NVIDIA_VERSION = $NVIDIA_VERSION"

echo "Testing stacks: "
for i in "${STACKS[@]}"
do
    echo -e "\t$i"
done

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

echo "Installing NVIDIA drivers, CUDA and utils"
_run sudo apt-get update
_run sudo apt-get install -y nvidia-driver-$NVIDIA_VERSION nvidia-utils-$NVIDIA_VERSION nvidia-cuda-toolkit

# Reboot the device to load NVIDIA drivers
# In background to avoid breaking the SSH connection prematurely
echo "Rebooting the device"
ssh ubuntu@$DEVICE_IP "(sleep 3 && sudo reboot) &"

# Wait for shutdown to happen
sleep 10

# Wait for reboot
wait_for_ssh

echo "Remove $SNAP_NAME if already installed"
_run sudo snap remove $SNAP_NAME --no-wait
wait_for_snap_changes
echo "Installing $SNAP_NAME from $SNAP_CHANNEL"
_run sudo snap install $SNAP_NAME --devmode --channel=$SNAP_CHANNEL --no-wait
wait_for_snap_changes

# Temporary workaround while issue #7 is unresolved
echo "Setting GPU layers"
_run sudo snap set $SNAP_NAME n-gpu-layers=29 --no-wait
wait_for_snap_changes

# Loop through the array of stacks
for i in "${STACKS[@]}"
do
    echo ""
    echo "Testing stack $i"
    _run sudo snap set $SNAP_NAME stack=\"$i\" --no-wait
    wait_for_snap_changes

    echo "Reconnecting opengl interface"
    _run sudo snap disconnect $SNAP_NAME:opengl
    _run sudo snap connect $SNAP_NAME:opengl

    TMP_FILE="/tmp/test-llm-chat"

    echo "Starting chat"
    (_run $SNAP_NAME.chat -v >$TMP_FILE 2>&1) &
    DSID=$!
    # Wait for chat to load
    sleep 5
    echo "Checking process $DSID"
    ps -p $DSID > /dev/null
    CHAT_EXIT_CODE=$?
    echo "ps exit code: $CHAT_EXIT_CODE"
    if [ $CHAT_EXIT_CODE -eq 0 ]; then
        # Succeeded
        echo "Success. Closing chat"
        kill $DSID || true
        rm $TMP_FILE
    else
        # Failed
        echo "Chat failed"
        echo "-- Log start --"
        cat $TMP_FILE
        echo "-- Log end --"
        rm $TMP_FILE
        exit $CHAT_EXIT_CODE
    fi

    # Start the server
    echo "Starting server"
    _run sudo snap start $SNAP_NAME.server
    # Wait for server to properly start before querying it
    sleep 10

    # Do two requests to the api to check that it works
    echo "Sending Hi to API"
    RESPONSE=$(_run curl --silent http://localhost:8080/v1/chat/completions -H 'Content-Type: application/json' -d '"{\"messages\": [{\"content\": \"Hi\", \"role\": \"user\"}]}"')

    TPS=$(echo $RESPONSE | jq '.timings.predicted_per_second')
    if [ "$TPS" == "null" ]; then
        echo "FAILED - TPS is null"
        echo $RESPONSE
        exit 1
    else
        echo "API worked. $TPS tokens per second."
    fi

    echo "Sending longer request to API"
    RESPONSE=$(_run curl --silent http://localhost:8080/v1/chat/completions -H 'Content-Type: application/json' -d '"{\"messages\": [{\"content\": \"Who was Alice in Wonderland?\", \"role\": \"user\"}]}"')

    TPS=$(echo $RESPONSE | jq '.timings.predicted_per_second')
    if [ "$TPS" == "null" ]; then
        echo "FAILED - TPS is null"
        echo $RESPONSE
        exit 1
    else
        echo "API worked. $TPS tokens per second."
    fi

    echo "Stopping server"
    _run sudo snap stop $SNAP_NAME.server
done