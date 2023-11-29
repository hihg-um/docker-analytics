# SPDX-License-Identifier: GPL-2.0
ARG BASE_IMAGE
FROM $BASE_IMAGE as base

ARG RUN_CMD
ENV RUN_CMD=${RUN_CMD}

# Install OS updates, security fixes and utils, generic app dependencies
RUN apt -y update -qq && apt -y upgrade && \
	DEBIAN_FRONTEND=noninteractive apt -y install \
		ca-certificates curl

FROM base
# analytics package target - we want a new layer here, since different
# dependencies will have to be installed, sharing the common base above
RUN DEBIAN_FRONTEND=noninteractive apt -y install apt-utils $RUN_CMD

# Create an entrypoint for the binary
RUN echo "#!/bin/bash\n$RUN_CMD \$@" > /entrypoint.sh && \
	chmod +x /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]
