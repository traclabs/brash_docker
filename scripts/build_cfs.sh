#!/usr/bin/env bash

echo ""
echo "##### Building cfe #####"
echo ""
COMPOSE_FILE="docker-compose-dev.yml"
CODE_DIR="/root/code"
SERVICE=rosws

build_cfs_code() {

  docker compose -f ${COMPOSE_FILE} run -w ${CODE_DIR}/cfs $SERVICE make SIMULATION=native prep
  ret=$?
  if [ $ret -ne 0 ]; then
    echo "!! Failed in make SIMULATION step !!"
    return 1  
  fi

  docker compose -f ${COMPOSE_FILE} run -w ${CODE_DIR}/cfs $SERVICE make
  ret=$? 
  if [ $ret -ne 0 ]; then
    echo "!! Failed in make step !!"
    return 1
  fi

  docker compose -f ${COMPOSE_FILE} run -w ${CODE_DIR}/cfs $SERVICE make install
  ret=$?
  if [ $ret -ne 0 ]; then
    echo "!! Failed in make install step !!"
    return 1  
  fi

  echo ""
  echo "##### Done! #####"
  return 0
}

build_cfs_code


