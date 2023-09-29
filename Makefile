# SPDX-License-Identifier: GPL-2.0

ORG_NAME := hihg-um
OS_BASE ?= ubuntu
OS_VER ?= 22.04

USER ?= $$(USER)
USERID ?= `id -u`
USERGNAME ?= "adgc"
USERGID ?= 5001

IMAGE_REPOSITORY :=
DOCKER_IMAGE_BASE := $(ORG_NAME)/$(USER)

GIT_REV := $(shell git describe --tags --dirty)
DOCKER_TAG ?= $(GIT_REV)

DOCKER_BUILD_ARGS :=

TOOLS := bcftools plink2 samtools shapeit4 tabix vcftools
SIF_IMAGES := $(TOOLS:=\:$(DOCKER_TAG).sif)
DOCKER_IMAGES := $(TOOLS:=\:$(DOCKER_TAG))

.PHONY: clean docker test $(TOOLS) $(DOCKER_IMAGES)

all: docker apptainer test

test: test_docker test_apptainer

clean: clean_docker clean_apptainer

clean_docker:
	for f in $(DOCKER_IMAGES); do \
		docker rmi -f $(DOCKER_IMAGE_BASE)/$$f 2>/dev/null; \
	done

clean_apptainer:
	@rm -f $(SIF_IMAGES)

docker: $(TOOLS)

$(TOOLS):
	@echo "Building $@"
	@docker build \
		-t $(DOCKER_IMAGE_BASE)/$@:$(DOCKER_TAG) \
		-t $(DOCKER_IMAGE_BASE)/$@:latest \
		$(DOCKER_BUILD_ARGS) \
		--build-arg BASE_IMAGE=$(OS_BASE):$(OS_VER) \
		--build-arg IMAGE_TOOLS="$(TOOLS)" \
		--build-arg USERNAME=$(USER) \
		--build-arg USERID=$(USERID) \
		--build-arg USERGNAME=$(USERGNAME) \
		--build-arg USERGID=$(USERGID) \
		--build-arg RUNCMD="$@" \
		.

test_docker:
	for f in $(DOCKER_IMAGES); do \
		echo "Testing docker image: $(DOCKER_IMAGE_BASE)/$$f"; \
		docker run -t $(DOCKER_IMAGE_BASE)/$$f; \
	done

apptainer: $(SIF_IMAGES)
	make test_apptainer

$(SIF_IMAGES):
	echo "Building $@"
	@apptainer build $@ docker-daemon:$(DOCKER_IMAGE_BASE)/$(patsubst %.sif,%,$@)

test_apptainer: $(SIF_IMAGES)
	for f in $(SIF_IMAGES); do \
		echo "Testing apptainer image: $<"; \
		apptainer run $$f; \
	done

release: $(DOCKER_IMAGES)
	for f in $(DOCKER_IMAGES); do \
		@docker push $(IMAGE_REPOSITORY)/$(DOCKER_IMAGE_BASE)/$$f; \
	done
