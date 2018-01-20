#!/bin/bash
set -e

# The propagating of SIGTERM was taken from
# <http://veithen.github.io/2014/11/16/sigterm-propagation.html>.
trap "kill -s TERM $supervisord_pid; ITS_A_TRAP=true" TERM

/configure_sigh.py "$SIGH_ROOT"
postconf -e "relayhost=$RELAY_HOST:$RELAY_PORT"
echo "$RELAY_HOST $RELAY_USER:$RELAY_PASSWORD" >> /etc/postfix/relay_passwd
postmap hash:/etc/postfix/relay_passwd

ITS_A_TRAP=false
supervisord -c /etc/supervisor/supervisord.conf &
supervisord_pid=$!
wait $supervisord_pid
result=$?
if [ "$ITS_A_TRAP" == "false" ]
then
   exit $result
fi
trap - TERM
wait $supervisord_pid
exit $?
