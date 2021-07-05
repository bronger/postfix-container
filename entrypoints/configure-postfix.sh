#!/bin/sh
set -e

echo "Container configuration: Setting relay host and port in Postfix configuration"
postconf -e "relayhost=$RELAY_HOST:$RELAY_PORT"
echo "Container configuration: Setting relay password in Postfix configuration"
echo "$RELAY_HOST $RELAY_USER:$RELAY_PASSWORD" >> /etc/postfix/relay_passwd
postmap hash:/etc/postfix/relay_passwd

debug=false
for word in $LOG_OUTPUT
do
    if [ $word = postfix ]
    then
        debug=true
    fi
done
if [ $debug = true ]
then
    echo "Container configuration: Logging of Postfix is ON"
    postconf -e "maillog_file=/dev/stdout"
else    
    echo "Container configuration: Logging of Postfix is OFF"
fi
