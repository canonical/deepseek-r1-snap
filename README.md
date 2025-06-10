# DeepSeek R1 snap


## Install
```console
sudo snap install deepseek-r1 --channel=<desired channel> --devmode
```

It should be installed in developer mode because it needs [hardware-observe](https://snapcraft.io/docs/hardware-observe-interface) during the installation.
This interface is currently not automatically connected.

To install gpu dependencies, refer [here](#nvidia-cuda-stacks).

To build and install from source, scroll to [here](#build-and-install-from-source).

## Usage
The configurations can be explored and changed using `snap get` and `snap set` respectively.

Query the top level config:
```shell
sudo snap get deepseek-r1
```

Query the available stacks:
```shell
snap get deepseek-r1 stacks
```

Change the stack (only possible if installed from the Store):
```shell
sudo snap set deepseek-r1 stack=<stack>
```

> [!TIP]
> For CUDA-based stacks the number of layers that are loaded on to the GPU can be configured.
> By default all layers are loaded into VRAM, which requires enough VRAM to fit the entire model.
> To only load a limited number of layers onto the GPU use the `n-gpu-layers` snap option:
> ```shell
> sudo snap set deepseek-r1 n-gpu-layers=20
> ```
> This is useful if your GPU does not have enough VRAM to fit the entire model.
> The remaining layers will run on the CPU.
> 
> To reset to the default option, which is to load the entire model onto the GPU, unset the value:
> ```
> sudo snap unset deepseek-r1 n-gpu-layers
> ```

### Chat
Start the chat app. The output varies based on the stack:
```shell
deepseek-r1.chat 
```

### Run server
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

## NVIDIA CUDA stacks

NVIDIA drivers, utils and CUDA are required to use the CUDA-based stacks.

These steps were tested on Ubuntu Server 24.04.1, running on a machine with an NVIDIA RTX A5000.
The version of driver and utils might be different depending on your setup.

```shell
sudo apt update
sudo apt install nvidia-driver-550 nvidia-utils-550 nvidia-cuda-toolkit
sudo reboot
```

## Build and install from source

Clone this repo with the submodule:
```shell
git clone --recurse-submodules https://github.com/canonical/deepseek-r1-snap.git
```

Download the models:
```shell
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

## Intel GPU

The user space drivers are included in the snap, so the snap should work standalone as long as you are running a relatively new kernel (>6.XX).

It has been tested on:
- Intel Battlemage G21 [Arc B580]
- Intel Meteor Lake-P [Intel Arc Graphics]
- Intel Raptor Lake-S UHD Graphics

The API calls using OpenVINO Model Server engine in this snap need to set their model to `DeepSeek-R1-Distill-Qwen-7B-ov-int4`.
For example:
```
curl http://localhost:8080/v3/chat/completions -d \
'{
  "model": "DeepSeek-R1-Distill-Qwen-7B-ov-int4",
  "max_tokens": 30,
  "temperature": 0,
  "stream": false,
  "messages": [
    {
      "role": "system",
      "content": "You are a helpful assistant."
    },
    {
      "role": "user",
      "content": "What are the 3 main tourist attractions in Paris?"
    }
  ]
}'
```

## Intel NPU

```
sudo snap install intel-npu-driver
sudo snap connect deepseek-r1:intel-npu intel-npu-driver # auto connects
sudo snap connect deepseek-r1:npu-libs intel-npu-driver
sudo snap install deepseek-r1+model-distill-qwen-7b-openvino-int4
sudo snap install deepseek-r1+openvino-model-server
```
