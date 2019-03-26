SHELL:=bash
#
# Build docker image for qgis platform
#

NAME=qgis-platform

BUILDID=$(shell date +"%Y%m%d%H%M")
COMMITID=$(shell git rev-parse --short HEAD)

FLAVOR=ltr-2.18
BUILD_ARGS=--build-arg qgis_repository=debian-$(FLAVOR)

ifdef REGISTRY_URL
REGISTRY_PREFIX=$(REGISTRY_URL)/
BUILD_ARGS += --build-arg REGISTRY_PREFIX=$(REGISTRY_PREFIX)
endif

BUILDIMAGE=$(NAME):$(FLAVOR)-$(COMMITID)

MANIFEST=factory.manifest

all:
	@echo "Usage: make [build|archive|deliver|clean]"

build: _build manifest

_build:
	docker build --rm --cache-from=$(NAME):2.18-latest $(BUILD_ARGS) -t $(BUILDIMAGE) -t $(NAME):2.18-latest $(DOCKERFILE) .

manifest:
	docker run --rm -v $$(pwd)/manifest.sh:/manifest -e FLAVOR=$(FLAVOR) \
		-e NAME=$(NAME) -e BUILDID=$(BUILDID) -e COMMITID=$(COMMITID) \
		$(BUILDIMAGE)  /manifest > $(MANIFEST)

deliver: tag push

tag: 
	@@{ \
	set -e; \
	source factory.manifest; \
	docker tag $(BUILDIMAGE) $(REGISTRY_PREFIX)$(NAME):$$version; \
	if [ ! -z $$version_short ]; then \
		docker tag $(BUILDIMAGE) $(REGISTRY_PREFIX)$(NAME):$$version_short; \
	fi; \
	}

push:
	@@{ \
	set -e; \
	source factory.manifest; \
	docker push $(REGISTRY_PREFIX)$(NAME):$$version; \
	if [ ! -z $$version_short ]; then \
		docker push $(REGISTRY_PREFIX)$(NAME):$$version_short; \
	fi \
	}

clean-all:
	docker rmi -f $(shell docker images $(BUILDIMAGE) -q)

clean:
	docker rmi $(BUILDIMAGE)

