# SPDX-License-Identifier: GPL-2.0

ORG_NAME := hihg-um
OS_BASE ?= ubuntu
OS_VER ?= 22.04

USER ?= $$(USER)
USERID ?= `id -u`
USERGNAME ?= "adgc"
USERGID ?= 5000

IMAGE_REPOSITORY :=
DOCKER_IMAGE_BASE := $(ORG_NAME)/$(USER)
DOCKER_TAG := latest

# Use this for debugging builds. Turn off for a more slick build log
DOCKER_BUILD_ARGS := --progress=plain

TOOLS := bcftools plink plink2 samtools tabix vcftools
SIF_IMAGES := $(TOOLS:=\:$(DOCKER_TAG).svf)
DOCKER_IMAGES := $(TOOLS:=\:$(DOCKER_TAG))

.PHONY: clean docker test $(TOOLS)

all:
	@echo $(SIF_IMAGES) $(DOCKER_IMAGES)

test: test_docker test_singularity

clean:
	@docker rmi $(DOCKER_IMAGES)
	@rm -f $(SVF_IMAGES)

docker: $(TOOLS)

$(TOOLS):
	@docker build -t $(DOCKER_IMAGE_BASE)/$@:$(DOCKER_TAG) \
		$(DOCKER_BUILD_ARGS) \
		--build-arg BASE_IMAGE=$(OS_BASE):$(OS_VER) \
		--build-arg IMAGE_TOOLS="$(TOOLS)" \
		--build-arg USERNAME=$(USER) \
		--build-arg USERID=$(USERID) \
		--build-arg USERGNAME=$(USERGNAME) \
		--build-arg USERGID=$(USERGID) \
		--build-arg RUNCMD="$@" \
		.

docker_test: $(DOCKER_IMAGES)
	@echo "Testing docker image: $(ORG_NAME)/$@"
	ifeq ($@,'plink')
		@docker run -it -v /mnt:/mnt $(ORG_NAME)/$@ --noweb --version
	else
		@docker run -it -v /mnt:/mnt $(ORG_NAME)/$@ --version
	endif

singularity: singularity_test

$(SIF_IMAGES): $(TOOLS)
	@singularity build $@ docker-daemon:$(DOCKER_IMAGE_BASE)/$(@:=

singularity_test: $(SIF_IMAGES)
	@echo "Testing singularity image: $@"
	@singularity run $(ORG_NAME)/$@ -v

release: $(DOCKER_IMAGES)
	@docker push $(IMAGE_REPOSITORY)/$(ORG_NAME)/$(USER)/$@
