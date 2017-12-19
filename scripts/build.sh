#!/usr/bin/env sh
set -ex

apk upgrade --no-cache

# install build dependencies
apk add --no-cache --virtual build-deps make gcc libc-dev linux-headers python pcre-dev openssl-dev zlib-dev

# compile haproxy
mkdir -p /usr/src/haproxy
wget -O haproxy.tar.gz http://www.haproxy.org/download/${HAPROXY_MAJOR}/src/haproxy-${HAPROXY_VERSION}.tar.gz
echo "$HAPROXY_MD5 *haproxy.tar.gz" | md5sum -c
tar -xzf haproxy.tar.gz -C /usr/src/haproxy --strip-components=1
rm haproxy.tar.gz
make -C /usr/src/haproxy all \
	PREFIX=/usr/ TARGET=linux2628 \
	USE_PCRE=1 USE_PCRE_JIT=1 \
	USE_OPENSSL=1 \
	USE_ZLIB=1

# install haproxy
make -C /usr/src/haproxy install-bin PREFIX=/usr TARGET=linux2628
mkdir -p /etc/haproxy
cp -R /usr/src/haproxy/examples/errorfiles /etc/haproxy/errors

# remove build dependencies
apk del build-deps

# install run dependencies
apk add --no-cache pcre libssl1.0 libcrypto1.0 zlib rsyslog openrc

# clean
rm -rf /usr/src/haproxy