#!/bin/bash -u

# exit code 0 = server is working correctly
# exit code 1 = server is still starting up - let's wait
# exit code 2 = server failed, do not wait

function debug_echo {
    if [ -n "${DEBUG+x}" ]; then
        echo "$*"
    fi
}

set +e

port="$(snapctl get http.port)"
model_name="$(snapctl get model-name)"
api_base_path="$(snapctl get http.base-path)"
if [ -z "$api_base_path" ]; then
  api_base_path="v3"
fi

# Checking if server is started with snapctl services produces false negative when running in foreground.
# Therefore rather check if ovms process is running.
if ! (pgrep -x "ovms" > /dev/null); then
    debug_echo "ovms process is not running"
    exit 2
fi


# Check if port is open and we can connect over TCP
if ! (nc -z localhost "$port" 2>/dev/null); then
  debug_echo "ovms is not listening on the configured port"
  exit 1
fi

api_config=$(wget http://localhost:"$port"/v1/config --header "Content-Type: application/json" --timeout=10 --tries=1 -O- 2>/dev/null)
# Starting up: {}
empty_json=$(echo "$api_config" | jq '. == {}')
if $empty_json; then
  debug_echo "Empty json from config endpoint - still starting up"
  exit 1
fi
# Missing drivers:
# {"DeepSeek-R1-Distill-Qwen-7B-ov-int4":{"model_version_status":[{"version":"1","state":"LOADING","status":{"error_code":"FAILED_PRECONDITION","error_message":"FAILED_PRECONDITION"}}]}}
if [[ "$api_config" == *FAILED_PRECONDITION* ]]; then
  debug_echo "Serving model failed"
  exit 2
fi

system_message="You are a helpful assistant."
prompt="Hello!"
post_json=$(printf '{"model":"%s","messages":[{"role":"developer","content":"%s"},{"role":"user","content":"%s"}],"temperature":0,"max_tokens":1}' "$model_name" "$system_message" "$prompt")
api_response=$(\
  wget http://localhost:"$port"/"$api_base_path"/chat/completions \
  --header "Content-Type: application/json" \
  --timeout=30 \
  --tries=1 \
  --post-data="$post_json" \
  --content-on-error \
  -O- \
  2>/dev/null\
)

# No response from server means either it's very slow, or server is in an error state.
# With a large timeout specified for the wget call, an empty response indicates an issue.
if [ -z "$api_response" ]; then
  debug_echo "Empty response from server"
  exit 2
fi

# Anything wrong with the request returns a mediapipe not found error
# Old versions of OVMS returned this as raw text, while new ones put it in a json error
if [[ "${api_response}" == *"Mediapipe graph definition with requested name is not found"* ]]; then
  debug_echo "Request error"
  exit 2
fi

# Check if response is an error
has_error=$(echo "$api_response" | jq 'has("error")')
if $has_error; then
  error_message=$(echo "$api_response" | jq .error)
  echo "Server error: $error_message"
  exit 2
fi

chat_text=$(echo "$api_response" | jq .choices[0].message.content)
if [ "$chat_text" == null ]; then
  # Chat response content key not found in JSON object
  debug_echo "Unexpected response: $api_response"
  exit 2
elif [ -z "${chat_text}" ]; then
  # Chat response content is empty
  debug_echo "Empty chat response"
  exit 2
fi

debug_echo "Valid response: $chat_text"
exit 0
