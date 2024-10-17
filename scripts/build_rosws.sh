#!/usr/bin/env bash

echo ""
echo "##### Building brash #####"
echo ""

COMPOSE_FILE="docker-compose-dev.yml"
CODE_DIR="/root/code"
SERVICE=rosws


# Build ROS2 workspace
build_rosws_code() {
  docker compose -f ${COMPOSE_FILE} run -w ${CODE_DIR}/rosws $SERVICE /bin/bash -c "source /opt/ros/humble/setup.bash && colcon build --symlink-install"
  ret=$?
  if [ $ret -ne 0 ]; then
    echo "!! Failed in colcon build step that builds rosws !!"
    return 1  
  fi
  
  return 0
}
 
# Going...
echo "**** Building ROS2... ****"
build_rosws_code
rosws_res=$?

if [ $rosws_res -eq 1 ]; then
  exit 1
fi

echo ""
echo "##### Done! #####"
exit 0
