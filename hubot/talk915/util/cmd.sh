#!/bin/bash

echo "install external scripts"
node -e "console.log(JSON.stringify('$EXTERNAL_SCRIPTS'.split(',')))" > external-scripts.json && npm install $(node -e "console.log('$EXTERNAL_SCRIPTS'.split(',').join(' '))")

echo "start screen to run"
screen -S talk915 -L -d -m bash -c "start.sh talk915"

echo "wait 5 second"
sleep 5

echo "tail -f screenlog.0"
tail -f screenlog.0
