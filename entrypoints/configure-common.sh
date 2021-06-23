#!/bin/sh
set -e

ln -snf "/usr/share/zoneinfo/$TZ" /etc/localtime
echo "$TZ" > /etc/timezone

: "${LOG_OUTPUT:=sigh postfix}"
export LOG_OUTPUT
