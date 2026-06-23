#!/bin/bash -eu

status_json=$(modelctl status --format=json --wait-for-components)

# Simple dump of status command in json
mkdir -p "$STATUS_SHARE"
echo "$status_json" > "$STATUS_SHARE/status.json"

# OpenAI endpoint configuration in Open WebUI content sharing format
rm -f "$OWUI_SHARE/openai.json"
openai_url=$(echo "$status_json" | jq -r '.endpoints.openai // empty')
if [ -n "$openai_url" ]; then
  mkdir -p "$OWUI_SHARE"
  jq -n \
    --arg base_url "$openai_url" \
    '{
      "base_url": $base_url
    }' > "$OWUI_SHARE/openai.json"
fi
