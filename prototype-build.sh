#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$ROOT_DIR/llvm"
BUILD_DIR="${BUILD_DIR:-$ROOT_DIR/../llvm-build-dependent-tensor-proto}"
JOBS="${JOBS:-2}"
CMAKE_BUILD_TYPE="${CMAKE_BUILD_TYPE:-Release}"
C_COMPILER="${C_COMPILER:-/usr/bin/cc}"
CXX_COMPILER="${CXX_COMPILER:-/usr/bin/c++}"

usage() {
  cat <<EOF
Usage: $(basename "$0") [configure|build|test|all]

Environment overrides:
  BUILD_DIR=/path/to/build-dir
  JOBS=2
  CMAKE_BUILD_TYPE=Release
  C_COMPILER=/usr/bin/cc
  CXX_COMPILER=/usr/bin/c++

Examples:
  $(basename "$0") configure
  JOBS=4 $(basename "$0") build
  JOBS=2 $(basename "$0") test
  $(basename "$0") all
EOF
}

configure_build() {
  mkdir -p "$BUILD_DIR"
  cmake -G Ninja \
    -S "$SOURCE_DIR" \
    -B "$BUILD_DIR" \
    -DCMAKE_BUILD_TYPE="$CMAKE_BUILD_TYPE" \
    -DLLVM_ENABLE_ASSERTIONS=ON \
    -DLLVM_ENABLE_PROJECTS=mlir \
    -DLLVM_TARGETS_TO_BUILD=host \
    -DMLIR_INCLUDE_TESTS=ON \
    -DCMAKE_C_COMPILER="$C_COMPILER" \
    -DCMAKE_CXX_COMPILER="$CXX_COMPILER"
}

build_proto() {
  ninja -C "$BUILD_DIR" -j "$JOBS" mlir-opt MLIRTestIR
}

test_proto() {
  "$BUILD_DIR/bin/llvm-lit" -sv \
    "$ROOT_DIR/mlir/test/IR/dependent-tensor-types.mlir" \
    "$ROOT_DIR/mlir/test/IR/dependent-tensor-transforms.mlir" \
    "$ROOT_DIR/mlir/test/IR/dependent-tensor-verifier-errors.mlir" \
    "$ROOT_DIR/mlir/test/IR/dependent-tensor-missing-owner.mlir" \
    "$ROOT_DIR/mlir/test/IR/dependent-tensor-missing-slot.mlir" \
    "$ROOT_DIR/mlir/test/IR/dependent-tensor-dead-anchor.mlir" \
    "$ROOT_DIR/mlir/test/IR/dependent-tensor-stale-anchor.mlir" \
    "$ROOT_DIR/mlir/test/IR/dependent-tensor-erase-owner-error.mlir" \
    "$ROOT_DIR/mlir/test/IR/dependent-tensor-erase-block-arg-error.mlir" \
    "$ROOT_DIR/mlir/test/IR/dependent-tensor-bulk-erase-block-args-error.mlir" \
    "$ROOT_DIR/mlir/test/IR/dependent-tensor-move-anchor-seed-error.mlir"
}

main() {
  local action="${1:-all}"
  case "$action" in
    configure)
      configure_build
      ;;
    build)
      build_proto
      ;;
    test)
      test_proto
      ;;
    all)
      configure_build
      build_proto
      test_proto
      ;;
    -h|--help|help)
      usage
      ;;
    *)
      echo "Unknown action: $action" >&2
      usage >&2
      exit 1
      ;;
  esac
}

main "$@"
