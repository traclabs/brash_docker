#!/bin/bash

## cFE/cFE Setup
docker image inspect cfs-base
if [[ $? -eq 0 ]]; then
    echo "cfs-base exists, not rebuilding"
else
    echo "Building cfs-base"
    docker build -t cfs-base -f base-Dockerfile .
fi
echo "Building cFS"
docker build -t brash-cfs -f cfs-Dockerfile .
