#!/bin/bash
set -e

/configure_sigh.py "$SIGH_ROOT"
postconf -e "relayhost=$HOST:$PORT"
echo "$HOST $USER:$PASSWORD" >> /etc/postfix/relay_passwd
postmap hash:/etc/postfix/relay_passwd
/usr/sbin/rsyslogd
service postfix start
supervisord -c /etc/supervisor/supervisord.conf
