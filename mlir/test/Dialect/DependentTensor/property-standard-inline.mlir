// RUN: mlir-opt %s -inline | FileCheck %s --implicit-check-not=func.call
// CHECK-LABEL: func.func @forward
// CHECK: return %arg1 : tensor<?xf32>
func.func private @identity(%n: index, %t: tensor<?xf32>) -> tensor<?xf32>
    #types[%t : #tensor<[%n], f32>] -> #tensor<[%n], f32> {
  return %t : tensor<?xf32>
}
func.func @forward(%n: index, %t: tensor<?xf32>) -> tensor<?xf32>
    #types[%t : #tensor<[%n], f32>] -> #tensor<[%n], f32> {
  %r = func.call @identity(%n, %t) : (index, tensor<?xf32>) -> tensor<?xf32>
  return %r : tensor<?xf32>
}

// CHECK-LABEL: func.func @inline_property_body
// CHECK: %[[C7:.*]] = arith.constant 7 : index
// CHECK: dependent_tensor.make () #tensor<[%[[C7]]], f32>
func.func private @create_read(%n: index, %i: index) -> f32 {
  %t = dependent_tensor.make () #tensor<[%n], f32> : tensor<?xf32>
  %v = dependent_tensor.extract %t[%i] : f32
  return %v : f32
}

func.func @inline_property_body(%i: index) -> f32 {
  %n = arith.constant 7 : index
  %v = func.call @create_read(%n, %i) : (index, index) -> f32
  return %v : f32
}

// Public visibility forces cloning: the original boundary remains valid.
func.func @clone_identity(%n: index, %t: tensor<?xf32>) -> tensor<?xf32>
    #types[%t : #tensor<[%n], f32>] -> #tensor<[%n], f32> {
  return %t : tensor<?xf32>
}
// CHECK-LABEL: func.func @clone_identity
// CHECK-SAME: #types[%arg1 : #tensor<[%arg0], f32>]
// CHECK: return %arg1
// CHECK-LABEL: func.func @clone_forward
// CHECK: return %arg1
func.func @clone_forward(%n: index, %t: tensor<?xf32>) -> tensor<?xf32>
    #types[%t : #tensor<[%n], f32>] -> #tensor<[%n], f32> {
  %r = func.call @clone_identity(%n, %t) : (index, tensor<?xf32>) -> tensor<?xf32>
  return %r : tensor<?xf32>
}

// CHECK-LABEL: func.func @clone_create
// CHECK-SAME: %[[N:arg[0-9]+]]: index
// CHECK: dependent_tensor.make () #tensor<[%[[N]]], f32>
func.func @clone_create(%n: index, %i: index) -> f32 {
  %t = dependent_tensor.make () #tensor<[%n], f32> : tensor<?xf32>
  %v = dependent_tensor.extract %t[%i] : f32
  return %v : f32
}
// CHECK-LABEL: func.func @clone_create_caller
// CHECK: %[[C9:.*]] = arith.constant 9 : index
// CHECK: dependent_tensor.make () #tensor<[%[[C9]]], f32>
func.func @clone_create_caller(%i: index) -> f32 {
  %n = arith.constant 9 : index
  %v = func.call @clone_create(%n, %i) : (index, index) -> f32
  return %v : f32
}
