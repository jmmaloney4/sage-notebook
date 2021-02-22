ARG BASE_CONTAINER=jupyter/minimal-notebook
FROM $BASE_CONTAINER
ARG SAGE_VERSION=9.2
ARG SAGE_PYTHON_VERSION=3.9
ARG  BUILD_JOBS 8

RUN echo "sage: $SAGE_VERSION  python: $SAGE_PYTHON_VERSION"

USER root

# Sage pre-requisites and jq for manipulating json
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    dvipng \
    ffmpeg \
    imagemagick \
    texlive \
    tk tk-dev \
    aria2 \
    git \
    libssl-dev \
    jq && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /opt/sage && chown $NB_USER /opt/sage/

USER $NB_UID

# Initialize conda for shell interaction
RUN conda init bash

# Install Sage conda environment
<<<<<<< HEAD
RUN conda install --quiet --yes -n base -c conda-forge widgetsnbextension sage=$SAGE_VERSION && \
=======
RUN conda install --quiet --yes -n base -c conda-forge widgetsnbextension && \
>>>>>>> 89e9967 (Try from source build)
    conda clean --all -f -y && \
    npm cache clean --force && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER
<<<<<<< HEAD
    
# ENTRYPOINT ["tini", "-g", "--", "conda", "run", "-n", "sage"]
# CMD ["sage", "--jupyter", "labhub"]
=======

WORKDIR /opt/sage/
RUN git clone --branch $SAGE_VERSION --depth 1 git@github.com:sagemath/sage.git .
RUN make configure
ENV MAKE "make -j4"
RUN ./configure --prefix=$PWD
RUN make ssl

# RUN aria2c --quiet --summary-interval=5 --seed-time=0 --check-integrity http://mirror.aarnet.edu.au/pub/sage/linux/64bit/meta/sage-9.2-Ubuntu_20.04-x86_64.tar.bz2.torrent &&
#     tar -xjf *.tar.bz2 && \
#     rm *.tar.bz2 *.torrent

# RUN wget --progress=bar:force:noscroll http://mirrors.mit.edu/sage/linux/64bit/sage-9.2-Ubuntu_20.04-x86_64.tar.bz2 && \
#     tar -xjf *.tar.bz2 && \
#     rm *.tar.bz2

ENTRYPOINT ["tini", "-g", "--", "conda", "run", "-n", "sage"]
CMD ["sage", "--jupyter", "labhub"]
>>>>>>> 89e9967 (Try from source build)
