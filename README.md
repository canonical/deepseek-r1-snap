# DeepSeek R1 snap

## Get the code

Clone this repo with the submodule:
```
git clone --recurse-submodules https://github.com/canonical/deepseek-r1-snap.git
```

## Build and install from source

Download the models:
```
wget -P components/model-distill-qwen-1-5b-q8-0-gguf \
    https://huggingface.co/unsloth/DeepSeek-R1-Distill-Qwen-1.5B-GGUF/resolve/main/DeepSeek-R1-Distill-Qwen-1.5B-Q8_0.gguf
wget -P components/model-distill-qwen-7b-q4-k-m-gguf \
    https://huggingface.co/bartowski/DeepSeek-R1-Distill-Qwen-7B-GGUF/resolve/main/DeepSeek-R1-Distill-Qwen-7B-Q4_K_M.gguf
```

Build the snap and its component:
```shell
snapcraft -v
```

Install: 
```console
$ ./install-local-build.sh <stack> [op]
```

## NVIDIA CUDA stacks

NVIDIA drivers, utils and CUDA is required to use the CUDA-based stacks.

These steps were tested on Ubuntu Server 24.04.1, running on a machine with an NVIDIA RTX A5000.
The version of driver and utils might be different depending on your setup.

```
sudo apt update
sudo apt install nvidia-driver-550 nvidia-utils-550 nvidia-cuda-toolkit
sudo reboot
```

For CUDA-based stacks the number of layers that are loaded on to the GPU can be configured.
By default all layers are loaded into VRAM, which requires enough VRAM to fit the entire model.

To only load a limited number of layers onto the GPU, the `n-gpu-layers` snap option can be set.

```
sudo snap set deepseek-r1 n-gpu-layers=20
```
This is useful if your GPU does not have enough VRAM to fit the entire model.
The remaining layers will run on the CPU.

To reset to the default option, which is to load the entire model onto the GPU, this snap option can be cleared:

```
sudo snap unset deepseek-r1 n-gpu-layers
```

## Usage
Check the configurations:
```shell
sudo snap get deepseek-r1
```

Change the stack (only possible if installed from the Store):
```shell
sudo snap set deepseek-r1 stack=<stack>
```

```shell
deepseek-r1.chat 
```

Start the server app (in foreground):
```shell
sudo snap run deepseek-r1.server
```
Note that does fail with a permission denial work if ran from the root of the home directory.

The server exposes an [OpenAI compatible](https://github.com/openai/openai-openapi) endpoint served via HTTP.
The HTTP server's bind host and port have the following default values:
```console
$ sudo snap get deepseek-r1 http
Key        Value
http.host  127.0.0.1
http.port  8080
```

To change, for example the http port to `8999`:
```shell
sudo snap set deepseek-r1 http.port=8999
```

Once you are ready with the configurations, run the server in the background:
```shell
sudo snap start deepseek-r1
```
