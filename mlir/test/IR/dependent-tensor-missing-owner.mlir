// RUN: mlir-opt %s -verify-dependent-tensor-semantics | FileCheck %s

func.func @missing_owner(%x : index) {
  %t = dependent_tensor.make () #tensor<[%x], f32> : tensor<?xf32>
  return
}

// CHECK-LABEL: func.func @missing_owner
// CHECK: dependent_tensor.make () #tensor<[%{{.*}}], f32> : tensor<?xf32>
