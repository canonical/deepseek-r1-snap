#!/bin/bash -ex

SNAP_NAME="deepseek-r1"

# sudo snap install mesa-2404
sudo snap disconnect $SNAP_NAME:opengl || true
sudo snap connect $SNAP_NAME:opengl
# sudo snap disconnect $SNAP_NAME:graphics || true
# sudo snap connect $SNAP_NAME:graphics mesa-2404:gpu-2404
