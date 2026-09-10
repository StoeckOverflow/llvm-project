# Dependent MemRef Artifact Harness

This directory contains convenience scripts for reproducing the dependent
memref artifact experiments with two MLIR builds:

- baseline routes use a clean upstream/main worktree build
- dependent routes use this branch's prototype build

The scripts assume this repository lives next to a main worktree at
`../llvm-project-main`, matching the archived benchmark metadata. Paths can be
overridden with environment variables.

## Dependencies

Install the usual LLVM build dependencies:

```bash
sudo apt-get update
sudo apt-get install -y git cmake ninja-build clang lld ccache python3 python3-matplotlib
```

## Build

From the repository root:

```bash
mlir/examples/dependent-memref-artifact/build-main-mlir.sh
mlir/examples/dependent-memref-artifact/build-dependent-mlir.sh
```

`build-main-mlir.sh` creates `../llvm-project-main` from branch `main` if the
worktree does not already exist, configures it in
`../llvm-project-main/build_mlir_baseline`, and builds `mlir-opt`.

`build-dependent-mlir.sh` configures this checkout in `build` and builds
`mlir-opt`, `mlir-translate`, `opt`, and `clang`.

## Run Everything

```bash
mlir/examples/dependent-memref-artifact/run-all.sh 2026-09-09_18-09-reproduced
```

This creates new archive folders with the given stamp:

```text
mlir/examples/dependent-memref-matmul/artifacts/archive/<stamp>
mlir/examples/dependent-memref-conv2d/artifacts/archive/<stamp>
mlir/examples/dependent-refinement-verification/artifacts/archive/<stamp>
```

## Fast Smoke Mode

To run only a short verification benchmark:

```bash
REPETITIONS=10 WARMUPS=1 \
  mlir/examples/dependent-memref-artifact/run-verification-benchmark.sh smoke
```

Matmul and Conv2D structural experiments are dry-run style here: they generate
compiler artifacts and structural metrics, but do not run the matmul C harness.

## Individual Runs

```bash
mlir/examples/dependent-memref-artifact/run-structural-experiments.sh 2026-09-09_18-09-reproduced
mlir/examples/dependent-memref-artifact/run-verification-benchmark.sh 2026-09-09_18-09-reproduced
```

The verification benchmark records the exact route-specific `mlir-opt` binaries
and full pass pipelines in `run_config.json` and in the representative raw MLIR
timing files under `mlir_timing_outputs/`.

## Path Overrides

The scripts accept these environment variables:

```text
MAIN_WORKTREE       default: ../llvm-project-main
MAIN_BUILD          default: ${MAIN_WORKTREE}/build_mlir_baseline
DEPENDENT_BUILD     default: ./build
BASELINE_MLIR_OPT   default: ${MAIN_BUILD}/bin/mlir-opt
DEPENDENT_MLIR_OPT  default: ${DEPENDENT_BUILD}/bin/mlir-opt
REPETITIONS         default: 1000 for verification
WARMUPS             default: 50 for verification
```

