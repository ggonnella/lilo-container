#!/bin/bash
echo $MEDAKA
echo "Running LILO Snakemake"
if [ "$MEDAKA" == "" ]; then
  echo "The medaka variable was not set correctly." > /dev/stderr
  exit 1
fi
echo "Medaka is $MEDAKA"
NCORES=`nproc`
echo "Using $NCORES cores..."
snakemake -k \
          -s /home/user/Lilo/LILO \
          --configfile $ASFVDIR/config.file \
          --config medaka=$MEDAKA \
          --cores $NCORES
