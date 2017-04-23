#!/bin/bash

set -eux

trap 'ovs-appctl -T1 -t/run/openvswitch/ovsdb-server.pid exit' SIGINT SIGTERM SIGHUP

if [[ -f /etc/openvswitch/conf.db ]]; then
    ovsdb-tool convert /etc/openvswitch/conf.db /usr/share/openvswitch/vswitch.ovsschema
else
    ovsdb-tool create /etc/openvswitch/conf.db /usr/share/openvswitch/vswitch.ovsschema
fi

ovsdb-server --remote=punix:/var/run/openvswitch/db.sock --remote=db:Open_vSwitch,Open_vSwitch,manager_options --pidfile --overwrite-pidfile &

wait
