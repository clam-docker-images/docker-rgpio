# syntax=docker/dockerfile:1.7

ARG BASE_IMAGE=debian:trixie-slim
ARG LG_REPO=Clam-/lg
ARG LG_TAG=202603-off-fix
FROM ${BASE_IMAGE}

ARG LG_REPO
ARG LG_TAG

SHELL ["/bin/sh", "-exc"]

RUN printf '%s\n' \
      "https://github.com/${LG_REPO}/archive/refs/tags/${LG_TAG}.tar.gz" \
      > /tmp/lg-source-url \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
      gcc \
      libc6-dev \
      make \
      procps \
      tar \
 && mkdir -p /tmp/lg-src \
 && curl -fsSL "$(cat /tmp/lg-source-url)" -o /tmp/lg.tar.gz \
 && tar -xzf /tmp/lg.tar.gz -C /tmp/lg-src --strip-components=1 \
 && make -C /tmp/lg-src \
 && make -C /tmp/lg-src install prefix=/usr/local \
 && ldconfig \
 && rgpiod -v \
 && rm -rf /tmp/lg-source-url /tmp/lg.tar.gz /tmp/lg-src \
 && rm -rf /var/lib/apt/lists/*

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

RUN chmod 0755 /usr/local/bin/docker-entrypoint.sh

EXPOSE 8889

ENTRYPOINT ["docker-entrypoint.sh"]
CMD []
