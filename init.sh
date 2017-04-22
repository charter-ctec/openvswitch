#!/bin/bash

set -eux

docker run --name=ovsdb-server --restart=always -d -t -v /etc/openvswitch/:/etc/openvswitch/ -v openvswitch:/run/openvswitch/ samyaple/openvswitch /etc/openvswitch/ovsdb-server.sh


docker run --rm -it -v openvswitch:/run/openvswitch/ samyaple/openvswitch ovs-vsctl --no-wait init
docker run --rm -it -v openvswitch:/run/openvswitch/ samyaple/openvswitch ovs-vsctl --no-wait set Open_vSwitch . other_config:pmd-cpu-mask=0x404
#docker run --rm -it -v openvswitch:/run/openvswitch/ samyaple/openvswitch ovs-vsctl --no-wait set Open_vSwitch . other_config:dpdk-lcore-mask=0x404
docker run --rm -it -v openvswitch:/run/openvswitch/ samyaple/openvswitch ovs-vsctl --no-wait set Open_vSwitch . other_config:dpdk-socket-mem=1024
docker run --rm -it -v openvswitch:/run/openvswitch/ samyaple/openvswitch ovs-vsctl --no-wait set Open_vSwitch . other_config:dpdk-init=true
#docker run --rm -it -v openvswitch:/run/openvswitch/ samyaple/openvswitch ovs-vsctl --no-wait set Open_vSwitch . "other_config:dpdk-extra=--vhost-owner libvirt-qemu:kvm --vhost-perm 0666"

docker run --name=ovs-vswitchd --restart=always -d -t --net=host --userns=host --privileged -v /etc/openvswitch/:/etc/openvswitch/ -v openvswitch:/run/openvswitch/ -v /hugepages/:/hugepages/ samyaple/openvswitch /etc/openvswitch/ovs-vswitchd.sh


ovs-vsctl add-br br-10gb -- set bridge br-10gb datapath_type=netdev
ovs-vsctl add-bond br-10gb bond-10gb enp2s0f0 enp2s0f1 -- set Interface enp2s0f0 type=dpdk options:dpdk-devargs=0000:02:00.0 -- set Interface enp2s0f1 type=dpdk options:dpdk-devargs=0000:02:00.1
ovs-vsctl add-port br-10gb vlan10 tag=10 -- set Interface vlan10 type=internal

docker run --restart=always -d --name keystone -it -p 10.10.1.2:5000:5000 -v /etc/keystone/:/etc/keystone/ samyaple/keystone:debian-10.0.1 /etc/keystone/start.sh
docker run -d --restart=always -v rabbitmq:/var/lib/rabbitmq/ -v /etc/rabbitmq/:/etc/rabbitmq/ -p 10.10.1.2:4369:4369 -p 10.10.1.2:5672:5672 -p 10.10.1.2:15672:15672 -p 10.10.1.2:25672:25672 --hostname $(hostname) --name rabbitmq --entrypoint rabbitmq-server rabbitmq:3.6.9
docker run -d -t --restart=always --entrypoint /bin/mysqld.sh -v /var/log/mysql/:/var/log/mysql/ -v /etc/mysql/mysqld.sh:/bin/mysqld.sh -v /etc/mysql/my.cnf:/etc/my.cnf -v mariadb:/var/lib/mysql/ -p 10.10.1.2:3306:3306 -p 10.10.1.2:4444:4444 -p 10.10.1.2:4567:4567/udp -p 10.10.1.2:4567-4568:4567-4568 --name mariadb mariadb:10.1
