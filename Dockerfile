FROM ubuntu:xenial

# Image labels
LABEL author="artem_rozumenko@epam.com"
LABEL updated.by="ivan_krakhmaliuk@epam.com"

# Image arguments
ARG JAVA_OPENJDK_URL=https://download.java.net/java/GA/jdk10/10.0.2/19aef61b38124481863b1413dce1855f/13/openjdk-10.0.2_linux-x64_bin.tar.gz
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
  && wget ${JAVA_OPENJDK_URL} -O openjdk.tar.gz \
  && tar vxfz openjdk.tar.gz \
  && rm -rf openjdk.tar.gz \
  && update-alternatives --install /usr/bin/appletviewer appletviewer /opt/jdk-10.0.2/bin/appletviewer 1 \
  && update-alternatives --install /usr/bin/extcheck extcheck /opt/jdk-10.0.2/bin/extcheck 1 \
  && update-alternatives --install /usr/bin/idlj idlj /opt/jdk-10.0.2/bin/idlj 1 \
  && update-alternatives --install /usr/bin/jar jar /opt/jdk-10.0.2/bin/jar 1 \
  && update-alternatives --install /usr/bin/jarsigner jarsigner /opt/jdk-10.0.2/bin/jarsigner 1 \
  && update-alternatives --install /usr/bin/java java /opt/jdk-10.0.2/bin/java 1 \
  && update-alternatives --install /usr/bin/javac javac /opt/jdk-10.0.2/bin/javac 1 \
  && update-alternatives --install /usr/bin/javadoc javadoc /opt/jdk-10.0.2/bin/javadoc 1 \
  && update-alternatives --install /usr/bin/javah javah /opt/jdk-10.0.2/bin/javah 1 \
  && update-alternatives --install /usr/bin/javap javap /opt/jdk-10.0.2/bin/javap 1 \
  && update-alternatives --install /usr/bin/java-rmi.cgi java-rmi.cgi /opt/jdk-10.0.2/bin/java-rmi.cgi 1 \
  && update-alternatives --install /usr/bin/jcmd jcmd /opt/jdk-10.0.2/bin/jcmd 1 \
  && update-alternatives --install /usr/bin/jconsole jconsole /opt/jdk-10.0.2/bin/jconsole 1 \
  && update-alternatives --install /usr/bin/jdb jdb /opt/jdk-10.0.2/bin/jdb 1 \
  && update-alternatives --install /usr/bin/jdeps jdeps /opt/jdk-10.0.2/bin/jdeps 1 \
  && update-alternatives --install /usr/bin/jhat jhat /opt/jdk-10.0.2/bin/jhat 1 \
  && update-alternatives --install /usr/bin/jinfo jinfo /opt/jdk-10.0.2/bin/jinfo 1 \
  && update-alternatives --install /usr/bin/jjs jjs /opt/jdk-10.0.2/bin/jjs 1 \
  && update-alternatives --install /usr/bin/jmap jmap /opt/jdk-10.0.2/bin/jmap 1 \
  && update-alternatives --install /usr/bin/jps jps /opt/jdk-10.0.2/bin/jps 1 \
  && update-alternatives --install /usr/bin/jrunscript jrunscript /opt/jdk-10.0.2/bin/jrunscript 1 \
  && update-alternatives --install /usr/bin/jsadebugd jsadebugd /opt/jdk-10.0.2/bin/jsadebugd 1 \
  && update-alternatives --install /usr/bin/jstack jstack /opt/jdk-10.0.2/bin/jstack 1 \
  && update-alternatives --install /usr/bin/jstat jstat /opt/jdk-10.0.2/bin/jstat 1 \
  && update-alternatives --install /usr/bin/jstatd jstatd /opt/jdk-10.0.2/bin/jstatd 1 \
  && update-alternatives --install /usr/bin/keytool keytool /opt/jdk-10.0.2/bin/keytool 1 \
  && update-alternatives --install /usr/bin/native2ascii native2ascii /opt/jdk-10.0.2/bin/native2ascii 1 \
  && update-alternatives --install /usr/bin/orbd orbd /opt/jdk-10.0.2/bin/orbd 1 \
  && update-alternatives --install /usr/bin/pack200 pack200 /opt/jdk-10.0.2/bin/pack200 1 \
  && update-alternatives --install /usr/bin/policytool policytool /opt/jdk-10.0.2/bin/policytool 1 \
  && update-alternatives --install /usr/bin/rmic rmic /opt/jdk-10.0.2/bin/rmic 1 \
  && update-alternatives --install /usr/bin/rmid rmid /opt/jdk-10.0.2/bin/rmid 1 \
  && update-alternatives --install /usr/bin/rmiregistry rmiregistry /opt/jdk-10.0.2/bin/rmiregistry 1 \
  && update-alternatives --install /usr/bin/schemagen schemagen /opt/jdk-10.0.2/bin/schemagen 1 \
  && update-alternatives --install /usr/bin/serialver serialver /opt/jdk-10.0.2/bin/serialver 1 \
  && update-alternatives --install /usr/bin/servertool servertool /opt/jdk-10.0.2/bin/servertool 1 \
  && update-alternatives --install /usr/bin/tnameserv tnameserv /opt/jdk-10.0.2/bin/tnameserv 1 \
  && update-alternatives --install /usr/bin/unpack200 unpack200 /opt/jdk-10.0.2/bin/unpack200 1 \
  && update-alternatives --install /usr/bin/wsgen wsgen /opt/jdk-10.0.2/bin/wsgen 1 \
  && update-alternatives --install /usr/bin/wsimport wsimport /opt/jdk-10.0.2/bin/wsimport 1 \
  && update-alternatives --install /usr/bin/xjc xjc /opt/jdk-10.0.2/bin/xjc 1

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
  && update-alternatives --install /usr/bin/arachni_console arachni_console /opt/arachni/bin/arachni_console 1 \
  && update-alternatives --install /usr/bin/arachni_web_create_user arachni_web_create_user /opt/arachni/bin/arachni_web_create_user 1 \
  && update-alternatives --install /usr/bin/arachni_web_import arachni_web_import /opt/arachni/bin/arachni_web_import 1 \
  && update-alternatives --install /usr/bin/arachni_rpc arachni_rpc /opt/arachni/bin/arachni_rpc 1 \
  && update-alternatives --install /usr/bin/arachni_restore arachni_restore /opt/arachni/bin/arachni_restore 1 \
  && update-alternatives --install /usr/bin/arachni_web_script arachni_web_script /opt/arachni/bin/arachni_web_script 1 \
  && update-alternatives --install /usr/bin/arachni_web arachni_web /opt/arachni/bin/arachni_web 1 \
  && update-alternatives --install /usr/bin/arachni_web_scan_import arachni_web_scan_import /opt/arachni/bin/arachni_web_scan_import 1 \
  && update-alternatives --install /usr/bin/arachni arachni /opt/arachni/bin/arachni 1 \
  && update-alternatives --install /usr/bin/arachni_rpcd arachni_rpcd /opt/arachni/bin/arachni_rpcd 1 \
  && update-alternatives --install /usr/bin/arachni_rpcd_monitor arachni_rpcd_monitor /opt/arachni/bin/arachni_rpcd_monitor 1 \
  && update-alternatives --install /usr/bin/arachni_rest_server arachni_rest_server /opt/arachni/bin/arachni_rest_server 1 \
  && update-alternatives --install /usr/bin/arachni_reproduce arachni_reproduce /opt/arachni/bin/arachni_reproduce 1 \
  && update-alternatives --install /usr/bin/arachni_script arachni_script /opt/arachni/bin/arachni_script 1 \
  && update-alternatives --install /usr/bin/arachni_web_change_password arachni_web_change_password /opt/arachni/bin/arachni_web_change_password 1 \
  && update-alternatives --install /usr/bin/arachni_multi arachni_multi /opt/arachni/bin/arachni_multi 1 \
  && update-alternatives --install /usr/bin/arachni_shell arachni_shell /opt/arachni/bin/arachni_shell 1 \
  && update-alternatives --install /usr/bin/arachni_reporter arachni_reporter /opt/arachni/bin/arachni_reporter 1 \
  && update-alternatives --install /usr/bin/arachni_web_task arachni_web_task /opt/arachni/bin/arachni_web_task 1

# Masscan
RUN set -x \
  && cd /opt \
  && git clone https://github.com/robertdavidgraham/masscan \
  && cd masscan \
  && make -j4 \
  && update-alternatives --install /usr/bin/masscan masscan /opt/masscan/bin/masscan 1

# Nikto
RUN set -x \
  && cd /opt \
  && git clone https://github.com/sullo/nikto \
  && update-alternatives --install /usr/bin/nikto.pl nikto.pl /opt/nikto/program/nikto.pl 1 \
  && update-alternatives --install /usr/bin/replay.pl replay.pl /opt/nikto/program/replay.pl 1

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
  && update-alternatives --install /usr/bin/w3af_console w3af_console /opt/w3af/w3af_console 1
