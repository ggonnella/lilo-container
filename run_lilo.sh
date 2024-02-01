#!/bin/bash
echo "Running LILO Snakemake"
if [ "$MEDAKA" == "" ]; then
  echo "The medaka variable was not set correctly." > /dev/stderr
  exit 1
fi
echo "Medaka is $MEDAKA"
NCORES=`nproc`
echo "Using $NCORES cores..."

source $HOME/miniforge/etc/profile.d/conda.sh
source $HOME/miniforge/etc/profile.d/mamba.sh
mamba activate LILO

original_user=$(stat -c "%u" "workdir")
original_group=$(stat -c "%g" "workdir")
cd workdir
snakemake -k \
          --use-conda \
          -s $HOME/Lilo/LILO \
          --configfile $ASFVDIR/config.file \
          --verbose \
          --config medaka=$MEDAKA \
          --cores $NCORES
chown -R $original_user:$original_group .
