#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(git -C "${SCRIPT_DIR}" rev-parse --show-toplevel)"
OUT_DIR="${OUT_DIR:-${SCRIPT_DIR}/artifacts}"
MLIR_OPT="${MLIR_OPT:-${REPO_ROOT}/build/bin/mlir-opt}"
MLIR_TRANSLATE="${MLIR_TRANSLATE:-${REPO_ROOT}/build/bin/mlir-translate}"
LLVM_OPT="${LLVM_OPT:-${REPO_ROOT}/build/bin/opt}"
CLANG="${CLANG:-${REPO_ROOT}/build/bin/clang}"
N="${N:-128}"
K="${K:-${N}}"
M="${M:-${N}}"
REPEATS="${REPEATS:-10}"
BUILD_ONLY=0
PIPELINE='builtin.module(one-shot-bufferize{bufferize-function-boundaries},func.func(convert-scf-to-cf,convert-arith-to-llvm),finalize-memref-to-llvm,convert-func-to-llvm,convert-cf-to-llvm,reconcile-unrealized-casts)'

while [[ $# -gt 0 ]]; do
  case "$1" in
  --out)
    OUT_DIR="$2"
    shift 2
    ;;
  --n)
    N="$2"
    shift 2
    ;;
  --k)
    K="$2"
    shift 2
    ;;
  --m)
    M="$2"
    shift 2
    ;;
  --repeats)
    REPEATS="$2"
    shift 2
    ;;
  --build-only)
    BUILD_ONLY=1
    shift
    ;;
  *)
    echo "unknown argument: $1" >&2
    exit 2
    ;;
  esac
done

mkdir -p "${OUT_DIR}"

"${MLIR_OPT}" "${SCRIPT_DIR}/baseline-tensor-matmul.mlir" \
  -pass-pipeline="${PIPELINE}" \
  -mlir-print-op-generic >"${OUT_DIR}/baseline.llvm.mlir"

"${MLIR_OPT}" "${SCRIPT_DIR}/baseline-tensor-matmul.mlir" \
  -pass-pipeline="${PIPELINE}" |
  "${MLIR_TRANSLATE}" -mlir-to-llvmir >"${OUT_DIR}/baseline.ll"

"${LLVM_OPT}" -O3 -S "${OUT_DIR}/baseline.ll" -o "${OUT_DIR}/baseline.opt.ll"

"${CLANG}" -O3 -Wno-override-module -c "${OUT_DIR}/baseline.opt.ll" \
  -o "${OUT_DIR}/baseline.o"
"${CLANG}" -O3 -DBASELINE_KERNEL "${SCRIPT_DIR}/driver.c" \
  "${OUT_DIR}/baseline.o" -lm -o "${OUT_DIR}/baseline-runner"

if [[ "${BUILD_ONLY}" -eq 1 ]]; then
  exit 0
fi

"${OUT_DIR}/baseline-runner" baseline "${N}" "${K}" "${M}" "${REPEATS}"
