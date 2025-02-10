# DeepSeek R1 snap

## Get the code

Clone this repo with the submodule:
```
git clone --recurse-submodules https://github.com/canonical/deepseek-r1-snap.git
```

## Build and install from source

Download the models:
```
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

## Usage
Check the configurations:
```shell
sudo snap get deepseek-r1
```

Change the stack (only possible if installed from the Store):
```shell
sudo snap set deepseek-r1 stack=<stack>
```

```shell
deepseek-r1.chat 
```

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
