# SPDX-License-Identifier: GPL-3.0
ARG BASE
FROM $BASE

# build-args
ARG BASE
ARG GIT_REPO
ARG GIT_TAG
ARG GIT_REV
ARG BUILD_REPO

# Install OS updates, security fixes and utils, generic app dependencies
RUN apt -y update -qq && apt -y upgrade && \
	DEBIAN_FRONTEND=noninteractive apt -y install \
	--no-install-recommends --no-install-suggests \
	ca-certificates

LABEL org.opencontainers.image.authors="kms309@miami.edu,sxd1425@miami.edu"
LABEL org.opencontainers.image.base.digest=""
LABEL org.opencontainers.image.base.name="$BASE"
LABEL org.opencontainers.image.description="HIHG Base Image: Analytics"
LABEL org.opencontainers.image.licenses="GPL-3.0"
LABEL org.opencontainers.image.ref.name="Ubuntu Genomics Packages"
LABEL org.opencontainers.image.revision="${GIT_REV}"
LABEL org.opencontainers.image.source="https://${GIT_REPO}"
LABEL org.opencontainers.image.title="Genomics Analysis Tools"
LABEL org.opencontainers.image.url="${BUILD_REPO}"
LABEL org.opencontainers.image.vendor="The Hussman Institute for Human Genomics, The University of Miami Miller School of Medicine"
LABEL org.opencontainers.image.version="${GIT_TAG}"
