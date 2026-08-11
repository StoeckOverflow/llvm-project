// RUN: mlir-opt %mlir_src_root/examples/dependent-memref-matmul/dependent-matmul.mlir -convert-dependent-tensor-to-dependent-memref -lower-dependent-memref-to-llvm -reconcile-unrealized-casts -mlir-print-op-generic | FileCheck %s --check-prefix=DEP
// RUN: mlir-opt %mlir_src_root/examples/dependent-memref-matmul/dependent-strided-matmul.mlir -lower-dependent-memref-to-llvm -reconcile-unrealized-casts -mlir-print-op-generic | FileCheck %s --check-prefix=STRIDED
// RUN: mlir-opt %mlir_src_root/examples/dependent-memref-matmul/baseline-tensor-matmul.mlir -pass-pipeline="builtin.module(one-shot-bufferize{bufferize-function-boundaries},func.func(convert-scf-to-cf,convert-arith-to-llvm),finalize-memref-to-llvm,convert-func-to-llvm,convert-cf-to-llvm,reconcile-unrealized-casts)" -mlir-print-op-generic | FileCheck %s --check-prefix=BASE

// DEP-LABEL: "llvm.func"() <{{.*}}function_type = !llvm.func<ptr (i64, i64, i64, ptr, ptr, ptr)>{{.*}}sym_name = "dependent_matmul_kernel"
// DEP-NOT: "dependent_tensor.
// DEP-NOT: "dependent_memref.
// DEP-NOT: "llvm.insertvalue"
// DEP-NOT: "llvm.extractvalue"
// DEP-NOT: !llvm.struct
// DEP: "llvm.getelementptr"(%{{.*}}, %{{.*}}) <{elem_type = f32{{.*}}> : (!llvm.ptr, i64) -> !llvm.ptr
// DEP: "llvm.load"(%{{.*}}) <{ordering = 0 : i64}> : (!llvm.ptr) -> f32
// DEP: "llvm.store"(%{{.*}}, %{{.*}}) <{ordering = 0 : i64}> : (f32, !llvm.ptr) -> ()
// DEP: "llvm.return"(%{{.*}}) : (!llvm.ptr) -> ()

// STRIDED-LABEL: "llvm.func"() <{{.*}}function_type = !llvm.func<void (i64, i64, i64, i64, i64, i64, i64, i64, i64, ptr, ptr, ptr)>{{.*}}sym_name = "dependent_matmul_strided"
// STRIDED-NOT: "dependent_memref.
// STRIDED-NOT: "llvm.insertvalue"
// STRIDED-NOT: "llvm.extractvalue"
// STRIDED: "llvm.call"(%{{.*}}) <{{.*}}callee = @dependent_matmul_strided_typed{{.*}}> : (i64, i64, i64, i64, i64, i64, i64, i64, i64, !llvm.ptr, !llvm.ptr, !llvm.ptr) -> ()
// STRIDED-LABEL: "llvm.func"() <{{.*}}function_type = !llvm.func<void (i64, i64, i64, i64, i64, i64, i64, i64, i64, ptr, ptr, ptr)>{{.*}}sym_name = "dependent_matmul_strided_typed"
// STRIDED-NOT: "dependent_memref.
// STRIDED: "llvm.mul"(%{{.*}}, %{{.*}}) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
// STRIDED: "llvm.getelementptr"(%{{.*}}, %{{.*}}) <{elem_type = f32{{.*}}> : (!llvm.ptr, i64) -> !llvm.ptr
// STRIDED: "llvm.load"(%{{.*}}) <{ordering = 0 : i64}> : (!llvm.ptr) -> f32
// STRIDED: "llvm.store"(%{{.*}}, %{{.*}}) <{ordering = 0 : i64}> : (f32, !llvm.ptr) -> ()

// BASE-LABEL: "llvm.func"() <{{.*}}function_type = !llvm.func<struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
// BASE-SAME: sym_name = "baseline_matmul_kernel"
// BASE: !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
// BASE: "llvm.insertvalue"
// BASE: "llvm.extractvalue"
// BASE: "llvm.getelementptr"(%{{.*}}, %{{.*}}) <{elem_type = f32{{.*}}> : (!llvm.ptr, i64) -> !llvm.ptr
// BASE: "llvm.load"(%{{.*}}) <{ordering = 0 : i64}> : (!llvm.ptr) -> f32
// BASE: "llvm.store"(%{{.*}}, %{{.*}}) <{ordering = 0 : i64}> : (f32, !llvm.ptr) -> ()

