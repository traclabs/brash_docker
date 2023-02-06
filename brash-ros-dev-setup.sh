#!/usr/bin/env bash

# Note: cFS setup piece may be redundant if using docker-compose
echo "Check if using podman or docker and initialize cFS"
podman --version
if [[ $? -eq 0 ]]; then
    MODE=podman
#    ./setup-podman.sh
else
    MODE=docker
    ./setup-docker.sh
fi

echo "MODE is $MODE"

echo "Brash ROS Dev Setup"
${MODE} run -it -v ${PWD}:/shared -w /shared/brash osrf/ros:galactic-desktop ./install.py
if [[ $? -ne 0 ]]; then
    echo "Brash ROS install.py execution failed. See above for details and retry."
    exit 1;
fi

echo "Setup Complete"
