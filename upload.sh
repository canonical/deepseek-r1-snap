#!/bin/bash -ue

channel=$1

# Extract components from snapcraft.yaml (ignore those commented-out)
components=$(yq '.components | to_entries | map(select(.value != null)) | .[].key' snap/snapcraft.yaml | tr -d '"')

# Build components argument list
component_args=()
for comp in $components; do
    files=(deepseek-r1+${comp}_*.comp)
    if [[ -e "${files[0]}" ]]; then
        for file in "${files[@]}"; do
            component_args+=(--component "$comp=$file")
        done
    else
        echo "Error:'$comp' comp file not found (expected: deepseek-r1+${comp}_*.comp)"
    fi
done

set -x
snapcraft upload deepseek-r1_v3_amd64.snap "${component_args[@]}" --release="$channel"
