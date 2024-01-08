#!/usr/bin/env bash

# NOTE: Use "docker-compose build" to build base images

echo "Brash ROS Dev Setup"
${MODE} run --rm -it -v ${PWD}:/shared -w /shared/brash brash-ros checkout_and_install.sh
if [[ $? -ne 0 ]]; then
    echo "Brash ROS setup & build failed. See above for details and retry."
    exit 1;
fi

echo "Setup Complete"
