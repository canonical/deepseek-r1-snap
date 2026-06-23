#!/bin/bash


# DeepSeek R1 Distill Qwen 1.5B Q8_0 GGUF
wget -nv https://huggingface.co/unsloth/DeepSeek-R1-Distill-Qwen-1.5B-GGUF/resolve/main/DeepSeek-R1-Distill-Qwen-1.5B-Q8_0.gguf \
    --directory-prefix=components/model-distill-qwen-1-5b-q8-0-gguf/

# DeepSeek R1 Distill Qwen 7B Q4_K_M GGUF
wget -nv https://huggingface.co/bartowski/DeepSeek-R1-Distill-Qwen-7B-GGUF/resolve/main/DeepSeek-R1-Distill-Qwen-7B-Q4_K_M.gguf \
    --directory-prefix=components/model-distill-qwen-7b-q4-k-m-gguf/

# OpenVINO DeepSeek R1 Distill Qwen 7B INT4 (Intel CPU/GPU)
git clone --depth 1 https://huggingface.co/llmware/DeepSeek-R1-Distill-Qwen-7B-ov-int4 \
    components/model-distill-qwen-7b-ov-int4/DeepSeek-R1-Distill-Qwen-7B-ov-int4
ln -sf /tmp/graph.pbtxt components/model-distill-qwen-7b-ov-int4/DeepSeek-R1-Distill-Qwen-7B-ov-int4/graph.pbtxt

# OpenVINO DeepSeek R1 Distill Qwen 7B INT4 (Intel NPU)
git clone --depth 1 https://huggingface.co/llmware/DeepSeek-R1-Distill-Qwen-7B-ov-int4-npu \
    components/model-distill-qwen-7b-ov-int4-npu/DeepSeek-R1-Distill-Qwen-7B-ov-int4-npu
ln -sf /tmp/graph.pbtxt components/model-distill-qwen-7b-ov-int4-npu/DeepSeek-R1-Distill-Qwen-7B-ov-int4-npu/graph.pbtxt
