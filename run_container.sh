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
  echo "    $0 <reads_directory> <medaka>"
  echo
  echo "    Arguments:"
  echo "      <reads_directory>  Directory containing the reads"
  echo "      <medaka>           Medaka configuration to use"
}

if [ $# -eq 1 ]; then
  if [ $1 == "interactive" ]; then
    docker run --rm -it lilo bash
    exit $?
  fi
  usage > /dev/stderr
  exit 1
elif [ $# -ne 2 ]; then
  usage > /dev/stderr
  exit 1
fi

READS_DIR=$1
MEDAKA=$2

if [ ! -d $READS_DIR ]; then
  echo "Error: $READS_DIR is not a directory" > /dev/stderr
  exit 1
fi

docker run --rm -it \
  -e MEDAKA=$MEDAKA \
  --mount type=bind,source=$READS_DIR,target=/home/user/raw \
  lilo \
  bash -ic '/home/user/run_lilo.sh'
