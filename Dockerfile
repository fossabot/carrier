FROM ubuntu:xenial
#   Copyright 2018-2019 getcarrier.io
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
LABEL author="artem_rozumenko@epam.com"
LABEL updated.by="ivan_krakhmaliuk@epam.com"

# Software versions
ARG JAVA_OPENJDK_URL=https://download.java.net/java/GA/jdk10/10.0.2/19aef61b38124481863b1413dce1855f/13/openjdk-10.0.2_linux-x64_bin.tar.gz
ARG JAVA_OPENJDK_VERSION=10.0.2
ARG RUBY_VERSION=2.3.0-dev

# SAST tool versions
ARG BANDIT_VERSION=1.5.1
ARG SPOTBUGS_VERSION=3.1.9
ARG FINDSECBUGS_VERSION=1.8.0

# DAST tool versions
ARG ARACHNI_VERSION=1.5.1
ARG ARACHNI_WEB_VERSION=0.5.12
ARG NMAP_VERSION=7.40
ARG W3AF_REVISION=356b14b975039706f4fd7f4f5db5b114cd75f14e
ARG SSLYZE_VERSION=2.0.1
ARG ZAP_STABLE_VERSION=2.7.0
ARG ZAP_WEEKLY_VERSION=2019-02-25

# Default locale
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

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
    autoconf bison libreadline6-dev libgdbm3 libgdbm-dev \
    rbenv ruby-build \
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

# Ruby
RUN set -x \
  && cd /tmp \
  && rbenv install ${RUBY_VERSION} \
  && rbenv global ${RUBY_VERSION} \
  && rm -rf /tmp/ruby-*

# NodeJS
RUN set -x \
  && curl -sL https://deb.nodesource.com/setup_10.x | bash - \
  && apt-get update \
  && apt-get install --no-install-recommends -y nodejs \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  && npm -g i n && n 10.13.0 --test && npm -g i npm@6.1 http-server@0.11.1 retire@1.6.0 --test \
  && rm -rf /tmp/npm-*

# SAST: pybandit (Python SAST tool)
RUN set -x \
  && mkdir -p /opt/virtualenv/bandit \
  && virtualenv -p python3.6 /opt/virtualenv/bandit \
  && /opt/virtualenv/bandit/bin/pip3.6 install bandit==${BANDIT_VERSION} \
  && update-alternatives --install /usr/bin/bandit bandit /opt/virtualenv/bandit/bin/bandit 9999

# SAST: safety (Python SAST composition analysis tool)
RUN set -x \
  && mkdir -p /opt/virtualenv/safety \
  && virtualenv -p python3.6 /opt/virtualenv/safety \
  && /opt/virtualenv/safety/bin/pip3.6 install safety \
  && update-alternatives --install /usr/bin/safety safety /opt/virtualenv/safety/bin/safety 9999

# SAST: Spotbugs
RUN set -x \
  && cd /opt \
  && curl -LOJ http://repo.maven.apache.org/maven2/com/github/spotbugs/spotbugs/${SPOTBUGS_VERSION}/spotbugs-${SPOTBUGS_VERSION}.zip \
  && unzip spotbugs-${SPOTBUGS_VERSION}.zip \
  && rm -rf spotbugs-${SPOTBUGS_VERSION}.zip \
  && cd /opt/spotbugs-${SPOTBUGS_VERSION}/plugin \
  && curl -LOJ https://search.maven.org/remotecontent?filepath=com/h3xstream/findsecbugs/findsecbugs-plugin/${FINDSECBUGS_VERSION}/findsecbugs-plugin-${FINDSECBUGS_VERSION}.jar \
  && cd ../.. \
  && find /opt/spotbugs-${SPOTBUGS_VERSION}/bin/ -type f -maxdepth 1 -printf 'update-alternatives --install /usr/bin/%f %f %p 9999\n' | bash

# SAST: NodeJsScan
RUN set -x \
  && mkdir -p /opt/virtualenv/nodejsscan \
  && virtualenv -p python3.6 /opt/virtualenv/nodejsscan \
  && /opt/virtualenv/nodejsscan/bin/pip3.6 install nodejsscan \
  && update-alternatives --install /usr/bin/nodejsscan nodejsscan /opt/virtualenv/nodejsscan/bin/nodejsscan 9999

# SAST: bakeman (Ruby SAST tool)
RUN set -x \
  && gem install brakeman

# DAST: Arachni
RUN set -x \
  && mkdir /opt/arachni \
  && cd /tmp \
  && wget -qO- https://github.com/Arachni/arachni/releases/download/v${ARACHNI_VERSION}/arachni-${ARACHNI_VERSION}-${ARACHNI_WEB_VERSION}-linux-x86_64.tar.gz | tar xvz -C /opt/arachni --strip-components=1 \
  && find /opt/arachni/bin/ -type f -iname 'arachni*' -printf 'update-alternatives --install /usr/bin/%f %f %p 9999\n' | bash

# DAST: Masscan
RUN set -x \
  && cd /opt \
  && git clone https://github.com/robertdavidgraham/masscan \
  && cd masscan \
  && make -j4 \
  && update-alternatives --install /usr/bin/masscan masscan /opt/masscan/bin/masscan 9999

# DAST: Nikto
RUN set -x \
  && cd /opt \
  && git clone https://github.com/sullo/nikto \
  && update-alternatives --install /usr/bin/nikto.pl nikto.pl /opt/nikto/program/nikto.pl 9999 \
  && update-alternatives --install /usr/bin/replay.pl replay.pl /opt/nikto/program/replay.pl 9999

# DAST: Nmap
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

# DAST: W3af
RUN set -x \
  && mkdir -p /opt/virtualenv/w3af \
  && virtualenv -p python2.7 /opt/virtualenv/w3af \
  && cd /opt \
  && git clone https://github.com/andresriancho/w3af.git \
  && cd w3af \
  && git reset --hard ${W3AF_REVISION} \
  && sed 's|#!/usr/bin/env python|#!/opt/virtualenv/w3af/bin/python|g' -i w3af_console \
  && ./w3af_console; true \
  && sed 's/sudo //g' -i /tmp/w3af_dependency_install.sh \
  && sed 's/apt-get/apt-get -y/g' -i /tmp/w3af_dependency_install.sh \
  && sed 's|pip install|/opt/virtualenv/w3af/bin/pip install --upgrade|g' -i /tmp/w3af_dependency_install.sh \
  && /tmp/w3af_dependency_install.sh \
  && rm -f /tmp/w3af_dependency_install.sh \
  && sed 's/dependency_check()/#dependency_check()/g' -i w3af_console \
  && update-alternatives --install /usr/bin/w3af_console w3af_console /opt/w3af/w3af_console 9999

# DAST: Sslyze
RUN set -x \
  && mkdir -p /opt/virtualenv/sslyze \
  && virtualenv -p python3.6 /opt/virtualenv/sslyze \
  && /opt/virtualenv/sslyze/bin/pip3.6 install sslyze==${SSLYZE_VERSION} \
  && /opt/virtualenv/sslyze/bin/python3.6 -m sslyze --update_trust_stores \
  && update-alternatives --install /usr/bin/sslyze sslyze /opt/virtualenv/sslyze/bin/sslyze 9999

# DAST: Aem-hacker
RUN set -x \
  && mkdir -p /opt/virtualenv/aemhacker \
  && virtualenv -p python3.6 /opt/virtualenv/aemhacker \
  && cd /opt \
  && git clone https://github.com/0ang3el/aem-hacker.git \
  && cd aem-hacker \
  && /opt/virtualenv/aemhacker/bin/pip3.6 install --upgrade -r requirements.txt \
  && echo '#!/bin/bash' > /opt/aem-hacker/aem-wrapper.sh \
  && echo '/opt/virtualenv/aemhacker/bin/python3.6 /opt/aem-hacker/aem_hacker.py $*' >> /opt/aem-hacker/aem-wrapper.sh \
  && chmod a+x *.py *.sh \
  && cd .. \
  && update-alternatives --install /usr/bin/aem-wrapper.sh aem-wrapper.sh /opt/aem-hacker/aem-wrapper.sh 9999

# DAST: ZAP (stable)
RUN set -x \
  && cd /opt \
  && mkdir /opt/zap \
  && wget -qO- https://github.com/zaproxy/zaproxy/releases/download/${ZAP_STABLE_VERSION}/ZAP_${ZAP_STABLE_VERSION}_Linux.tar.gz | tar xvz -C /opt/zap --strip-components=1 \
  && chmod +x /opt/zap/zap.sh \
  && update-alternatives --install /opt/zap/zap-stable.jar zap-stable.jar /opt/zap/zap-${ZAP_STABLE_VERSION}.jar 9999

# DAST: ZAP (weekly)
RUN set -x \
  && cd /opt \
  && curl -LOJ https://github.com/zaproxy/zaproxy/releases/download/w${ZAP_WEEKLY_VERSION}/ZAP_WEEKLY_D-${ZAP_WEEKLY_VERSION}.zip \
  && unzip ZAP_WEEKLY_D-${ZAP_WEEKLY_VERSION}.zip \
  && rm -f ZAP_WEEKLY_D-${ZAP_WEEKLY_VERSION}.zip \
  && mv ZAP_D-${ZAP_WEEKLY_VERSION} zap-weekly \
  && chmod +x /opt/zap-weekly/zap.sh \
  && update-alternatives --install /opt/zap-weekly/zap-weekly.jar zap-weekly.jar /opt/zap-weekly/zap-D-${ZAP_WEEKLY_VERSION}.jar 9999

# DAST: zap-cli
RUN set -x \
  && mkdir -p /opt/virtualenv/zapcli \
  && virtualenv -p python3.6 /opt/virtualenv/zapcli \
  && /opt/virtualenv/zapcli/bin/pip3.6 install zapcli==0.10.0 \
  && update-alternatives --install /usr/bin/zap-cli zap-cli /opt/virtualenv/zapcli/bin/zap-cli 9999
