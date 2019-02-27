FROM ubuntu:xenial

# Image labels
LABEL author="artem_rozumenko@epam.com"
LABEL updated.by="ivan_krakhmaliuk@epam.com"

# Image arguments
ARG JAVA_OPENJDK_URL=https://download.java.net/java/GA/jdk10/10.0.2/19aef61b38124481863b1413dce1855f/13/openjdk-10.0.2_linux-x64_bin.tar.gz
ARG JAVA_OPENJDK_VERSION=10.0.2
ARG ARACHNI_VERSION=1.5.1
ARG ARACHNI_WEB_VERSION=0.5.12
ARG NMAP_VERSION=7.40
ARG W3AF_REVISION=356b14b975039706f4fd7f4f5db5b114cd75f14e

# Base software package
RUN set -x \
  && apt-get update \
  && apt-get install --no-install-recommends -y \
    software-properties-common apt-transport-https ca-certificates curl gnupg2 wget \
  && add-apt-repository ppa:jonathonf/python-3.6 \
  && apt-get update \
  && apt-get install --no-install-recommends -y \
    default-jre default-jdk xvfb git gcc make \
    build-essential libssl-dev zlib1g-dev libbz2-dev libpcap-dev unzip \
    libreadline-dev libsqlite3-dev llvm libncurses5-dev libncursesw5-dev \
    xz-utils tk-dev libffi-dev liblzma-dev perl libnet-ssleay-perl python-dev python-pip \
    libxslt1-dev libxml2-dev libyaml-dev openssh-server  python-lxml \
    xdot python-gtk2 python-gtksourceview2 dmz-cursor-theme supervisor \
    python-setuptools maven python3.6 python3.6-dev \
    virtualenv python-virtualenv python3-virtualenv checkinstall \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Docker
RUN set -x \
  && curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - \
  && apt-key fingerprint 0EBFCD88 \
  && echo "deb [arch=amd64] https://download.docker.com/linux/debian stretch stable" | \
	 tee /etc/apt/sources.list.d/docker.list \
  && apt-get update \
  && apt-get install --no-install-recommends -y docker-ce \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Java
RUN set -x \
  && cd /opt \
  && wget -qO- ${JAVA_OPENJDK_URL} | tar vxfz - \
  && find /opt/jdk-${JAVA_OPENJDK_VERSION}/bin/ -type f -printf 'update-alternatives --install /usr/bin/%f %f %p 9999\n' | bash

# NodeJS
RUN set -x \
  && curl -sL https://deb.nodesource.com/setup_10.x | bash - \
  && apt-get update \
  && apt-get install --no-install-recommends -y nodejs \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  && npm -g i n && n 10.13.0 --test && npm -g i npm@6.1 http-server@0.11.1 retire@1.6.0 --test

# Arachni
RUN set -x \
  && mkdir /opt/arachni \
  && cd /tmp \
  && wget -qO- https://github.com/Arachni/arachni/releases/download/v${ARACHNI_VERSION}/arachni-${ARACHNI_VERSION}-${ARACHNI_WEB_VERSION}-linux-x86_64.tar.gz | tar xvz -C /opt/arachni --strip-components=1 \
  && find /opt/arachni/bin/ -type f -iname 'arachni*' -printf 'update-alternatives --install /usr/bin/%f %f %p 9999\n' | bash

# Masscan
RUN set -x \
  && cd /opt \
  && git clone https://github.com/robertdavidgraham/masscan \
  && cd masscan \
  && make -j4 \
  && update-alternatives --install /usr/bin/masscan masscan /opt/masscan/bin/masscan 9999

# Nikto
RUN set -x \
  && cd /opt \
  && git clone https://github.com/sullo/nikto \
  && update-alternatives --install /usr/bin/nikto.pl nikto.pl /opt/nikto/program/nikto.pl 9999 \
  && update-alternatives --install /usr/bin/replay.pl replay.pl /opt/nikto/program/replay.pl 9999

# Nmap
RUN set -x \
  && cd /tmp \
  && curl -O https://nmap.org/dist/nmap-${NMAP_VERSION}.tar.bz2 \
  && bzip2 -cd nmap-${NMAP_VERSION}.tar.bz2 | tar xvf - \
  && rm -f nmap-${NMAP_VERSION}.tar.bz2 \
  && cd nmap-${NMAP_VERSION} \
  && bash configure \
  && make \
  && checkinstall -y \
  && cd .. \
  && rm -rf nmap-${NMAP_VERSION}

# W3af
RUN set -x \
  && mkdir -p /opt/virtualenv/w3af \
  && virtualenv -p python2.7 /opt/virtualenv/w3af \
  && cd /opt \
  && git clone https://github.com/andresriancho/w3af.git \
  && cd w3af \
  && git reset --hard ${W3AF_REVISION} \
  && ./w3af_console; true \
  && sed 's/sudo //g' -i /tmp/w3af_dependency_install.sh \
  && sed 's/apt-get/apt-get -y/g' -i /tmp/w3af_dependency_install.sh \
  && sed 's|pip install|/opt/virtualenv/w3af/bin/pip install --upgrade|g' -i /tmp/w3af_dependency_install.sh \
  && /tmp/w3af_dependency_install.sh \
  && sed 's|#!/usr/bin/env python|/opt/virtualenv/w3af/bin/python|g' -i w3af_console \
  && sed 's/dependency_check()/#dependency_check()/g' -i w3af_console \
  && update-alternatives --install /usr/bin/w3af_console w3af_console /opt/w3af/w3af_console 9999
