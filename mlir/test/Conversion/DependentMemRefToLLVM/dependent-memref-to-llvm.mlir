// RUN: mlir-opt %s -lower-dependent-memref-to-llvm -split-input-file -mlir-print-op-generic | FileCheck %s

func.func @load_store(%n : index, %m : index, %s0 : index, %s1 : index, %A : memref<?x?xf32>, %C : memref<?x?xf32>) {
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  %a = dependent_memref.load %A[%c0, %c1] #memref<[%n, %m], f32, offset: 0, strides: [%s0, %s1]> : memref<?x?xf32> -> f32
  dependent_memref.store %a, %C[%c1, %c0] #memref<[%n, %m], f32, offset: 0, strides: [%s0, %s1]> : memref<?x?xf32>, f32
  return
}

// CHECK-DAG: "llvm.func"() <{{.*}}sym_name = "malloc"
// CHECK-DAG: "llvm.func"() <{{.*}}sym_name = "free"
// CHECK-LABEL: "llvm.func"() <{{.*}}function_type = !llvm.func<void (i64, i64, i64, i64, ptr, ptr)>{{.*}}sym_name = "load_store"
// CHECK-NOT: "llvm.extractvalue"
// CHECK-NOT: "llvm.insertvalue"
// CHECK-NOT: "dependent_memref.
// CHECK: "llvm.getelementptr"(%{{.*}}, %{{.*}}) <{elem_type = f32{{.*}}> : (!llvm.ptr, i64) -> !llvm.ptr
// CHECK: "llvm.load"(%{{.*}}) <{ordering = 0 : i64}> : (!llvm.ptr) -> f32
// CHECK: "llvm.getelementptr"(%{{.*}}, %{{.*}}) <{elem_type = f32{{.*}}> : (!llvm.ptr, i64) -> !llvm.ptr
// CHECK: "llvm.store"(%{{.*}}, %{{.*}}) <{ordering = 0 : i64}> : (f32, !llvm.ptr) -> ()
// CHECK: "llvm.return"() : () -> ()


func.func @alloc_free(%n : index, %m : index) {
  %A = dependent_memref.alloc #memref<[%n, %m], f32> : memref<?x?xf32>
  dependent_memref.dealloc %A : memref<?x?xf32>
  return
}

// CHECK-LABEL: "llvm.func"() <{{.*}}function_type = !llvm.func<void (i64, i64)>{{.*}}sym_name = "alloc_free"
// CHECK-NOT: "llvm.extractvalue"
// CHECK-NOT: "llvm.insertvalue"
// CHECK: "llvm.call"(%{{.*}}) <{{.*}}callee = @malloc{{.*}}> : (i64) -> !llvm.ptr
// CHECK: "llvm.call"(%{{.*}}) <{{.*}}callee = @free{{.*}}> : (!llvm.ptr) -> ()
// CHECK: "llvm.return"() : () -> ()
