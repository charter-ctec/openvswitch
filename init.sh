#!/bin/bash

set -eux

ovs-vsctl --no-wait init
#ovs-vsctl --no-wait set Open_vSwitch . other_config:dpdk-lcore-mask=0xf
ovs-vsctl --no-wait set Open_vSwitch . other_config:dpdk-socket-mem=1024
ovs-vsctl --no-wait set Open_vSwitch . other_config:dpdk-init=true
