#!/bin/sh

SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")

ROOT=/tmp/postfix-docker-context
rm -Rf "$ROOT"
mkdir "$ROOT"
cp "$SCRIPTPATH"/Dockerfile
