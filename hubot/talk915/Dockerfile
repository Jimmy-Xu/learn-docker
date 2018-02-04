FROM node:latest
MAINTAINER Jimmy Xu <xjimmyshcn@gmail.com>

RUN useradd hubot -m
ENV WORK_DIR=/home/hubot

###################################################
# Install dependency package                      #
###################################################
RUN npm install -g hubot coffee-script yo generator-hubot

ENV DEBIAN_FRONTEND noninteractive

# common package, shadowsocks and privoxy
RUN apt-get update &&\
    apt-get install -y vim screen net-tools&&\
    apt-get clean && rm -fr /var/lib/apt/lists/* /tmp/* /var/tmp/*

#######################
#  install gntp-send  #
#######################
RUN cd /opt/ &&\
    git clone https://github.com/mattn/gntp-send.git &&\
    cd gntp-send &&\
    ./autogen.sh &&\
    ./configure &&\
    make &&\
    ./gntp-send || echo -n &&\
    cp .libs/lt-gntp-send /usr/local/bin/gntp-send -rf

##############################################################
# ENV for hubot,gntp-send
##############################################################
## hubot
ENV HUBOT_NAME=${HUBOT_NAME:-myhubot}
ENV HUBOT_OWNER=${HUBOT_OWNER:-none}
ENV HUBOT_DESCRIPTION=${HUBOT_DESCRIPTION:-Hubot}

ENV HUBOT_PORT=
ENV HUBOT_EXT_CMD_BIN=
ENV HUBOT_EXT_CMD_ARG=
ENV HUBOT_EXT_CMD_OPT=
ENV HUBOT_CHECK_INTERVAL=
ENV HUBOT_GNTP_SERVER=
ENV HUBOT_GNTP_PASSWORD=
ENV HUBOT_EMAIL_USERNAME=
ENV HUBOT_EMAIL_PASSWORD=
ENV HUBOT_EMAIL_TO=

#######################
# change user and dir
#######################
USER hubot
WORKDIR ${WORK_DIR}


######################################################
RUN yo hubot --owner="${HUBOT_OWNER}" --name="${HUBOT_NAME}" --description="${HUBOT_DESCRIPTION}" --defaults &&\
    sed -i /heroku/d ./external-scripts.json &&\
		sed -i /redis-brain/d ./external-scripts.json &&\
		npm install hubot-scripts hubot-script-shellcmd &&\
		cp -R ./node_modules/hubot-script-shellcmd/bash . &&\
		npm install hubot-help node-growl nodemailer --save

ENV EXTERNAL_SCRIPTS "hubot-help"
CMD node -e "console.log(JSON.stringify('$EXTERNAL_SCRIPTS'.split(',')))" > external-scripts.json && \
	npm install $(node -e "console.log('$EXTERNAL_SCRIPTS'.split(',').join(' '))") && \
	bin/hubot -n $HUBOT_NAME


######################################################
ENTRYPOINT ["entrypoint.sh"]
VOLUME ["$WORK_DIR/scripts"]

######################################################
# add customized script
######################################################
COPY util /usr/bin
COPY scripts $WORK_DIR/scripts
USER hubot
