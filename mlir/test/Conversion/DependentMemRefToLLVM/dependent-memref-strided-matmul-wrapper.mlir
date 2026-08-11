// RUN: mlir-opt %s -lower-dependent-memref-to-llvm -split-input-file -mlir-print-op-generic | FileCheck %s

func.func @matmul_strided(%n : index, %m : index, %k : index,
                          %as0 : index, %as1 : index, %bs0 : index, %bs1 : index,
                          %cs0 : index, %cs1 : index,
                          %Aflat : memref<f32>, %Bflat : memref<f32>, %Cflat : memref<f32>) {
  %A = dependent_memref.reinterpret_cast %Aflat, #memref<[%n, %k], f32, offset: 0, strides: [%as0, %as1]> : memref<f32> to memref<?x?xf32>
  %B = dependent_memref.reinterpret_cast %Bflat, #memref<[%k, %m], f32, offset: 0, strides: [%bs0, %bs1]> : memref<f32> to memref<?x?xf32>
  %C = dependent_memref.reinterpret_cast %Cflat, #memref<[%n, %m], f32, offset: 0, strides: [%cs0, %cs1]> : memref<f32> to memref<?x?xf32>
  func.call @matmul_strided_typed(%n, %m, %k, %as0, %as1, %bs0, %bs1, %cs0, %cs1, %A, %B, %C) : (index, index, index, index, index, index, index, index, index, memref<?x?xf32>, memref<?x?xf32>, memref<?x?xf32>) -> ()
  return
}

func.func @matmul_strided_typed(%n : index, %m : index, %k : index,
                                %as0 : index, %as1 : index, %bs0 : index, %bs1 : index,
                                %cs0 : index, %cs1 : index,
                                %A : memref<?x?xf32>, %B : memref<?x?xf32>, %C : memref<?x?xf32>) {
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  %zero = arith.constant 0.0 : f32
  scf.for %i = %c0 to %n step %c1 {
    scf.for %j = %c0 to %m step %c1 {
      %sum = scf.for %p = %c0 to %k step %c1 iter_args(%acc = %zero) -> (f32) {
        %a = dependent_memref.load %A[%i, %p] #memref<[%n, %k], f32, offset: 0, strides: [%as0, %as1]> : memref<?x?xf32> -> f32
        %b = dependent_memref.load %B[%p, %j] #memref<[%k, %m], f32, offset: 0, strides: [%bs0, %bs1]> : memref<?x?xf32> -> f32
        %mul = arith.mulf %a, %b : f32
        %next = arith.addf %acc, %mul : f32
        scf.yield %next : f32
      }
      dependent_memref.store %sum, %C[%i, %j] #memref<[%n, %m], f32, offset: 0, strides: [%cs0, %cs1]> : memref<?x?xf32>, f32
    }
  }
  return
}

// CHECK-LABEL: "llvm.func"() <{{.*}}function_type = !llvm.func<void (i64, i64, i64, i64, i64, i64, i64, i64, i64, ptr, ptr, ptr)>{{.*}}sym_name = "matmul_strided"
// CHECK-NOT: "dependent_memref.
// CHECK: "llvm.call"(%{{.*}}) <{{.*}}callee = @matmul_strided_typed{{.*}}> : (i64, i64, i64, i64, i64, i64, i64, i64, i64, !llvm.ptr, !llvm.ptr, !llvm.ptr) -> ()
// CHECK: "llvm.return"() : () -> ()

// CHECK-LABEL: "llvm.func"() <{{.*}}function_type = !llvm.func<void (i64, i64, i64, i64, i64, i64, i64, i64, i64, ptr, ptr, ptr)>{{.*}}sym_name = "matmul_strided_typed"
// CHECK-NOT: "dependent_memref.
// CHECK-NOT: "arith.
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
