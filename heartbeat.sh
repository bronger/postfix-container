#!/bin/sh

while ps cax | grep master > /dev/null
do
    sleep 5
done

kill -9 `cat /var/run/supervisord.pid`
