#!/bin/bash

# This script downloads and installs PyPy and makes it available as
# /usr/local/bin/pypy. It will work only on 64-bit Ubuntu Linux.
# This must be run as root.

cd /tmp
wget https://bitbucket.org/pypy/pypy/downloads/pypy2-v5.7.1-linux64.tar.bz2
cd /usr/local/lib
tar xf /tmp/pypy2-v5.7.1-linux64.tar.bz2
ln -sf /usr/local/lib/pypy2-v5.7.1-linux64/bin/pypy /usr/local/bin/pypy
rm -f /tmp/pypy2-v5.7.1-linux64.tar.bz2
