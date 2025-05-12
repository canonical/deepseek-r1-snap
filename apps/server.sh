#!/bin/bash -u

$SNAP/bin/init.sh

stack="$(snapctl get stack)"

exec "$SNAP/stacks/$stack/server" "$@"
