#!/bin/bash

TMP_FILE="/tmp/test-llm-chat"
# SNAP_NAME="deepseek-r1"

echo "Starting chat"
($SNAP_NAME.chat -v >$TMP_FILE 2>&1) &
DSID=$!
# Wait for chat to load
sleep 5
# echo "Checking process $DSID"
ps -p $DSID > /dev/null
CHAT_EXIT_CODE=$?
# echo "ps exit code: $CHAT_EXIT_CODE"
if [ $CHAT_EXIT_CODE -eq 0 ]; then
	# Succeeded
	echo "Closing chat"
	kill $DSID || true
	rm $TMP_FILE
else
	# Failed
	echo "Chat failed"
	echo "-- Log start --"
	cat $TMP_FILE
	echo "-- Log end --"
	rm $TMP_FILE
	exit $CHAT_EXIT_CODE
fi

# Start the server
echo "Starting server"
sudo snap start $SNAP_NAME.server
# Wait for server to properly start before querying it
sleep 2

# Do two requests to the api to check that it works
echo "Sending request to API"
RESPONSE=$(curl --silent http://localhost:8080/v1/chat/completions -H "Content-Type: application/json" -d '{"messages": [{"content": "Hi", "role": "user"}]}')
API_RESULT=$?
if [ $API_RESULT -eq 0 ]; then
	# Succeeded
	TPS=$(echo $RESPONSE | jq '.timings.predicted_per_second')
	echo "API worked. $TPS tokens per second."
	if [ $TPS -eq "null" ]; then
		echo $RESPONSE
	fi
else
	# Failed
	echo "API failed"
	echo $RESPONSE
	exit 1
fi

echo "Sending another request to API"
RESPONSE=$(curl --silent http://localhost:8080/v1/chat/completions -H "Content-Type: application/json" -d '{"messages": [{"content": "Who was Alice in Wonderland?", "role": "user"}]}')
API_RESULT=$?
if [ $API_RESULT -eq 0 ]; then
	# Succeeded
	TPS=$(echo $RESPONSE | jq '.timings.predicted_per_second')
	echo "API worked. $TPS tokens per second."
	if [ $TPS -eq "null" ]; then
		echo $RESPONSE
	fi
else
	# Failed
	echo "API failed"
	echo $RESPONSE
	exit 1
fi

echo "Stopping server"
sudo snap stop $SNAP_NAME.server