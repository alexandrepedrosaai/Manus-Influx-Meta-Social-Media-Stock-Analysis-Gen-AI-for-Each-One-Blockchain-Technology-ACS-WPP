# Declared targets
.PHONY: all build sbom attention immutable clean

# Default target
all: build

GOOS ?= $(shell go env GOOS)
GOARCH ?= amd64
BINARY_DIR := build/$(GOOS)/bin
BINARY_NAME := app$(if $(filter windows,$(GOOS)),.exe,)

# Build Go binary
build:
	mkdir -p $(BINARY_DIR)
	GOOS=$(GOOS) GOARCH=$(GOARCH) go build -o $(BINARY_DIR)/$(BINARY_NAME) main.go

# Generate manifests
sbom:
	bash ./scripts/generate-sbom.sh > sbom-$(GOOS).json

attention:
	bash ./scripts/generate-attention.sh > attention-$(GOOS).json

immutable:
	bash ./scripts/generate-immutable.sh > immutable-$(GOOS).json

# Clean build artifacts
clean:
	rm -rf build/*/bin/*
	rm -f sbom-*.json attention-*.json immutable-*.json
