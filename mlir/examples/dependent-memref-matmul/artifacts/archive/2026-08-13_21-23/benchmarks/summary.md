# Dependent MemRef Matmul Benchmark Summary

Generated: `2026-08-13T18:00:09.320739+00:00`
Repeats: `30`
Sizes: `512, 1024, 2048, 4096`

| size | dep ns | base ns | base/dep | dep MLIR ms | base MLIR ms | dep opt lines | base opt lines | dep desc | base desc | base opt desc |
| ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 512 | 73893470 | 73666096 | 1.00 | 10.27 | 15.32 | 72 | 97 | 0 | 33 | 7 |
| 1024 | 2850597958 | 2919927170 | 1.02 | 12.35 | 15.36 | 72 | 97 | 0 | 33 | 7 |
| 2048 | 23958542533 | 24629127785 | 1.03 | 11.35 | 12.06 | 72 | 97 | 0 | 33 | 7 |
| 4096 | 566730314611 | 549159620372 | 0.97 | 12.98 | 14.54 | 72 | 97 | 0 | 33 | 7 |

`base/dep` above is `baseline median ns / dependent median ns`; values
larger than 1 mean the dependent executable was faster for that run.
Descriptor counts are textual counts in the generated IR artifacts.
