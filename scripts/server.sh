#!/bin/bash

set -euo pipefail

modelctl diagnose --serve-fallback=openai

engine="$(modelctl engine --format=json | jq -er .name)"
exec modelctl run --share-provider -- "$SNAP/engines/$engine/server" "$@"
