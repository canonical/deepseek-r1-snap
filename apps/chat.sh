#!/bin/bash

"$SNAP"/bin/init.sh

port="$(snapctl get http.port)"
model_name="$(snapctl get model-name)"

# Normally the OpenAI API is hosted under http://server:port/v1. In some cases like with OpenVINO it is under http://server:port/v3
api_base_path="$(snapctl get api-base-path)"
if [ -z "$base_url" ]; then
  api_base_path="v1"
fi

OPENAI_BASE_URL="http://localhost:$port/$api_base_path" MODEL_NAME="$model_name" REASONING_MODEL=True "$SNAP"/bin/go-chat-client
status=$?
if [ $status -ne 0 ]; then
  echo "Exit code: $status"
  echo ""
  echo "Unable to chat. Make sure the server is started successfully."
fi

exit $status
