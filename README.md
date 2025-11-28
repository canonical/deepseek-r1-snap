# DeepSeek R1 snap
[![deepseek-r1](https://snapcraft.io/deepseek-r1/badge.svg)](https://snapcraft.io/deepseek-r1)

This snap installs a hardware-optimized engine for inference with the [DeepSeek R1](https://github.com/deepseek-ai/DeepSeek-R1) reasoning language model.

Install:
```
sudo snap install deepseek-r1 --beta
```

Get help:
```
deepseek-r1 --help
```

## Resources

📚 **[Documentation](https://documentation.ubuntu.com/inference-snaps/)**, learn how to use inference snaps

💬 **[Discussions](https://github.com/canonical/inference-snaps/discussions)**, ask questions and share ideas

🐛 **[Issues](https://github.com/canonical/inference-snaps/issues)**, report bugs and request features

## Build and install from source

Clone this repo with its submodules:
```shell
git clone --recurse-submodules https://github.com/canonical/deepseek-r1-snap.git
```

Prepare the required models by following the instructions for each model, under the [components](./components) directory. 

Build the snap and its component:
```shell
snapcraft pack -v
```

Refer to `./dev` directory for additional development tools.
