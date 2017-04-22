FROM debian:jessie-slim

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
        file \
        iproute2 \
        libcap-ng0 \
        libcap-ng-dev \
        libnuma1 \
        libnuma-dev \
        libpcap0.8 \
        libpcap-dev \
        libssl1.0.0 \
        libssl-dev \
        linux-headers-amd64 \
        openssl \
        python \
        python-six \
        ; \
    mkdir /tmp/openvswitch /tmp/dpdk; \
    curl -sSL http://openvswitch.org/releases/openvswitch-${OVS_VERSION}.tar.gz | tar xz -C /tmp/openvswitch --strip-components=1; \
    curl -sSL http://fast.dpdk.org/rel/dpdk-${DPDK_VERSION}.tar.xz | tar xJ -C /tmp/dpdk --strip-components=1; \
    cd /tmp/dpdk; \
    make config T=x86_64-native-linuxapp-gcc; \
    sed -i -e '/^CONFIG_RTE_EAL_IGB_UIO/c\CONFIG_RTE_EAL_IGB_UIO=n' \
           -e '/^CONFIG_RTE_LIBRTE_KNI/c\CONFIG_RTE_LIBRTE_KNI=n' \
           -e '/^CONFIG_RTE_LIBRTE_VHOST/c\CONFIG_RTE_LIBRTE_VHOST=y' \
        build/.config; \
    make RTE_KERNELDIR=/lib/modules/*/build; \
    make install prefix=/usr; \
    for script in dpdk-{devbind,pmdinfo} cpu_layout; do \
        ln -s /usr/share/dpdk/usertools/${script}.py /bin/${script}; \
        ln -s /usr/share/dpdk/usertools/${script}.py /bin/${script}.py; \
    done; \
    cd /tmp/openvswitch; \
    ./configure --prefix=/usr --localstatedir=/var --sysconfdir=/etc CFLAGS="-O2" --with-dpdk=/tmp/dpdk/build --with-linux=/lib/modules/*/build; \
    make; \
    make install; \
    cd /; \
    apt-get purge --auto-remove -y \
        build-essential \
        curl \
        file \
        libcap-ng-dev \
        libnuma-dev \
        libpcap-dev \
        libssl-dev \
        linux-headers-amd64 \
        openssl \
        python-six \
        ; \
    rm -rf /tmp/* /var/lib/apt/lists/*
