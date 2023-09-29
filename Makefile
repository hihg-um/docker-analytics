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

help:
	@echo "Targets: all clean test"
	@echo "         docker clean_docker test_docker release_docker"
	@echo "         apptainer clean_apptainer test_apptainer"
	@echo
	@echo "Docker containers:\n$(DOCKER_IMAGES)"
	@echo
	@echo "Apptainer images:\n$(SIF_IMAGES)"

clean: clean_docker clean_apptainer

test: test_docker test_apptainer

# Docker
clean_docker:
	for f in $(DOCKER_IMAGES); do \
		docker rmi -f $(DOCKER_IMAGE_BASE)/$$f 2>/dev/null; \
	done

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

release: $(DOCKER_IMAGES)
	for f in $(DOCKER_IMAGES); do \
		docker push $(IMAGE_REPOSITORY)/$(DOCKER_IMAGE_BASE)/$$f; \
	done

# Apptainer
clean_apptainer:
	@rm -f $(SIF_IMAGES)

apptainer: $(SIF_IMAGES)

$(SIF_IMAGES):
	echo "Building $@"
	@apptainer build $@ \
		docker-daemon:$(DOCKER_IMAGE_BASE)/$(patsubst %.sif,%,$@)

test_apptainer: $(SIF_IMAGES)
	for f in $(SIF_IMAGES); do \
		echo "Testing Apptainer image: $$f"; \
		apptainer run $$f; \
	done
