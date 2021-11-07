SHELL := /bin/bash
export REPO_ROOT := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

# GitHub
GITHUB_OWNER := tprasadtp
GITHUB_REPO  := apt-cacher-ng-docker

# Define image names
DOCKER_IMAGES     := ghcr.io/$(GITHUB_OWNER)/apt-cacher-ng
DOCKER_IMAGE_URL  := ghcr.io/$(GITHUB_OWNER)/apt-cacher-ng
DOCKER_BUILDKIT   := 1
DOCKER_VULN_TYPES := os

# OCI Metadata
PROJECT_TITLE    := APT Caching Proxy
PROJECT_DESC     := apt-cacher-ng in a docker container
PROJECT_URL      := https://ghcr.io/tprasadtp/apt-cacher-ng
PROJECT_SOURCE   := https://github.com/tprasadtp/apt-cacher-ng-docker
PROJECT_LICENSE  := GPLv3


# Include makefiles
include $(REPO_ROOT)/makefiles/help.mk
include $(REPO_ROOT)/makefiles/docker.mk

# Inject Version into image
DOCKER_EXTRA_ARGS := --build-arg VERSION=$(VERSION_ID)

# go releaser
.PHONY: snapshot
snapshot: ## Build snapshot
	goreleaser release --rm-dist --snapshot

.PHONY: release
release: ## Build release
	goreleaser release --rm-dist --skip-publish

.PHONY: release-prod
release-prod: ## Build and release to production/QA
	goreleaser release --rm-dist

.PHONY: clean
clean: ## clean
	rm -rf build/
	rm -rf dist/

# Enforce BUILDKIT
ifneq ($(DOCKER_BUILDKIT),1)
# DO NOT INDENT!
$(error ✖ DOCKER_BUILDKIT!=1. Docker Buildkit cannot be disabled on this repo!)
endif
