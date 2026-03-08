# alvos declarados
.PHONY: all build sbom attention immutable clean

ifeq ($(OS),Windows_NT)
SHELL := pwsh.exe
SHELLFLAGS := -NoLogo -Command
RM := Remove-Item -ErrorAction SilentlyContinue -Recurse -Force
MKDIR_P := New-Item -ItemType Directory -Force -Path
else
RM := rm -rf
MKDIR_P := mkdir -p
endif

# alvo padrão
all: build

GOOS ?= $(shell go env GOOS)
GOARCH ?= amd64
BINARY_DIR := build/$(GOOS)/bin
BINARY_NAME := app$(if $(filter windows,$(GOOS)),.exe,)

# compilar código Go
build:
	$(MKDIR_P) $(BINARY_DIR)
	GOOS=$(GOOS) GOARCH=$(GOARCH) go build -o $(BINARY_DIR)/$(BINARY_NAME) main.go

# gerar manifestos extras
sbom:
ifeq ($(OS),Windows_NT)
	$(error sbom target is not supported on Windows runners)
else
	./scripts/generate-sbom.sh > sbom-$(GOOS).json
endif

attention:
ifeq ($(OS),Windows_NT)
	$(error attention target is not supported on Windows runners)
else
	./scripts/generate-attention.sh > attention-$(GOOS).json
endif

immutable:
ifeq ($(OS),Windows_NT)
	$(error immutable target is not supported on Windows runners)
else
	./scripts/generate-immutable.sh > immutable-$(GOOS).json
endif

# limpar binários
clean:
	$(RM) build/*/bin/*
	$(RM) sbom-*.json attention-*.json immutable-*.json
