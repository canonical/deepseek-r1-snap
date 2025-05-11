#!/bin/bash -eu

$SNAP/bin/init.sh

stack="$(snapctl get stack)"

exec "$SNAP/stacks/$stack/chat" "$@"
