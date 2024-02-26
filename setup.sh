#!/usr/bin/env bash

export BRASH_HOME=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

export COMPOSE_FILE=docker-compose-prod.yml

# Define a function for wrapping rosgsw commands (and evaluating bashrc ENV variables first)
rosgsw_cmd() {
    local CMD=$1
    docker-compose exec -it -w /src/brash rosgsw bash -ic "$CMD"
}
rosgsw_cmd_bg() {
    local CMD=$1
    docker-compose exec -d -w /src/brash rosgsw bash -ic "$CMD"
}

# Define the alias using the function
alias ros_to_en='rosgsw_cmd "ros2 topic pub --once /groundsystem/to_lab_enable_output_cmd cfe_msgs/msg/TOLABEnableOutputCmdt '\''{\"payload\":{\"dest_ip\":\"10.5.0.2\"}}'\''"'
alias rosgsw_tl='rosgsw_cmd "ros2 topic list"'
alias rosgsw_rqt='rosgsw_cmd_bg "rqt" && echo "Open http://localhost:8080/vnc.html to view GUI"'
