Container-based solution for running the African Swine Fever Virus
amplicon assembling pipeline based on LILO.

It can be run with Docker.

# Installation

## Paths

For simplifying calling the scripts, the following line must be added to
``.bashrc`` file in the home directory and the command line restarted:
```
export PATH=/srv/virology/software/bin:$PATH
```

## Install image to local Docker registry

This must be done only if the image is not already installed by anyone.

To check this, run:

```
docker images
```

If you see a line with ``lilo_asfv`` under REPOSITORY,  and ``latest`` under
TAG, then it's already installed.

If you don't see that line, run the following command:
```
docker load --input /srv/virology/software/docker-img/lilo_asfv-1.0.docker.tar
docker tag lilo_asfv:1.0 lilo_asfv:latest
```

# Usage

## Step 1: Combine barcodes

Barcode reads are combined into single files in a directory named ``raw``
using ``combine_barcodes_fastq.sh``, e.g. (xxx and yyy are placeholders for
the real path of the fastq-pass directory)
```
combine_barcode_fastq.sh raw /srv/xxxxxxx/yyyyyy/fastq-pass
```

Syntax of the command:
```
combine_barcode_fastq.sh <outdir> [<dirname>]

Arguments:
  <outdir>    use "raw" for Lilo (name of output directory of the script)
  <dirname>   (optional) input directory (containing the barcode files);
              if not, then it's assumed it's the current directory
```

## Step 2: Raw directory

### Check the results of combine barcode

First, check that the combined barcode files are present in the directory
``raw`` as expected after running the previous command.
The files should be named ``barcode01.fastq.gz`` etc.

### Decide the location of the results

If you want to have the results in a different place to the directory where
the reads are located, then move the ``raw`` directory to the desired
location. The results of Lilo will be in sister directories of ``raw``.

E.g.
```
mkdir /srv/foobar/asfv_results
mv /srv/xxxxxxx/yyyyyy/raw /srv/foobar/asfv_results
# the results of Lilo will be in /srv/foobar/asfv_results
```

### Handle unused barcodes

Sometimes, Lilo shall not be run on all barcodes. In this case, delete the
unwanted barcode files.

This is for example the case, when the number of
samples is less than the number of barcodes. If you leave the unwanted
barcode files in the directory, Lilo will fail for those barcodes and
output an Error message at the end (but should still complete the other
barcodes correctly).

E.g. for removing all barcodes from 04 to 12:
```
cd raw # move to the raw directory created by the previous step
rm barcode{04..12}.fastq.gz
```

## Step 3: Run LILO

Run the pipeline using the ``run_lilo_ASFV_docker.sh`` script, e.g.
```
run_lilo_ASFV_docker.sh /path/to/parent/of/raw/directory r104_e81_sup_g5015
```

The two arguments of the script are:

1. The parent directory of the ``raw`` directory created in the
   previous step. E.g. if ``.fastq.gz`` files are in
   ``/srv/xyz/reads/foobar/raw``, WORKDIR is ``/srv/xyz/reads/foobar``)
2. The medaka model to use e.g. ``r104_e81_sup_g5015``.

## Regarding the medaka model

Selecting the correct medaka model is important for the medaka long read
polishing step.

The medaka model is named in the format
``{flowcell}_{device}_{guppy_algorithm}_{guppy_version}`` and depends on:

- flowcell version and subversion (e.g. R9.41, R10.3)
- model of the ONT sequencer (MinION/GridION, PromethION)
- base calling algorithm used by the ``guppy`` base caller
- version of the ``guppy`` base caller

For example the model named ``r941_min_fast_g303`` should be used with data
from MinION (or GridION) R9.4.1 flowcells using the fast Guppy basecaller
version 3.0.3. By contrast the model ``r941_prom_hac_g303`` should be used with
PromethION data and the high accuracy basecaller.

### Guppy algorithm

Acronyms used are Fast basecalling (Fast), High Accuracy basecalling (HAC) and
Super accuracy basecalling (SUP).

### Guppy version

For each run, you can check which version of guppy was used by referring to the
html report.

Where a version of Guppy has been used without an exactly corresponding medaka
model, the medaka model with the highest version equal to or less than the
guppy version should be selected.

### Available models

The models available in the medaka version installed in the container are
the following:

- Flowcell R10.4 E81:
  - guppy 5:
    - Fast base calling: ``r104_e81_fast_g5015``
    - High accuracy base calling: ``r104_e81_hac_g5015``
    - Super high accuracy base calling: ``r104_e81_sup_g5015``

- Flowcell R10.3:
  - guppy 5:
    - Fast base calling: ``r103_fast_g507, r103_fast_snp_g507, r103_fast_variant_g507``
    - High accuracy base calling: ``r103_hac_g507, r103_hac_snp_g507, r103_hac_variant_g507``
    - Super high accuracy base calling: ``r103_sup_g507, r103_sup_snp_g507, r103_sup_variant_g507``
  - guppy 3:
    - MinIon/GridIon: ``r103_min_high_g345, r103_min_high_g360``
    - PromethIon: ``r103_prom_high_g360, r103_prom_snp_g3210, r103_prom_variant_g3210``

- Flowcell R10:
  - guppy 3:
    - MinIon/GridIon: ``r10_min_high_g303, r10_min_high_g340``

- Flowcell R9.41:
  - guppy 5:
    - MinIon/GridIon:
      - Fast base calling: ``r941_min_fast_g507, r941_min_fast_snp_g507, r941_min_fast_variant_g507``
      - High accuracy base calling: ``r941_min_hac_g507, r941_min_hac_snp_g507, r941_min_hac_variant_g507``
      - Super high accuracy base calling: ``r941_min_sup_g507, r941_min_sup_snp_g507, r941_min_sup_variant_g507``
    - PromethIon: ``r941_prom_fast_g507, r941_prom_fast_snp_g507,
                    r941_prom_fast_variant_g507, r941_prom_hac_g507,
                    r941_prom_hac_snp_g507, r941_prom_hac_variant_g507,
                    r941_prom_sup_g507, r941_prom_sup_snp_g507,
                    r941_prom_sup_variant_g507``
  - guppy 4:
      - PromethIon: ``r941_prom_high_g4011``
  - guppy 3:
    - MinIon/GridIon: ``r941_min_fast_g303, r941_min_high_g303,
                        r941_min_high_g330, r941_min_high_g340_rle,
                        r941_min_high_g344, r941_min_high_g351,
                        r941_min_high_g360``
    - PromethIon: ``r941_prom_fast_g303, r941_prom_high_g303,
                    r941_prom_high_g330, r941_prom_high_g344,
                    r941_prom_high_g360, r941_prom_snp_g303,
                    r941_prom_snp_g322, r941_prom_snp_g360,
                    r941_prom_variant_g303, r941_prom_variant_g322,
                    r941_prom_variant_g360``

## Step 4: Check the results

The results of the pipeline are under the directory indicated in the call to
``run_lilo_ASFV_docker.sh`` (i.e. the parent directory of the ``raw`` directory).

In particular there are:

- scaffold fasta files for each barcode
- summary .txt files with statistics for each barcode
  (these are tabular files and can be opened with spreadsheet software)
- one directory for each barcode with the intermediate files such as alignment
  bam files, consensus sequences of the amplicons, etc (these are good to check
  if things went wrong)

### Troubleshooting

Note that even if the pipeline fails for some barcodes, and will end with
``Error`` it may still be finished correctly for other barcodes.

In case the problem lies in e.g. a temporary problem (say, the disk is full,
the connection to the server is lost, etc.), you can re-run the pipeline and it
will re-start from the last successfully completed point.

# Apptainer

Currently the pipeline is being adapted to run in a Apptainer container.
