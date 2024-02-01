Docker container-based solution for running the African Swine Fever Virus
analysis pipeline based on LILO.

# Components

The code consists of the following components:
- a ``Dockerfile`` (kind of blueprint for the virtual system; using the
  Dockerfile, an "image" is created. The image contains all information from
  which a "container" is created, i.e. the live instance of the image.
- ``run_lilo_ASFV.sh`` script, which allows to automatize the running of Lilo
  from inside the container (this is hidden from the user in normal case)
- ``run_lilo_ASFV_docker.sh`` script, which is called from outside the
  container, to run the containerized pipeline -- this is what the user uses
- short scripts to perform administrative actions, such as creating the image,
  assigning a tag to it, saving it to file ...

# Installation

For simplicity we will first use a file-based solution for distributing the
images (directory /srv/virology/software/docker-img).

The image for the ``lilo_asfv`` container is installed by running:
```
docker load --input /srv/virology/software/docker-img/lilo_asfv-1.0.docker.tar
```

Furthermore the following line must be added to the ``.bashrc`` file in the
home directory, if not yet present (this will allow to access all of the
software installed under ``/srv/virology/software``):
```
export PATH=/srv/virology/software/bin:$PATH
```

# Usage

To run the pipeline you need two pieces of information:
1. MEDAKA: The medaka model to use e.g. ``r104_e81_sup_g5015``.
2. WORKDIR: The parent directory of the 'raw' directory containing
   the ``.fastq.gz`` files for each barcode (e.g. say ``/srv/xyz/reads/foobar/raw``
   contains the reads, then WORKDIR would be ``/srv/xyz/reads/foobar``)

Then the pipeline is run using:
```
run_lilo_ASFV_docker.sh $MEDAKA $WORKDIR
```
for example:
```
run_lilo_ASFV_docker.sh r104_e81_sup_g5015 /srv/xyz/reads/foobar
```
