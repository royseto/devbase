#!/bin/sh

# This script must be run sudo root as follows:
#
#     sudo ./root_install_phantomjs.sh
#
# It downloads and installs phantomjs on Ubuntu Linux and has been tested on
# Ubuntu 12.04.
#
# This script can be safely rerun. It will overwrite a prior installation
# if it exists.
#
# It is adapted from the following procedure:
# http://kb.solarvps.com/ubuntu/installing-phantomjs-on-ubuntu-12-04-lts/
#
# See the following page for current PhantomJS information:
# http://phantomjs.org/download.html
#

# fontconfig seems to be a hidden dependency for PhantomJS
apt-get update && apt-get install -y libfontconfig

PHANTOMJS_VER=2.1.1
PJS=phantomjs-$PHANTOMJS_VER-linux-x86_64

mkdir /usr/local/share
cd /usr/local/share
wget -q https://bitbucket.org/ariya/phantomjs/downloads/$PJS.tar.bz2
tar xjf $PJS.tar.bz2
ln -sf /usr/local/share/$PJS/bin/phantomjs /usr/local/share/phantomjs
ln -sf /usr/local/share/$PJS/bin/phantomjs /usr/local/bin/phantomjs
ln -sf /usr/local/share/$PJS/bin/phantomjs /usr/bin/phantomjs
