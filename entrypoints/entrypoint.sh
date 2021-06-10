#!/bin/sh
set -e

SCRIPT=$(realpath -e "$0")
SCRIPTPATH=$(dirname "$SCRIPT")

. "$SCRIPTPATH"/configure-common.sh
. "$SCRIPTPATH"/configure-sigh.sh
. "$SCRIPTPATH"/configure-postfix.sh

exec supervisord -c /etc/supervisor/supervisord.conf
