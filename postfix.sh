#!/bin/sh
# Taken from <https://gist.github.com/chrisnew/b0c1b8d310fc5ceaeac4>.

trap "postfix stop" SIGTERM
trap "postfix reload" SIGHUP

postfix start
sleep 3

PID=`cat /var/spool/postfix/pid/master.pid`
while kill -0 $PID
do
    sleep 1
done
