#!/usr/bin/env python3
from mistral_inference.transformer import Transformer
from mistral_inference.generate import generate

from mistral_common.tokens.tokenizers.mistral import MistralTokenizer
from mistral_common.protocol.instruct.messages import UserMessage
from mistral_common.protocol.instruct.request import ChatCompletionRequest

import os
import sys
import subprocess

snap_name = os.environ['SNAP_INSTANCE_NAME']
snap_revision = os.environ['SNAP_REVISION']

active_model = subprocess.run(["snapctl", "get", "active"], capture_output=True, text=True).stdout.strip()

print(f"active_model: {active_model}")

if not active_model:
    print("ERROR: no model selected")
    exit(1)

tokenizer = MistralTokenizer.from_file(f"/snap/{snap_name}/components/{snap_revision}/{active_model}/tokenizer.model.v3")  # change to extracted tokenizer file
model = Transformer.from_folder(f"/snap/{snap_name}/components/{snap_revision}/{active_model}")  # change to extracted model dir

# prompt = "How expensive would it be to ask a window cleaner to clean all windows in Paris. Make a reasonable guess in US Dollar."

completion_request = ChatCompletionRequest(messages=[UserMessage(content=sys.argv[1])])

tokens = tokenizer.encode_chat_completion(completion_request).tokens

out_tokens, _ = generate([tokens], model, max_tokens=1024, temperature=0.35, eos_id=tokenizer.instruct_tokenizer.tokenizer.eos_id)
result = tokenizer.instruct_tokenizer.tokenizer.decode(out_tokens[0])

print(result)
