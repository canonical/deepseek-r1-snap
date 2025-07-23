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
readarray -t components < <(yq '.components[]' "$STACK_FILE")
echo "Selected from stack ${STACK_NAME}: ${components[*]}"
printf -v llm_pieces "%s|" "${components[@]}"

echo -e "Generating new snapcraft.yaml\n"
essentials="app-scripts|stacks|ml-snap-utils|go-chat-client|common-runtime-dependencies"

yq "explode(.) |
  .parts |= with_entries(select(.key | test(\"^(${llm_pieces}${essentials})$\"))) |
  .components |= with_entries(select(.key | test(\"^(${llm_pieces})$\")))
" snap/snapcraft.yaml >snapcraft.yaml

if [[ ${2-} == "--dryrun" ]]; then
  exit 0
fi

echo "Building snap with stack '$STACK_NAME'"
snapcraft -v || true
rm -f snapcraft.yaml