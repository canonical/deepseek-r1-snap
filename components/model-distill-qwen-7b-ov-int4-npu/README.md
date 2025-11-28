# DeepSeek R1 Optimized for Intel NPU

The model is optimized for Intel hardware and distributed in Intermediate Representation (IR) on Huggingface.

Install Git and Git LFS:
```
sudo apt install git git-lfs
```

Clone:
```
git clone --depth 1 https://huggingface.co/llmware/DeepSeek-R1-Distill-Qwen-7B-ov-int4-npu
git -C DeepSeek-R1-Distill-Qwen-7B-ov-int4-npu lfs prune --force
```
