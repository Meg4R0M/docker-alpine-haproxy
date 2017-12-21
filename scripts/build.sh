#!/usr/bin/env sh
set -ex

BUILD_DEPS="make gcc libc-dev linux-headers python pcre-dev openssl-dev zlib-dev lua5.3-dev"
RUN_DEPS="pcre libssl1.0 libcrypto1.0 zlib rsyslog openrc lua5.3-libs"

if [ -z ${HAPROXY_MAJOR} ];
	then HAPROXY_MAJOR="1.6";
fi

if [ -z ${HAPROXY_VERSION} ];
	then HAPROXY_VERSION="1.6.13";
fi

if [ -z ${HAPROXY_MD5} ];
	then HAPROXY_MD5="782947642c0c7983f73624d8d45e2321";
fi

apk upgrade --no-cache

# install build dependencies
apk add --no-cache --virtual build-deps ${BUILD_DEPS}

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
	USE_ZLIB=1 \
	USE_LUA=1 LUA_LIB=/usr/lib/lua5.3/ LUA_INC=/usr/include/lua5.3

# install haproxy
make -C /usr/src/haproxy install-bin PREFIX=/usr TARGET=linux2628
mkdir -p /etc/haproxy
cp -R /usr/src/haproxy/examples/errorfiles /etc/haproxy/errors

# remove build dependencies
apk del build-deps

# install run dependencies
apk add --no-cache ${RUN_DEPS}

# clean
rm -rf /usr/src/haproxy