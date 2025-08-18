#!/bin/bash -eux

export SNAP_NAME="deepseek-r1"
export SNAP_CHANNEL="latest/edge"

# Values from matrix
#export JOB_QUEUE="dell-xps-13-7390"
#export EXPECTED_STACK="cpu"
#export EXPECTED_TPS=1.5

## Ampere Altra
#export JOB_QUEUE="202212-30936"
#export EXPECTED_STACK="ampere-altra"
#export EXPECTED_TPS=15

## Ampere Altra Max
#export JOB_QUEUE="202303-31419"
#export EXPECTED_STACK="ampere-altra"
#export EXPECTED_TPS=15

# Ampere One - puniper
export JOB_QUEUE="202501-36266"
export EXPECTED_STACK="ampere-one"
export EXPECTED_TPS=8

envsubst < testflinger.yaml > testflinger.temp.yaml

testflinger submit --poll testflinger.temp.yaml
