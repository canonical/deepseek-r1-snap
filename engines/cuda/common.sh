#!/bin/bash -eu

server="$SNAP_COMPONENTS/$(deepseek-r1 get server)"
model="$SNAP_COMPONENTS/$(deepseek-r1 get model)"

if [ ! -d "$model" ]; then
    echo "Missing component: $model"
    exit 1
fi

source "$model/init" # exports MODEL_FILE

if [ ! -d "$server" ]; then
    echo "Missing component: $server"
    exit 1
fi

# For staged shared objects
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$server/usr/lib/$ARCH_TRIPLET:$server/usr/local/lib"

# Other user changeable configs

N_GPU_LAYERS="$(deepseek-r1 get n-gpu-layers)"
if [ -z "$N_GPU_LAYERS" ]; then
    N_GPU_LAYERS=33 # By default load all 33 layers on to GPU
fi
