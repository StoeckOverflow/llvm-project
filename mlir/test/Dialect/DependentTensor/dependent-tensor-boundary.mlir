// RUN: mlir-opt %s -verify-dependent-tensor-semantics | FileCheck %s

func.func @identity_with_boundary(
    %m : index,
    %n : index,
    %t : tensor<?x?xf32>)
    -> tensor<?x?xf32>
    #types[%t : #tensor<[%m, %n], f32>] -> #tensor<[%m, %n], f32> {
  return %t : tensor<?x?xf32>
}

func.func @call_and_return_boundary(
    %m : index,
    %n : index) -> tensor<?x?xf32>
    #types[] -> #tensor<[%m, %n], f32> {
  %t = dependent_tensor.make () #tensor<[%m, %n], f32> : tensor<?x?xf32>
  %r = func.call @identity_with_boundary(%m, %n, %t) : (index, index, tensor<?x?xf32>) -> tensor<?x?xf32>
  return %r : tensor<?x?xf32>
}

func.func @return_insert_boundary(
    %m : index,
    %n : index,
    %i : index,
    %j : index,
    %v : f32) -> tensor<?x?xf32>
    #types[] -> #tensor<[%m, %n], f32> {
  %t = dependent_tensor.make () #tensor<[%m, %n], f32> : tensor<?x?xf32>
  %r = dependent_tensor.insert %v into %t[%i, %j] #tensor<[%m, %n], f32> : f32 into tensor<?x?xf32>
  return %r : tensor<?x?xf32>
}

// CHECK-LABEL: func.func @identity_with_boundary
// CHECK-SAME: #types[%{{.*}} : #tensor<[%{{.*}}, %{{.*}}], f32>] -> #tensor<[%{{.*}}, %{{.*}}], f32>
// CHECK-LABEL: func.func @call_and_return_boundary
// CHECK-SAME: #types[] -> #tensor<[%{{.*}}, %{{.*}}], f32>
// CHECK: %[[T:.*]] = dependent_tensor.make
// CHECK: %[[R:.*]] = call @identity_with_boundary
// CHECK-LABEL: func.func @return_insert_boundary
// CHECK-SAME: #types[] -> #tensor<[%{{.*}}, %{{.*}}], f32>
// CHECK: dependent_tensor.insert
