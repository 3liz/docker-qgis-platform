SHELL:=bash
#
# Build docker image for qgis platform
#

NAME=qgis-platform

BUILDID=$(shell date +"%Y%m%d%H%M")
COMMITID=$(shell git rev-parse --short HEAD)

# There is 5 flavors of qgis
# see https://www.qgis.org/fr/site/forusers/alldownloads.html
# 
# - release
# - nigthly-release
# - ltr
# - nightly-ltr
# - nightly

# 'release' is the default'
FLAVOR:=release


ifeq ($(FLAVOR),nightly-release)
BUILD_ARGS=--build-arg qgis_repository=debian-nightly-release
else ifeq ($(FLAVOR),ltr)
BUILD_ARGS=--build-arg qgis_repository=debian-ltr
else ifeq ($(FLAVOR),nightly-ltr)
BUILD_ARGS=--build-arg qgis_repository=debian-nightly-ltr
else ifeq ($(FLAVOR),nightly)
BUILD_ARGS=--build-arg qgis_repository=debian-nightly
else ifneq ($(FLAVOR),release)
$(error unsupported FLAVOR)
endif

ifdef REGISTRY_URL
REGISTRY_PREFIX=$(REGISTRY_URL)/
BUILD_ARGS += --build-arg REGISTRY_PREFIX=$(REGISTRY_PREFIX)
endif

BUILDIMAGE=$(NAME):$(FLAVOR)-$(COMMITID)

TEST_FLAVOR:=$(FLAVOR)-$(COMMITID)

MANIFEST=factory.manifest

all:
	@echo "Usage: make [build|archive|deliver|clean]"

build: _build manifest

_build:
	docker build --rm --force-rm --no-cache $(BUILD_ARGS) -t $(BUILDIMAGE) $(DOCKERFILE) .

manifest:
	docker run --rm -v $$(pwd)/manifest.sh:/manifest -e FLAVOR=$(FLAVOR) \
		-e NAME=$(NAME) -e BUILDID=$(BUILDID) -e COMMITID=$(COMMITID) \
		$(BUILDIMAGE)  /manifest > $(MANIFEST)

LOCAL_HOME ?= $(shell pwd)

BECOME_USER:=$(shell id -u)

test:
	mkdir -p $(shell pwd)/.local $(LOCAL_HOME)/.cache
	docker run --rm --name qgis-py-server-test-$(COMMITID) -w /src \
		-u $(BECOME_USER) \
		-v $(shell pwd):/src \
		-v $(shell pwd)/.local:/.local \
		-v $(LOCAL_HOME)/.cache:/.cache \
		-e PIP_CACHE_DIR=/.cache \
		-e PYTEST_ADDOPTS="$(PYTEST_ADDOPTS)" \
		$(NAME):$(TEST_FLAVOR) ./tests/run-tests.sh


deliver: tag push

tag: 
	@@{ \
	set -e; \
	source factory.manifest; \
	if [[ "$$flavor" != "$(FLAVOR)" ]]; then \
		echo "Flavor manifest mismatch"; \
		exit 1; \
	fi; \
	docker tag $(BUILDIMAGE) $(REGISTRY_PREFIX)$(NAME):$(FLAVOR); \
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
	docker push $(REGISTRY_PREFIX)$(NAME):$$flavor; \
	if [ ! -z $$version_short ]; then \
		docker push $(REGISTRY_PREFIX)$(NAME):$$version_short; \
	fi \
	}

clean-all:
	docker rmi -f $(shell docker images $(BUILDIMAGE) -q)

clean:
	docker rmi $(BUILDIMAGE)

