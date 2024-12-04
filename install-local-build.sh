#!/bin/bash -e

name=mistral-7b-instruct

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

# Validate stack syntax (and make sure yq is installed)
yq stacks/$stack/stack.yaml > /dev/null

# Install the snap
sudo snap install --dangerous --devmode $name_*.snap

# Set stack name
sudo snap set $name stack="$stack"

# Install stack components
cat "./stacks/$stack/stack.yaml" | yq .components[] | while read -r component; do
    snap install --dangerous ./$name+"$component"_*.comp
done

if [[ "$stack" == "mistral-gpu" ]]; then
    # Connect the graphics interface
    sudo snap connect $name:graphics mesa-2404:gpu-2404
fi

# See https://github.com/canonical/mistral-7b-instruct-snap/issues/3
if [[ "$op" == "reconnect-graphics" ]]; then
    sudo snap disconnect $name:graphics
    sudo snap connect $name:graphics mesa-2404:gpu-2404
fi
