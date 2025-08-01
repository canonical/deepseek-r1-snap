#!/bin/bash -u

# This script waits for the server to start before running the commands in the arguments.
# The script is expected to be used in the command chain of the chat app.

stack="$(snapctl get stack)"

TIMEOUT=60
WAIT_PRINTED=false

newline_after_wait() {
  if $WAIT_PRINTED; then
    echo ""
  fi
}

start_time="$(date -u +%s)"
while true; do
  current_time="$(date -u +%s)"
  elapsed_seconds=$((current_time-start_time))
  if [ $elapsed_seconds -gt $TIMEOUT ]; then
    if $WAIT_PRINTED; then
      echo ""
    fi
    echo "Timed out waiting for server to start. Check the server logs and try again."
    exit 1
  fi

  "$SNAP/stacks/$stack/check-server"
  exit_code=$?

  case $exit_code in
    0)
      # server is running
      newline_after_wait
      break
      ;;
    1)
      # server is still starting up, so retry after a short delay
      if ! $WAIT_PRINTED; then
        WAIT_PRINTED=true
        echo -n "Waiting for server ..."
      fi
      echo -n "."
      ;;
    2)
      newline_after_wait
      echo "Server is not running or failed. Please check the logs."
      exit 1
      ;;
    *)
      newline_after_wait
      echo "Unexpected exit code when waiting for server: $exit_code"
      exit $exit_code
      ;;
  esac

  sleep 0.5

done

