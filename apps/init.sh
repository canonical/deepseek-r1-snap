#!/bin/bash -eu

stack="$(snapctl get stack)"
if [ -z "$stack" ]; then
    # This happens only if install/configure hook were unable to auto select, due to hardware-observe not being connected.
    # In this case, the user is expected to manually connect the interface right after installation.

    echo "Stack not set. Will auto select a stack ..."

    if snapctl is-connected hardware-observe; then
        # These need root privileges to run
        stack select --auto
        stack download
    else
        echo "Unable to auto select a stack: hardware-observe interface not connected."
        echo "Please connect and try again: sudo snap connect $SNAP_INSTANCE_NAME:hardware-observe"
        exit 1
    fi
fi

model="$SNAP_COMPONENTS/$(snapctl get model)"
engine="$SNAP_COMPONENTS/$(snapctl get engine)"

# Download and install missing stack components, useful if stack is changed manually.
if [[ ! -d "$engine" || ! -d "$model" ]]; then
    # TODO: check if download happened successfully, not skipped. Also above.
    # Otherwise,
    # 1) the model init command fails. 
    # 2) in confined mode & local install, the download request happens a second time here.
    stack download
fi

exec "$model/init"
