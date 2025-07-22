#!/bin/bash -eu

# if no argument is provided, just build everything
if [ -z "${1-}" ]; then
  rm -f snapcraft.yaml
  snapcraft -v
  exit 0
fi

echo "Stack selected: '$1'"

STACK_NAME="${1-}"
STACK_DIR="stacks/$STACK_NAME"
STACK_FILE="$STACK_DIR/stack.yaml"
if [ ! -d "$STACK_DIR" ]; then
  echo "Error: Stack '$STACK_NAME' does not exist."
  exit 1
fi

echo "Extracting model and engine"
stack_yaml=$(yq '. | explode(.)' "$STACK_FILE")
model=$(echo "$stack_yaml" | yq '.configurations.model')
engine=$(echo "$stack_yaml" | yq '.configurations.engine')

echo "model: $model"
echo "engine: $engine"

echo -e "Generating new snapcraft.yaml\n"

essentials="app-scripts|stacks|ml-snap-utils|go-chat-client|common-runtime-dependencies"

yq "explode(.) |
  .parts |= with_entries(select(.key | test(\"^(${essentials}|${model}|${engine})$\"))) |
  .components |= with_entries(select(.key | test(\"^(${model}|${engine})$\")))
" snap/snapcraft.yaml >snapcraft.yaml

if [[ ${2-} == "--dryrun" ]]; then
  exit 0
fi

echo "Building snap with stack '$STACK_NAME'"
snapcraft -v
