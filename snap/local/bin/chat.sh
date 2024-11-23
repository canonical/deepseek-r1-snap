#!/bin/bash -u

STACK="$(snapctl get stack)"

exec "$SNAP/stacks/$STACK/chat"
