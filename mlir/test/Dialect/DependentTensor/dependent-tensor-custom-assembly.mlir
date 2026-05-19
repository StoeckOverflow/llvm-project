// RUN: mlir-opt %s | FileCheck %s

func.func @make_from_constants() {
  %n = arith.constant 4 : index
  %m = arith.constant 8 : index
  %A = dependent_tensor.make () #tensor<[%n, %m], f32> : tensor<?x?xf32>
  return
}

// CHECK-LABEL: func.func @make_from_constants
// CHECK-NEXT: %[[N:.*]] = arith.constant 4 : index
// CHECK-NEXT: %[[M:.*]] = arith.constant 8 : index
// CHECK-NEXT: %[[A:.*]] = dependent_tensor.make () #tensor<[%[[N]], %[[M]]], f32> : tensor<?x?xf32>
// CHECK-NEXT: return

// -----

func.func @matmul_kernel(
    %m : index,
    %k : index,
    %n : index,
    %A : tensor<?x?xf32>,
    %B : tensor<?x?xf32>,
    %Cinit : tensor<?x?xf32>) -> tensor<?x?xf32>
    #types[
        %A : #tensor<[%m, %k], f32>,
        %B : #tensor<[%k, %n], f32>,
        %Cinit : #tensor<[%m, %n], f32>,
    ] -> #tensor<[%m, %n], f32>
    {
      return %Cinit : tensor<?x?xf32>
    }

// CHECK-LABEL: func.func @matmul_kernel
// CHECK-SAME: (%[[M:arg[0-9]+]]: index, %[[K:arg[0-9]+]]: index, %[[N:arg[0-9]+]]: index,
// CHECK-SAME:  %[[A:arg[0-9]+]]: tensor<?x?xf32>, %[[B:arg[0-9]+]]: tensor<?x?xf32>, %[[C:arg[0-9]+]]: tensor<?x?xf32>) -> tensor<?x?xf32>
// CHECK-SAME: #types[%[[A]] : #tensor<[%[[M]], %[[K]]], f32>, %[[B]] : #tensor<[%[[K]], %[[N]]], f32>, %[[C]] : #tensor<[%[[M]], %[[N]]], f32>] -> #tensor<[%[[M]], %[[N]]], f32>
// CHECK-NEXT: return %[[C]] : tensor<?x?xf32>
