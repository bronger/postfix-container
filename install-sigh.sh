#!/bin/bash
set -e

cd /tmp
tar xzf v"$1".tar.gz
cd sigh-"$1"
cmake .
make -j4
make install
