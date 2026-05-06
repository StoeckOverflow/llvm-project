// RUN: mlir-opt %s -verify-dependent-tensor-semantics | FileCheck %s

func.func @identity_with_boundary(
    %m : index,
    %n : index,
    %t : tensor<?x?xf32>)
    -> tensor<?x?xf32> {
  return %t : tensor<?x?xf32>
} dependent_tensor_boundary args[2 dims[%m, %n] names[m, n]] results[0 dims[%m, %n] names[m, n]]

func.func @call_and_return_boundary(
    %m : index,
    %n : index) -> tensor<?x?xf32> {
  %t = dependent_tensor.make %m, %n dims[m, n] : tensor<?x?xf32>
  %r = func.call @identity_with_boundary(%m, %n, %t) : (index, index, tensor<?x?xf32>) -> tensor<?x?xf32>
  return %r : tensor<?x?xf32>
} dependent_tensor_boundary args[] results[0 dims[%m, %n] names[m, n]]

func.func @return_insert_boundary(
    %m : index,
    %n : index,
    %i : index,
    %j : index,
    %v : f32) -> tensor<?x?xf32> {
  %t = dependent_tensor.make %m, %n dims[m, n] : tensor<?x?xf32>
  %r = dependent_tensor.insert %v into %t[%i, %j] result_dims[%m, %n] dims[m, n] : f32 into tensor<?x?xf32>
  return %r : tensor<?x?xf32>
} dependent_tensor_boundary args[] results[0 dims[%m, %n] names[m, n]]

// CHECK-LABEL: func.func @identity_with_boundary
// CHECK: dependent_tensor_boundary args[2 dims[%{{.*}}, %{{.*}}] names[m, n]] results[0 dims[%{{.*}}, %{{.*}}] names[m, n]]
// CHECK-LABEL: func.func @call_and_return_boundary
// CHECK: %[[T:.*]] = dependent_tensor.make
// CHECK: %[[R:.*]] = call @identity_with_boundary
// CHECK: dependent_tensor_boundary args[] results[0 dims[%{{.*}}, %{{.*}}] names[m, n]]
// CHECK-LABEL: func.func @return_insert_boundary
// CHECK: dependent_tensor.insert
// CHECK: dependent_tensor_boundary args[] results[0 dims[%{{.*}}, %{{.*}}] names[m, n]]
