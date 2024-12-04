#!/bin/bash -u

stack="$(snapctl get stack)"

if [ -z "$stack" ]; then
    echo "stack not set!"
    exit 1
fi

exec "$SNAP/stacks/$stack/chat"
