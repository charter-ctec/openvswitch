FROM ubuntu:xenial

SHELL ["/bin/bash", "-c"]

ENV DEBIAN_FRONTEND=noninteractive \
    OVS_VERSION=2.7.0 \
    DPDK_VERSION=17.02

RUN set -eux; \
    apt-get update; \
    apt-get dist-upgrade -y; \
    apt-get install --no-install-recommends -y \
        build-essential \
        curl \
        iproute2 \
        libcap-ng0 \
        libcap-ng-dev \
        libnuma1 \
        libnuma-dev \
        libpcap0.8 \
        libpcap-dev \
        libssl1.0.0 \
        libssl-dev \
        linux-headers-generic \
        openssl \
        python-six \
        ; \
    mkdir /tmp/openvswitch /tmp/dpdk; \
    curl -sSL http://openvswitch.org/releases/openvswitch-${OVS_VERSION}.tar.gz | tar xz -C /tmp/openvswitch --strip-components=1; \
    curl -sSL http://fast.dpdk.org/rel/dpdk-${DPDK_VERSION}.tar.xz | tar xJ -C /tmp/dpdk --strip-components=1; \
    cd /tmp/dpdk; \
    make install T=x86_64-native-linuxapp-gcc DESTDIR=install; \
    cd /tmp/openvswitch; \
    ./configure --prefix=/usr --localstatedir=/var --sysconfdir=/etc CFLAGS="-g -O2 -march=native" --with-dpdk=/tmp/dpdk/install --with-linux=/lib/modules/*/build; \
    make; \
    make install; \
    cd /; \
    apt-get purge --autoremove -y \
        build-essential \
        curl \
        libcap-ng-dev \
        libnuma-dev \
        libpcap-dev \
        libssl-dev \
        linux-headers-generic-hwe-16.04-edge \
        openssl \
        python-six \
        ; \
    rm -rf /tmp/* /var/lib/apt/lists/*
