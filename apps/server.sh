#!/bin/bash -u

stack="$(snapctl get stack)"

if [ -z "$stack" ]; then
    echo "Stack not set!"
    exit 1
fi

stack_file="$SNAP/stacks/$stack/stack.yaml"
if [ ! -f "$stack_file" ]; then
    echo "Stack file not found: $stack_file"
    exit 1
fi

# Check for missing components
missing_components=()
while read -r component; do
    if [ ! -d "$SNAP_COMPONENTS/$component" ]; then
        missing_components+=("$component")
    fi
done <<< "$(cat "$stack_file" | yq .components[])"

if [ ${#missing_components[@]} -ne 0 ]; then
    echo "Error: missing required snap components: [${missing_components[*]}]"
    exit 1
fi


exec "$SNAP/stacks/$stack/server" "$@"
