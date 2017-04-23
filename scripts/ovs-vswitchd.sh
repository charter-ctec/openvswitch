#!/bin/bash

set -eux

trap 'ovs-appctl -T1 -t/run/openvswitch/ovs-vswitch.pid exit' SIGINT SIGTERM SIGHUP

while [[ ! -S /run/openvswitch/db.sock ]]; do
    sleep 1
done

ovs-vsctl --no-wait init

ovs-vswitchd unix:/run/openvswitch/db.sock --pidfile --overwrite-pidfile &

wait
