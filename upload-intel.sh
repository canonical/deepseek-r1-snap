#!/bin/bash -ue

channel=$1

snapcraft upload deepseek-r1_v3_amd64.snap \
    --component openvino-model-server=deepseek-r1+openvino-model-server_2025.1.comp \
    --component model-distill-qwen-7b-gpu-openvino=deepseek-r1+model-distill-qwen-7b-gpu-openvino_v3.comp \
    --component model-distill-qwen-7b-q4-k-m-gguf=deepseek-r1+model-distill-qwen-7b-q4-k-m-gguf_v3.comp \
    --component llamacpp=deepseek-r1+llamacpp_b4595.comp \
    --release="$channel"
