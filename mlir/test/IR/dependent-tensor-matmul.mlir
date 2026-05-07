// RUN: mlir-opt %s -verify-dependent-tensor-semantics | FileCheck %s

func.func @dependent_matmul_boundary(
    %m : index,
    %k : index,
    %n : index,
    %a : tensor<?x?xf32>,
    %b : tensor<?x?xf32>,
    %c : tensor<?x?xf32>) -> tensor<?x?xf32>
    #types[
      %a : #tensor<[%m, %k], f32>,
      %b : #tensor<[%k, %n], f32>,
      %c : #tensor<[%m, %n], f32>
    ] -> #tensor<[%m, %n], f32> {
  return %c : tensor<?x?xf32>
}

// CHECK-LABEL: func.func @dependent_matmul_boundary
// CHECK-SAME: (%[[M:arg[0-9]+]]: index, %[[K:arg[0-9]+]]: index, %[[N:arg[0-9]+]]: index
// CHECK-SAME: #types[%{{.*}} : #tensor<[%[[M]], %[[K]]], f32>, %{{.*}} : #tensor<[%[[K]], %[[N]]], f32>, %{{.*}} : #tensor<[%[[M]], %[[N]]], f32>] -> #tensor<[%[[M]], %[[N]]], f32>
// CHECK-NEXT: return %{{.*}} : tensor<?x?xf32>
