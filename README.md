# DeepSeek R1 snap

## Supported environment

The software has primarily been tested on Ubuntu 24.04 and newer. 

The snap supports various hardware, in many cases with the help of drivers installed on the host. 
For the best experience, make sure the drivers are installed on the host before installing the snap.
Follow the links below to learn about these requirements.

The following hardware is supported:
* CPUs:
  * amd64: Intel or AMD
  * arm64: Ampere
* NPUs:   
  * Intel Core Ultra; refer [here](intel-npu)
* GPUs:
  * Intel integrated or discrete GPUs; refer [here](intel-gpu)
  * Nvidia GPUs for amd64 platforms; refer [here](nvidia-gpu)


## Install
Set the right channel and install the model as a snap:
```console
sudo snap install deepseek-r1 --channel=<channel> --devmode
```

It should be installed in developer mode because it needs [hardware-observe](https://snapcraft.io/docs/hardware-observe-interface) during the installation.
This interface is currently not automatically connected.

To install gpu dependencies, refer [here](#nvidia-cuda-stacks).

To build and install from source, scroll to [here](#build-and-install-from-source).

## Use

Upon installation of the snap, a suitable *stack* comprised of an engine and a model get automatically installed as snap components. 
You can check the installed components with:
```shell
sudo snap components deepseek-r1
```

The engine is a server application, but it is not started by default.
This is to allow on-demand start of the service and use of the computing resources.

The snap includes several configurations, some of which are set based on the detected environment. 
To explore the configurations, use:
```shell
sudo snap get deepseek-r1
```

### Run server
Start the server app (in foreground):
```shell
sudo snap run deepseek-r1.server
```

> [!NOTE]
> Running a llama.cpp-based engine from the root of the home directory may result in a permission denial error.

The server exposes an [OpenAI compatible](https://github.com/openai/openai-openapi) endpoint served via HTTP.
The HTTP server's bind host and port have the following default values:
```console
$ sudo snap get deepseek-r1 http
Key        Value
http.host  127.0.0.1
http.port  8080
```

To change, for example the HTTP port to `8999`:
```shell
sudo snap set deepseek-r1 http.port=8999
```

For more details on the configuration options, refer [here](configure).

Once you are ready with the configurations, re-run the service using the same command. 

To run the server in the background:
```shell
sudo snap start deepseek-r1
```

### Chat
You can use a range of OpenAI-compatible chat clients to interact with the server. 

The snap ships an application that allows basic prompting from the command line:
```shell
deepseek-r1.chat 
```

### Configure 
The configurations can be explored and changed using `snap get` and `snap set`.
See below examples.

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

## NVIDIA GPU

NVIDIA drivers, utils and CUDA are required to use the CUDA-based stacks.

These steps were tested on Ubuntu Server 24.04.1, running on a machine with an NVIDIA RTX A5000.
The version of driver and utils might be different depending on your setup.

```shell
sudo apt update
sudo apt install nvidia-driver-550 nvidia-utils-550 nvidia-cuda-toolkit
sudo reboot
```

## Intel GPU

The user space drivers are included in the snap, so the snap should work standalone as long as you are running a relatively new kernel (>6.XX).
A HWE kernel is required for discrete GPU support on some systems, please refer [here](https://dgpu-docs.intel.com/driver/client/overview.html) for details.

It has been tested on:
- Intel Battlemage G21 [Arc B580]
- Intel Meteor Lake-P [Intel Arc Graphics]
- Intel Raptor Lake-S UHD Graphics

The API calls using OpenVINO Model Server engine in this snap need to set their model to [`DeepSeek-R1-Distill-Qwen-7B-ov-int4`](components/model-distill-qwen-7b-openvino-int4/).

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
