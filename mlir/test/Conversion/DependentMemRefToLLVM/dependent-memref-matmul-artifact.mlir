// RUN: mlir-opt %mlir_src_root/examples/dependent-memref-matmul/dependent-matmul.mlir -convert-dependent-tensor-to-dependent-memref -reconcile-unrealized-casts | FileCheck %s --check-prefix=SIG
// RUN: mlir-opt %mlir_src_root/examples/dependent-memref-matmul/dependent-matmul.mlir -convert-dependent-tensor-to-dependent-memref -lower-dependent-memref-to-llvm -reconcile-unrealized-casts -mlir-print-op-generic | FileCheck %s --check-prefix=DEP
// RUN: mlir-opt %mlir_src_root/examples/dependent-memref-matmul/baseline-tensor-matmul.mlir -pass-pipeline="builtin.module(one-shot-bufferize{bufferize-function-boundaries},func.func(convert-scf-to-cf,convert-arith-to-llvm),finalize-memref-to-llvm,convert-func-to-llvm,convert-cf-to-llvm,reconcile-unrealized-casts)" -mlir-print-op-generic | FileCheck %s --check-prefix=BASE

// SIG-LABEL: func.func @dependent_matmul_kernel
// SIG-SAME: (%{{.*}}: index, %{{.*}}: index, %{{.*}}: index, %{{.*}}: memref<?x?xf32>, %{{.*}}: memref<?x?xf32>, %{{.*}}: memref<?x?xf32>) -> memref<?x?xf32>
// SIG-SAME: #types[
// SIG-SAME: #memref<[
// SIG-SAME: #memref<[
// SIG-SAME: #memref<[
// SIG-SAME: ] -> #memref<[
// SIG-NOT: dependent_memref.reinterpret_cast

// DEP-LABEL: "llvm.func"() <{{.*}}function_type = !llvm.func<ptr (i64, i64, i64, ptr, ptr, ptr)>{{.*}}sym_name = "dependent_matmul_kernel"
// DEP-NOT: "dependent_tensor.
// DEP-NOT: "dependent_memref.
// DEP-NOT: "llvm.insertvalue"
// DEP-NOT: "llvm.extractvalue"
// DEP-NOT: !llvm.struct
// DEP-NOT: value = 0 : i64
// DEP-NOT: value = 1 : i64
// DEP: "llvm.getelementptr"(%{{.*}}, %{{.*}}) <{elem_type = f32{{.*}}> : (!llvm.ptr, i64) -> !llvm.ptr
// DEP: "llvm.load"(%{{.*}}) <{ordering = 0 : i64}> : (!llvm.ptr) -> f32
// DEP: "llvm.store"(%{{.*}}, %{{.*}}) <{ordering = 0 : i64}> : (f32, !llvm.ptr) -> ()
// DEP: "llvm.return"(%{{.*}}) : (!llvm.ptr) -> ()


// BASE-LABEL: "llvm.func"() <{{.*}}function_type = !llvm.func<struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
// BASE-SAME: sym_name = "baseline_matmul_kernel"
// BASE: !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
// BASE: "llvm.insertvalue"
// BASE: "llvm.extractvalue"
// BASE: "llvm.getelementptr"(%{{.*}}, %{{.*}}) <{elem_type = f32{{.*}}> : (!llvm.ptr, i64) -> !llvm.ptr
// BASE: "llvm.load"(%{{.*}}) <{ordering = 0 : i64}> : (!llvm.ptr) -> f32
// BASE: "llvm.store"(%{{.*}}, %{{.*}}) <{ordering = 0 : i64}> : (f32, !llvm.ptr) -> ()

