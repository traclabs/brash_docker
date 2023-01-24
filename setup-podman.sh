#!/bin/bash

## cFE/cFE Setup
podman image exists cfs-base
if [[ $? -eq 0 ]]; then
    echo "cfs-base exists, not rebuilding"
else
    echo "Building cfs-base"
    podman build -t cfs-base -f base-Dockerfile .
fi
echo "Building cFS"
podman build -t brash-cfs -f cfs-Dockerfile .
