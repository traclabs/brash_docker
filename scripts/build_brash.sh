#!/usr/bin/env bash -e

echo ""
echo "##### Building brash #####"
echo ""

COMPOSE_FILE="docker-compose-dev.yml"
CODE_DIR="/code"

# Build BRASH workspace
docker compose -f ${COMPOSE_FILE} run -w ${CODE_DIR}/brash rosgsw colcon build --symlink-install
ret=$?
if [ $ret -ne 0 ]; then
  echo "!! Failed in colcon build step that builds brash workspace !!"
  return 1  
fi

# Build juicer
docker compose -f ${COMPOSE_FILE} run -w ${CODE_DIR}/juicer rosgsw make
ret=$?
if [ $ret -ne 0 ]; then
  echo "!! Failed in colcon build step that builds juicer !!"
  return 1
fi

  
echo ""
echo "##### Done! #####"

