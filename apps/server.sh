#!/bin/bash -eu

check_missing_components() {
    local -n missing=$1 # nameref for output array
    local required="$2"

    missing=()
    for component in $required; do
        if [ ! -d "$SNAP_COMPONENTS/$component" ]; then
            missing+=("$component")
        fi
    done
}

wait_for_components() {
    local required_components
    
    required_components="$(deepseek-r1 show-engine | yq .components[])"

    missing_components=()
    check_missing_components missing_components "$required_components"

    max=3600 # seconds
    interval=10
    elapsed=0
    while [ ${#missing_components[@]} -ne 0 ] && [ "$elapsed" -lt $max ]; do
        ((elapsed+=interval))
        echo "Waiting for required snap components: [${missing_components[*]}] ($elapsed/${max}s)"
        sleep "$interval"
        
        check_missing_components missing_components "$required_components"
    done

    if [ ${#missing_components[@]} -ne 0 ]; then
        echo "Error: timed out after ${elapsed}s while waiting for required components: [${missing_components[*]}]"
        echo "Please use \"snap changes\" to monitor the progress and start the service once all components are installed."
        
        # Stop service to avoid indefinite retries by systemd, until the next reboot
        snapctl stop deepseek-r1
        
        exit 1
    fi
}

wait_for_components

engine="$(deepseek-r1 show-engine | yq .name)"
exec "$SNAP/engines/$engine/server" "$@"
