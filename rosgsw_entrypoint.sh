#!/bin/bash
 
# Source ROS 2
source /opt/ros/humble/setup.bash
 
if [ -f /code/brash/install/setup.bash ]
then
  source /code/brash/install/setup.bash
fi
  
# Execute the command passed into this entrypoint
exec "$@"
