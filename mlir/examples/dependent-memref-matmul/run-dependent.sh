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
mkdir -p "${OUT_DIR}/direct-strided"

"${MLIR_OPT}" "${SCRIPT_DIR}/dependent-matmul.mlir" \
  -convert-dependent-tensor-to-dependent-memref \
  -lower-dependent-memref-to-llvm \
  -reconcile-unrealized-casts \
  -mlir-print-op-generic >"${OUT_DIR}/dependent.llvm.mlir"

"${MLIR_OPT}" "${SCRIPT_DIR}/dependent-matmul.mlir" \
  -convert-dependent-tensor-to-dependent-memref \
  -lower-dependent-memref-to-llvm \
  -reconcile-unrealized-casts |
  "${MLIR_TRANSLATE}" -mlir-to-llvmir >"${OUT_DIR}/dependent.ll"

"${LLVM_OPT}" -O3 -S "${OUT_DIR}/dependent.ll" -o "${OUT_DIR}/dependent.opt.ll"

cp "${SCRIPT_DIR}/dependent-strided-matmul.mlir" \
  "${OUT_DIR}/direct-strided/input.mlir"

"${MLIR_OPT}" "${SCRIPT_DIR}/dependent-strided-matmul.mlir" \
  -lower-dependent-memref-to-llvm \
  -reconcile-unrealized-casts \
  -mlir-print-op-generic >"${OUT_DIR}/direct-strided/dependent_matmul_strided.llvm.mlir"

"${MLIR_OPT}" "${SCRIPT_DIR}/dependent-strided-matmul.mlir" \
  -lower-dependent-memref-to-llvm \
  -reconcile-unrealized-casts |
  "${MLIR_TRANSLATE}" -mlir-to-llvmir >"${OUT_DIR}/direct-strided/dependent_matmul_strided.ll"

"${LLVM_OPT}" -O3 -S "${OUT_DIR}/direct-strided/dependent_matmul_strided.ll" \
  -o "${OUT_DIR}/direct-strided/dependent_matmul_strided.opt.ll"


"${CLANG}" -O3 -Wno-override-module -c "${OUT_DIR}/dependent.opt.ll" \
  -o "${OUT_DIR}/dependent.o"
"${CLANG}" -O3 -DDEPENDENT_KERNEL "${SCRIPT_DIR}/driver.c" \
  "${OUT_DIR}/dependent.o" -lm -o "${OUT_DIR}/dependent-runner"

if [[ "${BUILD_ONLY}" -eq 1 ]]; then
  exit 0
fi

"${OUT_DIR}/dependent-runner" dependent "${N}" "${K}" "${M}" "${REPEATS}"
