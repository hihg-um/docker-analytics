FROM ubuntu:22.04

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

# analytics packages
RUN DEBIAN_FRONTEND=noninteractive apt -y install \
	bcftools plink plink2 samtools vcftools && ln -s /usr/bin/plink1 /usr/bin/plink

ARG RUNCMD
RUN echo "$RUNCMD \$@" > /entrypoint.sh && chmod +x /entrypoint.sh
ENTRYPOINT [ "bash", "/entrypoint.sh" ]
