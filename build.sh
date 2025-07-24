#!/bin/bash -eu

exit_error() {
  echo "Error: ${1}" >&2
  exit 1
}

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
  exit_error "Stack '$STACK_NAME' does not exist."
fi

# Load selected stack.yaml into variable, explode to evaluate aliases
stack_yaml=$(yq '. | explode(.)' "$STACK_FILE")
if [[ -z "$stack_yaml" ]]; then
  exit_error "Stack '$STACK_FILE' is empty"
fi

# Creates the components array with the contents of the .components[] list
readarray -t components < <(yq '.components[]' "$STACK_FILE")

# Check if array lenght is 0
if [[ ${#components[@]} -eq 0 ]]; then
  exit_error "Stack '$STACK_FILE' has no components"
fi
echo "Selected from stack ${STACK_NAME}: ${components[*]}"

# Converts the array into a string separated by '|'
printf -v llm_pieces "%s|" "${components[@]}"

echo "Generating new snapcraft.yaml"
essentials="app-scripts|stacks|ml-snap-utils|go-chat-client|common-runtime-dependencies"

# Copy snap/snapcraft.yaml to snapcraft.yaml, retaining only the selected parts and components
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
