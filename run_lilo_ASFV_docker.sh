#!/bin/bash

function usage {
  echo "Usage:"
  echo
  echo
  echo "  Open an interactive console on the container:"
  echo "    $0 interactive"
  echo
  echo
  echo "  Run the LILO pipeline:"
  echo "    $0 <workdir> <medaka>"
  echo
  echo "    Arguments:"
  echo "      <workdir>  Working directory, must contain the 'raw' directory"
  echo "      <medaka>   Medaka configuration to use"
}

IMG=lilo_asfv

if [ $# -eq 1 ]; then
  if [ $1 == "interactive" ]; then
    docker run --rm -it $IMG bash
    exit $?
  fi
  usage 
  exit 1
elif [ $# -ne 2 ]; then
  usage 
  exit 1
fi

WORKDIR=$1
MEDAKA=$2

if [ ! -d $WORKDIR ]; then
  echo "Error: $WORKDIR is not a directory" 
  exit 1
fi

if [ ! -d $WORKDIR/raw ]; then
  echo "Error: $WORKDIR does not contain a directory called raw" 
  exit 1
fi

DOCKERHOME=/root

docker run --rm -it \
  -e HOSTUSER=$(id -u) \
  -e MEDAKA=$MEDAKA \
  --mount type=bind,source=$WORKDIR,target=$DOCKERHOME/workdir \
  $IMG \
  bash -ic 'run_lilo_ASFV.sh'
