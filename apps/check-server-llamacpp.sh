#!/bin/bash -u

# exit code 0 = server is working correctly
# exit code 1 = server is still starting up - let's wait
# exit code 2 = server failed, do not wait

set +e

port="$(snapctl get http.port)"
model_name="$(snapctl get model-name)"
api_base_path="$(snapctl get http.base-path)"

# Check if server is started. - False negative when running in foreground. Will also not detect "failed".
#service_status="$(snapctl services | grep "deepseek-r1.server" | awk '{print $3}')"
#if [ "$service_status" == "active" ]; then
#  echo "Server is running"
#else
#  echo "Server is not started"
#  exit 1
#fi

# Check if port is open and we can connect over TCP
if ! (nc -z localhost $port 2>/dev/null); then
#  echo "Server is not listening"
  exit 2
fi

#served_model=$(wget http://localhost:8080/$api_base_path/models -O- 2>/dev/null | jq .data[0].id)
#if [[ "$served_model" == *"$model_name"* ]]; then
#  echo "Expected model is being served"
#else
#  echo "Models endpoint not returning expected model"
#  exit 1
#fi

request=$(printf '{"model": "%s", "prompt": "Say this is a test", "temperature": 0, "max_tokens": 1}' "$model_name")
api_response=$(\
  wget http://localhost:8080/$api_base_path/completions \
   --timeout=1 \
  --post-data="$request" \
  --content-on-error \
  -O- \
  2>/dev/null\
)

# Still starting up api_response = {"error":{"code":503,"message":"Loading model","type":"unavailable_error"}}
error_text=$(echo "$api_response" | jq .error.message)
if [ "${error_text}" != "null" ]; then
#  echo "Server is not ready: $error_text"
  exit 1
fi

chat_text=$(echo "$api_response" | jq .choices[0].text)
if [ -z "${chat_text}" ]; then
#  echo "No response from completions api"
  exit 2
fi

exit 0
