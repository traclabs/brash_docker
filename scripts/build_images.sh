#!/usr/bin/env bash

echo ""
echo "##### Building base images #####"
echo ""
COMPOSE_FILE="docker-compose-dev.yml"

while getopts 'c:' opt ; do
  case "$opt" in 
  c) COMPOSE_FILE=$OPTARG ;; 
  esac 
done 

echo "...Using COMPOSE_FILE: ${COMPOSE_FILE}..."

echo ""
echo "##### Building fsw, rosgsw and rosfsw #####"
echo ""
env UID=${UID} docker compose -f ${COMPOSE_FILE} build
ret=$?
if [ $ret -ne 0 ]; then
  echo "!! Failed in building base image for fsw, rosgsw and rosfsw services !!"
  return 1  
fi

echo ""
echo "##### Done! #####"
return 0
