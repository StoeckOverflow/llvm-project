#!/usr/bin/env bash
set -euo pipefail

STAMP="${1:-$(date +%Y-%m-%d_%H-%M)}"
ROOT="$(git rev-parse --show-toplevel)"
MAIN_WORKTREE="${MAIN_WORKTREE:-${ROOT}/../llvm-project-main}"
MAIN_BUILD="${MAIN_BUILD:-${MAIN_WORKTREE}/build_mlir_baseline}"
DEPENDENT_BUILD="${DEPENDENT_BUILD:-${ROOT}/build}"
BASELINE_MLIR_OPT="${BASELINE_MLIR_OPT:-${MAIN_BUILD}/bin/mlir-opt}"
DEPENDENT_MLIR_OPT="${DEPENDENT_MLIR_OPT:-${DEPENDENT_BUILD}/bin/mlir-opt}"

python3 "${ROOT}/mlir/examples/dependent-memref-matmul/compare.py" \
  --n 128 --k 128 --m 128 --repeats 10 --skip-run \
  --out "${ROOT}/mlir/examples/dependent-memref-matmul/artifacts/archive/${STAMP}" \
  --baseline-mlir-opt "${BASELINE_MLIR_OPT}" \
  --dependent-mlir-opt "${DEPENDENT_MLIR_OPT}"

python3 "${ROOT}/mlir/examples/dependent-memref-conv2d/compare.py" \
  --out "${ROOT}/mlir/examples/dependent-memref-conv2d/artifacts/archive/${STAMP}" \
  --baseline-mlir-opt "${BASELINE_MLIR_OPT}" \
  --dependent-mlir-opt "${DEPENDENT_MLIR_OPT}"

