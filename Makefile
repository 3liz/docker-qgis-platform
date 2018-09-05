#
# Build docker image for qgis platform
#

NAME=qgis-platform

BUILDID=$(shell date +"%Y%m%d%H%M")
COMMITID=$(shell git rev-parse --short HEAD)

VERSION=3.2
VERSION_SHORT=3

ifeq ($(QGIS_BUILD_TYPE),nightly)
BUILD_ARGS=--build-arg qgis_repository=debian-nigthly-release
VERSION += -nightly
VERSION_SHORT += -nightly
endif

VERSION_TAG=$(VERSION)

ifdef REGISTRY_URL
REGISTRY_PREFIX=$(REGISTRY_URL)/
BUILD_ARGS += --build-arg REGISTRY_PREFIX=$(REGISTRY_PREFIX)
endif

BUILDIMAGE=$(NAME):$(VERSION_TAG)-$(COMMITID)
ARCHIVENAME=$(shell echo $(NAME):$(VERSION_TAG)|tr '[:./]' '_')

MANIFEST=factory.manifest

all:
	@echo "Usage: make [build|archive|deliver|clean]"

manifest:
	echo name=$(NAME) > $(MANIFEST) && \
    echo version=$(VERSION)   >> $(MANIFEST) && \
    echo version_short=$(VERSION_SHORT) >> $(MANIFEST) && \
    echo buildid=$(BUILDID)   >> $(MANIFEST) && \
    echo commitid=$(COMMITID) >> $(MANIFEST) && \
    echo archive=$(ARCHIVENAME) >> $(MANIFEST)

build: manifest
	docker build --rm --force-rm --no-cache $(BUILD_ARGS) -t $(BUILDIMAGE) $(DOCKERFILE) .

test:
	docker run --rm $(BUILDIMAGE) qgis-check-platform --verbose 

archive:
	docker save $(BUILDIMAGE) | bzip2 > $(FACTORY_ARCHIVE_PATH)/$(ARCHIVENAME).bz2

deliver: tag push

tag:
	docker tag $(BUILDIMAGE) $(REGISTRY_PREFIX)$(NAME):latest
	docker tag $(BUILDIMAGE) $(REGISTRY_PREFIX)$(NAME):$(VERSION)
	docker tag $(BUILDIMAGE) $(REGISTRY_PREFIX)$(NAME):$(VERSION_SHORT)

push:
	docker push $(REGISTRY_URL)/$(NAME):latest
	docker push $(REGISTRY_URL)/$(NAME):$(VERSION)
	docker push $(REGISTRY_URL)/$(NAME):$(VERSION_SHORT)

clean:
	docker rmi -f $(shell docker images $(BUILDIMAGE) -q)

