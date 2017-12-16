#!/bin/sh

echo [`date`] Bootstrapping Haproxy...

function clean_up {
    # Perform program exit housekeeping
    echo [`date`] Stopping the service...
    rc-service rsyslog stop
    rm /run/haproxy.pid
    exit
}

trap clean_up SIGTERM

rc-service rsyslog restart
mkdir /run/haproxy
mkdir /dev/log; touch /dev/log/haproxy_0.log; touch /dev/log/haproxy_1.log; touch /dev/log/haproxy.log; chmod 777 -R /dev/log
haproxy -p /run/haproxy.pid -f /etc/haproxy/haproxy.cfg

echo [`date`] Bootstrap finished

tail -f /dev/null &
child=$!
wait "$child"
