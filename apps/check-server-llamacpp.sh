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
  api_base_path="v1"
fi

# Checking if server is started with snapctl services produces false negative when running in foreground.
# Therefore rather check if llama-server process is running.
if ! (pgrep -x "llama-server" > /dev/null); then
  debug_echo "llama-server process is not running"
  exit 2
fi

# Check if port is open and we can connect over TCP
if ! (nc -z localhost "$port" 2>/dev/null); then
  debug_echo "llama-server is not listening on the configured port"
  exit 1
fi

# Not checking model, as completions API has better status reporting
#served_model=$(wget http://localhost:8080/$api_base_path/models -O- 2>/dev/null | jq .data[0].id)
#if [[ "$served_model" != *"$model_name"* ]]; then
#  exit 1
#fi

request=$(printf '{"model": "%s", "prompt": "Say this is a test", "temperature": 0, "max_tokens": 1}' "$model_name")
api_response=$(\
  wget http://localhost:8080/"$api_base_path"/completions \
  --timeout=30 \
  --tries=1 \
  --post-data="$request" \
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

# Check if response is an error
has_error=$(echo "$api_response" | jq 'has("error")')
if $has_error; then
  error_message=$(echo "$api_response" | jq .error.message)
  if [[ "$error_message" == "\"Loading model\"" ]]; then
    # Still starting up api_response = {"error":{"code":503,"message":"Loading model","type":"unavailable_error"}}
    debug_echo "Loading model"
    exit 1
  else
    echo "Server error: $error_message"
    exit 2
  fi
fi

chat_text=$(echo "$api_response" | jq .choices[0].text)
if [ -z "$chat_text" ]; then
  debug_echo "Empty chat response"
  exit 2
fi

debug_echo "Valid response: $chat_text"
exit 0
