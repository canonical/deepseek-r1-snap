#!/bin/bash -u

stack="$(snapctl get stack)"

exec "$SNAP/stacks/$stack/server" "$@"
