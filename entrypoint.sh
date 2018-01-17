#!/bin/bash
set -e

su -c '/configure_sigh.py "$SIGH_ROOT"' filter
postconf -e "relayhost=$HOST:$PORT"
echo "$HOST $USER:$PASSWORD" >> /etc/postfix/relay_passwd
postmap hash:/etc/postfix/relay_passwd
/usr/sbin/rsyslogd
service postfix start
supervisord -c /etc/supervisor/supervisord.conf
