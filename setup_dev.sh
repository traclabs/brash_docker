#!/usr/bin/env bash

# Import base settings
source setup.sh

# Override COMPOSE_FILE
export COMPOSE_FILE=docker-compose-dev.yml

# Dev-specific commands
alias build_cfe="pushd ${BRASH_HOME} && docker compose run -w /src/cFS fsw make && popd"
alias build_ros="pushd ${BRASH_HOME} && docker compose run -w /src/brash rosgsw colcon build --symlink-install && popd"
