# Mistral 7B Instruct

Download the model (~14GB):
```shell
wget https://models.mistralcdn.com/mistral-7b-v0-3/mistral-7B-Instruct-v0.3.tar
```

Build the snap and its component:
```shell
snapcraft -v
```

Install snap and then the component: 
```shell
sudo snap install --dangerous --devmode \
    mistral-7b-instruct_v0.3+0.0.1_amd64.snap

sudo snap install --dangerous \
    mistral-7b-instruct+model-mistral-7b-instruct_v0.3.comp
```

Install NVIDIA drivers (Ubuntu 24.04):
```shell
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-keyring_1.1-1_all.deb
sudo dpkg -i cuda-keyring_1.1-1_all.deb
sudo apt-get update
sudo apt-get install cuda-toolkit
sudo reboot
```
Source: https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html#ubuntu

Install snapped mesa libraries snap and connect the content interfaces:
```shell
sudo snap install mesa-2404
sudo snap connect mistral-7b-instruct:graphics-core22 mesa-2404:gpu-2404
```

Use:
```shell
mistral-7b-instruct.prompt mistral-7b-instruct
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
