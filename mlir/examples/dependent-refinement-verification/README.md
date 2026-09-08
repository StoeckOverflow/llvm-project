# Dependent Refinement Verification Benchmark

This microbenchmark isolates refinement verification cost from the lowering
pipelines. It generates rank-polymorphic generalized contractions for both
`dependent_tensor` and `dependent_memref`, then times only the verifier pass
using MLIR pass timing.

For contraction rank `r`, the generated kernels use the shape relation:

```mlir
A : [a0, a1, ..., a{r-1}, k0, k1, ..., k{r-1}]
B : [k0, k1, ..., k{r-1}, b0, b1, ..., b{r-1}]
C : [a0, a1, ..., a{r-1}, b0, b1, ..., b{r-1}]
```

Thus `rank(A) = rank(B) = rank(C) = 2r`. The benchmark grows both the
free dimensions and the contracted dimensions, instead of only adding batch
dimensions around a fixed 2D matmul or keeping a single contracted axis.

```bash
python3 generate.py --out artifacts/generated --ranks 1 2 3 4 5 6 --kernels 16
python3 run-benchmarks.py --generated artifacts/generated --out artifacts/runs/small --repetitions 5
python3 plot.py --input artifacts/runs/small/summary.csv --out artifacts/runs/small/plots
```
