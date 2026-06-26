#!/bin/bash

set -e

# Setup Hugging Face CLI
sudo apt-get install -y python3-venv
python3 -m venv .venv
source .venv/bin/activate
pip install --upgrade pip
pip install --upgrade huggingface_hub

# DeepSeek R1 Distill Qwen 1.5B Q8_0 GGUF
hf download unsloth/DeepSeek-R1-Distill-Qwen-1.5B-GGUF \
    DeepSeek-R1-Distill-Qwen-1.5B-Q8_0.gguf \
    --local-dir components/model-distill-qwen-1-5b-q8-0-gguf/

# DeepSeek R1 Distill Qwen 7B Q4_K_M GGUF
hf download bartowski/DeepSeek-R1-Distill-Qwen-7B-GGUF \
    DeepSeek-R1-Distill-Qwen-7B-Q4_K_M.gguf \
    --local-dir components/model-distill-qwen-7b-q4-k-m-gguf/

# OpenVINO DeepSeek R1 Distill Qwen 7B INT4 (Intel CPU/GPU)
hf download llmware/DeepSeek-R1-Distill-Qwen-7B-ov-int4 \
    --local-dir components/model-distill-qwen-7b-ov-int4/DeepSeek-R1-Distill-Qwen-7B-ov-int4
# Make symlink for mediapipe graph to make it writable by OVMS when moved to a snap component
ln -sf /tmp/graph.pbtxt components/model-distill-qwen-7b-ov-int4/DeepSeek-R1-Distill-Qwen-7B-ov-int4/graph.pbtxt

# OpenVINO DeepSeek R1 Distill Qwen 7B INT4 (Intel NPU)
hf download llmware/DeepSeek-R1-Distill-Qwen-7B-ov-int4-npu \
    --local-dir components/model-distill-qwen-7b-ov-int4-npu/DeepSeek-R1-Distill-Qwen-7B-ov-int4-npu
# Make symlink for mediapipe graph to make it writable by OVMS when moved to a snap component
ln -sf /tmp/graph.pbtxt components/model-distill-qwen-7b-ov-int4-npu/DeepSeek-R1-Distill-Qwen-7B-ov-int4-npu/graph.pbtxt

echo "All models downloaded successfully!"
