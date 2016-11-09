#
# Base Webdriver Dockerfile
#

FROM debian:jessie

MAINTAINER Sebastian Tschan <mail@blueimp.net>

# Install the base requirements to run and debug webdriver implementations:
RUN export DEBIAN_FRONTEND=noninteractive \
  && apt-get update \
  && apt-get dist-upgrade -y \
  && apt-get install --no-install-recommends --no-install-suggests -y \
    xvfb \
    x11-utils \
    ca-certificates \
    x11vnc \
    fluxbox \
    xvt \
    curl \
  # Remove obsolete files:
  && apt-get clean \
  && rm -rf \
    /tmp/* \
    /usr/share/doc/* \
    /var/cache/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

# Add tini, a tiny but valid init system for containers:
RUN export TINI_VERSION=v0.10.0 && curl -sL \
  https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini \
  > /sbin/tini && chmod +x /sbin/tini \
  && curl -sL \
  https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini.asc \
  > /sbin/tini.asc \
  && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys \
    595E85A6B1B4779EA4DAAEC70B588DFF0527A9B7 \
  && gpg --verify /sbin/tini.asc \
  && rm -rf /root/.gnupg \
  && rm /sbin/tini.asc

# Avoid error messages on Xvfb startup despite using the -nolisten tcp option:
RUN mkdir /tmp/.X11-unix && chmod 1777 /tmp/.X11-unix

# Add webdriver user+group as a workaround for
# https://github.com/boot2docker/boot2docker/issues/581
RUN useradd -u 1000 -m -U webdriver

WORKDIR /home/webdriver

COPY entrypoint.sh /usr/local/bin/entrypoint

# Configure Xvfb via environment variables:
ENV SCREEN_WIDTH 1360
ENV SCREEN_HEIGHT 1020
ENV SCREEN_DEPTH 24
ENV DISPLAY :99.0

ENTRYPOINT ["tini", "-g", "--", "entrypoint"]

# Expose the default webdriver port:
EXPOSE 4444