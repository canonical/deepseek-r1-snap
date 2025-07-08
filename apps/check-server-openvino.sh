#!/bin/bash -u

# exit code 0 = server is working correctly
# exit code 1 = server is still starting up - let's wait
# exit code 2 = server failed, do not wait

set +e

port="$(snapctl get http.port)"
model_name="$(snapctl get model-name)"
api_base_path="$(snapctl get http.base-path)"

# Checking if server is started with snapctl services produces false negative when running in foreground.
# Therefore rather check if ovms process is running.
if ! (pgrep -x "ovms" > /dev/null); then
    exit 2
fi


# Check if port is open and we can connect over TCP
if ! (nc -z localhost "$port" 2>/dev/null); then
  exit 1
fi

api_config=$(wget http://localhost:8080/v1/config --timeout=1 --tries=1 -O- 2>/dev/null)
# Starting up: {}
if [[ "$api_config" != *"$model_name"* ]]; then
  exit 1
fi
# Missing drivers:
# {"DeepSeek-R1-Distill-Qwen-7B-ov-int4":{"model_version_status":[{"version":"1","state":"LOADING","status":{"error_code":"FAILED_PRECONDITION","error_message":"FAILED_PRECONDITION"}}]}}
if [[ "$api_config" == *FAILED_PRECONDITION* ]]; then
  exit 2
fi

request=$(printf '{"model": "%s", "prompt": "Say this is a test", "temperature": 0, "max_tokens": 1}' "$model_name")
api_response=$(\
  wget http://localhost:8080/"$api_base_path"/completions \
  --timeout=1 \
  --tries=1 \
  --post-data="$request" \
  --content-on-error \
  -O- \
  2>/dev/null\
)

# Still starting up api_response
if [ "${api_response}" == "Mediapipe graph definition with requested name is not found" ]; then
  exit 1
fi

chat_text=$(echo "$api_response" | jq .choices[0].text)
if [ "$chat_text" == null ]; then
  # Response without chat text
  exit 2
elif [ -z "${chat_text}" ]; then
  # No response from completions api
  exit 2
fi

exit 0
