# DeepSeek R1 inference snap
[![deepseek-r1](https://snapcraft.io/deepseek-r1/badge.svg)](https://snapcraft.io/deepseek-r1)

DeepSeek R1 is a reasoning language model from [DeepSeek](https://github.com/deepseek-ai/DeepSeek-R1).

Use this snap to quickly install an optimized environment for local inference with DeepSeek R1.

The snap includes the following hardware-optimized inference engines:

* cpu: Optimized for various CPUs, for a wide range of amd64 and arm64 architecture variants
* nvidia-gpu: CUDA-optimized for NVIDIA GPUs
* intel-cpu: Optimized for Intel CPUs using OpenVINO Model Server
* intel-gpu: Optimized for Intel GPUs using OpenVINO Model Server
* intel-npu: Optimized for Intel NPUs (Core Ultra series) using OpenVINO Model Server
* ampere-altra: Optimized for Ampere Altra CPUs using llama-aio
* ampere-one: Optimized for Ampere One CPUs using llama-aio

The most suitable engine is automatically selected based on the available hardware.

#### Install
```shell
sudo snap install deepseek-r1
```

#### Run
```shell
deepseek-r1
```

> [!TIP]
> Some accelerators require extra [drivers](https://documentation.ubuntu.com/inference-snaps/how-to/setup/drivers/) to be usable with this snap.

## Resources

📚 **[Documentation](https://documentation.ubuntu.com/inference-snaps/)**, learn how to use inference snaps

💬 **[Discussions](https://github.com/canonical/inference-snaps/discussions)**, ask questions and share ideas

🐛 **[Issues](https://github.com/canonical/inference-snaps/issues)**, report bugs and request features

## Build and install from source

Clone this repo with its submodules:
```shell
git clone --recurse-submodules https://github.com/canonical/deepseek-r1-snap.git
cd deepseek-r1-snap
```

Initialize the development environment:
```shell
make init
```

Build and install snap:
```shell
make build
make install
```

Refer to the `./dev` directory for additional development tools.
