#!/bin/bash -x

# This should eventually become directly available via a SNAP env var
SNAP_COMPONENTS="/snap/$SNAP_INSTANCE_NAME/components/$SNAP_REVISION" 

MODEL_DIR="$SNAP_COMPONENTS/model-$MODEL"

export PYTHONPATH="$SNAP_COMPONENTS/$ENGINE_PYTHONPATH"
exec "$SNAP_COMPONENTS/$ENGINE_CHAT" "$MODEL_DIR"