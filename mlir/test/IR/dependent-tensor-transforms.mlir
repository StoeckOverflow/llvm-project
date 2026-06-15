// RUN: mlir-opt %s -pass-pipeline='builtin.module(func.func(test-dependent-tensor-clone-local-producer))' | FileCheck %s --check-prefix=CLONE
// RUN: mlir-opt %s -pass-pipeline='builtin.module(func.func(test-dependent-tensor-replace-dim-value))' | FileCheck %s --check-prefix=REMAP
// RUN: mlir-opt %s -pass-pipeline='builtin.module(func.func(test-dependent-tensor-replace-op-uses))' | FileCheck %s --check-prefix=OPREMAP

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

// -----

func.func @clone_insert_refinement() {
  %d = arith.constant 1 : index
  %c0 = arith.constant 0 : index
  %v = arith.constant 0.000000e+00 : f32
  %t = dependent_tensor.make () #tensor<[%d], f32> : tensor<?xf32>
  %r = dependent_tensor.insert %v into %t[%c0] #tensor<[%d], f32> : f32 into tensor<?xf32>
  return
}

// CLONE-LABEL: func.func @clone_insert_refinement
// CLONE-NEXT: %[[D0:.*]] = arith.constant 1 : index
// CLONE-NEXT: %[[C0:.*]] = arith.constant 0 : index
// CLONE-NEXT: %[[V0:.*]] = arith.constant 0.000000e+00 : f32
// CLONE-NEXT: %[[T0:.*]] = dependent_tensor.make () #tensor<[%[[D0]]], f32> : tensor<?xf32>
// CLONE-NEXT: %{{.*}} = dependent_tensor.insert %[[V0]] into %[[T0]][%[[C0]]] #tensor<[%[[D0]]], f32> : f32 into tensor<?xf32>
// CLONE-NEXT: %[[D1:.*]] = arith.constant 1 : index
// CLONE-NEXT: %[[C1:.*]] = arith.constant 0 : index
// CLONE-NEXT: %[[V1:.*]] = arith.constant 0.000000e+00 : f32
// CLONE-NEXT: %[[T1:.*]] = dependent_tensor.make () #tensor<[%[[D1]]], f32> : tensor<?xf32>
// CLONE-NEXT: %{{.*}} = dependent_tensor.insert %[[V1]] into %[[T1]][%[[C1]]] #tensor<[%[[D1]]], f32> : f32 into tensor<?xf32>
// CLONE-NEXT: return

// -----

func.func @replace_insert_refinement_seed() {
  %seed = arith.constant 1 : index
  %replacement = arith.constant 2 : index
  %c0 = arith.constant 0 : index
  %v = arith.constant 0.000000e+00 : f32
  %t = dependent_tensor.make () #tensor<[%seed], f32> : tensor<?xf32>
  %r = dependent_tensor.insert %v into %t[%c0] #tensor<[%seed], f32> : f32 into tensor<?xf32>
  return
}

// REMAP-LABEL: func.func @replace_insert_refinement_seed
// REMAP-NEXT: %[[S:.*]] = arith.constant 1 : index
// REMAP-NEXT: %[[R:.*]] = arith.constant 2 : index
// REMAP-NEXT: %[[C0:.*]] = arith.constant 0 : index
// REMAP-NEXT: %[[V:.*]] = arith.constant 0.000000e+00 : f32
// REMAP-NEXT: %[[T:.*]] = dependent_tensor.make () #tensor<[%[[R]]], f32> : tensor<?xf32>
// REMAP-NEXT: %{{.*}} = dependent_tensor.insert %[[V]] into %[[T]][%[[C0]]] #tensor<[%[[R]]], f32> : f32 into tensor<?xf32>
// REMAP-NEXT: return

// -----

func.func @replace_insert_destination_refinement() {
  %m = arith.constant 4 : index
  %n = arith.constant 8 : index
  %c0 = arith.constant 0 : index
  %v = arith.constant 0.000000e+00 : f32
  %lhs = dependent_tensor.make () #tensor<[%m], f32> : tensor<?xf32>
  %rhs = dependent_tensor.make () #tensor<[%n], f32> : tensor<?xf32>
  %r = dependent_tensor.insert %v into %lhs[%c0] #tensor<[%m], f32> : f32 into tensor<?xf32>
  return
}

// OPREMAP-LABEL: func.func @replace_insert_destination_refinement
// OPREMAP: %[[N:.*]] = arith.constant 8 : index
// OPREMAP: %[[RHS:.*]] = dependent_tensor.make () #tensor<[%[[N]]], f32> : tensor<?xf32>
// OPREMAP: dependent_tensor.insert {{.*}} into %[[RHS]][{{.*}}] #tensor<[%[[N]]], f32> : f32 into tensor<?xf32>
