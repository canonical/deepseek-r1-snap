#!/bin/bash -eu

check_missing_components() {
    local -n missing_ref=$1
    local required_components="$2"

    missing_ref=()
    for component in $required_components; do
        if [ ! -d "$SNAP_COMPONENTS/$component" ]; then
            missing_ref+=("$component")
        fi
    done
}

engine_manifest=$(deepseek-r1 show-engine)
engine="$(echo "$engine_manifest" | yq .name)"
required_components="$(echo "$engine_manifest" | yq .components[])"
unset engine_manifest

# Check for missing components
missing_components=()
check_missing_components missing_components "$required_components"

retry_count=0
delay=10
max_retries=360 # 10 seconds * 360 = 1 hour
while [ ${#missing_components[@]} -ne 0 ] && [ "$retry_count" -lt $max_retries ]; do
    echo "Missing required snap components: [${missing_components[*]}], retrying in $delay seconds..."
    sleep "$delay"
    ((++retry_count))
    check_missing_components missing_components "$required_components"
done

if [ ${#missing_components[@]} -ne 0 ]; then
    echo "Error: timed out after $max_retries retries, missing components [${missing_components[*]}]."
    exit 1
fi


exec "$SNAP/engines/$engine/server" "$@"
