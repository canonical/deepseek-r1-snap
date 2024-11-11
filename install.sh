#!/bin/bash -e

if [[ "$1" == "clean" ]]; then
    sudo snap remove mistral-7b-instruct
fi

name=mistral-7b-instruct

sudo snap install --dangerous --devmode $name_*.snap
sudo snap install --dangerous $name+mistral-inference_*.comp
sudo snap install --dangerous $name+model-mistral-7b-instruct_*.comp