#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
MAIN_WORKTREE="${MAIN_WORKTREE:-${ROOT}/../llvm-project-main}"
MAIN_BUILD="${MAIN_BUILD:-${MAIN_WORKTREE}/build_mlir_baseline}"

if [[ ! -d "${MAIN_WORKTREE}/.git" ]]; then
  git -C "${ROOT}" worktree add "${MAIN_WORKTREE}" main
fi

cmake -S "${MAIN_WORKTREE}/llvm" \
  -B "${MAIN_BUILD}" \
  -G Ninja \
  -DLLVM_ENABLE_PROJECTS='mlir;clang' \
  -DLLVM_TARGETS_TO_BUILD=Native \
  -DCMAKE_BUILD_TYPE=Release \
  -DLLVM_ENABLE_ASSERTIONS=ON \
  -DLLVM_CCACHE_BUILD=ON \
  -DLLVM_BUILD_EXAMPLES=OFF \
  -DMLIR_ENABLE_BINDINGS_PYTHON=0

ninja -C "${MAIN_BUILD}" mlir-opt

