#!/bin/bash -e

name=deepseek-r1

architecture=$(dpkg --print-architecture)

stack=$1
op=$2

# check if stack is provided
if [[ -z "$stack" ]]; then
    echo "Error: Stack name is required."
    echo "Usage: $0 <stack> [clean]"
    exit 1
fi

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
# The service will first fail to start because the stack is not selected yet
sudo snap install --dangerous $name_*_$architecture.snap

# Connect interfaces
sudo snap connect $name:home
sudo snap connect $name:hardware-observe

# Install stack components
cat "./stacks/$stack/stack.yaml" | yq .components[] | while read -r component; do
    sudo snap install --dangerous ./$name+"$component"_*.comp
done

# Select a stack
sudo $name use "$stack" --assume-yes
