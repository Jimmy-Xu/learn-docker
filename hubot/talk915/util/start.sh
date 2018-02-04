#!/usr/bin/env bash

function show_usage() {
    cat <<EOF
usage: ./start.sh <OPTION>

OPTION:
    init          # install external scripts
    talk915       # start with talk915
EOF
    exit
}

function show_env() {
    echo "--------------------------------"
    netstat -tnopl
    echo "--------------------------------"

cat <<EOF
###########################################
talk915:
HUBOT_PORT           :$HUBOT_PORT
HUBOT_EXT_CMD_BIN    :$HUBOT_EXT_CMD_BIN
HUBOT_EXT_CMD_ARG    :$HUBOT_EXT_CMD_ARG
HUBOT_EXT_CMD_OPT    :$HUBOT_EXT_CMD_OPT
HUBOT_CHECK_INTERVAL :$HUBOT_CHECK_INTERVAL
HUBOT_GNTP_SERVER    :$HUBOT_GNTP_SERVER
HUBOT_GNTP_PASSWORD  :$HUBOT_GNTP_PASSWORD
HUBOT_EMAIL_USERNAME :$HUBOT_EMAIL_USERNAME
HUBOT_EMAIL_PASSWORD :$HUBOT_EMAIL_PASSWORD
HUBOT_EMAIL_TO       :$HUBOT_EMAIL_TO
###########################################
EOF
}

case $1 in
    init)
        echo "install external scripts"
        node -e "console.log(JSON.stringify('$EXTERNAL_SCRIPTS'.split(',')))" > external-scripts.json && npm install $(node -e "console.log('$EXTERNAL_SCRIPTS'.split(',').join(' '))")
        ;;
    talk915)
        show_env
        PORT=$HUBOT_PORT bin/hubot -n $HUBOT_NAME
        ;;
    *)
        show_usage
        ;;
esac
