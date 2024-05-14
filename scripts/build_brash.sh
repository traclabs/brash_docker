#!/usr/bin/env bash

echo ""
echo "##### Building brash #####"
echo ""

COMPOSE_FILE="docker-compose-dev.yml"
CODE_DIR="/code"

# Build BRASH workspace
build_brash_code() {
  docker compose -f ${COMPOSE_FILE} run -w ${CODE_DIR}/brash rosgsw colcon build --symlink-install
  ret=$?
  if [ $ret -ne 0 ]; then
    echo "!! Failed in colcon build step that builds brash workspace !!"
    return 1  
  fi
  
  return 0
}

# Build juicer
build_juicer_code() {
  docker compose -f ${COMPOSE_FILE} run -w ${CODE_DIR}/juicer rosgsw make
  ret=$?
  if [ $ret -ne 0 ]; then
    echo "!! Failed in colcon build step that builds juicer !!"
    return 1
  fi
  
  return 0
}
 
# Going...
echo "**** Building brash... ****"
build_brash_code
brash_res=$?

if [ $brash_res -eq 1 ]; then
  exit 1
fi

echo "**** Building juicer...****"
build_juicer_code
juicer_res=$?

if [ $juicer_res -eq 1 ]; then
  exit 1
fi
   
echo ""
echo "##### Done! #####"
exit 0
