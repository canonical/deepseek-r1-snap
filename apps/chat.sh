#!/bin/bash -eu

"$SNAP"/bin/wait-for-server.sh

port="$($SNAP_NAME get http.port)"
model_name="$($SNAP_NAME get model-name)"

# Normally the OpenAI API is hosted under http://server:port/v1. In some cases like with OpenVINO Model Server it is under http://server:port/v3
api_base_path="$($SNAP_NAME get http.base-path)"
if [ -z "$api_base_path" ]; then
  api_base_path="v1"
fi

export OPENAI_BASE_URL="http://localhost:$port/$api_base_path"
export MODEL_NAME="$model_name"
export REASONING_MODEL=true

"$SNAP"/bin/go-chat-client
