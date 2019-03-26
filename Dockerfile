# Need docker above v17-05.0-ce
ARG REGISTRY_PREFIX=''

FROM  ${REGISTRY_PREFIX}debian:stretch
MAINTAINER David Marteau <david.marteau@3liz.com>
LABEL Description="QGIS2 Server Framework" Vendor="3liz.org"

ENV DEBIAN_FRONTEND noninteractive

# Use debian-nightly-release for nightly next release version
ARG qgis_repository=debian
ARG QGIS_UID=10001

RUN export DEBIAN_FRONTEND=noninteractive \
    && export APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1 \
    && dpkg-divert --local --rename --add /sbin/initctl \
    && apt-get update \
    && apt-get install -y --no-install-recommends apt-transport-https ca-certificates dirmngr gnupg2 \
    && echo "deb https://qgis.org/$qgis_repository stretch main" > /etc/apt/sources.list.d/qgis.list \
    && gpg --no-tty --keyserver keyserver.ubuntu.com --recv CAEB3DC3BDF7FB45 \
    && gpg --no-tty --export --armor CAEB3DC3BDF7FB45 | apt-key add - \
    && apt-get -y update \
    && apt-get install -y --no-install-recommends \
      unzip \
      gosu \
      xvfb \
      qgis-server \
      python-qgis \
      supervisor \
    && apt-get clean && rm -rf /var/lib/apt/lists/* && rm -rf /usr/share/man

# Use utf-8 for python 3
ENV LC_ALL="C.UTF-8"

ENV QGIS_DISABLE_MESSAGE_HOOKS=1
ENV QGIS_NO_OVERRIDE_IMPORT=1

RUN useradd --uid=${QGIS_UID} --no-create-home qgis

COPY run-qgis-server /usr/local/bin/

# Supervisor config
COPY supervisor/ /etc/supervisor/

EXPOSE 7000/tcp

