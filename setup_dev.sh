#!/usr/bin/env bash

# Import base settings
source setup.sh

# Override COMPOSE_FILE
export COMPOSE_FILE=docker-compose-dev.yml

# Dev-specific commands
alias build_cfe="docker-compose run -w /shared/cFS fsw make"
alias build_ros="docker-compose run -w /shared/brash rosgsw colcon build --symlink-install"
