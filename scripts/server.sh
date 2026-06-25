#!/bin/bash

set -euo pipefail

# Export the configuration for content sharing
# This must be done each time the server is started to expose the actual configuration
$SNAP/bin/export-shared-configs.sh

engine="$(modelctl show-engine --format=json | jq -r .name)"
exec modelctl run -- "$SNAP/engines/$engine/server" "$@"
