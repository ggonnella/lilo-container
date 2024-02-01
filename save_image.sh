#!/bin/bash

if [ "$1" == "" ]; then
  echo "Usage: $0 <tag>" > /dev/stderr
  exit 1
fi

IMG=lilo
TAG=$1
docker save --output $IMG-$TAG.docker.tar $IMG:$TAG
