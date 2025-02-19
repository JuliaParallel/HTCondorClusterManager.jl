# We intentionally use full-length digests (NOT tags) for reproducibility.
# FROM ghcr.io/juliaparallel/dask-jobqueue-ci-images:htcondor-submit as submit
FROM ghcr.io/juliaparallel/dask-jobqueue-ci-images@sha256:5ada6445b5d8b53b6693ab86be364dd1ce385ada8e53763731ba50d145f0350d as submit

# We intentionally have no default value:
ARG JULIA_VERSION

RUN mkdir -p /home/docker/.local/opt/julia \
    && cd /home/docker/.local/opt/julia \
    && folder="$(echo 1.11.2 | cut -d. -f1-2)" \
    && curl -L https://julialang-s3.julialang.org/bin/linux/x64/1.11/julia-1.11.2-linux-x86_64.tar.gz | tar xz --strip 1 \
    && /home/docker/.local/opt/julia/bin/julia --version

ENV PATH="/home/docker/.local/opt/julia/bin:${PATH}"

RUN bash -c "pwd"

COPY --chown=docker . SlurmClusterManager
RUN chmod -R u+rw,g+rw,o+rw SlurmClusterManager

SHELL ["conda", "run", "-n", "dask-jobqueue", "/bin/bash", "-c"]

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# We intentionally use full-length digests (NOT tags) for reproducibility.
# FROM ghcr.io/juliaparallel/dask-jobqueue-ci-images:htcondor-execute as execute
FROM ghcr.io/juliaparallel/dask-jobqueue-ci-images@sha256:5723d0380f627779bc54a31ebac9a77f0937189453f597845411257dea6ac0db as execute

# We intentionally have no default value:
ARG JULIA_VERSION

RUN mkdir -p /home/docker/.local/opt/julia \
    && cd /home/docker/.local/opt/julia \
    && folder="$(echo 1.11.2 | cut -d. -f1-2)" \
    && curl -L https://julialang-s3.julialang.org/bin/linux/x64/1.11/julia-1.11.2-linux-x86_64.tar.gz | tar xz --strip 1 \
    && /home/docker/.local/opt/julia/bin/julia --version

ENV PATH="/home/docker/.local/opt/julia/bin:${PATH}"

RUN bash -c "pwd"

COPY --chown=docker . SlurmClusterManager
RUN chmod -R u+rw,g+rw,o+rw SlurmClusterManager
