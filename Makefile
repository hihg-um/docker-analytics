ORG_NAME := um
PROJECT_NAME ?= docker-analytics

USER ?= `whoami`
USERID := `id -u`
USERGID := `id -g`

IMAGE_REPOSITORY :=
IMAGE := $(USER)/$(ORG_NAME)/$(PROJECT_NAME):latest

# Use this for debugging builds. Turn off for a more slick build log
DOCKER_BUILD_ARGS := --progress=plain

.PHONY: all build clean test tests

all: docker test

test: docker
	@docker run -t $(IMAGE) R --version > /dev/null

tests: test

clean:
	@docker rmi $(IMAGE)

docker:
	@docker build -t $(IMAGE) \
		--build-arg USERNAME=$(USER) \
		--build-arg USERID=$(USERID) \
		--build-arg USERGID=$(USERGID) \
		$(DOCKER_BUILD_ARGS) \
	  .
	@docker run -it  $(IMAGE) /bin/bash -c exit

release:
	docker push $(IMAGE_REPOSITORY)/$(IMAGE)
