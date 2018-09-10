# Need docker above v17-05.0-ce
ARG REGISTRY_PREFIX=''

FROM  ${REGISTRY_PREFIX}debian:stretch
MAINTAINER David Marteau <david.marteau@3liz.com>
LABEL Description="QGIS3 Server Framework" Vendor="3liz.org" Version="3.2"

ENV DEBIAN_FRONTEND noninteractive

# Use debian-nightly-release for nightly next release version
ARG qgis_repository=debian

RUN export DEBIAN_FRONTEND=noninteractive \
    && export APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1 \
    && dpkg-divert --local --rename --add /sbin/initctl \
    && apt-get update \
    && apt-get install -y --no-install-recommends apt-transport-https ca-certificates dirmngr gnupg2 curl \
    && echo "deb https://qgis.org/$qgis_repository stretch main" > /etc/apt/sources.list.d/qgis.list \
    && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys CAEB3DC3BDF7FB45 \
    && apt-get update \
    && apt-get install -y --no-install-recommends python3-setuptools \
    && easy_install3 pip \
    && apt-get remove -y python3-setuptools \
    && pip3 install setuptools wheel \
    && apt-get install -y --no-install-recommends \
      unzip \
      gosu \
      xvfb \
      qgis-server \
      python-qgis \ 
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Use utf-8 for python 3
ENV LC_ALL="C.UTF-8"

ENV QGIS_DISABLE_MESSAGE_HOOKS=1
ENV QGIS_NO_OVERRIDE_IMPORT=1

COPY qgis-check-platform /usr/local/bin/

