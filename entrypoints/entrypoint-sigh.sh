#!/bin/sh
set -e

SCRIPT=$(realpath -e "$0")
SCRIPTPATH=$(dirname "$SCRIPT")

. "$SCRIPTPATH"/configure-common.sh
. "$SCRIPTPATH"/configure-sigh.sh

debug=
for word in $LOG_OUTPUT
do
    if [ $word = sigh ]
    then
        debug=--debug
    fi
done

exec sigh $debug
