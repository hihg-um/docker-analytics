ORG_NAME := hihg-um
PROJECT_NAME ?= docker-analytics

IMAGE_REPOSITORY :=
IMAGE := $(PROJECT_NAME):latest
# Use this for debugging builds. Turn off for a more slick build log
DOCKER_BUILD_ARGS := --progress=plain

TOOLS = bcftools plink plink2 samtools vcftools
.PHONY: all build clean docker test tests $(TOOLS)

all: docker

test: $(TOOLS)

        ifeq ($@,'plink')
		@docker run -it $(ORG_NAME)/$@ --noweb --version
        else
		@docker run -it $(ORG_NAME)/$@ --version
        endif

clean:
	@docker rmi $(IMAGE)

docker: $(TOOLS)

$(TOOLS):
	@docker build -t $(ORG_NAME)/$@ \
		$(DOCKER_BUILD_ARGS) \
		--build-arg RUNCMD="$@" \
		.

release:
	docker push $(IMAGE_REPOSITORY)/$(IMAGE)
