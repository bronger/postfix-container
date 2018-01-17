#!/bin/sh

cd /tmp
tar xzf v1607.1.1.tar.gz
cd sigh-1607.1.1
cmake .
make -j4
make install
