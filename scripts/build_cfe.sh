#!/usr/bin/env bash

echo ""
echo "##### Building cfe #####"
echo ""
COMPOSE_FILE="docker-compose-dev.yml"
CODE_DIR="/code"
echo "** UID: ${UID}"
echo "Run docker compose config.."
env UID=${UID}  docker compose -f ${COMPOSE_FILE} config

echo "Print UID: ${UID}"
echo "Try to run first compose"
env UID=${UID} docker compose -f ${COMPOSE_FILE} run -w ${CODE_DIR}/cFS fsw make SIMULATION=native prep
ret=$?
if [ $ret -ne 0 ]; then
  echo "!! Failed in make SIMULATION step !!"
  return 1  
fi
echo "Try to run second compose"  
docker compose -f ${COMPOSE_FILE} run -w ${CODE_DIR}/cFS fsw make
ret=$?
if [ $ret -ne 0 ]; then
  echo "!! Failed in make step !!"
  return 1  
fi
echo "Print 3rd compose"
docker compose -f ${COMPOSE_FILE} run -w ${CODE_DIR}/cFS fsw make install
ret=$?
if [ $ret -ne 0 ]; then
  echo "!! Failed in make install step !!"
  return 1  
fi
echo "ending..."
echo ""
echo "##### Done! #####"
return 0
