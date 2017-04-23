FROM debian:jessie-slim

SHELL ["/bin/bash", "-c"]

ENV DEBIAN_FRONTEND=noninteractive \
    OVS_VERSION=2.7.0

RUN set -eux; \
    apt-get update; \
    apt-get dist-upgrade -y; \
    apt-get install --no-install-recommends -y \
        build-essential \
        curl \
        libatomic1 \
        libssl1.0.0 \
        openssl \
        uuid-runtime \
        graphviz \
        autoconf \
        automake \
        bzip2 \
        debhelper \
        dh-autoreconf \
        libssl-dev \
        libtool \
        python-all \
        python-six \
        python-twisted-conch \
        python-zopeinterface \
        ; \
    mkdir /tmp/openvswitch; \
    curl -sSL http://openvswitch.org/releases/openvswitch-${OVS_VERSION}.tar.gz | tar xz -C /tmp/openvswitch --strip-components=1; \
    cd /tmp/openvswitch; \
    ./boot.sh; \
    ./configure --prefix=/usr --localstatedir=/var --sysconfdir=/etc; \
    make; \
    # Test 2323: mcast is broken in DockerHub builds
    # Some tests fail intermittently in DockerHub; RECHECK
    make check TESTSUITEFLAGS='1-2322' RECHECK=yes; \
    make install; \
    cd /; \
    apt-get purge --auto-remove -y \
        build-essential \
        curl \
        graphviz \
        autoconf \
        automake \
        bzip2 \
        debhelper \
        dh-autoreconf \
        libssl-dev \
        libtool \
        python-all \
        python-six \
        python-twisted-conch \
        python-zopeinterface \
        ; \
    rm -rf /tmp/* /var/lib/apt/lists/*
