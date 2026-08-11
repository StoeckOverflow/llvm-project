# Dependent MemRef Matmul Experiment

This artifact compares the ScaIR-style dependent path against the standard MLIR
tensor-to-memref path for the same scalar matmul loop nest.

The dependent path is:

```text
dependent_tensor -> dependent_memref -> LLVM dialect -> LLVM IR -> opt -O3
```

The baseline path is:

```text
tensor -> one-shot-bufferize -> memref -> LLVM dialect -> LLVM IR -> opt -O3
```

Run the comparison from the repository root:

```sh
mlir/examples/dependent-memref-matmul/compare.py --n 128 --k 128 --m 128 --repeats 10
```


For a benchmark sweep, use:

```sh
mlir/examples/dependent-memref-matmul/run-benchmarks.py
```

The benchmark runner defaults to 30 repeats for each square size:

```text
128x128x128
256x256x256
512x512x512
```

Add the larger 1024 case with:

```sh
mlir/examples/dependent-memref-matmul/run-benchmarks.py --large
```

Benchmark outputs are stored under:

```text
artifacts/benchmarks/
  summary.json
  summary.md
  size-128/results.json
  size-256/results.json
  size-512/results.json
```

Use `--skip-run` to collect lowering/code-size metrics without executing the
kernels.

The scripts save generated artifacts under
`mlir/examples/dependent-memref-matmul/artifacts/`:

```text
dependent.llvm.mlir
dependent.ll
dependent.opt.ll
dependent-strided.llvm.mlir
dependent-strided.ll
dependent-strided.opt.ll
baseline.llvm.mlir
baseline.ll
baseline.opt.ll
results.json
```

The primary structural metric is descriptor traffic. The dependent lowering keeps
memrefs as bare `!llvm.ptr` values and emits no `llvm.insertvalue` or
`llvm.extractvalue` descriptor construction. The standard baseline intentionally
uses standard memref descriptors.

`compare.py` reports both raw LLVM IR metrics and post-`opt -O3` metrics. The raw
metrics show the direct lowering shape; the optimized metrics are the fairer
place to compare generated code after both paths have seen the same LLVM
optimization pipeline.

Descriptor-operation counts are literal textual instruction counts in the saved
IR files. For example, `llvm_opt_ir_insertvalue` counts occurrences of the
substring `insertvalue` in `*.opt.ll`; it can differ from the raw LLVM dialect
counts because LLVM optimization may fold some descriptor extraction or
construction.

Timing fields are intentionally split:

```text
mlir_opt.wall_ms   time spent in the MLIR lowering pipeline
llvm_opt.wall_ms   time spent in common LLVM opt -O3
run.median_ns      median kernel execution time from the C harness
```

Small matrix runtimes are only smoke checks. Use larger matrices and more
repeats for performance claims.
