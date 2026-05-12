// RUN: mlir-opt %s -pass-pipeline='builtin.module(test-dependent-tensor-clone-func-boundary,verify-dependent-tensor-semantics)' | FileCheck %s --check-prefix=CLONEBOUNDARY
// RUN: mlir-opt %s -pass-pipeline='builtin.module(func.func(test-dependent-tensor-rewriter-replace-op),verify-dependent-tensor-semantics)' | FileCheck %s --check-prefix=REWRITER
// RUN: mlir-opt %s -pass-pipeline='builtin.module(func.func(test-dependent-tensor-dialect-conversion-remap),verify-dependent-tensor-semantics)' | FileCheck %s --check-prefix=CONVERSION
// RUN: mlir-opt %s -pass-pipeline='builtin.module(func.func(test-dependent-tensor-refresh-property-uses),verify-dependent-tensor-semantics)' | FileCheck %s --check-prefix=REFRESH
// RUN: mlir-opt %s -pass-pipeline='builtin.module(func.func(test-dependent-tensor-check-property-uses),verify-dependent-tensor-semantics)'
// RUN: mlir-opt %s -pass-pipeline='builtin.module(func.func(remove-dead-values),verify-dependent-tensor-semantics)' | FileCheck %s --check-prefix=RDV
// RUN: not --crash mlir-opt %s -pass-pipeline='builtin.module(func.func(test-dependent-tensor-erase-live-entry-block))' 2>&1 | FileCheck %s --check-prefix=ERASE

func.func @clone_func_boundary_source(%dim: index, %t: tensor<?xf32>)
    -> tensor<?xf32> #types[%t : #tensor<[%dim], f32>] -> #tensor<[%dim], f32> {
  return %t : tensor<?xf32>
}

// CLONEBOUNDARY-LABEL: func.func @clone_func_boundary_source
// CLONEBOUNDARY-SAME: (%[[DIM:.*]]: index, %[[T:.*]]: tensor<?xf32>) -> tensor<?xf32> #types[%[[T]] : #tensor<[%[[DIM]]], f32>] -> #tensor<[%[[DIM]]], f32>
// CLONEBOUNDARY-LABEL: func.func @clone_func_boundary_source_clone
// CLONEBOUNDARY-SAME: (%[[CLONED_DIM:.*]]: index, %[[CLONED_T:.*]]: tensor<?xf32>) -> tensor<?xf32> #types[%[[CLONED_T]] : #tensor<[%[[CLONED_DIM]]], f32>] -> #tensor<[%[[CLONED_DIM]]], f32>

// -----

func.func @rewriter_replace_op_property_ref() {
  %dim = arith.constant 1 : index
  %t = dependent_tensor.make () #tensor<[%dim], f32> : tensor<?xf32>
  return
}

// REWRITER-LABEL: func.func @rewriter_replace_op_property_ref
// REWRITER-NOT: arith.constant 1 : index
// REWRITER: %[[REPLACEMENT:.*]] = arith.constant 9 : index
// REWRITER: dependent_tensor.make () #tensor<[%[[REPLACEMENT]]], f32> : tensor<?xf32>

// -----

func.func @dialect_conversion_property_ref() {
  %dim = arith.constant 11 : index
  %t = dependent_tensor.make () #tensor<[%dim], f32> : tensor<?xf32>
  return
}

// CONVERSION-LABEL: func.func @dialect_conversion_property_ref
// CONVERSION-NOT: arith.constant 11 : index
// CONVERSION: %[[REPLACEMENT:.*]] = arith.constant 12 : index
// CONVERSION: dependent_tensor.make () #tensor<[%[[REPLACEMENT]]], f32> : tensor<?xf32>

// -----

func.func @refresh_property_use_membership(%old: index, %new: index,
                                           %t: tensor<?xf32>)
    #types[%t : #tensor<[%old], f32>] {
  return
}

// REFRESH-LABEL: func.func @refresh_property_use_membership
// REFRESH-SAME: (%[[OLD:.*]]: index, %[[NEW:.*]]: index, %[[T:.*]]: tensor<?xf32>)
// REFRESH-SAME: #types[%[[T]] : #tensor<[%[[NEW]]], f32>]

// -----

func.func @check_repeated_property_users(%dim: index) {
  %a = dependent_tensor.make () #tensor<[%dim, %dim], f32> : tensor<?x?xf32>
  %b = dependent_tensor.make () #tensor<[%dim], f32> : tensor<?xf32>
  return
}

// -----

func.func @check_multi_result_property_use(%cond: i1) {
  %pair:2 = scf.if %cond -> (index, index) {
    %a = arith.constant 31 : index
    %b = arith.constant 32 : index
    scf.yield %a, %b : index, index
  } else {
    %a = arith.constant 33 : index
    %b = arith.constant 34 : index
    scf.yield %a, %b : index, index
  }
  %t = dependent_tensor.make () #tensor<[%pair#0], f32> : tensor<?xf32>
  return
}

// -----

func.func @check_func_boundary_property_users(%dim: index, %t: tensor<?xf32>)
    #types[%t : #tensor<[%dim], f32>] {
  %use = arith.addi %dim, %dim : index
  return
}

// -----

func.func @remove_dead_values_keeps_property_only_dim(%a: index, %b: index) -> f32 {
  %c0 = arith.constant 0 : index
  %dim = arith.muli %a, %b : index
  %t = dependent_tensor.make () #tensor<[%dim], f32> : tensor<?xf32>
  %v = dependent_tensor.extract %t[%c0] : tensor<?xf32>
  return %v : f32
}

// RDV-LABEL: func.func @remove_dead_values_keeps_property_only_dim
// RDV: %[[DIM:.*]] = arith.muli
// RDV: dependent_tensor.make () #tensor<[%[[DIM]]], f32>

// -----

func.func @erase_live_entry_block(%dim: index, %t: tensor<?xf32>)
    #types[%t : #tensor<[%dim], f32>] {
  return
}

// ERASE: cannot erase block; block argument #0 has live property SSA use owned by 'func.func' op
