// RUN: mlir-opt %s -split-input-file -verify-dependent-tensor-semantics | FileCheck %s

func.func @erase_owner_rejected(%seed : index) {
  %d = arith.constant 7 : index
  %t = dependent_tensor.make () #tensor<[%d], f32> : tensor<?xf32>
  return
}

// CHECK-LABEL: func.func @erase_owner_rejected
// CHECK: dependent_tensor.make () #tensor<[%{{.*}}], f32> : tensor<?xf32>

// -----

func.func @erase_owner_rejected_multiple_live_users() {
  %d = arith.constant 7 : index
  %t0 = dependent_tensor.make () #tensor<[%d], f32> : tensor<?xf32>
  %t1 = dependent_tensor.make () #tensor<[%d], f32> : tensor<?xf32>
  return
}

// CHECK-LABEL: func.func @erase_owner_rejected_multiple_live_users
// CHECK: dependent_tensor.make () #tensor<[%{{.*}}], f32> : tensor<?xf32>
