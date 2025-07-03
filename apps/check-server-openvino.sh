#!/bin/bash -eu

port="$(snapctl get http.port)"
model_name="$(snapctl get model-name)"
api_base_path="$(snapctl get http.base-path)"

# Check is server is started. - False negative when running in foreground. Will also not detect "failed".
#service_status="$(snapctl services | grep "deepseek-r1.server" | awk '{print $3}')"
#if [ "$service_status" == "active" ]; then
#  echo "Server is running"
#else
#  echo "Server is not started"
#  exit 1
#fi

# Check if port is open and we can connect over TCP
if (nc -z localhost $port 2>/dev/null); then
  echo "Server is listening"
else
  echo "Server is not listening"
  exit 1
fi

# http://localhost:8080/v1/config

# Starting up: {}

# [GPU] Can't get PERFORMANCE_HINT property as no supported devices found or an error happened during devices query.
# [GPU] Please check OpenVINO documentation for GPU drivers setup guide.
# {"DeepSeek-R1-Distill-Qwen-7B-ov-int4":{"model_version_status":[{"version":"1","state":"LOADING","status":{"error_code":"FAILED_PRECONDITION","error_message":"FAILED_PRECONDITION"}}]}}
api_config=$(wget http://localhost:8080/v1/config -O- 2>/dev/null)
if [[ "$api_config" == *"$model_name"* ]]; then
  echo "Expected model is being served"
else
  echo "Models not served. Still starting?"
  exit 1
fi

if [[ "$api_config" == *FAILED_PRECONDITION* ]]; then
  echo "Server startup failed. Check your drivers and restart"
  exit 1
fi

request=$(printf '{"model": "%s", "prompt": "Say this is a test", "temperature": 0, "max_tokens": 1}' "$model_name")
api_response=$(\
  wget http://localhost:8080/$api_base_path/completions \
  --post-data="$request" \
  --content-on-error \
  -O- \
  2>/dev/null\
)

# Still starting up api_response = "Mediapipe graph definition with requested name is not found"
if [ "${api_response}" == "Mediapipe graph definition with requested name is not found" ]; then
  echo "Server is not ready"
  exit 1
fi

if ! (echo "$api_response" | jq -ne 0 2>/dev/null > /dev/null); then
  echo "Server response is not json: $api_response"
fi

chat_text=$(echo "$api_response" | jq .choices[0].text)
if [ "$chat_text" == null ]; then
  echo "Invalid response: $api_response"
  exit 1
elif [ -z "${chat_text}" ]; then
  echo "No response from completions api"
  exit 1
else
  echo "Valid response from completions api"
fi

exec "$@"
