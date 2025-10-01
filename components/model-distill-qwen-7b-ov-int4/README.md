# DeepSeek R1 Optimized for Intel CPU and Intel GPU

The model is optimized by Intel and distributed in Intermediate Representation (IR) on Huggingface.

Install Git and Git LFS:
```
sudo apt install git git-lfs
```

Clone:
```
git clone --depth 1 https://huggingface.co/helenai/DeepSeek-R1-Distill-Qwen-7B-ov-int4
git -C DeepSeek-R1-Distill-Qwen-7B-ov-int4 lfs prune --force
```