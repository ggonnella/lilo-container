#!/bin/bash
#
# (c) 2023, Giorgio Gonnella, IPC

function usage {
  echo
  echo Concatenate fastq.gz files in the demultiplexed
  echo output of GridIon into single files, one per each barcode
  echo
  echo "Usage:"
  echo "  combine_barcode_fastq.sh <outdir> [<dirname>]"
  echo
  echo "Arguments:"
  echo "  <outdir>    the name of the output directory"
  echo "  <dirname>   (optional) the directory containing the barcode files;"
  echo "              if none is specified, then the currently directory is used"
}

if [ $# -lt 1 ]; then
  usage > /dev/stderr
  exit 1
fi
OUTDIR=$1

NBCDIRS=0
INDIR=${2:-.}

for BCDIR in "$INDIR/barcode"[0-9][0-9]; do
  if [ -d "$BCDIR" ]; then
    NFASTQ=$(ls "$BCDIR"/*.fastq.gz 2> /dev/null | wc -l)
    if [ $NFASTQ -gt 0 ]; then
      NBCDIRS=$[NBCDIRS+1]
      mkdir -p $OUTDIR
      OUTFILE="$OUTDIR/${BCDIR}.fastq.gz"
      cat $BCDIR/*.fastq.gz > $OUTFILE
      echo "INFO: $BCDIR: $NFASTQ fastq.gz files found" >&2
    else
      echo "WARNING: skipped directory '$BCDIR' since it does not contain fastq.gz files" >&2
    fi
  fi
done

if [ "$NBCDIRS" -eq 0 ]; then
  echo "ERROR: No 'barcode<NN>' subdirectory found under the current directory!" >&2
  exit 1
else
  echo "SUCCESS: $NBCDIRS concatenated read files were created under '$OUTDIR'"
fi

