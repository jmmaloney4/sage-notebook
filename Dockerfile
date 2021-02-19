ARG BASE_CONTAINER=jupyter/minimal-notebook
FROM $BASE_CONTAINER
ARG SAGE_VERSION=9.2
ARG SAGE_PYTHON_VERSION=3.9

RUN echo "Building image with Sage $SAGE_VERSION"

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
    apt-get -y autoremove

USER $NB_UID

# Initialize conda for shell interaction
RUN conda init bash

# Install Sage conda environment
RUN conda update conda && \
    conda install mamba -c conda-forge && \
    mamba install --quiet --yes -n base -c conda-forge widgetsnbextension && \
    mamba create --quiet --yes -n sage -c conda-forge sage=$SAGE_VERSION python=$SAGE_PYTHON_VERSION && \
    conda clean --all -f -y && \
    npm cache clean --force && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

# # Install sagemath kernel and extensions using conda run:
# #   Create jupyter directories if they are missing
# #   Add environmental variables to sage kernal using jq
# RUN echo ' \
#         from sage.repl.ipython_kernel.install import SageKernelSpec; \
#         SageKernelSpec.update(prefix=os.environ["CONDA_DIR"]); \
#     ' | conda run -n sage sage && \
#     echo ' \
#         cat $SAGE_ROOT/etc/conda/activate.d/sage-activate.sh | \
#             grep -Po '"'"'(?<=^export )[A-Z_]+(?=)'"'"' | \
#             jq --raw-input '"'"'.'"'"' | jq -s '"'"'.'"'"' | \
#             jq --argfile kernel $SAGE_LOCAL/share/jupyter/kernels/sagemath/kernel.json \
#             '"'"'. | map(. as $k | env | .[$k] as $v | {($k):$v}) | add as $vars | $kernel | .env= $vars'"'"' > \
#             $CONDA_DIR/share/jupyter/kernels/sagemath/kernel.json \
#     ' | conda run -n sage sh && \
#     fix-permissions $CONDA_DIR && \
#     fix-permissions /home/$NB_USER

# # Install sage's python kernel
# RUN echo ' \
#         ls /opt/conda/envs/sage/share/jupyter/kernels/ | \
#             grep -Po '"'"'python\d'"'"' | \
#             xargs -I % sh -c '"'"' \
#                 cd $SAGE_LOCAL/share/jupyter/kernels/% && \
#                 cat kernel.json | \
#                     jq '"'"'"'"'"'"'"'"' . | .display_name = .display_name + " (sage)" '"'"'"'"'"'"'"'"' > \
#                     kernel.json.modified && \
#                 mv -f kernel.json.modified kernel.json && \
#                 ln  -s $SAGE_LOCAL/share/jupyter/kernels/% $CONDA_DIR/share/jupyter/kernels/%_sage \
#             '"'"' \
#     ' | conda run -n sage sh && \
#     fix-permissions $CONDA_DIR && \
#     fix-permissions /home/$NB_USER

RUN echo $CONDA_DIR

USER root

# Install sage's python kernel
RUN jupyter kernelspec install $CONDA_DIR/base/envs/sage/share/jupyter/kernels/sagemath

USER $NB_UID

RUN fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

