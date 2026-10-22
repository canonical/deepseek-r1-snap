#!/bin/bash

set -euo pipefail

engine="$(modelctl show-engine --format=json | jq -r .name)"
exec modelctl run --share-provider --fallback-server -- "$SNAP/engines/$engine/server" "$@"
