// RUN: mlir-opt %s -pass-pipeline='builtin.module(func.func(test-dependent-tensor-clone-local-anchor-producer))' | FileCheck %s --check-prefix=CLONE
// RUN: mlir-opt %s -pass-pipeline='builtin.module(func.func(test-dependent-tensor-replace-anchor-seed))' | FileCheck %s --check-prefix=REMAP

func.func @clone_anchor_remap(%skip : i1) {
  %d = "builtin.unrealized_conversion_cast"() : () -> index
  %t = "builtin.unrealized_conversion_cast"() : () -> tensor<[%d], f32>
  return
}

// CLONE-LABEL: func.func @clone_anchor_remap
// CLONE-SAME: (%[[SKIP:arg[0-9]+]]: i1)
// CLONE-NEXT: %[[D0:[0-9]+]] = builtin.unrealized_conversion_cast to index
// CLONE-NEXT: %[[T0:[0-9]+]] = builtin.unrealized_conversion_cast to tensor<[%[[D0]]], f32>
// CLONE-NEXT: %[[D1:[0-9]+]] = builtin.unrealized_conversion_cast to index
// CLONE-NEXT: %[[T1:[0-9]+]] = builtin.unrealized_conversion_cast to tensor<[%[[D1]]], f32>
// CLONE-NEXT: return

// -----

func.func @clone_mixed_multi_anchor(%seed : index) {
  %d = "builtin.unrealized_conversion_cast"() : () -> index
  %t = "builtin.unrealized_conversion_cast"() : () -> tensor<[%seed, %d], f32>
  return
}

// CLONE-LABEL: func.func @clone_mixed_multi_anchor
// CLONE-SAME: (%[[SEED:arg[0-9]+]]: index)
// CLONE-NEXT: %[[D0:[0-9]+]] = builtin.unrealized_conversion_cast to index
// CLONE-NEXT: %[[T0:[0-9]+]] = builtin.unrealized_conversion_cast to tensor<[%[[SEED]], %[[D0]]], f32>
// CLONE-NEXT: %[[D1:[0-9]+]] = builtin.unrealized_conversion_cast to index
// CLONE-NEXT: %[[T1:[0-9]+]] = builtin.unrealized_conversion_cast to tensor<[%[[SEED]], %[[D1]]], f32>
// CLONE-NEXT: return

// -----

func.func @clone_block_arg_anchor(%seed : index) -> tensor<[%seed], f32> {
  %t = "builtin.unrealized_conversion_cast"() : () -> tensor<[%seed], f32>
  return %t : tensor<[%seed], f32>
}

// CLONE-LABEL: func.func @clone_block_arg_anchor
// CLONE-SAME: (%[[A0:arg[0-9]+]]: index)
// CLONE-NEXT: %[[T0:[0-9]+]] = builtin.unrealized_conversion_cast to tensor<[%[[A0]]], f32>
// CLONE-NEXT: %[[T1:[0-9]+]] = builtin.unrealized_conversion_cast to tensor<[%[[A0]]], f32>
// CLONE-NEXT: return %[[T0]] : tensor<[%[[A0]]], f32>

// -----

func.func @replace_anchor_seed() {
  %seed = arith.constant 1 : index
  %replacement = arith.constant 2 : index
  %t = "builtin.unrealized_conversion_cast"() : () -> tensor<[%seed], f32>
  return
}

// REMAP-LABEL: func.func @replace_anchor_seed
// REMAP-NEXT: %[[S:.*]] = arith.constant 1 : index
// REMAP-NEXT: %[[R:.*]] = arith.constant 2 : index
// REMAP-NEXT: %[[T:.*]] = builtin.unrealized_conversion_cast to tensor<[%[[R]]], f32>
// REMAP-NEXT: return

// -----

func.func @replace_one_dim_of_multi_anchor() {
  %seed = arith.constant 1 : index
  %replacement = arith.constant 2 : index
  %other = arith.constant 3 : index
  %t = "builtin.unrealized_conversion_cast"() : () -> tensor<[%seed, %other], f32>
  return
}

// REMAP-LABEL: func.func @replace_one_dim_of_multi_anchor
// REMAP-NEXT: %[[S:.*]] = arith.constant 1 : index
// REMAP-NEXT: %[[R:.*]] = arith.constant 2 : index
// REMAP-NEXT: %[[O:.*]] = arith.constant 3 : index
// REMAP-NEXT: %[[T:.*]] = builtin.unrealized_conversion_cast to tensor<[%[[R]], %[[O]]], f32>
// REMAP-NEXT: return
