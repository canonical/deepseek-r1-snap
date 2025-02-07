#!/bin/bash -eu

model="$SNAP_COMPONENTS/$(snapctl get model)"

if [ ! -d "$model" ]; then
    echo "Missing component: $model"
    exit 1
fi

exec "$model/init"
