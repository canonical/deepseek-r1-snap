SHELL := /bin/bash

# Always run `hf` via pipx to avoid relying on local `hf` installations.
hf := pipx run --spec "huggingface_hub[cli]" hf

SNAP_NAME ?= deepseek-r1
ENGINE ?= cpu

.PHONY: all help init init-submodules install-deps download-models \
	download-model-distill-qwen-1-5b download-model-distill-qwen-7b \
	download-model-distill-qwen-7b-ov download-model-distill-qwen-7b-ov-npu \
	build install upload smoke-test

all: help

#
# Main targets
#

help: ## Show this help message
	@echo "Usage: make <target>"
	@echo
	@echo "Targets:"
	@# List all targets with descriptions (lines starting with '##'):
	@grep -E '^[a-zA-Z0-9_-]+:.*## .*$$' $(MAKEFILE_LIST) | \
		sort | \
		awk 'BEGIN {FS = ":.*## "}; {printf "  %-11s %s\n", $$1, $$2}'

init: init-submodules install-deps download-models ## Initialize the build environment (dependencies, model weights, submodules, etc.)

build: ## Build the snap
	./dev/build.sh

install: ## Install the snap
	./dev/install.sh

upload: ## Upload the snap
	./dev/upload.sh

smoke-test: ## Run smoke tests (override with SNAP_NAME=... ENGINE=...)
	sudo ./dev/smoke-test.sh $(SNAP_NAME) $(ENGINE)

#
# Supporting targets
#

install-deps:
	@echo "Installing dependencies..."
	@# Ensure pipx is available for running the hf CLI.
	@command -v pipx >/dev/null 2>&1 || { \
		sudo apt-get update; \
		sudo apt-get install -y pipx; \
	}

init-submodules:
	@echo "Initializing submodules..."
	@if git submodule status | grep -q '^-'; then \
		git submodule update --init; \
	fi

download-models: download-model-distill-qwen-1-5b download-model-distill-qwen-7b download-model-distill-qwen-7b-ov download-model-distill-qwen-7b-ov-npu

download-model-distill-qwen-1-5b:
	@echo "Downloading DeepSeek R1 Distill Qwen 1.5B model weights..."
	$(hf) download unsloth/DeepSeek-R1-Distill-Qwen-1.5B-GGUF \
		DeepSeek-R1-Distill-Qwen-1.5B-Q8_0.gguf \
		--local-dir components/model-distill-qwen-1-5b-q8-0-gguf/

download-model-distill-qwen-7b:
	@echo "Downloading DeepSeek R1 Distill Qwen 7B model weights..."
	$(hf) download bartowski/DeepSeek-R1-Distill-Qwen-7B-GGUF \
		DeepSeek-R1-Distill-Qwen-7B-Q4_K_M.gguf \
		--local-dir components/model-distill-qwen-7b-q4-k-m-gguf/

download-model-distill-qwen-7b-ov:
	@echo "Downloading DeepSeek R1 Distill Qwen 7B OpenVINO (Intel CPU/GPU) model weights..."
	$(hf) download llmware/DeepSeek-R1-Distill-Qwen-7B-ov-int4 \
		--local-dir components/model-distill-qwen-7b-ov-int4/DeepSeek-R1-Distill-Qwen-7B-ov-int4

download-model-distill-qwen-7b-ov-npu:
	@echo "Downloading DeepSeek R1 Distill Qwen 7B OpenVINO (Intel NPU) model weights..."
	$(hf) download llmware/DeepSeek-R1-Distill-Qwen-7B-ov-int4-npu \
		--local-dir components/model-distill-qwen-7b-ov-int4-npu/DeepSeek-R1-Distill-Qwen-7B-ov-int4-npu
