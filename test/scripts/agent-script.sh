#!/bin/bash -x

# Stacks to test
declare -a stacks=("generic-cpu-1-5b" "generic-cuda-7b")

# Inject env vars into device scripts
envsubst '$SNAP_NAME' \
  < device-script.sh \
  > device-script.temp
mv device-script.temp device-script.sh

envsubst '$SNAP_NAME' \
  < connect-graphics.sh \
  > connect-graphics.temp
mv connect-graphics.temp connect-graphics.sh

echo "Testing:"
echo "DEVICE_IP = $DEVICE_IP"
echo "SNAP_NAME = $SNAP_NAME"
echo "SNAP_CHANNEL = $SNAP_CHANNEL"
echo "NVIDIA_VERSION = $NVIDIA_VERSION"

# Don't refresh snaps automatically
ssh ubuntu@$DEVICE_IP "sudo snap refresh --hold=3h --no-wait"

# On UC22, the kernel, core, snapd snaps get refreshed right after first boot,
# causing unexpected errors and triggering a reboot
# On UC24, the auto refresh starts after a delay while testing
echo "Force refresh snaps for consistency"
ssh ubuntu@$DEVICE_IP "sudo snap refresh --no-wait"
# Refresh of some system snaps stops SnapD and schedules a reboot
while ! ssh ubuntu@$DEVICE_IP "$(< check-snap-changes.sh)"; do
  echo "Waiting for snap changes ..."
  sleep 30
done

echo "Installing NVIDIA drivers, CUDA and utils"
ssh ubuntu@$DEVICE_IP "sudo apt-get -qqq update && \
sudo apt-get -qqq install -y nvidia-driver-$NVIDIA_VERSION nvidia-utils-$NVIDIA_VERSION nvidia-cuda-toolkit"

# Reboot the device to load NVIDIA drivers
# In background to avoid breaking the SSH connection prematurely
echo "Rebooting the device"
ssh ubuntu@$DEVICE_IP "(sleep 3 && sudo reboot) &"

# Wait for shutdown to happen
sleep 10

# Wait for reboot
while ! ssh ubuntu@$DEVICE_IP "ls"; do
  echo "Wait for reboot (ssh server online)..."
  sleep 30
done

echo "Installing $SNAP_NAME from $SNAP_CHANNEL"
ssh ubuntu@$DEVICE_IP "sudo snap install $SNAP_NAME --devmode --channel=$SNAP_CHANNEL"
# If the snap is already installed, we need to do a refresh
echo "Refreshing $SNAP_NAME from $SNAP_CHANNEL"
ssh ubuntu@$DEVICE_IP "sudo snap refresh $SNAP_NAME --channel=$SNAP_CHANNEL"

# Temporary workaround while issue #7 is unresolved
echo "Setting GPU layers"
ssh ubuntu@$DEVICE_IP "sudo snap set $SNAP_NAME n-gpu-layers=29"

# Loop through the array of stacks
for i in "${stacks[@]}"
do
    echo ""
    echo "Testing stack $i"
    ssh ubuntu@$DEVICE_IP "sudo snap set $SNAP_NAME stack=\"$i\""

    echo "Reconnecting opengl interface"
    ssh ubuntu@$DEVICE_IP "$(< connect-graphics.sh)"

    ssh ubuntu@$DEVICE_IP "$(< device-script.sh)"
    EXIT_CODE=$?
    if [ $EXIT_CODE -eq 0 ]; then
        echo "Stack $i succeeded"
    else
        echo "Stack $i failed"
        exit 1
    fi
done