# Dependent MemRef Lowering Compile-Time Benchmark

This benchmark measures full MLIR lowering compile time for generated strided
memref contraction kernels. It compares two generated kernels with the same
loop-nest shape:

- `baseline_memref`: flat `memref<?xf32>` buffers reinterpreted into ranked,
  dynamic-strided views, then ordinary `memref.load` / `memref.store`, lowered
  through MLIR's native memref-to-LLVM pipeline.
- `memref`: ranked memref carriers with function-boundary `#types` and
  per-operation `#memref` refinements, checked by normal MLIR verification and
  dependent op verifiers, then lowered through the dependent memref-to-LLVM
  pipeline.

Each generated MLIR file contains exactly one `func.func`. The dependent kernels
intentionally do not attach loop-carried `#types`; this matches the paper kernel
shape and avoids measuring repeated full-rank loop annotations.

## Kernel Shape

For contraction rank `r`, each generated kernel uses:

```mlir
A : [a0, a1, ..., a{r-1}, k0, k1, ..., k{r-1}]
B : [k0, k1, ..., k{r-1}, b0, b1, ..., b{r-1}]
C : [a0, a1, ..., a{r-1}, b0, b1, ..., b{r-1}]
```

Thus `rank(A) = rank(B) = rank(C) = 2r`. The plot uses this actual memref rank
as the x-axis dimension count.

## Commands

Run from `mlir/examples/dependent-refinement-verification`. The baseline route
should use an upstream/main `mlir-opt`; the dependent route should use the
prototype `mlir-opt` from this branch. A convenient local setup is:

```bash
git worktree add ../../../../llvm-project-main main
cmake -S ../../../../llvm-project-main/llvm \
  -B ../../../../llvm-project-main/build_mlir_baseline \
  -G Ninja \
  -DLLVM_ENABLE_PROJECTS='mlir;clang' \
  -DLLVM_TARGETS_TO_BUILD=Native \
  -DCMAKE_BUILD_TYPE=Release \
  -DLLVM_ENABLE_ASSERTIONS=ON \
  -DLLVM_CCACHE_BUILD=ON \
  -DLLVM_BUILD_EXAMPLES=OFF \
  -DMLIR_ENABLE_BINDINGS_PYTHON=0
ninja -C ../../../../llvm-project-main/build_mlir_baseline mlir-opt
```

Then run the benchmark:

```bash
python3 generate.py \
  --out artifacts/runs/latest/generated_kernels \
  --ranks 2 4 8 16 32 64

python3 run-benchmarks.py \
  --generated artifacts/runs/latest/generated_kernels \
  --out artifacts/runs/latest \
  --baseline-mlir-opt ../../../../llvm-project-main/build_mlir_baseline/bin/mlir-opt \
  --dependent-mlir-opt ../../../build/bin/mlir-opt \
  --warmups 50 \
  --repetitions 1000

python3 plot.py \
  --input artifacts/runs/latest/summary.csv \
  --out artifacts/runs/latest/plots
```

The plotter emits one paper-facing figure:

```text
mlir-lowering-compile-time-vs-dimensions.pdf
mlir-lowering-compile-time-vs-dimensions.png
```

The figure has two point/line series, `baseline memref` and `dependent memref`,
with memref dimensions on the x-axis and median full MLIR lowering compile time
on the y-axis.

## Timing Method

For each generated file, the runner first performs shuffled warmup executions
that are not recorded. It then shuffles all measured route/rank/repetition jobs
so baseline and dependent runs are interleaved.

Each measured execution uses the route-specific full MLIR lowering command and
writes the transformed LLVM-dialect MLIR to `/dev/null` to avoid per-repetition
filesystem output noise. The benchmark parses MLIR's timing output in memory;
it does not archive one timing file per repetition.

To manually inspect MLIR's raw timing report for a baseline input, run:

```bash
../../../../llvm-project-main/build_mlir_baseline/bin/mlir-opt <baseline-input.mlir> \
  -pass-pipeline='builtin.module(func.func(convert-scf-to-cf,convert-arith-to-llvm),finalize-memref-to-llvm,convert-func-to-llvm,convert-cf-to-llvm,reconcile-unrealized-casts)' \
  -mlir-disable-threading \
  -mlir-timing \
  -mlir-timing-display=list \
  -o /dev/null
```

For a dependent input, run:

```bash
../../../build/bin/mlir-opt <dependent-input.mlir> \
  -pass-pipeline='builtin.module(func.func(convert-scf-to-cf,convert-arith-to-llvm),lower-dependent-memref-to-llvm,convert-func-to-llvm,convert-cf-to-llvm,reconcile-unrealized-casts)' \
  -mlir-disable-threading \
  -mlir-timing \
  -mlir-timing-display=list \
  -o /dev/null
```

The CSV summary reports the MLIR timing `Total` entry and median parser/output
buckets:

```text
median_total_ms
mean_total_ms
p25_total_ms
p75_total_ms
median_parser_ms
median_output_ms
median_rest_ms
```

The plotted value is `median_total_ms`. One lowered LLVM-dialect MLIR output is
also written per generated input under `lowered_kernels/` for artifact
inspection. One representative raw MLIR timing report per generated input is
written under `mlir_timing_outputs/`; each file starts with the exact command,
including the route-specific `mlir-opt` binary and full pass pipeline.

## Archive Layout

Use this layout for a dated artifact run:

```text
artifacts/archive/2026-09-09_18-09/
```

Produce it with:

```bash
python3 generate.py \
  --out artifacts/archive/2026-09-09_18-09/generated_kernels \
  --ranks 2 4 8 16 32 64

python3 run-benchmarks.py \
  --generated artifacts/archive/2026-09-09_18-09/generated_kernels \
  --out artifacts/archive/2026-09-09_18-09 \
  --baseline-mlir-opt ../../../../llvm-project-main/build_mlir_baseline/bin/mlir-opt \
  --dependent-mlir-opt ../../../build/bin/mlir-opt \
  --warmups 50 \
  --repetitions 1000

python3 plot.py \
  --input artifacts/archive/2026-09-09_18-09/summary.csv \
  --out artifacts/archive/2026-09-09_18-09/plots
```

The resulting artifact should contain:

```text
artifacts/archive/2026-09-09_18-09/generated_kernels/manifest.csv
artifacts/archive/2026-09-09_18-09/results.csv
artifacts/archive/2026-09-09_18-09/summary.csv
artifacts/archive/2026-09-09_18-09/lowered_kernels/
artifacts/archive/2026-09-09_18-09/mlir_timing_outputs/
artifacts/archive/2026-09-09_18-09/plots/mlir-lowering-compile-time-vs-dimensions.pdf
artifacts/archive/2026-09-09_18-09/plots/mlir-lowering-compile-time-vs-dimensions.png
artifacts/archive/2026-09-09_18-09/pass-timing-interpretation.md
artifacts/archive/2026-09-09_18-09/dependent-verification-coverage.md
```
