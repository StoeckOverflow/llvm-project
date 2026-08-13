// RUN: mlir-opt %s -pass-pipeline='builtin.module(func.func(test-dependent-tensor-clone-local-producer))' | FileCheck %s --check-prefix=CLONE
// RUN: mlir-opt %s -pass-pipeline='builtin.module(func.func(test-dependent-tensor-replace-dim-value))' | FileCheck %s --check-prefix=REMAP
// RUN: mlir-opt %s -pass-pipeline='builtin.module(func.func(test-dependent-tensor-replace-op-uses))' | FileCheck %s --check-prefix=OPREMAP
// RUN: mlir-opt %s -pass-pipeline='builtin.module(func.func(test-dependent-tensor-dialect-conversion-remap))' | FileCheck %s --check-prefix=CONVERT
// RUN: mlir-opt %s -pass-pipeline='builtin.module(func.func(test-dependent-tensor-erase-scf-for-result))' | FileCheck %s --check-prefix=ERASE-RESULT
// RUN: mlir-opt %s -pass-pipeline='builtin.module(func.func(test-dependent-tensor-erase-function-signature))' | FileCheck %s --check-prefix=SIG

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
  %dim = dependent_tensor.dim %t, %c0, #dim %d : tensor<?xf32>
  %r = dependent_tensor.insert %v into %t[%c0] #tensor<[%d], f32> : f32 into tensor<?xf32>
  return
}

// CLONE-LABEL: func.func @clone_insert_refinement
// CLONE-NEXT: %[[D0:.*]] = arith.constant 1 : index
// CLONE-NEXT: %[[C0:.*]] = arith.constant 0 : index
// CLONE-NEXT: %[[V0:.*]] = arith.constant 0.000000e+00 : f32
// CLONE-NEXT: %[[T0:.*]] = dependent_tensor.make () #tensor<[%[[D0]]], f32> : tensor<?xf32>
// CLONE-NEXT: %{{.*}} = dependent_tensor.dim %[[T0]], %[[C0]], #dim %[[D0]] : tensor<?xf32>
// CLONE-NEXT: %{{.*}} = dependent_tensor.insert %[[V0]] into %[[T0]][%[[C0]]] #tensor<[%[[D0]]], f32> : f32 into tensor<?xf32>
// CLONE-NEXT: %[[D1:.*]] = arith.constant 1 : index
// CLONE-NEXT: %[[C1:.*]] = arith.constant 0 : index
// CLONE-NEXT: %[[V1:.*]] = arith.constant 0.000000e+00 : f32
// CLONE-NEXT: %[[T1:.*]] = dependent_tensor.make () #tensor<[%[[D1]]], f32> : tensor<?xf32>
// CLONE-NEXT: %{{.*}} = dependent_tensor.dim %[[T1]], %[[C1]], #dim %[[D1]] : tensor<?xf32>
// CLONE-NEXT: %{{.*}} = dependent_tensor.insert %[[V1]] into %[[T1]][%[[C1]]] #tensor<[%[[D1]]], f32> : f32 into tensor<?xf32>
// CLONE-NEXT: return

// -----

func.func @replace_insert_refinement_seed() {
  %seed = arith.constant 1 : index
  %replacement = arith.constant 2 : index
  %c0 = arith.constant 0 : index
  %v = arith.constant 0.000000e+00 : f32
  %t = dependent_tensor.make () #tensor<[%seed], f32> : tensor<?xf32>
  %dim = dependent_tensor.dim %t, %c0, #dim %seed : tensor<?xf32>
  %r = dependent_tensor.insert %v into %t[%c0] #tensor<[%seed], f32> : f32 into tensor<?xf32>
  return
}

// REMAP-LABEL: func.func @replace_insert_refinement_seed
// REMAP-NEXT: %[[S:.*]] = arith.constant 1 : index
// REMAP-NEXT: %[[R:.*]] = arith.constant 2 : index
// REMAP-NEXT: %[[C0:.*]] = arith.constant 0 : index
// REMAP-NEXT: %[[V:.*]] = arith.constant 0.000000e+00 : f32
// REMAP-NEXT: %[[T:.*]] = dependent_tensor.make () #tensor<[%[[R]]], f32> : tensor<?xf32>
// REMAP-NEXT: %{{.*}} = dependent_tensor.dim %[[T]], %[[C0]], #dim %[[R]] : tensor<?xf32>
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


// -----

func.func @dialect_conversion_property_ref() {
  %d = arith.constant 11 : index
  %c0 = arith.constant 0 : index
  %v = arith.constant 0.000000e+00 : f32
  %t = dependent_tensor.make () #tensor<[%d], f32> : tensor<?xf32>
  %dim = dependent_tensor.dim %t, %c0, #dim %d : tensor<?xf32>
  %r = dependent_tensor.insert %v into %t[%c0] #tensor<[%d], f32> : f32 into tensor<?xf32>
  return
}

// CONVERT-LABEL: func.func @dialect_conversion_property_ref
// CONVERT-NOT: arith.constant 11 : index
// CONVERT: %[[D:.*]] = arith.constant 12 : index
// CONVERT: %[[T:.*]] = dependent_tensor.make () #tensor<[%[[D]]], f32> : tensor<?xf32>
// CONVERT: dependent_tensor.dim %[[T]], {{.*}}, #dim %[[D]] : tensor<?xf32>
// CONVERT: dependent_tensor.insert {{.*}} into %[[T]][{{.*}}] #tensor<[%[[D]]], f32> : f32 into tensor<?xf32>

// -----

func.func @erase_scf_for_result_refinement() -> tensor<?xf32> {
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  %m = arith.constant 4 : index
  %n = arith.constant 8 : index
  %lhs = dependent_tensor.make () #tensor<[%m], f32> : tensor<?xf32>
  %rhs = dependent_tensor.make () #tensor<[%n], f32> : tensor<?xf32>
  %r0, %r1 = scf.for %i = %c0 to %c0 step %c1
      iter_args(%a = %lhs, %b = %rhs) -> (tensor<?xf32>, tensor<?xf32>)
      #types[%a : #tensor<[%m], f32>, %b : #tensor<[%n], f32>] -> [#tensor<[%m], f32>, #tensor<[%n], f32>]
 {
    scf.yield %a, %b : tensor<?xf32>, tensor<?xf32>
  }
  return %r1 : tensor<?xf32>
}

// ERASE-RESULT-LABEL: func.func @erase_scf_for_result_refinement
// ERASE-RESULT: %[[N:.*]] = arith.constant 8 : index
// ERASE-RESULT: %[[RHS:.*]] = dependent_tensor.make () #tensor<[%[[N]]], f32> : tensor<?xf32>
// ERASE-RESULT: %[[R:.*]] = scf.for {{.*}} iter_args(%[[ARG:.*]] = %[[RHS]]) -> (tensor<?xf32>) #types[%[[ARG]] : #tensor<[%[[N]]], f32>] -> #tensor<[%[[N]]], f32> {
// ERASE-RESULT:   scf.yield %[[ARG]] : tensor<?xf32>
// ERASE-RESULT: return %[[R]] : tensor<?xf32>

// -----

func.func @erase_func_boundary_arg_metadata(%dead_tensor : tensor<?xf32>, %m : index,
                                            %keep_tensor : tensor<?xf32>,
                                            %dead_dim : index) -> tensor<?xf32>
    #types[%dead_tensor : #tensor<[%dead_dim], f32>,
           %keep_tensor : #tensor<[%m], f32>] -> #tensor<[%m], f32> {
  return %keep_tensor : tensor<?xf32>
}

// SIG-LABEL: func.func @erase_func_boundary_arg_metadata
// SIG-SAME: (%[[M:arg[0-9]+]]: index, %[[T:arg[0-9]+]]: tensor<?xf32>) -> tensor<?xf32>
// SIG-SAME: #types[%[[T]] : #tensor<[%[[M]]], f32>] -> #tensor<[%[[M]]], f32>
// SIG-NEXT: return %[[T]] : tensor<?xf32>

// -----

func.func @erase_func_boundary_result_metadata(%m : index, %n : index,
                                               %lhs : tensor<?xf32>,
                                               %rhs : tensor<?xf32>)
    -> (tensor<?xf32>, tensor<?xf32>)
    #types[%lhs : #tensor<[%m], f32>, %rhs : #tensor<[%n], f32>]
    -> [#tensor<[%m], f32>, #tensor<[%n], f32>] {
  return %lhs, %rhs : tensor<?xf32>, tensor<?xf32>
}

// SIG-LABEL: func.func @erase_func_boundary_result_metadata
// SIG-SAME: (%[[M:arg[0-9]+]]: index, %[[N:arg[0-9]+]]: index, %[[LHS:arg[0-9]+]]: tensor<?xf32>, %[[RHS:arg[0-9]+]]: tensor<?xf32>) -> tensor<?xf32>
// SIG-SAME: #types[%[[LHS]] : #tensor<[%[[M]]], f32>, %[[RHS]] : #tensor<[%[[N]]], f32>] -> #tensor<[%[[N]]], f32>
// SIG-NEXT: return %[[RHS]] : tensor<?xf32>
