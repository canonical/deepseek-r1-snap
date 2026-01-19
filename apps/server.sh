#!/bin/bash -eu

# Save the status for content sharing
# This must be done each time the server is started to expose the actual status
mkdir -p "$STATUS_SHARE"
# Wait for component before querying status
modelctl run true --wait-for-components && \
    modelctl status --format=json > "$STATUS_SHARE/status.json"

engine="$(modelctl show-engine | yq .name)"
modelctl run "$SNAP/engines/$engine/server" --wait-for-components
