#!/usr/bin/env bash

echo ""
echo "##### Building base images (needs to be in order for image dependencies) #####"
echo ""
COMPOSE_FILE="docker-compose-dev.yml"

while getopts 'c:' opt ; do
  case "$opt" in 
  c) COMPOSE_FILE=$OPTARG ;; 
  esac 
done 

echo "...Using COMPOSE_FILE: ${COMPOSE_FILE}..."

echo ""
echo "##### Building fsw #####"
echo ""
env UID=${UID} docker compose -f ${COMPOSE_FILE} build fsw
ret=$?
if [ $ret -ne 0 ]; then
  echo "!! Failed in building base image for fsw service !!"
  return 1  
fi

echo ""
echo "##### Building ros_base #####"
echo ""
env UID=${UID} docker compose -f ${COMPOSE_FILE} build ros_base
ret=$?
if [ $ret -ne 0 ]; then
  echo "!! Failed in building base image for ros_base (base for rosgsw and rosfsw) !!"
  return 1  
fi

echo ""
echo "##### Building rosgsw #####"
echo ""
env UID=${UID} docker compose -f ${COMPOSE_FILE} build rosgsw
ret=$?
if [ $ret -ne 0 ]; then
  echo "!! Failed in building base image for rosgsw !!"
  return 1  
fi

echo ""
echo "##### Building rosfsw #####"
echo ""
env UID=${UID} docker compose -f ${COMPOSE_FILE} build rosfsw
ret=$?
if [ $ret -ne 0 ]; then
  echo "!! Failed in building base image for rosfsw !!"
  return 1  
fi


echo ""
echo "##### Done! #####"
return 0
