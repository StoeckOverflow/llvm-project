// RUN: mlir-opt %s -verify-dependent-tensor-semantics | FileCheck %s

func.func @identity_with_metadata(
    %m : index,
    %n : index,
    %t : tensor<?x?xf32> {dependent_tensor.seed_args = array<i32: 0, 1>})
    -> (tensor<?x?xf32> {dependent_tensor.seed_args = array<i32: 0, 1>}) {
  return %t : tensor<?x?xf32>
}

func.func @call_and_return_metadata(
    %m : index,
    %n : index) -> (tensor<?x?xf32> {dependent_tensor.seed_args = array<i32: 0, 1>}) {
  %t = dependent_tensor.make %m, %n dims[m, n] : tensor<?x?xf32>
  %r = func.call @identity_with_metadata(%m, %n, %t) : (index, index, tensor<?x?xf32>) -> tensor<?x?xf32>
  return %r : tensor<?x?xf32>
}

func.func @return_gemm_metadata(
    %m : index,
    %k : index,
    %n : index) -> (tensor<?x?xf32> {dependent_tensor.seed_args = array<i32: 0, 2>}) {
  %a = dependent_tensor.make %m, %k dims[m, k] : tensor<?x?xf32>
  %b = dependent_tensor.make %k, %n dims[k, n] : tensor<?x?xf32>
  %c = dependent_tensor.make %m, %n dims[m, n] : tensor<?x?xf32>
  %r = dependent_tensor.gemm %a, %b, %c dims[m, k, n] (m, k) x (k, n) + (m, n) -> (m, n)
    : tensor<?x?xf32>, tensor<?x?xf32>, tensor<?x?xf32> -> tensor<?x?xf32>
  return %r : tensor<?x?xf32>
}

// CHECK-LABEL: func.func @call_and_return_metadata
// CHECK: %[[T:.*]] = dependent_tensor.make
// CHECK: %[[R:.*]] = call @identity_with_metadata
// CHECK-LABEL: func.func @return_gemm_metadata
// CHECK: dependent_tensor.gemm
