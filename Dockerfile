# SPDX-License-Identifier: GPL-3.0
ARG BASE
FROM $BASE

# build-args
ARG BASE
ARG BUILD_TIME
ARG DOCKER_ARCH
ARG GIT_TAG
ARG GIT_REV

LABEL org.opencontainers.image.authors="kms309@miami.edu,sxd1425@miami.edu"
LABEL org.opencontainers.image.base.digest=""
LABEL org.opencontainers.image.base.name="$BASE"
LABEL org.opencontainers.image.description="Base Image"
LABEL org.opencontainers.image.created="$BUILD_TIME"
LABEL org.opencontainers.image.url="ghcr.io/hihg-um/${RUN_CMD}:${GIT_TAG}-${GIT_REV}_${DOCKER_ARCH}"
LABEL org.opencontainers.image.source="https://github.com/hihg-um/docker-analytics"
LABEL org.opencontainers.image.version="$GIT_TAG"
LABEL org.opencontainers.image.revision="$GIT_REV"
LABEL org.opencontainers.image.vendor="The Hussman Institute for Human Genomics, The University of Miami Miller School of Medicine"
LABEL org.opencontainers.image.licenses="GPL-3.0"
LABEL org.opencontainers.image.title="Genomics Analysis Tools"

# Install OS updates, security fixes and utils, generic app dependencies
RUN apt -y update -qq && apt -y upgrade && \
	DEBIAN_FRONTEND=noninteractive apt -y install \
	--no-install-recommends --no-install-suggests \
	apt-utils ca-certificates curl
