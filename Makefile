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

# 'ltr' is the default'
FLAVOR:=ltr

DISTRO:=debian

ifeq ($(FLAVOR),nightly-release)
BUILD_ARGS=--build-arg qgis_repository=$(DISTRO)-nightly-release
else ifeq ($(FLAVOR),ltr)
BUILD_ARGS=--build-arg qgis_repository=$(DISTRO)-ltr
else ifeq ($(FLAVOR),nightly-ltr)
BUILD_ARGS=--build-arg qgis_repository=$(DISTRO)-nightly-ltr
else ifeq ($(FLAVOR),nightly)
BUILD_ARGS=--build-arg qgis_repository=$(DISTRO)-nightly
else ifeq ($(FLAVOR),release)
BUILD_ARGS=--build-arg qgis_repository=$(DISTRO)
else
BUILD_ARGS=--build-arg qgis_repository=$(DISTRO)-ltr
BUILD_ARGS += --build-arg qgis_version=$(FLAVOR)
endif

ifdef REGISTRY_URL
REGISTRY_PREFIX=$(REGISTRY_URL)/
BUILD_ARGS += --build-arg REGISTRY_PREFIX=$(REGISTRY_PREFIX)
endif

BUILDIMAGE=$(NAME):$(FLAVOR)-$(DISTRO)-$(COMMITID)

TEST_FLAVOR:=$(FLAVOR)-$(DISTRO)-$(COMMITID)

MANIFEST=factory.manifest

ifndef REGISTRY_PREFIX
REGISTRY_TAG_PREFIX:=3liz/
else
REGISTRY_TAG_PREFIX:=$(REGISTRY_PREFIX)
endif

DOCKERFILE=-f Dockerfile.$(DISTRO)

all:
	@echo "Usage: make [build|archive|deliver|clean]"

build: _build manifest

_build:
	docker build --rm $(BUILD_ARGS) \
		-t $(BUILDIMAGE) -t 3liz/$(NAME):$(FLAVOR)-$(DISTRO) $(DOCKERFILE) .

manifest:
	docker run --rm -v $$(pwd)/manifest.sh:/manifest -e FLAVOR=$(FLAVOR) \
		-e NAME=$(NAME) -e BUILDID=$(BUILDID) -e COMMITID=$(COMMITID) \
		$(BUILDIMAGE)  /manifest > $(MANIFEST)

LOCAL_HOME ?= $(shell pwd)

BECOME_USER:=$(shell id -u)

test:
	mkdir -p $(shell pwd)/.local $(LOCAL_HOME)/.cache
	docker run --rm --name qgis-platform-test-$(FLAVOR)-$(COMMITID) -w /src \
		-u $(BECOME_USER) \
		-v $(shell pwd):/src \
		-v $(shell pwd)/.local:/.local \
		-v $(LOCAL_HOME)/.cache:/.cache \
		-e PIP_CACHE_DIR=/.cache \
		-e PYTEST_ADDOPTS="$(PYTEST_ADDOPTS)" \
		-e QGIS_OPTIONS_PATH=/src/tests/qgis \
		-e QGIS_DEBUG=$(QGIS_DEBUG) \
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
	docker tag $(BUILDIMAGE) $(REGISTRY_TAG_PREFIX)$(NAME):$(FLAVOR); \
	docker tag $(BUILDIMAGE) $(REGISTRY_TAG_PREFIX)$(NAME):$$version; \
	if [ ! -z $$version_short ]; then \
		docker tag $(BUILDIMAGE) $(REGISTRY_TAG_PREFIX)$(NAME):$$version_short; \
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
	docker rmi -f $(shell docker images $(BUILDIMAGE) -q)||true

clean:
	docker rmi $(BUILDIMAGE)

