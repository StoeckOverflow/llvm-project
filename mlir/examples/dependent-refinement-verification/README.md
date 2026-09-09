# Dependent Refinement Verification Benchmark

This benchmark measures the compile-time overhead of property-backed dependent
memref refinement verification. It compares two generated memref kernels with
the same loop-nest shape:

- `baseline_memref`: flat `memref<?xf32>` buffers reinterpreted into ranked,
  dynamic-strided views, then ordinary `memref.load` / `memref.store`.
- `memref`: `dependent_memref.load` / `dependent_memref.store` with function
  boundary `#types` and per-operation `#memref` refinements.

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

Run from `mlir/examples/dependent-refinement-verification`:

```bash
python3 generate.py \
  --out artifacts/generated \
  --ranks 1 2 3 4 5 6 8

python3 run-benchmarks.py \
  --generated artifacts/generated \
  --out artifacts/runs/latest \
  --warmups 50 \
  --repetitions 1000

python3 plot.py \
  --input artifacts/runs/latest/summary.csv \
  --out artifacts/runs/latest/plots
```

The plotter emits exactly one paper-facing figure:

```text
verification-compile-time-vs-dimensions.pdf
verification-compile-time-vs-dimensions.png
```

The figure has two point/line series, `baseline memref` and `dependent memref`,
with memref dimensions on the x-axis and median full verifier-enabled MLIR
compile time on the y-axis.

## Timing Method

For each generated file, the runner first performs shuffled warmup executions
that are not recorded. It then shuffles all measured route/rank/repetition jobs
so baseline and dependent runs are interleaved.

Each measured execution uses the full verifier-enabled MLIR timing command and
writes the transformed IR to `/dev/null` to avoid per-repetition filesystem
output noise. The benchmark parses this timing output in memory; it does not
archive one timing file per repetition.

To manually inspect MLIR's raw timing report for any generated input, run:

```bash
build/bin/mlir-opt <input.mlir> \
  -pass-pipeline='builtin.module(verify-dependent-memref-refinements)' \
  -mlir-disable-threading \
  -mlir-timing \
  -mlir-timing-display=list \
  -o /dev/null
```

The CSV summary reports the MLIR timing `Total` entry and the verifier pass entry:

```text
median_total_ms
mean_total_ms
p25_total_ms
p75_total_ms
median_pass_ms
mean_pass_ms
```

The plotted value is `median_total_ms`. One untimed verified output is also
written per generated input under `run/verified/` for artifact inspection.

## Archive Layout

Use this layout for a dated artifact run:

```text
artifacts/archive/2026-09-09_verification-compile-time-single-kernel/
```

Produce it with:

```bash
python3 generate.py \
  --out artifacts/archive/2026-09-09_verification-compile-time-single-kernel/generated \
  --ranks 1 2 3 4 5 6 8

python3 run-benchmarks.py \
  --generated artifacts/archive/2026-09-09_verification-compile-time-single-kernel/generated \
  --out artifacts/archive/2026-09-09_verification-compile-time-single-kernel/run \
  --warmups 50 \
  --repetitions 1000

python3 plot.py \
  --input artifacts/archive/2026-09-09_verification-compile-time-single-kernel/run/summary.csv \
  --out artifacts/archive/2026-09-09_verification-compile-time-single-kernel/run/plots
```

The resulting artifact should contain:

```text
artifacts/archive/2026-09-09_verification-compile-time-single-kernel/generated/manifest.csv
artifacts/archive/2026-09-09_verification-compile-time-single-kernel/run/results.csv
artifacts/archive/2026-09-09_verification-compile-time-single-kernel/run/summary.csv
artifacts/archive/2026-09-09_verification-compile-time-single-kernel/run/verified/
artifacts/archive/2026-09-09_verification-compile-time-single-kernel/run/plots/verification-compile-time-vs-dimensions.pdf
artifacts/archive/2026-09-09_verification-compile-time-single-kernel/run/plots/verification-compile-time-vs-dimensions.png
```
