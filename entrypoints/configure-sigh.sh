#!/bin/sh
set -e

SCRIPT=$(realpath -e "$0")
SCRIPTPATH=$(dirname "$SCRIPT")

"$SCRIPTPATH"/configure_sigh.py "$SIGH_ROOT"

debug=false
for word in $LOG_OUTPUT
do
    if [ $word = sigh ]
    then
        debug=true
    fi
done
if [ $debug = true ]
then
    echo "Container configuration: Debugging output of Sigh is ON"
else    
    echo "Container configuration: Debugging output of Sigh is OFF"
    config_path=/etc/supervisor/supervisord.conf
    grep -q '^command = /usr/local/sbin/sigh$' "$config_path" && exit 1
    sed -i 's!^command = /usr/local/sbin/sigh --debug$!command = /usr/local/sbin/sigh!' "$config_path"
    grep -q '^command = /usr/local/sbin/sigh$' "$config_path" || exit 2
fi
