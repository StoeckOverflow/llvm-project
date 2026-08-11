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

For paper/artifact performance numbers, use the larger sweep:

```sh
mlir/examples/dependent-memref-matmul/run-benchmarks.py --paper
```

`--paper` runs 30 repeats for:

```text
512x512x512
1024x1024x1024
2048x2048x2048
4096x4096x4096
```

This can take a long time and should be run on a quiet machine. Use
`--paper --repeats 10` for a faster dry run. For non-paper sweeps, `--large`
adds the 1024 case to the default/custom size list.

Benchmark outputs are stored under:

```text
artifacts/benchmarks/
  summary.json
  summary.md
  size-512/results.json
  size-1024/results.json
  size-2048/results.json
  size-4096/results.json
```

Use `--skip-run` to collect lowering/code-size metrics without executing the
kernels.

Generate the two paper-facing plots from a benchmark summary with:

```sh
mlir/examples/dependent-memref-matmul/plot-benchmarks.py \
  mlir/examples/dependent-memref-matmul/artifacts/benchmarks/summary.json
```

The plotting script writes PDF and PNG files by default:

```text
artifacts/benchmarks/plots/
  performance-stacked.pdf
  performance-stacked.png
  llvm-line-count.pdf
  llvm-line-count.png
```

`performance-stacked` shows, for each matrix size, one dependent bar and one
baseline bar. Each bar stacks three costs in milliseconds:

```text
MLIR lowering      time spent in mlir-opt lowering to the LLVM dialect
LLVM opt -O3       time spent in LLVM opt -O3 on the emitted LLVM IR
kernel execution   median time for one generated matmul kernel call
```

The first two segments are compile-time costs; the last segment is runtime. The
stacked bar is therefore a "compile once, execute once" view, useful for seeing
where each path spends time. For pure runtime claims, compare only the kernel
execution segment or the `run.median_ns` values in `summary.json`.

`llvm-line-count` compares only the optimized LLVM IR line count for dependent
versus baseline.

Use `--formats pdf` or `--formats svg png` to choose output formats. Add
`--debug-plots` to also generate the more detailed diagnostic plots for runtime,
compile-time, IR size, and descriptor-operation counts. The script requires
matplotlib and prints an installation hint if it is missing.

For artifact packaging, keep the scripts in the repository and include the
machine-generated benchmark directory in the artifact bundle:

```sh
tar -czf dependent-memref-matmul-benchmarks.tar.gz \
  mlir/examples/dependent-memref-matmul/artifacts/benchmarks
```

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
