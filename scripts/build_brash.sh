#!/usr/bin/env bash -e

echo ""
echo "##### Building brash #####"
echo ""

COMPOSE_FILE="docker-compose-dev.yml"
CODE_DIR="/code"

docker compose -f ${COMPOSE_FILE} run -w ${CODE_DIR}/brash rosgsw colcon build --symlink-install
ret=$?
if [ $ret -ne 0 ]; then
  echo "!! Failed in colcon build step !!"
  return 1  
fi
  
echo ""
echo "##### Done! #####"

