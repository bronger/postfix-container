#!/bin/sh
set -e

echo "Container configuration: Setting TZ"
ln -snf "/usr/share/zoneinfo/$TZ" /etc/localtime
echo "$TZ" > /etc/timezone

: "${LOG_OUTPUT:=sigh postfix}"
export LOG_OUTPUT
