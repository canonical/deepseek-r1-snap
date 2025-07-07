#!/bin/bash -e

name=deepseek-r1

architecture=$(dpkg --print-architecture)

stack=$1
op=$2

if [[ "$op" == "clean" ]]; then
    sudo snap remove $name
fi

# Validate stack name
stack_file=./stacks/$stack/stack.yaml
if [[ ! -f "$stack_file" ]]; then
    echo "Unknown stack: $stack"
    exit 1
fi


if [[ "$(yq --version)" != *v4* ]]; then
    echo "Please install yq v4."
    exit 1
fi

# Validate stack syntax
yq stacks/$stack/stack.yaml > /dev/null

# Install the snap
sudo snap install --dangerous $name_*_$architecture.snap

# Connect interfaces
sudo snap connect $name:home
sudo snap connect $name:hardware-observe

# Set stack name
sudo snap set $name stack="$stack"

# Install stack components
cat "./stacks/$stack/stack.yaml" | yq .components[] | while read -r component; do
    sudo snap install --dangerous ./$name+"$component"_*.comp
done

