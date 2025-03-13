# Test

This snap can be tested using Testflinger.
The snap and components are downloaded from a specified channel in the Snap Store.

In this directory run:
```
testflinger submit --poll testflinger.yaml
```

To change what is tested, edit the `SNAP_NAME`, `SNAP_CHANNEL`, `NVIDIA_VERSION` and `STACKS` variables inside [testfligner.yaml](testfligner.yaml).
