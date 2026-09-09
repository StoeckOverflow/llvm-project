# Dependent MemRef Conv2D Structural Experiment

This artifact mirrors the matmul structural experiment for a Conv2D-shaped loop
nest. It is dry-run only: the scripts generate LLVM dialect, LLVM IR, optimized
LLVM IR, and descriptor-plumbing metrics, but they do not build or run a C
harness.

Routes:

```text
baseline
  tensor Conv2D -> one-shot-bufferize -> standard memref descriptors -> LLVM

dependent
  dependent tensor Conv2D -> dependent memref refinements -> descriptor-free LLVM

baseline-strided
  flat memref buffers -> memref.reinterpret_cast views -> standard memref descriptors -> LLVM

direct-strided
  ranked memref carriers + #memref refinements -> descriptor-free LLVM
```

Run from the repository root. Baseline routes should use the clean
upstream/main worktree build; dependent routes should use this branch's
prototype build:

```sh
mlir/examples/dependent-memref-conv2d/compare.py \
  --out mlir/examples/dependent-memref-conv2d/artifacts/archive/2026-09-08_timing-instrumentation \
  --baseline-mlir-opt ../llvm-project-main/build_mlir_baseline/bin/mlir-opt \
  --dependent-mlir-opt build/bin/mlir-opt
```

The primary structural metrics are generated LLVM-dialect MLIR line count,
`llvm.insertvalue` count, and `llvm.extractvalue` count. Each route also records
compile-time measurements. `results.json` records the `mlir-opt` binary and
pass pipeline used for each route:

```text
mlir_opt.wall_ms                  process wall time around mlir-opt
mlir_opt.pass_timing_total_ms     MLIR internal pass timing total
llvm_opt.wall_ms                  process wall time around LLVM opt -O3
llvm_opt.pass_timing_total_ms     LLVM internal pass timing total
```

The `*.mlir-timing.txt` files contain MLIR pass timing JSON from
`-mlir-disable-threading -mlir-timing -mlir-timing-display=list
-mlir-output-format=json`. The `*.opt-timing.txt` files contain LLVM
`-time-passes` reports.
