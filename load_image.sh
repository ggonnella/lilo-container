#!/bin/bash

if [ "$1" == "" ]; then
  echo "Usage: $0 <tag>" > /dev/stderr
  exit 1
fi

IMG=lilo_asfv
TAG=$1
docker load --input $IMG-$TAG.docker.tar
