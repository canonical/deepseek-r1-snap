#!/bin/bash -eu

server="$SNAP_COMPONENTS/$(snapctl get server)"
model="$SNAP_COMPONENTS/$(snapctl get model)"

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
