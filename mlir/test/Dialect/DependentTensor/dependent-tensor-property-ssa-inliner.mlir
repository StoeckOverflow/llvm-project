// RUN: mlir-opt %s -pass-pipeline='builtin.module(test-dependent-tensor-inline-callee,verify-dependent-tensor-semantics)' | FileCheck %s

func.func @inline_property_ssa_callee(%dim: index, %t: tensor<?xf32>)
    -> tensor<?xf32> #types[%t : #tensor<[%dim], f32>] -> #tensor<[%dim], f32> {
  %made = dependent_tensor.make () #tensor<[%dim], f32> : tensor<?xf32>
  return %made : tensor<?xf32>
}

func.func @inline_property_ssa_caller(%caller_dim: index) -> tensor<?xf32>
    #types[] -> #tensor<[%caller_dim], f32> {
  %input = dependent_tensor.make () #tensor<[%caller_dim], f32> : tensor<?xf32>
  %result = func.call @inline_property_ssa_callee(%caller_dim, %input)
      : (index, tensor<?xf32>) -> tensor<?xf32>
  return %result : tensor<?xf32>
}

// CHECK-LABEL: func.func @inline_property_ssa_caller
// CHECK-SAME: (%[[CALLER_DIM:.*]]: index) -> tensor<?xf32> #types[] -> #tensor<[%[[CALLER_DIM]]], f32>
// CHECK-NEXT: %[[INPUT:.*]] = dependent_tensor.make () #tensor<[%[[CALLER_DIM]]], f32> : tensor<?xf32>
// CHECK-NOT: func.call
// CHECK-NEXT: %[[MADE:.*]] = dependent_tensor.make () #tensor<[%[[CALLER_DIM]]], f32> : tensor<?xf32>
// CHECK-NEXT: return %[[MADE]] : tensor<?xf32>
