ARG BASE_IMAGE
FROM $BASE_IMAGE

# SPDX-License-Identifier: GPL-2.0

# List of analytics tools
ARG IMAGE_TOOLS

# user data provided by the host system via the make file
# without these, the container will fail-safe and be unable to write output
ARG USERNAME
ARG USERID
ARG USERGNAME
ARG USERGID

ARG RUNCMD

# Put the user name and ID into the ENV, so the runtime inherits them
ENV USERNAME=${USERNAME:-nouser} \
        USERID=${USERID:-65533} \
        USERGID=${USERGID:-nogroup}

# match the building user. This will allow output only where the building
# user has write permissions
RUN groupadd -g $USERGID $USERGNAME && \
	useradd -m -u $USERID -g $USERGID $USERNAME && \
	adduser $USERNAME $USERGNAME

# Install OS updates, security fixes and utils, generic app dependencies
# htslib is libhts3 in Ubuntu see https://github.com/samtools/htslib/
RUN apt -y update -qq && apt -y upgrade && \
	DEBIAN_FRONTEND=noninteractive apt -y install \
		ca-certificates \
		curl \
		dirmngr \
		ghostscript gnuplot \
		less libfile-pushd-perl libhts3 \
		python3 python3-pip \
		pkg-config \
		software-properties-common \
		strace wget xz-utils zlib1g

# analytics packages
RUN DEBIAN_FRONTEND=noninteractive apt -y install \
	${IMAGE_TOOLS} && ln -s /usr/bin/plink1 /usr/bin/plink


RUN echo "$RUNCMD \$@" > /entrypoint.sh && chmod +x /entrypoint.sh

# we map the user owning the image so permissions for input/output will work
USER $USERNAME

ENTRYPOINT [ "bash", "/entrypoint.sh" ]
