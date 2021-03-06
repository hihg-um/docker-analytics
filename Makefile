# SPDX-License-Identifier: GPL-2.0

ORG_NAME := hihg-um
PROJECT_NAME ?= docker-analytics
OS_BASE ?= ubuntu
OS_VER ?= 22.04

USER ?= `whoami`
USERID := `id -u`
USERGID := `id -g`

IMAGE_REPOSITORY :=
IMAGE := $(USER)/$(PROJECT_NAME):latest
# Use this for debugging builds. Turn off for a more slick build log
DOCKER_BUILD_ARGS := --progress=plain

TOOLS = bcftools plink plink2 samtools tabix vcftools
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
	@docker build -t $(ORG_NAME)/$(USER)/$@ \
		$(DOCKER_BUILD_ARGS) \
		--build-arg BASE_IMAGE=$(OS_BASE):$(OS_VER) \
		--build-arg IMAGE_TOOLS="$(TOOLS)" \
		--build-arg USERNAME=$(USER) \
		--build-arg USERID=$(USERID) \
		--build-arg USERGID=$(USERGID) \
		--build-arg RUNCMD="$@" \
		.

release:
	docker push $(IMAGE_REPOSITORY)/$(IMAGE)
