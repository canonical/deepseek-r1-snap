# Mistral 7B Instruct snap

## Install dependencies (Ubuntu 24.04)

Install CUDA drivers:
```shell
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-keyring_1.1-1_all.deb
sudo dpkg -i cuda-keyring_1.1-1_all.deb
sudo apt update
sudo apt install -y cuda-drivers
sudo reboot
```
Source: [NVIDIA](https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html#ubuntu) and others

Install mesa libraries snap:
```shell
sudo snap install mesa-2404
```

## Build and install

Download models:
```shell
mkdir -p models

# ~14GB
wget https://models.mistralcdn.com/mistral-7b-v0-3/mistral-7B-Instruct-v0.3.tar

# ~4GB
wget https://huggingface.co/lmstudio-community/Mistral-7B-Instruct-v0.3-GGUF/resolve/main/Mistral-7B-Instruct-v0.3-Q4_K_M.gguf
```

Build the snap and its component:
```console
$ snapcraft -v
...
Creating snap package...                                                                                                     
Packed: mistral-7b-instruct_v0.3_amd64.snap, mistral-7b-instruct+mistral-inference_1.5.0.comp, mistral-7b-instruct+llamacpp_b4130.comp, mistral-7b-instruct+model_v0.3.comp, mistral-7b-instruct+model-q4-k-m-gguf_v0.3.comp

$ file *.snap *.comp
mistral-7b-instruct_v0.3_amd64.snap:              Squashfs filesystem, little endian, version 4.0, lzo compressed, 2586 bytes, 16 inodes, blocksize: 131072 bytes, created: Wed Nov 20 17:22:22 2024
mistral-7b-instruct+llamacpp_b4130.comp:          Squashfs filesystem, little endian, version 4.0, lzo compressed, 13563724 bytes, 12 inodes, blocksize: 131072 bytes, created: Wed Nov 20 17:23:15 2024
mistral-7b-instruct+mistral-inference_1.5.0.comp: Squashfs filesystem, little endian, version 4.0, lzo compressed, 3499739130 bytes, 24835 inodes, blocksize: 131072 bytes, created: Wed Nov 20 17:23:14 2024
mistral-7b-instruct+model-q4-k-m-gguf_v0.3.comp:  Squashfs filesystem, little endian, version 4.0, lzo compressed, 4367010870 bytes, 4 inodes, blocksize: 131072 bytes, created: Wed Nov 20 17:26:26 2024
mistral-7b-instruct+model_v0.3.comp:              Squashfs filesystem, little endian, version 4.0, lzo compressed, 13582299347 bytes, 6 inodes, blocksize: 131072 bytes, created: Wed Nov 20 17:25:54 2024
```

Install either of: 
```console
$ ./install-fallback-gpu.sh

$ ./install-fallback-cpu.sh
```

## Usage

The output varies based on the stack.

```console
$ mistral-7b-instruct.chat 
> can you code?

Yes, I can help with coding questions and problems! I can't write or execute code myself, but I can certainly provide guidance, explanations, and suggestions to help you solve coding problems. I'm familiar with a variety of programming languages, including Python, JavaScript, Java, C++, and more. Let me know what you're working on, and I'll do my best to assist you!

> 
```

## Upload
Note: This doesn't currently work for two reasons:
- Due to upload limitations. It only works if the overall size is reduced, for example by commenting out the `mistral-inference` and `model` parts in snapcraft.yaml.
- It fails after the upload with the following message: `Issues while processing snap: Snap is not allowed to use components`

```console
snapcraft upload mistral-7b-instruct_v0.3_amd64.snap \
    --component mistral-inference=mistral-7b-instruct+mistral-inference_1.5.0.comp \
    --component llamacpp=mistral-7b-instruct+llamacpp_b4130.comp \
    --component model=mistral-7b-instruct+model_v0.3.comp \
    --component model-q4-k-m-gguf=mistral-7b-instruct+model-q4-k-m-gguf_v0.3.comp
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
