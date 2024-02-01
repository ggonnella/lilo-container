# syntax=docker/dockerfile:1

FROM ubuntu:23.10
SHELL ["/bin/bash", "-c"]

# === Install basic packages as root user (of the container)

USER root
ARG HOME=/root
WORKDIR $HOME
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
      ca-certificates \
      vim \
      sudo
EOT

# === Install Mamba Miniforge

ARG MFVER=23.3.1-1
ARG CONDA_DIR=$HOME/miniforge
ENV PATH=${CONDA_DIR}/bin:${PATH}

RUN <<EOT
  URL=https://github.com/conda-forge/miniforge/releases/download/${MFVER}/Mambaforge-${MFVER}-Linux-x86_64.sh
  wget --no-hsts --quiet $URL -O /tmp/miniforge.sh
  bash /tmp/miniforge.sh -b -p ${CONDA_DIR}
  rm /tmp/miniforge.sh
  mamba config --add channels bioconda
EOT

# === Install LILO

RUN <<EOT
  git clone https://github.com/amandawarr/Lilo
  cd $HOME/Lilo
  mamba env create --file LILO.yaml
  mamba env create --file scaffold_builder.yaml
EOT

# === Install the Porechop fork required by LILO

RUN <<EOT
  git clone https://github.com/sclamons/Porechop-1
  cd $HOME/Porechop-1
  mamba install gcc=13 --yes
  pip install .
  porechop -h
EOT

# === Edit the configuration file in Lilo/schemes/ASFV

ENV ASFVDIR=$HOME/Lilo/schemes/ASFV

COPY <<-EOT $ASFVDIR/config.file
scheme: $ASFVDIR/ASFV.scheme.bed
reference: $ASFVDIR/ASFV.reference.fasta
primers: $ASFVDIR/ASFV.primers.csv
EOT

# === Copy scripts to the container and add $HOME/scripts to its PATH
RUN mkdir $HOME/scripts
ENV PATH=${HOME}/scripts:${PATH}
COPY run_lilo_ASFV.sh $HOME/scripts/run_lilo_ASFV.sh
RUN chmod +x $HOME/scripts/run_lilo_ASFV.sh
COPY combine_barcodes_fastq.sh \
                  $HOME/scripts/combine_barcodes_fastq.sh
RUN chmod +x $HOME/scripts/combine_barcodes_fastq.sh

# === Create a normal user and switch to it

#RUN useradd -ms /bin/bash user
#USER user
#ARG HOME=/home/user
#WORKDIR $HOME

