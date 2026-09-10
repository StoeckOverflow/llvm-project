FROM ubuntu:24.04

RUN apt-get update && apt-get install -y --no-install-recommends \
  ca-certificates \
  ccache \
  clang \
  cmake \
  git \
  lld \
  ninja-build \
  python3 \
  python3-matplotlib \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace
RUN git clone https://github.com/StoeckOverflow/llvm-project.git llvm-project
WORKDIR /workspace/llvm-project

ARG BRANCH=paper/dependent-memref-llvm-artifact
RUN git checkout ${BRANCH}

CMD ["bash", "mlir/examples/dependent-memref-artifact/run-all.sh"]

