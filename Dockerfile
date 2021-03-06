# Need docker above v17-05.0-ce
ARG REGISTRY_PREFIX=''

FROM  ${REGISTRY_PREFIX}debian:buster-slim
MAINTAINER David Marteau <david.marteau@3liz.com>
LABEL Description="QGIS3 Server Framework" Vendor="3liz.org" Version="20.02.1"

ENV DEBIAN_FRONTEND noninteractive

# Use debian-nightly-release for nightly next release version
ARG qgis_repository=debian

RUN export DEBIAN_FRONTEND=noninteractive \
    && export APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1 \
    && dpkg-divert --local --rename --add /sbin/initctl \
    && apt-get update \
    && apt-get install -y --no-install-recommends apt-transport-https ca-certificates dirmngr gnupg2 \
    && echo "deb https://qgis.org/$qgis_repository buster main" > /etc/apt/sources.list.d/qgis.list \
    && gpg --no-tty --keyserver keyserver.ubuntu.com --recv 51F523511C7028C3 \
    && gpg --no-tty --export --armor 51F523511C7028C3 | apt-key add - \
    && apt-get -y update  \
    && apt-get install -y --no-install-recommends python3-setuptools \
    && python3 -m easy_install pip \
    && apt-get remove -y python3-setuptools \
    && pip3 install setuptools wheel \
    && apt-get install -y --no-install-recommends \
      unzip \
      gosu \
      iputils-ping \
      xvfb \
      libgl1-mesa-dri \
      python3-psutil \
      python3-qgis \
      qgis-providers \
      qgis-server \
    && apt-get clean && rm -rf /var/lib/apt/lists/* && rm -rf /usr/share/man \
    && rm -rf /root/.cache

# Use utf-8 for python 3
ENV LC_ALL="C.UTF-8"

ENV QGIS_DISABLE_MESSAGE_HOOKS=1
ENV QGIS_NO_OVERRIDE_IMPORT=1

# Backport 3.6 processing scripts
# XXX To be removed when ltr switch to 3.6
COPY script-backports /script-backports 
RUN cd /script-backports && ./backport-scripts.sh 

COPY qgis-check-platform /usr/local/bin/

