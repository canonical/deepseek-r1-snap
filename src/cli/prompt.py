#!/usr/bin/env python3
from mistral_inference.transformer import Transformer
from mistral_inference.generate import generate

from mistral_common.tokens.tokenizers.mistral import MistralTokenizer
from mistral_common.protocol.instruct.messages import UserMessage
from mistral_common.protocol.instruct.request import ChatCompletionRequest

import os
import subprocess
import sys
from datetime import datetime

snap_name = os.environ['SNAP_INSTANCE_NAME']
snap_revision = os.environ['SNAP_REVISION']


if len(sys.argv) != 2:
    print(f"Usage: {snap_name}.prompt <model>")
    exit(1)

model = sys.argv[1]
model_dir = f"/snap/{snap_name}/components/{snap_revision}/model-{model}"
print(f"Loading model from {model_dir}")

if not os.path.isdir(model_dir):
    # Download and install model from Store
    result = subprocess.run(["snapctl", "install", f"+{model}"], capture_output=True, text=True)
    if result.returncode:
        print(f"Error installing model: {result.stderr}")
        exit(1)

# TODO: select tokenizer by model
tokenizer = "tokenizer.model.v3"

print("[%s] Loading tokenizer... " % datetime.now())
tokenizer = MistralTokenizer.from_file(f"{model_dir}/{tokenizer}")
print("[%s] Tokenizer loaded. " % datetime.now())
print("[%s] Loading model... " % datetime.now())
model = Transformer.from_folder(model_dir)
print("[%s] Model loaded. " % datetime.now())


while True:
    prompt = input("chat >>")

    completion_request = ChatCompletionRequest(messages=[UserMessage(content=prompt)])

    tokens = tokenizer.encode_chat_completion(completion_request).tokens

    out_tokens, _ = generate([tokens], model, max_tokens=1024, temperature=0.35, eos_id=tokenizer.instruct_tokenizer.tokenizer.eos_id)
    result = tokenizer.instruct_tokenizer.tokenizer.decode(out_tokens[0])

    print(result)
