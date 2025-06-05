# DeepSeek R1 Distill Qwen 7B Optimized for OpenVINO

The model files should be added under `models` directory to be found by the engine.
The corresponding config file is expected at `models/config.json`.

For side-loading another model, set the `models-config` snap option to Model Server JSON configuration file (generated via `export_model.py --config_file_path <path>`).
This should not be confused with the HF model's config file.

## Download the model

This requires Git and Git LFS:
```
sudo apt install git git-lfs
```

Clone:
```shell
git clone https://huggingface.co/helenai/DeepSeek-R1-Distill-Qwen-7B-ov-int4 models/DeepSeek-R1-Distill-Qwen-7B-ov-int4 
```


## Export the model

GPU:
```
python export_model.py text_generation \
    --source_model DeepSeek-R1-Distill-Qwen-7B-ov-int4 \
    --config_file_path models/config.json \
    --model_repository_path models \
    --weight-format int4 \
    --cache 2 \
    --target_device GPU
```

For NPU, set `--target_device NPU` instead.

The target `device` value which is added in the generated `graph.pbtxt` gets overridden by [./init](./init).
