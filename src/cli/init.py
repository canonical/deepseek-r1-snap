#!/usr/bin/env python3

import os
import sys
import subprocess

# known = [
#     '7b-instruct'
# ]

snap_name = os.environ['SNAP_INSTANCE_NAME']
snap_revision = os.environ['SNAP_REVISION']

model = sys.argv[1]

if not model:
    print(f"Usage: {snap_name}.init <model>")
    exit(1)

# if not to_set in known:
#     print(f"Unknown model '{model}'")
#     print(f"Model should be one of {known}")
#     exit(1)

result = subprocess.run(["snapctl", "set", f"active={model}"])

if result.returncode:
    print(f"Internal error setting model")
    exit(1)

if os.path.isdir(f"/snap/{snap_name}/components/{snap_revision}/{model}"):
    result = subprocess.run(["snapctl", "install", f"+{model}"], capture_output=True, text=True)
    if result.returncode:
        print(f"Error installing model: {result.stderr}")
        exit(1)
