#!/bin/sh
# Inspired from <https://gist.github.com/chrisnew/b0c1b8d310fc5ceaeac4>.

trap "kill -s TERM $PID; result=0" TERM
trap "postfix reload" HUP

/usr/sbin/rsyslogd
sleep 3

PID=`cat /var/run/rsyslogd.pid`
result=1
while kill -0 $PID
do
    sleep 1
done
exit $result
