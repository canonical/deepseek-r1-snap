#!/bin/bash -u

# Read stack config
MODEL="$(snapctl get model)"
ENGINE="$(snapctl get internal.engine)"
ENGINE_CHAT="$(snapctl get internal.engine-chat)"
ENGINE_PYTHON_PACKAGES="$(snapctl get internal.engine-python-packages)"

MODEL_DIR="$SNAP_COMPONENTS/model-$MODEL"

export PYTHONPATH="$SNAP_COMPONENTS/$ENGINE/$ENGINE_PYTHON_PACKAGES"
exec "$SNAP_COMPONENTS/$ENGINE/$ENGINE_CHAT" "$MODEL_DIR"