// RUN: mlir-opt %s -verify-dependent-tensor-semantics | FileCheck %s

func.func @dependent_matmul_kernel(
    %n : index,
    %k : index,
    %m : index,
    %A : tensor<?x?xf32>,
    %B : tensor<?x?xf32>,
    %Cinit : tensor<?x?xf32>) -> tensor<?x?xf32>
    #types[
      %A : #tensor<[%n, %k], f32>,
      %B : #tensor<[%k, %m], f32>,
      %Cinit : #tensor<[%n, %m], f32>
    ] -> #tensor<[%n, %m], f32> {
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  %Cout = scf.for %i = %c0 to %n step %c1 iter_args(%row = %Cinit) -> (tensor<?x?xf32>) {
    %next = scf.for %j = %c0 to %m step %c1 iter_args(%col = %row) -> (tensor<?x?xf32>) {
      %sum0 = arith.constant 0.000000e+00 : f32
      %sum = scf.for %p = %c0 to %k step %c1 iter_args(%acc = %sum0) -> (f32) {
        %a = dependent_tensor.extract %A[%i, %p] : f32
        %b = dependent_tensor.extract %B[%p, %j] : f32
        %mul = arith.mulf %a, %b : f32
        %next_acc = arith.addf %acc, %mul : f32
        scf.yield %next_acc : f32
      }
      %updated = dependent_tensor.insert %sum into %col[%i, %j] #tensor<[%n, %m], f32> : f32 into tensor<?x?xf32>
      scf.yield %updated : tensor<?x?xf32>
    }
    scf.yield %next : tensor<?x?xf32>
  }
  return %Cout : tensor<?x?xf32>
}

// CHECK-LABEL: func.func @dependent_matmul_kernel
// CHECK-SAME: (%[[N:arg[0-9]+]]: index, %[[K:arg[0-9]+]]: index, %[[M:arg[0-9]+]]: index
// CHECK-SAME: #types[%{{.*}} : #tensor<[%[[N]], %[[K]]], f32>, %{{.*}} : #tensor<[%[[K]], %[[M]]], f32>, %{{.*}} : #tensor<[%[[N]], %[[M]]], f32>] -> #tensor<[%[[N]], %[[M]]], f32>
// CHECK: scf.for
// CHECK: scf.for
// CHECK: scf.for
// CHECK: dependent_tensor.extract
// CHECK: arith.mulf
// CHECK: arith.addf
// CHECK: dependent_tensor.insert
// CHECK-NOT: dependent_tensor.matmul
// CHECK-NOT: dependent_tensor.gemm

// -----

func.func @call_dependent_matmul_kernel(
    %n : index,
    %k : index,
    %m : index) -> tensor<?x?xf32>
    #types[] -> #tensor<[%n, %m], f32> {
  %A = dependent_tensor.make () #tensor<[%n, %k], f32> : tensor<?x?xf32>
  %B = dependent_tensor.make () #tensor<[%k, %m], f32> : tensor<?x?xf32>
  %C = dependent_tensor.make () #tensor<[%n, %m], f32> : tensor<?x?xf32>
  %R = func.call @dependent_matmul_kernel(%n, %k, %m, %A, %B, %C)
      : (index, index, index, tensor<?x?xf32>, tensor<?x?xf32>, tensor<?x?xf32>) -> tensor<?x?xf32>
  return %R : tensor<?x?xf32>
}

// CHECK-LABEL: func.func @call_dependent_matmul_kernel
// CHECK-SAME: #types[] -> #tensor<[%{{.*}}, %{{.*}}], f32>
// CHECK: call @dependent_matmul_kernel
