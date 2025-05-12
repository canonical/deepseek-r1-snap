#!/bin/bash -eu

engine="$SNAP_COMPONENTS/$(snapctl get engine)"
model="$SNAP_COMPONENTS/$(snapctl get model)"

if [ ! -d "$model" ]; then
    echo "Missing component: $model"
    exit 1
fi

source "$model/init" # exports MODEL_FILE

if [ ! -d "$engine" ]; then
    echo "Missing component: $engine"
    exit 1
fi

# For staged shared objects
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$engine/usr/lib/$ARCH_TRIPLET:$engine/usr/local/lib"

# Other user changeable configs

N_GPU_LAYERS="$(snapctl get n-gpu-layers)"
if [ -z "$N_GPU_LAYERS" ]; then
    N_GPU_LAYERS=33 # By default load all 33 layers on to GPU
fi
