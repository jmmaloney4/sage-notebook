ARG BASE_CONTAINER=jupyter/minimal-notebook
FROM $BASE_CONTAINER
ARG SAGE_VERSION=9.0
ARG SAGE_PYTHON_VERSION=3.9

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
    jq && \
    rm -rf /var/lib/apt/lists/*

USER $NB_UID

# Initialize conda for shell interaction
RUN conda init bash

# Install Sage conda environment
RUN conda install --quiet --yes -n base -c conda-forge widgetsnbextension sage=$SAGE_VERSION && \
    conda clean --all -f -y && \
    npm cache clean --force && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER
    
# ENTRYPOINT ["tini", "-g", "--", "conda", "run", "-n", "sage"]
# CMD ["sage", "--jupyter", "labhub"]
