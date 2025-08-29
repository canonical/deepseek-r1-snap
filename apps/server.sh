#!/bin/bash -u

stack="$(snapctl get stack)"

if [ -z "$stack" ]; then
    echo "Stack not set!"
    sleep 5
    exit 1
fi

engine="$(snapctl get engine)"
model="$(snapctl get model)"

# Check for missing components
missing_components=()

if [ ! -d "$SNAP_COMPONENTS/$model" ]; then
    missing_components+=("$model")
fi

if [ ! -d "$SNAP_COMPONENTS/$engine" ]; then
    missing_components+=("$engine")
fi

if [ ${#missing_components[@]} -ne 0 ]; then
    echo "Missing components: ${missing_components[*]}" >&2
    sleep 10
    exit 1
fi


exec "$SNAP/stacks/$stack/server" "$@"
