#!/bin/sh
set -e

SCRIPT=$(realpath -e "$0")
SCRIPTPATH=$(dirname "$SCRIPT")

"$SCRIPTPATH"/configure_sigh.py "$SIGH_ROOT"
