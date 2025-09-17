#!/bin/bash -eu

$SNAP/bin/wait-for-server.sh

port="$(snapctl get http.port)"
host="$(snapctl get http.host)"
model_name="$(snapctl get model-name)"

# Normally the OpenAI API is hosted under http://server:port/v1. In some cases like with OpenVINO Model Server it is under http://server:port/v3
api_base_path="$(snapctl get http.base-path)"
if [ -z "$api_base_path" ]; then
  api_base_path="v1"
fi

export OPENAI_BASE_URL="http://"$host":$port/$api_base_path"
export MODEL_NAME="$model_name"
export REASONING_MODEL=true

$SNAP/bin/go-chat-client
