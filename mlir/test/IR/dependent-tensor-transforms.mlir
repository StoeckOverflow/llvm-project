// RUN: mlir-opt %s -pass-pipeline='builtin.module(func.func(dependent-tensor-clone-local-producer))' | FileCheck %s --check-prefix=CLONE
// RUN: mlir-opt %s -pass-pipeline='builtin.module(func.func(dependent-tensor-replace-dim-value))' | FileCheck %s --check-prefix=REMAP

func.func @clone_anchor_remap() {
  %d = arith.constant 1 : index
  %t = dependent_tensor.make () #tensor<[%d], f32> : tensor<?xf32>
  return
}

// CLONE-LABEL: func.func @clone_anchor_remap
// CLONE-NEXT: %[[D0:.*]] = arith.constant 1 : index
// CLONE-NEXT: %[[T0:.*]] = dependent_tensor.make () #tensor<[%[[D0]]], f32> : tensor<?xf32>
// CLONE-NEXT: %[[D1:.*]] = arith.constant 1 : index
// CLONE-NEXT: %[[T1:.*]] = dependent_tensor.make () #tensor<[%[[D1]]], f32> : tensor<?xf32>
// CLONE-NEXT: return

// -----

func.func @clone_mixed_multi_anchor(%seed : index) {
  %d = arith.constant 1 : index
  %t = dependent_tensor.make () #tensor<[%seed, %d], f32> : tensor<?x?xf32>
  return
}

// CLONE-LABEL: func.func @clone_mixed_multi_anchor
// CLONE-SAME: (%[[SEED:arg[0-9]+]]: index)
// CLONE-NEXT: %[[D0:.*]] = arith.constant 1 : index
// CLONE-NEXT: %[[T0:.*]] = dependent_tensor.make () #tensor<[%[[SEED]], %[[D0]]], f32> : tensor<?x?xf32>
// CLONE-NEXT: %[[D1:.*]] = arith.constant 1 : index
// CLONE-NEXT: %[[T1:.*]] = dependent_tensor.make () #tensor<[%[[SEED]], %[[D1]]], f32> : tensor<?x?xf32>
// CLONE-NEXT: return

// -----

func.func @clone_block_arg_anchor(%seed : index) -> tensor<?xf32>
    #types[] -> #tensor<[%seed], f32> {
  %t = dependent_tensor.make () #tensor<[%seed], f32> : tensor<?xf32>
  return %t : tensor<?xf32>
}

// CLONE-LABEL: func.func @clone_block_arg_anchor
// CLONE-SAME: (%[[A0:arg[0-9]+]]: index)
// CLONE-SAME: #types[] -> #tensor<[%[[A0]]], f32>
// CLONE-NEXT: %[[T0:.*]] = dependent_tensor.make () #tensor<[%[[A0]]], f32> : tensor<?xf32>
// CLONE-NEXT: %[[T1:.*]] = dependent_tensor.make () #tensor<[%[[A0]]], f32> : tensor<?xf32>
// CLONE-NEXT: return %[[T0]] : tensor<?xf32>

// -----

func.func @replace_anchor_seed() {
  %seed = arith.constant 1 : index
  %replacement = arith.constant 2 : index
  %t = dependent_tensor.make () #tensor<[%seed], f32> : tensor<?xf32>
  return
}

// REMAP-LABEL: func.func @replace_anchor_seed
// REMAP-NEXT: %[[S:.*]] = arith.constant 1 : index
// REMAP-NEXT: %[[R:.*]] = arith.constant 2 : index
// REMAP-NEXT: %[[T:.*]] = dependent_tensor.make () #tensor<[%[[R]]], f32> : tensor<?xf32>
// REMAP-NEXT: return

// -----

func.func @replace_one_dim_of_multi_anchor() {
  %seed = arith.constant 1 : index
  %replacement = arith.constant 2 : index
  %other = arith.constant 3 : index
  %t = dependent_tensor.make () #tensor<[%seed, %other], f32> : tensor<?x?xf32>
  return
}

// REMAP-LABEL: func.func @replace_one_dim_of_multi_anchor
// REMAP-NEXT: %[[S:.*]] = arith.constant 1 : index
// REMAP-NEXT: %[[R:.*]] = arith.constant 2 : index
// REMAP-NEXT: %[[O:.*]] = arith.constant 3 : index
// REMAP-NEXT: %[[T:.*]] = dependent_tensor.make () #tensor<[%[[R]], %[[O]]], f32> : tensor<?x?xf32>
// REMAP-NEXT: return
