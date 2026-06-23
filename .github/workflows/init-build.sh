#!/bin/bash -ex

# Remove LFS object copies to reduce disk usage
git lfs prune --force
