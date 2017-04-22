#!/bin/bash

set -eux

if [[ -f /etc/openvswitch/devices ]]; then
    while read line; do
        dpdk-devbind --bind=vfio-pci ${line}
    done < /etc/openvswitch/devices
fi

exec $@
