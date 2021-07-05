#!/bin/sh
set -e

SCRIPT=$(realpath -e "$0")
SCRIPTPATH=$(dirname "$SCRIPT")

. "$SCRIPTPATH"/configure-common.sh
. "$SCRIPTPATH"/configure-sigh.sh

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
    exec sigh --debug
else    
    echo "Container configuration: Debugging output of Sigh is OFF"
    exec sigh
fi
