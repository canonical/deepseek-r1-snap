#!/bin/bash -u

STACK="$(snapctl get stack)"

if [ -z "$STACK" ]; then
    echo "Stack not set!"
    exit 1
fi

exec "$SNAP/stacks/$STACK/chat"
