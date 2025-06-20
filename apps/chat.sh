#!/bin/bash -eu

port="$(snapctl get http.port)"
model_name="$(snapctl get model-name)"

# Normally the OpenAI API is hosted under http://server:port/v1. In some cases like with OpenVINO Model Server it is under http://server:port/v3
api_base_path="$(snapctl get api-base-path)"
if [ -z "$api_base_path" ]; then
  api_base_path="v1"
fi

set -e

OPENAI_BASE_URL="http://localhost:$port/$api_base_path" MODEL_NAME="$model_name" REASONING_MODEL=true "$SNAP"/bin/go-chat-client
status=$?

set +e

if [ $status -ne 0 ]; then
  echo "Exit code: $status"
  echo ""
  echo "Unable to chat. Make sure the server is started successfully."
fi

exit $status
