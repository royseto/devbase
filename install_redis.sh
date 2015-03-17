#!/bin/bash

echo "Installing latest stable Redis per http://redis.io/topics/quickstart"
set -ex

mkdir -p /tmp/build_redis && cd /tmp/build_redis
wget http://download.redis.io/redis-stable.tar.gz
tar xvzf redis-stable.tar.gz
cd redis-stable
make && make install
cd /tmp && /bin/rm -rf /tmp/build_redis
