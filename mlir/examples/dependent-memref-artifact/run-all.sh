#!/usr/bin/env bash
set -euo pipefail

STAMP="${1:-$(date +%Y-%m-%d_%H-%M)}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

"${SCRIPT_DIR}/build-main-mlir.sh"
"${SCRIPT_DIR}/build-dependent-mlir.sh"
"${SCRIPT_DIR}/run-structural-experiments.sh" "${STAMP}"
"${SCRIPT_DIR}/run-verification-benchmark.sh" "${STAMP}"

echo "Artifact run complete: ${STAMP}"

