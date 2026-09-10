#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
DEPENDENT_BUILD="${DEPENDENT_BUILD:-${ROOT}/build}"

cmake -S "${ROOT}/llvm" \
  -B "${DEPENDENT_BUILD}" \
  -G Ninja \
  -DLLVM_ENABLE_PROJECTS='mlir;clang' \
  -DLLVM_TARGETS_TO_BUILD=Native \
  -DCMAKE_BUILD_TYPE=Release \
  -DLLVM_ENABLE_ASSERTIONS=ON \
  -DLLVM_CCACHE_BUILD=ON \
  -DLLVM_BUILD_EXAMPLES=OFF \
  -DMLIR_ENABLE_BINDINGS_PYTHON=0

ninja -C "${DEPENDENT_BUILD}" mlir-opt mlir-translate opt clang

