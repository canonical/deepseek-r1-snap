#!/bin/bash -eu

exit_error() {
  echo "Error: ${1}" >&2
  exit 1
}

help() {
  echo "Usage:" >&2
  echo "  $0 <stack-name> [--dryrun]" >&2
  echo "" >&2
  echo "Options:" >&2
  echo "  --dryrun    Generate snapcraft.yaml without building the snap." >&2
}

if [[ "$(yq --version)" != *v4* ]]; then
  exit_error "Please install yq v4."
fi

if [ -z "${1-}" ]; then
  help
  exit_error "No stack provided"
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

# Check if array length is 0
if [[ ${#components[@]} -eq 0 ]]; then
  exit_error "Stack '$STACK_FILE' has no components"
fi
echo "Stack components: ${components[*]}"

# Converts the array into a regex
printf -v llm_pieces "%s|" "${components[@]}"

echo "Generating new snapcraft.yaml"
essentials="app-scripts|stacks|ml-snap-utils|go-chat-client|common-runtime-dependencies"

# Copy snap/snapcraft.yaml to snapcraft.yaml, retaining only the parts and components that match the regex
yq "explode(.) |
  .parts |= with_entries(select(.key | test(\"^(${llm_pieces}${essentials})$\"))) |
  .components |= with_entries(select(.key | test(\"^(${llm_pieces})$\")))
" snap/snapcraft.yaml >snapcraft.yaml

if [[ ${2-} == "--dryrun" ]]; then
  exit 0
fi

echo "Building snap with stack '$STACK_NAME'"
snapcraft -v pack || true
rm -f snapcraft.yaml
