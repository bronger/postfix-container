#!/bin/sh
set -e

postconf -e "relayhost=$RELAY_HOST:$RELAY_PORT"
echo "$RELAY_HOST $RELAY_USER:$RELAY_PASSWORD" >> /etc/postfix/relay_passwd
postmap hash:/etc/postfix/relay_passwd

for word in $LOG_OUTPUT
do
    if [ $word = postfix ]
    then
        postconf -e "maillog_file=/dev/stdout"
    fi
done
