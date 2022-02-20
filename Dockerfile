# This is a typical multi-stage docker build.
#
# Stage 1 is known as the base image. This contains packages and
# configuration common to both the builder and release images.
#
# Stage 2 is the release container. This is the only image that is
# retained, and tagged with a name. The release stage also uses
# the base image as starting point, eliminating duplication,
# speeding things up, and maintianing consistency.

# Each RUN command adds another layer to the container.
# After things are working correctly it is best-practice to
# chain commands together using && to factor out layers.

FROM ubuntu:22.04 as base

# user data provided by the host system via the make file
# without these, the container will fail-safe and be unable to write output
ARG USERNAME
ARG USERID
ARG USERGID

# Put the user name and ID into the ENV, so the runtime inherits them
ENV USERNAME=${USERNAME:-nouser} \
	USERID=${USERID:-65533} \
	USERGID=${USERGID:-nogroup}

# match the building user. This will allow output only where the building
# user has write permissions
RUN useradd -m -u $USERID -g $USERGID $USERNAME

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
		r-base r-base-core r-recommended \
		software-properties-common \
		strace tabix wget xz-utils zlib1g

# This creates the actual container we will run
FROM base AS release

# analytics packages
RUN DEBIAN_FRONTEND=noninteractive apt -y install \
	bcftools plink plink2 samtools vcftools

# we map the user owning the image so permissions for input/output will work
USER $USERNAME
