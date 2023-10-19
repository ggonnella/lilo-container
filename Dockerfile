# syntax=docker/dockerfile:1

FROM ubuntu:23.10
SHELL ["/bin/bash", "-c"]

# (1) Install basic packages as root user (of the container)

USER root
RUN <<EOT
  apt-get update -y
  apt-get install --no-install-recommends --yes \
      build-essential \
      software-properties-common \
      wget \
      git \
      curl \
      time \
      tini \
      bzip2 \
      ca-certificates
EOT

# (2) Create a normal user and switch to it

RUN useradd -ms /bin/bash user
USER user
ARG HOME=/home/user
WORKDIR $HOME

# (3) Install Mamba Miniforge

ARG MFVER=23.3.1-1
ARG CONDA_DIR=$HOME/miniforge
ENV PATH=${CONDA_DIR}/bin:${PATH}

RUN <<EOT
  URL=https://github.com/conda-forge/miniforge/releases/download/${MFVER}/Mambaforge-${MFVER}-Linux-x86_64.sh
  wget --no-hsts --quiet $URL -O /tmp/miniforge.sh
  bash /tmp/miniforge.sh -b -p ${CONDA_DIR}
  rm /tmp/miniforge.sh
  mamba init bash
  mamba config --add channels bioconda
EOT

# (4) Install LILO

RUN <<EOT
  git clone https://github.com/amandawarr/Lilo
  cd $HOME/Lilo
  mamba env create --file LILO.yaml
  echo "mamba activate LILO" >> ~/.bashrc
  mamba env create -f scaffold_builder.yaml
EOT

# (5) Install the Porechop fork required by LILO

RUN <<EOT
  git clone https://github.com/sclamons/Porechop-1
  cd $HOME/Porechop-1
  mamba install gcc=13 --yes
  pip install .
  porechop -h
EOT

# (6) Edit the configuration file in Lilo/schemes/ASFV

ENV ASFVDIR=$HOME/Lilo/schemes/ASFV
ARG MEDAKA=r104_e81_sup_g5015

COPY --chown=user <<-EOT $ASFVDIR/config.file
scheme: $ASFVDIR/ASFV.scheme.bed
reference: $ASFVDIR/ASFV.reference.fasta
primers: $ASFVDIR/ASFV.primers.csv
medaka: $MEDAKA
EOT

# (7) Create a script for running LILO

ENV NCORES=64
COPY --chown=user <<-EOT $HOME/run_lilo.sh
#!/bin/bash
snakemake -k -s ~/Lilo/LILO --configfile $ASFVDIR/config.file --cores $NCORES
EOT
RUN chmod +x $HOME/run_lilo.sh

VOLUME /srv/giorgio/virology/ASVF/runs/
#20230908_AFS_Run_03_R10/

# (8) Entry point

CMD bash
