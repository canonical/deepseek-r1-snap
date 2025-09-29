#!/bin/bash -eu

engine_manifest=$($SNAP_NAME show-engine)
engine="$(echo "$engine_manifest" | yq .name)"
required_components="$(echo "$engine_manifest" | yq .components[])"
unset engine_manifest

# Check for missing components
missing_components=()
for component in $required_components; do
    if [ ! -d "$SNAP_COMPONENTS/$component" ]; then
        missing_components+=("$component")
    fi
done

if [ ${#missing_components[@]} -ne 0 ]; then
    echo "Error: missing required snap components: [${missing_components[*]}]"
    exit 1
fi


exec "$SNAP/engines/$engine/server" "$@"
