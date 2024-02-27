#!/usr/bin/env bash

echo ""
echo "##### Building cfe #####"
echo ""
echo "Set compose file"
COMPOSE_FILE="docker-compose-dev.yml"
echo "Code dir"
CODE_DIR="/code"
echo "Set uid"
UID=$UID
echo "UID: ${UID}"
echo "Run docker compose config.."
docker compose -f ${COMPOSE_FILE} config

echo "Print UID: ${UID}"
echo "Try to run first compose"
docker compose -f ${COMPOSE_FILE} run -w ${CODE_DIR}/cFS fsw make SIMULATION=native prep
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
