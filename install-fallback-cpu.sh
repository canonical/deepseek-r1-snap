#!/bin/bash -e

if [[ "$1" == "clean" ]]; then
    sudo snap remove mistral-7b-instruct
fi

name=mistral-7b-instruct

# install the snap
sudo snap install --dangerous $name_*.snap

# install the snap components
sudo snap install --dangerous $name+llamacpp*.comp
sudo snap install --dangerous $name+model*gguf*.comp

sudo snap set $name stack=fallback-cpu
