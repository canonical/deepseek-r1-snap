# DeepSeek R1 snap

This snap installs a hardware-optimized engine for inference with the [DeepSeek R1](https://github.com/deepseek-ai/DeepSeek-R1) reasoning language model.

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

Testing a change
