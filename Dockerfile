#syntax=docker/dockerfile:1.2

FROM ubuntu:focal-20211006 as upstream
FROM upstream as base

RUN rm -f /etc/apt/apt.conf.d/docker-clean

# Copy GPG Keys
COPY --chown=root:root --chmod=0644 root/usr/share/keyrings/ /usr/share/keyrings/

# Install Base packages common for all ubuntu images
# hadolint ignore=DL3008,DL3009
RUN --mount=type=tmpfs,target=/var/lib/apt \
    --mount=type=cache,sharing=private,target=/var/cache/apt \
    apt-get update \
    && apt-get install --no-install-recommends --yes \
    curl \
    htop \
    ca-certificates
ARG S6_OVERLAY_VERSION="2.2.0.3"

RUN --mount=type=tmpfs,target=/downloads/ \
    ARCH="$(uname -m)" \
    && export ARCH \
    && if [ "$ARCH" = "x86_64" ]; then \
    S6_ARCH="amd64"; \
    elif [ "$ARCH" = "aarch64" ]; then \
    S6_ARCH="aarch64"; \
    elif [ "$ARCH" = "armv7l" ]; then \
    S6_ARCH="armhf"; \
    else \
    exit 1; \
    fi \
    && export S6_ARCH \
    && mkdir -p /downloads \
    && curl -sSfL "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-${S6_ARCH}-installer" -o /downloads/s6-overlay-installer \
    && curl -sSfL "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-${S6_ARCH}-installer.sig" -o /downloads/s6-overlay-installer.sig \
    && gpgv --keyring /usr/share/keyrings/just-containers.gpg /downloads/s6-overlay-installer.sig /downloads/s6-overlay-installer \
    && chmod +x /downloads/s6-overlay-installer \
    && /downloads/s6-overlay-installer /

# Install Packages
# hadolint ignore=DL3008,DL3009
RUN --mount=type=tmpfs,target=/var/lib/apt \
    --mount=type=cache,sharing=private,target=/var/cache/apt \
    apt-get update \
    && apt-get install --no-install-recommends --yes \
    apt-cacher-ng \
    cron \
    logrotate

EXPOSE 3142/tcp

# Tweak apt-cacher-ng config for docker
RUN echo "## DOCKER MOD ##" >> /etc/apt-cacher-ng/acng.conf \
    && echo "PassThroughPattern: .*" >> /etc/apt-cacher-ng/acng.conf \
    && sed -i "s/# ReuseConnections: 1/ReuseConnections: 1/g" /etc/apt-cacher-ng/acng.conf \
    && sed -i "s#size 10M#size 100M#g" /etc/logrotate.d/apt-cacher-ng

COPY --chown=root:root --chmod=0755 root/etc /etc
COPY --chown=root:root --chmod=0755 root/usr/bin /usr/bin

ENTRYPOINT ["/init"]
