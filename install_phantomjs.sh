#!/bin/bash

# This script installs PhantomJS.
# It is adapted from the following procedure:
# http://kb.solarvps.com/ubuntu/installing-phantomjs-on-ubuntu-12-04-lts/
#
# See the following page for current PhantomJS information:
# http://phantomjs.org/download.html
#

PHANTOMJS_VER=1.9.2
PJS=phantomjs-$PHANTOMJS_VER-linux-x86_64

mkdir -p /usr/local/share
cd /usr/local/share
wget https://phantomjs.googlecode.com/files/$PJS.tar.bz2
tar xjf $PJS.tar.bz2
ln -sf /usr/local/share/$PJS/bin/phantomjs /usr/local/share/phantomjs
ln -sf /usr/local/share/$PJS/bin/phantomjs /usr/local/bin/phantomjs
ln -sf /usr/local/share/$PJS/bin/phantomjs /usr/bin/phantomjs
