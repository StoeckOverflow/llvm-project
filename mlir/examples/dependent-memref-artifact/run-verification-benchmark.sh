#!/usr/bin/env bash
set -euo pipefail

STAMP="${1:-$(date +%Y-%m-%d_%H-%M)}"
ROOT="$(git rev-parse --show-toplevel)"
EXP="${ROOT}/mlir/examples/dependent-refinement-verification"
OUT="${EXP}/artifacts/archive/${STAMP}"
MAIN_WORKTREE="${MAIN_WORKTREE:-${ROOT}/../llvm-project-main}"
MAIN_BUILD="${MAIN_BUILD:-${MAIN_WORKTREE}/build_mlir_baseline}"
DEPENDENT_BUILD="${DEPENDENT_BUILD:-${ROOT}/build}"
BASELINE_MLIR_OPT="${BASELINE_MLIR_OPT:-${MAIN_BUILD}/bin/mlir-opt}"
DEPENDENT_MLIR_OPT="${DEPENDENT_MLIR_OPT:-${DEPENDENT_BUILD}/bin/mlir-opt}"

python3 "${EXP}/generate.py" \
  --out "${OUT}/generated_kernels" \
  --ranks 2 4 8 16 32 64

python3 "${EXP}/run-benchmarks.py" \
  --generated "${OUT}/generated_kernels" \
  --out "${OUT}" \
  --baseline-mlir-opt "${BASELINE_MLIR_OPT}" \
  --dependent-mlir-opt "${DEPENDENT_MLIR_OPT}" \
  --warmups "${WARMUPS:-50}" \
  --repetitions "${REPETITIONS:-1000}"

python3 "${EXP}/plot.py" \
  --input "${OUT}/summary.csv" \
  --out "${OUT}/plots"

