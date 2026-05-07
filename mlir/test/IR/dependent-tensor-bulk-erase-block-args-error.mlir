// RUN: mlir-opt %s -verify-dependent-tensor-semantics | FileCheck %s

func.func @bulk_erase_block_arg_rejected(%seed : index) -> tensor<?xf32>
    #types[] -> #tensor<[%seed], f32> {
  %t = dependent_tensor.make () #tensor<[%seed], f32> : tensor<?xf32>
  return %t : tensor<?xf32>
}

// CHECK-LABEL: func.func @bulk_erase_block_arg_rejected
// CHECK-SAME: #types[] -> #tensor<[%{{.*}}], f32>
