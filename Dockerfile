# syntax=docker/dockerfile:1

FROM ubuntu:23.10
ENV DEBIAN_FRONTEND noninteractive

USER root
RUN apt-get update -y
RUN apt-get install --no-install-recommends --yes \
      build-essential software-properties-common \
      wget git curl time tini bzip2 ca-certificates

# Install Mamba

RUN useradd -ms /bin/bash user
USER user
WORKDIR /home/user

ENV MAMBA_URLBASE=https://github.com/conda-forge/miniforge/releases/download/
ENV MINIFORGE_NAME=Mambaforge
ENV MINIFORGE_VERSION=23.3.1-1
ENV CONDA_DIR=/home/user/miniforge
ENV PLATFORM=Linux-x86_64

RUN wget --no-hsts --quiet \
  ${MAMBA_URLBASE}/${MINIFORGE_VERSION}/${MINIFORGE_NAME}-${MINIFORGE_VERSION}-${PLATFORM}.sh \
  -O /tmp/miniforge.sh
RUN bash /tmp/miniforge.sh -b -p ${CONDA_DIR} && rm /tmp/miniforge.sh

ENV PATH=${CONDA_DIR}/bin:${PATH}
SHELL ["/bin/bash", "-c"]
RUN mamba init bash
RUN source ~/.bashrc
RUN mamba config --add channels bioconda

RUN git clone https://github.com/amandawarr/Lilo
WORKDIR /home/user/Lilo
RUN mamba env create --file LILO.yaml
RUN mamba env create -f scaffold_builder.yaml

RUN eval "$(conda shell.bash hook)" &&\
    conda activate LILO


## Lilo requires the installation of a particular Porechop fork
WORKDIR /home/user/
RUN git clone https://github.com/sclamons/Porechop-1
RUN cd Porechop-1 && python3 setup.py install
RUN porechop -h

RUN echo "mamba activate LILO" >> ~/.bashrc

ENTRYPOINT ["tini", "--"]
CMD ["/bin/bash"]
