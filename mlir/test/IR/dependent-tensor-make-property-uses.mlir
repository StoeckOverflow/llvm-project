// RUN: mlir-opt %s -pass-pipeline='builtin.module(func.func(test-dependent-tensor-check-property-uses))' | FileCheck %s

func.func @check_make_dims_property_only(%m : index, %n : index) -> tensor<?x?xf32>
    #types[] -> #tensor<[%m, %n], f32> {
  %t = dependent_tensor.make () #tensor<[%m, %n], f32> : tensor<?x?xf32>
  return %t : tensor<?x?xf32>
}

// CHECK-LABEL: func.func @check_make_dims_property_only
// CHECK-SAME: (%[[M:arg[0-9]+]]: index, %[[N:arg[0-9]+]]: index) -> tensor<?x?xf32>
// CHECK-SAME: #types[] -> #tensor<[%[[M]], %[[N]]], f32>
// CHECK: dependent_tensor.make () #tensor<[%[[M]], %[[N]]], f32> : tensor<?x?xf32>
