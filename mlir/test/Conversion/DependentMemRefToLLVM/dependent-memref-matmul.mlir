// RUN: mlir-opt %s -lower-dependent-memref-to-llvm -split-input-file -mlir-print-op-generic | FileCheck %s

func.func @matmul(%n : index, %m : index, %k : index,
                  %as0 : index, %as1 : index, %bs0 : index, %bs1 : index,
                  %cs0 : index, %cs1 : index,
                  %A : memref<?x?xf32>, %B : memref<?x?xf32>, %C : memref<?x?xf32>) {
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  %zero = arith.constant 0.0 : f32
  scf.for %i = %c0 to %n step %c1 {
    scf.for %j = %c0 to %m step %c1 {
      %sum = scf.for %kk = %c0 to %k step %c1 iter_args(%acc = %zero) -> (f32) {
        %a = dependent_memref.load %A[%i, %kk] #memref<[%n, %k], f32, offset: 0, strides: [%as0, %as1]> : memref<?x?xf32> -> f32
        %b = dependent_memref.load %B[%kk, %j] #memref<[%k, %m], f32, offset: 0, strides: [%bs0, %bs1]> : memref<?x?xf32> -> f32
        %mul = arith.mulf %a, %b : f32
        %next = arith.addf %acc, %mul : f32
        scf.yield %next : f32
      }
      dependent_memref.store %sum, %C[%i, %j] #memref<[%n, %m], f32, offset: 0, strides: [%cs0, %cs1]> : memref<?x?xf32>, f32
    }
  }
  return
}

// CHECK-LABEL: "llvm.func"() <{{.*}}function_type = !llvm.func<void (i64, i64, i64, i64, i64, i64, i64, i64, i64, ptr, ptr, ptr)>{{.*}}sym_name = "matmul"
// CHECK-NOT: "dependent_memref.
// CHECK-NOT: "llvm.extractvalue"
// CHECK-NOT: "llvm.insertvalue"
// CHECK: "llvm.icmp"(%{{.*}}, %{{.*}}) <{predicate = 2 : i64}> : (i64, i64) -> i1
// CHECK: "llvm.mul"(%{{.*}}, %{{.*}}) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
// CHECK: "llvm.getelementptr"(%{{.*}}, %{{.*}}) <{elem_type = f32{{.*}}> : (!llvm.ptr, i64) -> !llvm.ptr
// CHECK: "llvm.load"(%{{.*}}) <{ordering = 0 : i64}> : (!llvm.ptr) -> f32
// CHECK: "llvm.getelementptr"(%{{.*}}, %{{.*}}) <{elem_type = f32{{.*}}> : (!llvm.ptr, i64) -> !llvm.ptr
// CHECK: "llvm.load"(%{{.*}}) <{ordering = 0 : i64}> : (!llvm.ptr) -> f32
// CHECK: "llvm.fmul"(%{{.*}}, %{{.*}}) <{fastmathFlags = #llvm.fastmath<none>}> : (f32, f32) -> f32
// CHECK: "llvm.fadd"(%{{.*}}, %{{.*}}) <{fastmathFlags = #llvm.fastmath<none>}> : (f32, f32) -> f32
// CHECK: "llvm.getelementptr"(%{{.*}}, %{{.*}}) <{elem_type = f32{{.*}}> : (!llvm.ptr, i64) -> !llvm.ptr
// CHECK: "llvm.store"(%{{.*}}, %{{.*}}) <{ordering = 0 : i64}> : (f32, !llvm.ptr) -> ()
// CHECK: "llvm.return"() : () -> ()
