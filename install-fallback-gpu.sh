#!/bin/bash -e

if [[ "$1" == "clean" ]]; then
    sudo snap remove mistral-7b-instruct
fi

name=mistral-7b-instruct

# install the snap
sudo snap install --dangerous --devmode $name_*.snap

# install the snap components
sudo snap install --dangerous $name+mistral-inference_*.comp
sudo snap install --dangerous $name+model_*.comp

# connect the graphics interface
sudo snap connect mistral-7b-instruct:graphics mesa-2404:gpu-2404

if [[ "$1" == "re-connect" ]]; then
    # TODO: look into this bug
    sudo snap disconnect mistral-7b-instruct:graphics
    sudo snap connect mistral-7b-instruct:graphics mesa-2404:gpu-2404
fi

sudo snap set $name stack=mistral-gpu
