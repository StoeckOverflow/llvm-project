// RUN: mlir-opt %s -verify-dependent-tensor-semantics | FileCheck %s

func.func @move_anchor_seed_rejected() {
  %seed = arith.constant 1 : index
  %extra = arith.constant 2 : index
  %t = dependent_tensor.make () #tensor<[%seed], f32> : tensor<?xf32>
  return
}

// CHECK-LABEL: func.func @move_anchor_seed_rejected
// CHECK: dependent_tensor.make () #tensor<[%{{.*}}], f32> : tensor<?xf32>
