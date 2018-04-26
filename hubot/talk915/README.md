# talk915-monitor

> build source from https://bitbucket.org/Jimmy-Xu/talk915


# ENV

```
export HUBOT_EXT_CMD_BIN="/usr/bin/talk915-monitor"
export HUBOT_EXT_CMD_ARG="--username xxxxx --password=xxxxx --period=0 --quiet"
export HUBOT_EXT_CMD_OPT="--teacher=Shen,Hanna"                                            
export HUBOT_CHECK_INTERVAL="4"
export HUBOT_EMAIL_USERNAME="xjimmyshcn@sina.com"
export HUBOT_EMAIL_PASSWORD='xxxxxx'
export HUBOT_EMAIL_TO="xxxxxx"
```

# run with docker

```
docker run -it --name talk915 --rm \
-e HUBOT_NAME="hubot" \
-e EXTERNAL_SCRIPTS="hubot-help" \
-e HUBOT_EXT_CMD_BIN=$HUBOT_EXT_CMD_BIN \
-e HUBOT_EXT_CMD_ARG=$HUBOT_EXT_CMD_ARG \
-e HUBOT_EXT_CMD_OPT=$HUBOT_EXT_CMD_OPT \
-e HUBOT_CHECK_INTERVAL=$HUBOT_CHECK_INTERVAL \
-e HUBOT_GNTP_SERVER=$HUBOT_GNTP_SERVER \
-e HUBOT_GNTP_PASSWORD=$HUBOT_GNTP_PASSWORD \
-e HUBOT_EMAIL_USERNAME=$HUBOT_EMAIL_USERNAME \
-e HUBOT_EMAIL_PASSWORD=$HUBOT_EMAIL_PASSWORD \
-e HUBOT_EMAIL_TO=$HUBOT_EMAIL_TO \
xjimmyshcn/talk915
```

# run with hyper

## debug
```
hyper run -d --name talk915 \
--restart=always --protection=true \
-e HUBOT_NAME="hubot" \
-e EXTERNAL_SCRIPTS="hubot-help" \
-e HUBOT_EXT_CMD_BIN=$HUBOT_EXT_CMD_BIN \
-e HUBOT_EXT_CMD_ARG=$HUBOT_EXT_CMD_ARG \
-e HUBOT_EXT_CMD_OPT=$HUBOT_EXT_CMD_OPT \
-e HUBOT_CHECK_INTERVAL=$HUBOT_CHECK_INTERVAL \
-e HUBOT_GNTP_SERVER=$HUBOT_GNTP_SERVER \
-e HUBOT_GNTP_PASSWORD=$HUBOT_GNTP_PASSWORD \
-e HUBOT_EMAIL_USERNAME=$HUBOT_EMAIL_USERNAME \
-e HUBOT_EMAIL_PASSWORD=$HUBOT_EMAIL_PASSWORD \
-e HUBOT_EMAIL_TO=$HUBOT_EMAIL_TO \
xjimmyshcn/talk915 sleep infinity

hyper exec -it talk915 bash
screen -S talk915 -L -d -m bash -c "start.sh talk915"
tail -f screenlog.0
```

## release

```
hyper run -d --name talk915 \
--restart=always --protection=true \
-e HUBOT_NAME="hubot" \
-e EXTERNAL_SCRIPTS="hubot-help" \
-e HUBOT_EXT_CMD_BIN=$HUBOT_EXT_CMD_BIN \
-e HUBOT_EXT_CMD_ARG=$HUBOT_EXT_CMD_ARG \
-e HUBOT_EXT_CMD_OPT=$HUBOT_EXT_CMD_OPT \
-e HUBOT_CHECK_INTERVAL=$HUBOT_CHECK_INTERVAL \
-e HUBOT_EMAIL_USERNAME=$HUBOT_EMAIL_USERNAME \
-e HUBOT_EMAIL_PASSWORD=$HUBOT_EMAIL_PASSWORD \
-e HUBOT_EMAIL_TO=$HUBOT_EMAIL_TO \
xjimmyshcn/talk915
```
