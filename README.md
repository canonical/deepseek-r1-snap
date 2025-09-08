# DeepSeek R1 snap

This snap installs a hardware-optimized runtime for inference with the DeepSeek R1 LLM.

## Supported environment

The software has mainly been tested on Ubuntu 24.04 and newer. 

The snap supports a range of hardware, in many cases with the help of drivers installed on the host. 
For the best experience, make sure the drivers are installed on the host before installing the snap.


### CPUs

| Architecture | Vendor      |
|--------------|-------------|
| amd64        | Intel, AMD  |
| arm64        | Ampere      |


### Accelerators

| Type | Vendor  | ⚠️ Setup instructions         |
|------|---------|---------------------------|
| GPU  | Intel   | [Intel GPU](#intel-gpu)   |
| GPU  | NVIDIA  | [NVIDIA GPU](#nvidia-gpu) |
| NPU  | Intel   | [Intel NPU](#intel-npu)   |

## Install

> [!IMPORTANT]
> Make sure that your environment is set up correctly, as explained [⇑ above ⇑](#supported-environment).

Set the right channel and install the model snap:
```console
sudo snap install deepseek-r1 --channel=<channel>
```

## Use

During the installation, the snap detects the hardware and picks a suitable *stack*.
Each stack consists of an inference **engine** and a **model**. 

The engine is a server application.
It exposes an [OpenAI compatible](https://github.com/openai/openai-openapi) endpoint served over HTTP.
The HTTP server's bind host and port have the following default values:
```console
$ sudo snap get deepseek-r1 http
Key        Value
http.host  127.0.0.1
http.port  8080
```

To change, for example, the HTTP port to `8999`:
```shell
sudo snap set deepseek-r1 http.port=8999
```

Once changed, restart the server:
```
sudo snap restart deepseek-r1
```

For more details on the configuration options, refer [here](configure).

You can query the server logs to debug possible issues:
```shell
sudo snap logs deepseek-r1
```
Try with `-n 100 -f` to query more lines and follow the logs.

### Chat
You can use a range of OpenAI-compatible chat clients to interact with the server. 

The snap ships an application that allows basic prompting from the command line:
```shell
deepseek-r1.chat 
```

### Configure 
The configurations can be explored and changed using `snap get` and `snap set`.
See the examples below.

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
> For CUDA-based stacks, the number of layers that are loaded on to the GPU can be configured.
>
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

### Manage components

This snap uses snap components to deploy optional artifacts. 

You can check the installed components with:
```shell
sudo snap components deepseek-r1
```

To remove a component, use:
```shell
sudo snap remove <snap+component>
```

## NVIDIA GPU

Using an NVIDIA GPU has a few dependencies.

These steps were tested on Ubuntu Server 24.04.1, running on a machine with an NVIDIA RTX A5000.
The version of driver and utils on your machine might be different depending on your setup.

```shell
sudo apt update
sudo apt install nvidia-driver-550 nvidia-utils-550 nvidia-cuda-toolkit
sudo reboot
```

## Intel GPU

The user-space drivers for Intel GPUs (integrated and discrete) are included in the snap. 

Using Lunar Lake or Battlemage GPUs may require a hardware enablement (HWE) kernel; please refer [here](https://dgpu-docs.intel.com/driver/client/overview.html) for details.

The snap has been tested on:
- Intel Battlemage G21 [Arc B580]
- Intel Meteor Lake-P [Intel Arc Graphics]
- Intel Raptor Lake-S UHD Graphics

The Intel stacks make use of OpenVINO Model Server.
It has the OpenAI-compatible API available under the `/v3` base path.
It also requires the `model` field in the API requests to be set to [`DeepSeek-R1-Distill-Qwen-7B-ov-int4`](components/model-distill-qwen-7b-openvino-int4/).

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
To use an Intel NPU, install and connect the driver snap after installing the deepseek-r1 snap:
```shell
sudo snap install intel-npu-driver

# After installing deepseek-r1 snap
sudo snap connect deepseek-r1:npu-libs intel-npu-driver 
```

> [!NOTE]
> The Intel NPU stack also uses OpenVINO Model Server, and therefore using its API has the same considerations as for Intel GPUs described [above](#intel-gpu). 

## Build and install from source

Clone this repo with its submodules:
```shell
git clone --recurse-submodules https://github.com/canonical/deepseek-r1-snap.git
```

Prepare the models that are required from the following list:
- [model-distill-qwen-1-5b-q8-0-gguf](./components/model-distill-qwen-1-5b-q8-0-gguf)
- [model-distill-qwen-7b-q4-k-m-gguf](./components/model-distill-qwen-7b-q4-k-m-gguf)
- [model-distill-llama-70b-q4-k-m-gguf](./components/model-distill-llama-70b-q4-k-m-gguf)
- [model-distill-qwen-7b-openvino-int4](./components/model-distill-qwen-7b-openvino-int4)


Build the snap and its component:
```shell
snapcraft -v
```

Refer to [dev](./dev) explore the additional development tools.
