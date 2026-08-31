// RUN: mlir-opt %s | FileCheck %s --check-prefix=ROUNDTRIP
// RUN: mlir-opt %s -lower-dependent-memref-to-llvm -split-input-file -mlir-print-op-generic | FileCheck %s --check-prefix=LLVM

// ROUNDTRIP-LABEL: func.func @dependent_matmul_strided
// ROUNDTRIP: #types[
// ROUNDTRIP-SAME: #memref<[
// ROUNDTRIP-SAME: f32, offset: 0, strides: [
// ROUNDTRIP-SAME: #memref<[
// ROUNDTRIP-SAME: f32, offset: 0, strides: [
// ROUNDTRIP-SAME: #memref<[
// ROUNDTRIP-SAME: f32, offset: 0, strides: [

// LLVM-LABEL: "llvm.func"() <{{.*}}function_type = !llvm.func<void (i64, i64, i64, i64, i64, i64, i64, i64, i64, ptr, ptr, ptr)>{{.*}}sym_name = "dependent_matmul_strided"
// LLVM-NOT: dependent_memref
// LLVM-NOT: llvm.insertvalue
// LLVM-NOT: llvm.extractvalue
// LLVM-NOT: !llvm.struct
// LLVM: "llvm.mul"(%{{.*}}, %arg3)
// LLVM: "llvm.mul"(%{{.*}}, %arg4)
// LLVM: "llvm.add"
// LLVM: "llvm.getelementptr"(%arg9,
// LLVM: "llvm.load"
// LLVM: "llvm.mul"(%{{.*}}, %arg5)
// LLVM: "llvm.mul"(%{{.*}}, %arg6)
// LLVM: "llvm.add"
// LLVM: "llvm.getelementptr"(%arg10,
// LLVM: "llvm.load"
// LLVM: "llvm.fmul"
// LLVM: "llvm.fadd"
// LLVM: "llvm.mul"(%{{.*}}, %arg7)
// LLVM: "llvm.mul"(%{{.*}}, %arg8)
// LLVM: "llvm.add"
// LLVM: "llvm.getelementptr"(%arg11,
// LLVM: "llvm.store"
func.func @dependent_matmul_strided(
    %n : index, %m : index, %k : index,
    %as0 : index, %as1 : index,
    %bs0 : index, %bs1 : index,
    %cs0 : index, %cs1 : index,
    %A : memref<f32>,
    %B : memref<f32>,
    %C : memref<f32>)
    #types[
      %A : #memref<[%n, %k], f32, offset: 0, strides: [%as0, %as1]>,
      %B : #memref<[%k, %m], f32, offset: 0, strides: [%bs0, %bs1]>,
      %C : #memref<[%n, %m], f32, offset: 0, strides: [%cs0, %cs1]>
    ] {
  %zero = arith.constant 0.0 : f32
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index

  scf.for %i = %c0 to %n step %c1 {
    scf.for %j = %c0 to %m step %c1 {
      %sum = scf.for %p = %c0 to %k step %c1
          iter_args(%acc = %zero) -> (f32) {
        %a = dependent_memref.load %A[%i, %p]
            #memref<[%n, %k], f32, offset: 0, strides: [%as0, %as1]>
            : memref<f32> -> f32
        %b = dependent_memref.load %B[%p, %j]
            #memref<[%k, %m], f32, offset: 0, strides: [%bs0, %bs1]>
            : memref<f32> -> f32
        %mul = arith.mulf %a, %b : f32
        %next = arith.addf %acc, %mul : f32
        scf.yield %next : f32
      }
      dependent_memref.store %sum, %C[%i, %j]
          #memref<[%n, %m], f32, offset: 0, strides: [%cs0, %cs1]>
          : memref<f32>, f32
    }
  }
  return
}
