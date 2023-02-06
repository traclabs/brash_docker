#!/bin/bash

echo "Check if using podman or docker and initialize cFS"
podman --version
if [[ $? -eq 0 ]]; then
    MODE=podman
    podman image exists cfs-base
else
    MODE=docker
    docker image inspect cfs-base
fi

## cFE/cFE Setup
if [[ $? -eq 0 ]]; then
    echo "cfs-base exists, not rebuilding"
else
    echo "Building cfs-base"
    ${MODE} build -t cfs-base -f base-Dockerfile .
fi

echo "Building cFS"
${MODE} build -t brash-cfs -f cfs-Dockerfile .
