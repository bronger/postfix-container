#!/bin/sh
set -e

ln -snf "/usr/share/zoneinfo/$TZ" /etc/localtime
echo "$TZ" > /etc/timezone

/configure_sigh.py "$SIGH_ROOT"
postconf -e "relayhost=$RELAY_HOST:$RELAY_PORT"
echo "$RELAY_HOST $RELAY_USER:$RELAY_PASSWORD" >> /etc/postfix/relay_passwd
postmap hash:/etc/postfix/relay_passwd

exec postfix start-fg
