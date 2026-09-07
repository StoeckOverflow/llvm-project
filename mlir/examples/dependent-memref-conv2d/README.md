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
  flat memref buffers + #memref refinements -> descriptor-free LLVM
```

Run from the repository root:

```sh
mlir/examples/dependent-memref-conv2d/compare.py   --out mlir/examples/dependent-memref-conv2d/artifacts/archive/2026-09-07_14-39
```

The primary structural metrics are generated LLVM-dialect MLIR line count,
`llvm.insertvalue` count, and `llvm.extractvalue` count.
