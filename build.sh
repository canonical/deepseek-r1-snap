#!/bin/bash -eu

# if no argument is provided, just build everything
if [ -z "${1-}" ]; then
  rm -f snapcraft.yaml
  snapcraft -v
  exit 0
fi

STACK_NAME="${1-}"
echo "Stack selected: '$STACK_NAME'"

STACK_DIR="stacks/$STACK_NAME"
STACK_FILE="$STACK_DIR/stack.yaml"
if [ ! -d "$STACK_DIR" ]; then
  echo "Error: Stack '$STACK_NAME' does not exist." >&2
  exit 1
fi

stack_yaml=$(yq '. | explode(.)' "$STACK_FILE")
readarray -t components < <(yq '.components[]' "$STACK_FILE")
echo "Selected from stack ${STACK_NAME}: ${components[*]}"
printf -v llm_pieces "%s|" "${components[@]}"

echo "Generating new snapcraft.yaml"
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
