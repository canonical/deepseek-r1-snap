#!/bin/bash -x

# Stacks to test
declare -a stacks=("generic-cpu-1-5b" "generic-cuda-7b")

echo "Testing: DEVICE_IP = $DEVICE_IP"

echo "Installing drivers"
ssh ubuntu@$DEVICE_IP "sudo apt-get -qqq update && \
sudo apt-get -qqq install -y nvidia-driver-$NVIDIA_VERSION nvidia-utils-$NVIDIA_VERSION nvidia-cuda-toolkit"

# Reboot the device in background to avoid breaking the SSH connection prematurely
echo "Rebooting the device"
ssh ubuntu@$DEVICE_IP "(sleep 3 && sudo reboot) &"

# Wait for shutdown
sleep 10

# Wait for reboot
while ! ssh ubuntu@$DEVICE_IP "ls"; do
  echo "Wait for reboot (ssh server online)..."
  sleep 30
done

# On Ubuntu Core, kernel, core, snapd snaps get refreshed right after first boot,
# causing unexpected errors and triggering a reboot
while ! ssh ubuntu@$DEVICE_IP "$(< check-snap-changes.sh)"; do
  echo "Wait for snap changes..."
  sleep 30
done

echo "Installing $SNAP_NAME from $SNAP_CHANNEL"
ssh ubuntu@$DEVICE_IP "sudo snap install $SNAP_NAME --devmode --channel=$SNAP_CHANNEL"
# If the snap is already installed, we need to do a refresh
echo "Refreshing $SNAP_NAME from $SNAP_CHANNEL"
ssh ubuntu@$DEVICE_IP "sudo snap refresh $SNAP_NAME --channel=$SNAP_CHANNEL"

echo "Setting GPU layers"
ssh ubuntu@$DEVICE_IP "sudo snap set $SNAP_NAME n-gpu-layers=30"

# echo "Installing and reconnecting graphics interfaces"
# ssh ubuntu@$DEVICE_IP "$(< connect-graphics.sh)"

# It looks like we need to reboot after installing the snap for the graphics to be available
# Reboot the device in background to avoid breaking the SSH connection prematurely
echo "Rebooting the device"
ssh ubuntu@$DEVICE_IP "(sleep 3 && sudo reboot) &"

# Wait for shutdown
sleep 10

# Wait for reboot
while ! ssh ubuntu@$DEVICE_IP "ls"; do
  echo "Wait for reboot (ssh server online)..."
  sleep 30
done

# Loop through the array of stacks
for i in "${stacks[@]}"
do
    echo ""
    echo "Testing stack $i"
    ssh ubuntu@$DEVICE_IP "sudo snap set $SNAP_NAME stack=\"$i\""
    RESPONSE=$(ssh ubuntu@$DEVICE_IP "$(< device-script.sh)")
    EXIT_CODE=$?
    echo "$RESPONSE"
    if [ $EXIT_CODE -eq 0 ]; then
        echo "Stack $i succeeded"
    else
        echo "Stack $i failed"
        exit 1
    fi
done