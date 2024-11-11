# Mistral 7B Instruct snap

Download the model (~14GB):
```shell
wget https://models.mistralcdn.com/mistral-7b-v0-3/mistral-7B-Instruct-v0.3.tar
```

Build the snap and its component:
```shell
snapcraft -v
```

Install snap and its components: 
```shell
./install.sh
```

Install NVIDIA drivers (Ubuntu 24.04):
```shell
sudo apt install nvidia-driver-565
```

Install CUDA Toolkit:
```shell
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-keyring_1.1-1_all.deb
sudo dpkg -i cuda-keyring_1.1-1_all.deb
sudo apt-get update
sudo apt-get install -y cuda-toolkit
sudo reboot
```
Source: https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html#ubuntu

Install snapped mesa libraries snap and connect the content interfaces:
```shell
sudo snap install mesa-2404
sudo snap connect mistral-7b-instruct:graphics mesa-2404:gpu-2404
```

Use:
```shell
$ mistral-7b-instruct.chat
Model directory: /snap/mistral-7b-instruct/components/x1/model-mistral-7b-instruct
[2024-11-11 16:41:43.555718] Loading tokenizer... 
[2024-11-11 16:41:43.572029] Tokenizer loaded. 
[2024-11-11 16:41:43.572044] Loading model... 
[2024-11-11 16:42:09.274762] Model loaded. 
chat >> can you code?
As a text-based AI model, I don't have the ability to directly execute code. However, I can certainly help explain code, write code snippets, and assist with coding questions to the best of my ability! If you have any specific programming questions or need help with a coding problem, feel free to ask!
```

## FAQ
```
RuntimeError: Found no NVIDIA driver on your system. Please check that you have an NVIDIA GPU and installed a driver from http://www.nvidia.com/Download/index.aspx
```
Install NVIDIA drivers.


```
RuntimeError: Unexpected error from cudaGetDeviceCount(). Did you run some cuda functions before calling NumCudaDevices() that might have already set an error? Error 304: OS call failed or operation not supported on this OS
```
Install mesa-2404 snap and connect the interface.
