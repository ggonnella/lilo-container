# syntax=docker/dockerfile:1

FROM ubuntu:23.10

USER root
RUN apt-get update -y
RUN apt-get install --no-install-recommends --yes \
      build-essential software-properties-common \
      wget git curl time tini bzip2 ca-certificates
SHELL ["/bin/bash", "-c"]

RUN useradd -ms /bin/bash user
USER user
WORKDIR /home/user

# Install Mamba

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

RUN mamba init bash
RUN mamba config --add channels bioconda

# Install LILO

RUN git clone https://github.com/amandawarr/Lilo
WORKDIR /home/user/Lilo
RUN mamba env create --file LILO.yaml
RUN echo "mamba activate LILO" >> ~/.bashrc
RUN mamba env create -f scaffold_builder.yaml

WORKDIR /home/user/
RUN git clone https://github.com/sclamons/Porechop-1
WORKDIR /home/user/Porechop-1
RUN mamba install gcc=13 --yes
RUN pip install .
RUN porechop -h

#ENTRYPOINT ["tini", "--"]
#CMD ["/bin/bash"]

CMD bash
