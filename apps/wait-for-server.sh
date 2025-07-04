#!/bin/bash -u

TIMEOUT=60

start_time="$(date -u +%s)"
while true; do
  current_time="$(date -u +%s)"
  elapsed_seconds=$((current_time-start_time))
  if [ $elapsed_seconds -gt $TIMEOUT ]; then
    echo "Timed out waiting for server to start. Check the server logs and try again."
    exit 1
  fi

  "$SNAP"/bin/check-server.sh
  result=$?

  if [ $result == 0 ]; then
    # server is running
    break
  fi

  if [ $result == 2 ]; then
    echo "Server is not running or failed. Please check the logs."
    exit 1
  fi

  # else the result is 1, which means the server is still starting up, so retry after a short delay
  sleep 0.5

done

# start the chat client
exec "$@"
