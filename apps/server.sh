#!/bin/bash -u

engine="$(snapctl get engine)"

if [ -z "$engine" ]; then
    echo "engine not set!"
    exit 1
fi

engine_file="$SNAP/engines/$engine/engine.yaml"
if [ ! -f "$engine_file" ]; then
    echo "engine manifest not found: $engine_file"
    exit 1
fi

# Check for missing components
missing_components=()
while read -r component; do
    if [ ! -d "$SNAP_COMPONENTS/$component" ]; then
        missing_components+=("$component")
    fi
done <<< "$(cat "$engine_file" | yq .components[])"

if [ ${#missing_components[@]} -ne 0 ]; then
    echo "Error: missing required snap components: [${missing_components[*]}]"
    exit 1
fi


exec "$SNAP/engines/$engine/server" "$@"
