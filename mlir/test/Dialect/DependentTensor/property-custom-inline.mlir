// RUN: mlir-opt %s -test-dependent-tensor-inline-callee | FileCheck %s
// CHECK-LABEL: func.func @inline_property_ssa_caller
// CHECK: %[[C7:.*]] = arith.constant 7 : index
// CHECK: dependent_tensor.make () #tensor<[%[[C7]]], f32>
// CHECK-NOT: func.call
// CHECK: return

func.func private @inline_property_ssa_callee(%n: index, %i: index) -> f32 {
  %t = dependent_tensor.make () #tensor<[%n], f32> : tensor<?xf32>
  %v = dependent_tensor.extract %t[%i] : f32
  return %v : f32
}

func.func @inline_property_ssa_caller(%i: index) -> f32 {
  %n = arith.constant 7 : index
  %v = func.call @inline_property_ssa_callee(%n, %i) : (index, index) -> f32
  return %v : f32
}
