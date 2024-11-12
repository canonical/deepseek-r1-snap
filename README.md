# Mistral 7B Instruct snap

## Install dependencies (Ubuntu 24.04)

Install CUDA drivers:
```shell
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-keyring_1.1-1_all.deb
sudo dpkg -i cuda-keyring_1.1-1_all.deb
sudo apt update
sudp apt install -y cuda-drivers
sudo reboot
```
Source: [NVIDIA](https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html#ubuntu) and others

Install mesa libraries snap:
```shell
sudo snap install mesa-2404
```

## Build and install

Download the model (~14GB):
```shell
wget https://models.mistralcdn.com/mistral-7b-v0-3/mistral-7B-Instruct-v0.3.tar
```

Build the snap and its component:
```console
$ snapcraft -v
...
Creating snap package...                                                                                                     
Packed: mistral-7b-instruct_v0.3+0.0.1_amd64.snap, mistral-7b-instruct+mistral-inference_1.5.0.comp, mistral-7b-instruct+mistral-7b-instruct-model_v0.3.comp  
```

Install: 
```console
$ ./install.sh
mistral-7b-instruct v0.3+0.0.1 installed
component mistral-inference 1.5.0 for mistral-7b-instruct v0.3+0.0.1 installed
component mistral-7b-instruct-model v0.3 for mistral-7b-instruct v0.3+0.0.1 installed
```

## Usage

```console
$ mistral-7b-instruct.chat 
[2024-11-12 17:13:14.825162] Model directory: /snap/mistral-7b-instruct/components/x7/mistral-7b-instruct-model
[2024-11-12 17:13:14.825178] Loading tokenizer... 
[2024-11-12 17:13:14.841729] Loading model... 
[2024-11-12 17:13:40.727845] Ready!

Prompt > can you code?

Response: 
Yes, I can help with coding questions and problems! I can't write or execute code myself, but I can certainly provide guidance, explanations, and suggestions to help you solve coding problems. I'm familiar with a variety of programming languages, including Python, JavaScript, Java, C++, and more. Let me know what you're working on, and I'll do my best to assist you!

Prompt > 
```

## FAQ
> RuntimeError: Found no NVIDIA driver on your system. Please check that you have an NVIDIA GPU and installed a driver from http://www.nvidia.com/Download/index.aspx

Install NVIDIA drivers.


> RuntimeError: Unexpected error from cudaGetDeviceCount(). Did you run some cuda functions before calling NumCudaDevices() that might have already set an error? Error 304: OS call failed or operation not supported on this OS

Install mesa-2404 snap and connect the interface.

If this happens after re-installing the inference snap, disconnect and re-connect the following interface:
```shell
sudo snap disconnect mistral-7b-instruct:graphics
sudo snap connect mistral-7b-instruct:graphics mesa-2404:gpu-2404
```

> RuntimeError: CUDA unknown error - this may be due to an incorrectly set up environment, e.g. changing env variable CUDA_VISIBLE_DEVICES after program start. Setting the available devices to be zero.

Run `nvidia-smi` to verify the installation.
Try again!
