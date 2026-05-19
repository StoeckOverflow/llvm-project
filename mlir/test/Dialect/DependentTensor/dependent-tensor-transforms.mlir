// RUN: mlir-opt %s -pass-pipeline='builtin.module(func.func(test-dependent-tensor-clone-local-producer))' | FileCheck %s --check-prefix=CLONE
// RUN: mlir-opt %s -pass-pipeline='builtin.module(func.func(test-dependent-tensor-replace-dim-value))' | FileCheck %s --check-prefix=REMAP
// RUN: mlir-opt %s -pass-pipeline='builtin.module(func.func(test-dependent-tensor-replace-dim-value-except),verify-dependent-tensor-semantics)' | FileCheck %s --check-prefix=EXCEPT
// RUN: mlir-opt %s -pass-pipeline='builtin.module(func.func(test-dependent-tensor-rewriter-replace-dim-value-except),verify-dependent-tensor-semantics)' | FileCheck %s --check-prefix=REWRITER-EXCEPT
// RUN: mlir-opt %s -pass-pipeline='builtin.module(func.func(test-dependent-tensor-replace-dim-value-if),verify-dependent-tensor-semantics)' | FileCheck %s --check-prefix=IFREMAP
// RUN: mlir-opt %s -pass-pipeline='builtin.module(func.func(test-dependent-tensor-replace-dim-value-ssa-if),verify-dependent-tensor-semantics)' | FileCheck %s --check-prefix=SSAIF
// RUN: mlir-opt %s -pass-pipeline='builtin.module(func.func(test-dependent-tensor-replace-op-uses))' | FileCheck %s --check-prefix=OPREMAP
// RUN: mlir-opt %s -pass-pipeline='builtin.module(func.func(test-dependent-tensor-replace-first-block-arg))' | FileCheck %s --check-prefix=ARGREMAP
// RUN: mlir-opt %s -pass-pipeline='builtin.module(func.func(test-dependent-tensor-check-property-uses))'
// RUN: mlir-opt %s -pass-pipeline='builtin.module(func.func(test-dependent-tensor-replace-dim-value),verify-dependent-tensor-semantics)'
// RUN: mlir-opt %s -pass-pipeline='builtin.module(func.func(test-dependent-tensor-dce-local-dims),verify-dependent-tensor-semantics)' | FileCheck %s --check-prefix=DCE
// RUN: mlir-opt %s -pass-pipeline='builtin.module(func.func(canonicalize))' | FileCheck %s --check-prefix=CANON
// RUN: mlir-opt %s -pass-pipeline='builtin.module(func.func(cse))' | FileCheck %s --check-prefix=CSE

func.func @clone_make() {
  %m = arith.constant 1 : index
  %n = arith.constant 2 : index
  %t = dependent_tensor.make () #tensor<[%m, %n], f32> : tensor<?x?xf32>
  return
}

// CLONE-LABEL: func.func @clone_make
// CLONE-NEXT: %[[M0:.*]] = arith.constant 1 : index
// CLONE-NEXT: %[[N0:.*]] = arith.constant 2 : index
// CLONE-NEXT: %[[T0:.*]] = dependent_tensor.make () #tensor<[%[[M0]], %[[N0]]], f32> : tensor<?x?xf32>
// CLONE-NEXT: %[[M1:.*]] = arith.constant 1 : index
// CLONE-NEXT: %[[N1:.*]] = arith.constant 2 : index
// CLONE-NEXT: %[[T1:.*]] = dependent_tensor.make () #tensor<[%[[M1]], %[[N1]]], f32> : tensor<?x?xf32>
// CLONE-NEXT: return

// -----

func.func @replace_dim_value() {
  %dim = arith.constant 1 : index
  %replacement = arith.constant 2 : index
  %other = arith.constant 3 : index
  %t = dependent_tensor.make () #tensor<[%dim, %other], f32> : tensor<?x?xf32>
  return
}

// REMAP-LABEL: func.func @replace_dim_value
// REMAP-NEXT: %[[S:.*]] = arith.constant 1 : index
// REMAP-NEXT: %[[R:.*]] = arith.constant 2 : index
// REMAP-NEXT: %[[O:.*]] = arith.constant 3 : index
// REMAP-NEXT: %[[T:.*]] = dependent_tensor.make () #tensor<[%[[R]], %[[O]]], f32> : tensor<?x?xf32>
// REMAP-NEXT: return

// -----

func.func @replace_dim_value_except() {
  %dim = arith.constant 1 : index
  %replacement = arith.constant 2 : index
  %kept = dependent_tensor.make () #tensor<[%dim], f32> : tensor<?xf32>
  %updated = dependent_tensor.make () #tensor<[%dim], f32> : tensor<?xf32>
  return
}

// EXCEPT-LABEL: func.func @replace_dim_value_except
// EXCEPT-NEXT: %[[DIM:.*]] = arith.constant 1 : index
// EXCEPT-NEXT: %[[REPLACEMENT:.*]] = arith.constant 2 : index
// EXCEPT-NEXT: %[[KEPT:.*]] = dependent_tensor.make () #tensor<[%[[DIM]]], f32> : tensor<?xf32>
// EXCEPT-NEXT: %[[UPDATED:.*]] = dependent_tensor.make () #tensor<[%[[REPLACEMENT]]], f32> : tensor<?xf32>
// EXCEPT-NEXT: return

// -----

func.func @rewriter_replace_dim_value_except() {
  %dim = arith.constant 1 : index
  %replacement = arith.constant 2 : index
  %kept = dependent_tensor.make () #tensor<[%dim], f32> : tensor<?xf32>
  %updated = dependent_tensor.make () #tensor<[%dim], f32> : tensor<?xf32>
  return
}

// REWRITER-EXCEPT-LABEL: func.func @rewriter_replace_dim_value_except
// REWRITER-EXCEPT-NEXT: %[[DIM:.*]] = arith.constant 1 : index
// REWRITER-EXCEPT-NEXT: %[[REPLACEMENT:.*]] = arith.constant 2 : index
// REWRITER-EXCEPT-NEXT: %[[KEPT:.*]] = dependent_tensor.make () #tensor<[%[[DIM]]], f32> : tensor<?xf32>
// REWRITER-EXCEPT-NEXT: %[[UPDATED:.*]] = dependent_tensor.make () #tensor<[%[[REPLACEMENT]]], f32> : tensor<?xf32>
// REWRITER-EXCEPT-NEXT: return

// -----

// replaceUsesWithIf remains a native OpOperand API. Property refs are not
// approximated through their owner; use replaceSSAUsesWithIf for semantic uses.
func.func @replace_dim_value_if(%dim: index, %replacement: index,
                                %boundary: tensor<?xf32>)
    #types[%boundary : #tensor<[%dim], f32>] {
  %selected = arith.addi %dim, %dim : index
  return
}

// IFREMAP-LABEL: func.func @replace_dim_value_if
// IFREMAP-SAME: (%[[DIM:.*]]: index, %[[REPLACEMENT:.*]]: index, %[[BOUNDARY:.*]]: tensor<?xf32>)
// IFREMAP-SAME: #types[%[[BOUNDARY]] : #tensor<[%[[DIM]]], f32>]
// IFREMAP-NEXT: %[[SELECTED:.*]] = arith.addi %[[REPLACEMENT]], %[[REPLACEMENT]] : index
// IFREMAP-NEXT: return

// -----

func.func @replace_dim_value_ssa_if(%dim: index, %replacement: index,
                                    %t: tensor<?xf32>)
    #types[%t : #tensor<[%dim], f32>] {
  %native = arith.addi %dim, %dim : index
  return
}

// SSAIF-LABEL: func.func @replace_dim_value_ssa_if
// SSAIF-SAME: (%[[DIM:.*]]: index, %[[REPLACEMENT:.*]]: index, %[[T:.*]]: tensor<?xf32>)
// SSAIF-SAME: #types[%[[T]] : #tensor<[%[[REPLACEMENT]]], f32>]
// SSAIF-NEXT: %[[NATIVE:.*]] = arith.addi %[[DIM]], %[[DIM]] : index
// SSAIF-NEXT: return

// -----

func.func @rewriter_replace_dim_value_ssa_if(%dim: index, %replacement: index,
                                             %t: tensor<?xf32>)
    #types[%t : #tensor<[%dim], f32>] {
  %native = arith.addi %dim, %dim : index
  return
}

// SSAIF-LABEL: func.func @rewriter_replace_dim_value_ssa_if
// SSAIF-SAME: (%[[DIM:.*]]: index, %[[REPLACEMENT:.*]]: index, %[[T:.*]]: tensor<?xf32>)
// SSAIF-SAME: #types[%[[T]] : #tensor<[%[[REPLACEMENT]]], f32>]
// SSAIF-NEXT: %[[NATIVE:.*]] = arith.addi %[[DIM]], %[[DIM]] : index
// SSAIF-NEXT: return

// -----

func.func @clone_insert() {
  %m = arith.constant 1 : index
  %n = arith.constant 2 : index
  %i = arith.constant 0 : index
  %v = arith.constant 0.000000e+00 : f32
  %t = dependent_tensor.make () #tensor<[%m, %n], f32> : tensor<?x?xf32>
  %r = dependent_tensor.insert %v into %t[%i, %i] #tensor<[%m, %n], f32> : f32 into tensor<?x?xf32>
  return
}

// CLONE-LABEL: func.func @clone_insert
// CLONE-NEXT: %[[M0:.*]] = arith.constant 1 : index
// CLONE-NEXT: %[[N0:.*]] = arith.constant 2 : index
// CLONE-NEXT: %[[I0:.*]] = arith.constant 0 : index
// CLONE-NEXT: %[[V0:.*]] = arith.constant 0.000000e+00 : f32
// CLONE-NEXT: %[[T0:.*]] = dependent_tensor.make () #tensor<[%[[M0]], %[[N0]]], f32> : tensor<?x?xf32>
// CLONE-NEXT: %[[R0:.*]] = dependent_tensor.insert %[[V0]] into %[[T0]][%[[I0]], %[[I0]]] #tensor<[%[[M0]], %[[N0]]], f32> : f32 into tensor<?x?xf32>
// CLONE-NEXT: %[[M1:.*]] = arith.constant 1 : index
// CLONE-NEXT: %[[N1:.*]] = arith.constant 2 : index
// CLONE-NEXT: %[[I1:.*]] = arith.constant 0 : index
// CLONE-NEXT: %[[V1:.*]] = arith.constant 0.000000e+00 : f32
// CLONE-NEXT: %[[T1:.*]] = dependent_tensor.make () #tensor<[%[[M1]], %[[N1]]], f32> : tensor<?x?xf32>
// CLONE-NEXT: %[[R1:.*]] = dependent_tensor.insert %[[V1]] into %[[T1]][%[[I1]], %[[I1]]] #tensor<[%[[M1]], %[[N1]]], f32> : f32 into tensor<?x?xf32>
// CLONE-NEXT: return

// -----

func.func @replace_op_local_property_use() {
  %dim = arith.constant 1 : index
  %replacement = arith.constant 2 : index
  %t = dependent_tensor.make () #tensor<[%dim], f32> : tensor<?xf32>
  return
}

// OPREMAP-LABEL: func.func @replace_op_local_property_use
// OPREMAP-NEXT: %[[DIM:.*]] = arith.constant 1 : index
// OPREMAP-NEXT: %[[REPLACEMENT:.*]] = arith.constant 2 : index
// OPREMAP-NEXT: %[[T:.*]] = dependent_tensor.make () #tensor<[%[[REPLACEMENT]]], f32> : tensor<?xf32>
// OPREMAP-NEXT: return

// -----

func.func @replace_boundary_arg(%m: index, %n: index,
                                %t: tensor<?xf32>) -> tensor<?xf32>
    #types[%t : #tensor<[%m], f32>] -> #tensor<[%m], f32> {
  return %t : tensor<?xf32>
}

// ARGREMAP-LABEL: func.func @replace_boundary_arg
// ARGREMAP-SAME: (%[[M:.*]]: index, %[[N:.*]]: index, %[[T:.*]]: tensor<?xf32>)
// ARGREMAP-SAME: #types[%[[T]] : #tensor<[%[[N]]], f32>] -> #tensor<[%[[N]]], f32>

// -----

func.func @replace_scf_for_semantics() {
  %dim = arith.constant 1 : index
  %replacement = arith.constant 2 : index
  %lb = arith.constant 0 : index
  %ub = arith.constant 4 : index
  %step = arith.constant 1 : index
  %init = dependent_tensor.make () #tensor<[%dim], f32> : tensor<?xf32>
  %result = scf.for %iv = %lb to %ub step %step iter_args(%arg = %init) -> (tensor<?xf32>) {
    scf.yield %arg : tensor<?xf32>
  }
  return
}

// -----

func.func @check_property_use_list_api(%dim: index, %t: tensor<?xf32>)
    #types[%t : #tensor<[%dim], f32>] {
  %lb = arith.constant 0 : index
  %ub = arith.constant 4 : index
  %step = arith.constant 1 : index
  %use = arith.addi %dim, %dim : index
  %result = scf.for %iv = %lb to %ub step %step iter_args(%arg = %t) -> (tensor<?xf32>) {
    scf.yield %arg : tensor<?xf32>
  }
  return
}

// -----

func.func @check_physical_unified_use_list_api(%dim: index,
                                               %property_only: index,
                                               %t: tensor<?xf32>,
                                               %boundary: tensor<?xf32>)
    #types[%t : #tensor<[%dim], f32>, %boundary : #tensor<[%property_only], f32>] {
  %unused_property_dim = arith.constant 8 : index
  %one = arith.constant 1 : index
  %native = arith.addi %dim, %one : index
  %selected = dependent_tensor.make () #tensor<[%dim], f32> : tensor<?xf32>
  return
}

// -----

func.func @keep_property_only_dim(%r: index) -> tensor<?xf32>
    #types[] -> #tensor<[%r], f32> {
  %m = arith.constant 8 : index
  %t = dependent_tensor.make () #tensor<[%m], f32> : tensor<?xf32>
  %ret = dependent_tensor.make () #tensor<[%r], f32> : tensor<?xf32>
  return %ret : tensor<?xf32>
}

// DCE-LABEL: func.func @keep_property_only_dim
// DCE-SAME: (%[[R:.*]]: index) -> tensor<?xf32> #types[] -> #tensor<[%[[R]]], f32>
// DCE-NEXT: %[[M:.*]] = arith.constant 8 : index
// DCE-NEXT: %[[T:.*]] = dependent_tensor.make () #tensor<[%[[M]]], f32> : tensor<?xf32>
// DCE-NEXT: %[[RET:.*]] = dependent_tensor.make () #tensor<[%[[R]]], f32> : tensor<?xf32>
// DCE-NEXT: return %[[RET]] : tensor<?xf32>

// -----

func.func @erase_dead_dim(%r: index) -> tensor<?xf32>
    #types[] -> #tensor<[%r], f32> {
  %dead = arith.constant 4 : index
  %m = arith.constant 8 : index
  %t = dependent_tensor.make () #tensor<[%m], f32> : tensor<?xf32>
  %ret = dependent_tensor.make () #tensor<[%r], f32> : tensor<?xf32>
  return %ret : tensor<?xf32>
}

// DCE-LABEL: func.func @erase_dead_dim
// DCE-SAME: (%[[R:.*]]: index) -> tensor<?xf32> #types[] -> #tensor<[%[[R]]], f32>
// DCE-NOT: arith.constant 4 : index
// DCE-NEXT: %[[M:.*]] = arith.constant 8 : index
// DCE-NEXT: %[[T:.*]] = dependent_tensor.make () #tensor<[%[[M]]], f32> : tensor<?xf32>
// DCE-NEXT: %[[RET:.*]] = dependent_tensor.make () #tensor<[%[[R]]], f32> : tensor<?xf32>
// DCE-NEXT: return %[[RET]] : tensor<?xf32>

// -----

func.func @keep_ordinary_use_dim(%r: index) -> tensor<?xf32>
    #types[] -> #tensor<[%r], f32> {
  %one = arith.constant 1 : index
  %m = arith.constant 8 : index
  %ordinary = arith.addi %m, %one : index
  %t = dependent_tensor.make () #tensor<[%m], f32> : tensor<?xf32>
  %u = dependent_tensor.make () #tensor<[%ordinary], f32> : tensor<?xf32>
  %ret = dependent_tensor.make () #tensor<[%r], f32> : tensor<?xf32>
  return %ret : tensor<?xf32>
}

// DCE-LABEL: func.func @keep_ordinary_use_dim
// DCE-SAME: (%[[R:.*]]: index) -> tensor<?xf32> #types[] -> #tensor<[%[[R]]], f32>
// DCE-NEXT: %[[ONE:.*]] = arith.constant 1 : index
// DCE-NEXT: %[[M:.*]] = arith.constant 8 : index
// DCE-NEXT: %[[ORDINARY:.*]] = arith.addi %[[M]], %[[ONE]] : index
// DCE-NEXT: %[[T:.*]] = dependent_tensor.make () #tensor<[%[[M]]], f32> : tensor<?xf32>
// DCE-NEXT: %[[U:.*]] = dependent_tensor.make () #tensor<[%[[ORDINARY]]], f32> : tensor<?xf32>
// DCE-NEXT: %[[RET:.*]] = dependent_tensor.make () #tensor<[%[[R]]], f32> : tensor<?xf32>
// DCE-NEXT: return %[[RET]] : tensor<?xf32>

// -----

func.func @keep_func_boundary_dim(%m: index, %t: tensor<?xf32>)
    -> tensor<?xf32> #types[%t : #tensor<[%m], f32>] -> #tensor<[%m], f32> {
  %dead = arith.constant 5 : index
  return %t : tensor<?xf32>
}

// DCE-LABEL: func.func @keep_func_boundary_dim
// DCE-SAME: (%[[M:.*]]: index, %[[T:.*]]: tensor<?xf32>) -> tensor<?xf32> #types[%[[T]] : #tensor<[%[[M]]], f32>] -> #tensor<[%[[M]]], f32>
// DCE-NOT: arith.constant 5 : index
// DCE-NEXT: return %[[T]] : tensor<?xf32>

// -----

func.func @keep_scf_for_semantics_dim(%m: index, %init: tensor<?xf32>)
    -> tensor<?xf32> #types[%init : #tensor<[%m], f32>] -> #tensor<[%m], f32> {
  %dead = arith.constant 6 : index
  %lb = arith.constant 0 : index
  %ub = arith.constant 4 : index
  %step = arith.constant 1 : index
  %result = scf.for %iv = %lb to %ub step %step iter_args(%arg = %init) -> (tensor<?xf32>) {
    scf.yield %arg : tensor<?xf32>
  }
  return %result : tensor<?xf32>
}

// DCE-LABEL: func.func @keep_scf_for_semantics_dim
// DCE-SAME: (%[[M:.*]]: index, %[[INIT:.*]]: tensor<?xf32>) -> tensor<?xf32> #types[%[[INIT]] : #tensor<[%[[M]]], f32>] -> #tensor<[%[[M]]], f32>
// DCE-NOT: arith.constant 6 : index
// DCE-NEXT: %[[LB:.*]] = arith.constant 0 : index
// DCE-NEXT: %[[UB:.*]] = arith.constant 4 : index
// DCE-NEXT: %[[STEP:.*]] = arith.constant 1 : index
// DCE-NEXT: %[[RESULT:.*]] = scf.for %{{.*}} = %[[LB]] to %[[UB]] step %[[STEP]] iter_args(%[[ARG:.*]] = %[[INIT]]) -> (tensor<?xf32>) {
// DCE-NEXT:   scf.yield %[[ARG]] : tensor<?xf32>
// DCE-NEXT: }
// DCE-NEXT: return %[[RESULT]] : tensor<?xf32>

// -----

func.func @generic_dce_keeps_property_only_dim(%a: index, %b: index) -> f32 {
  %c0 = arith.constant 0 : index
  %dim = arith.muli %a, %b : index
  %t = dependent_tensor.make () #tensor<[%dim], f32> : tensor<?xf32>
  %v = dependent_tensor.extract %t[%c0] : f32
  return %v : f32
}

// CANON-LABEL: func.func @generic_dce_keeps_property_only_dim
// CANON-SAME: (%[[A:arg[0-9]+]]: index, %[[B:arg[0-9]+]]: index) -> f32
// CANON-NEXT: %[[C0:.*]] = arith.constant 0 : index
// CANON-NEXT: %[[DIM:.*]] = arith.muli %[[A]], %[[B]] : index
// CANON-NEXT: %[[T:.*]] = dependent_tensor.make () #tensor<[%[[DIM]]], f32> : tensor<?xf32>
// CANON-NEXT: %[[V:.*]] = dependent_tensor.extract %[[T]][%[[C0]]] #tensor<[%[[DIM]]], f32> : f32
// CANON-NEXT: return %[[V]] : f32

// CSE-LABEL: func.func @generic_dce_keeps_property_only_dim
// CSE-SAME: (%[[A:arg[0-9]+]]: index, %[[B:arg[0-9]+]]: index) -> f32
// CSE-NEXT: %[[C0:.*]] = arith.constant 0 : index
// CSE-NEXT: %[[DIM:.*]] = arith.muli %[[A]], %[[B]] : index
// CSE-NEXT: %[[T:.*]] = dependent_tensor.make () #tensor<[%[[DIM]]], f32> : tensor<?xf32>
// CSE-NEXT: %[[V:.*]] = dependent_tensor.extract %[[T]][%[[C0]]] #tensor<[%[[DIM]]], f32> : f32
// CSE-NEXT: return %[[V]] : f32

// -----

func.func @fold_dependent_dim(%m : index, %n : index) -> index {
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  %t = dependent_tensor.make () #tensor<[%m, %n], f32> : tensor<?x?xf32>
  %d0 = dependent_tensor.dim %t, %c0 : tensor<?x?xf32>
  %d1 = dependent_tensor.dim %t, %c1 : tensor<?x?xf32>
  %sum = arith.addi %d0, %d1 : index
  return %sum : index
}

// CANON-LABEL: func.func @fold_dependent_dim
// CANON-SAME: (%[[M:.*]]: index, %[[N:.*]]: index) -> index
// CANON-NEXT: %[[SUM:.*]] = arith.addi %[[M]], %[[N]] : index
// CANON-NEXT: return %[[SUM]] : index

// -----

func.func @keep_dynamic_dependent_dim(%m : index, %n : index, %i : index) -> index {
  %t = dependent_tensor.make () #tensor<[%m, %n], f32> : tensor<?x?xf32>
  %d = dependent_tensor.dim %t, %i : tensor<?x?xf32>
  return %d : index
}

// CANON-LABEL: func.func @keep_dynamic_dependent_dim
// CANON-SAME: (%[[M:.*]]: index, %[[N:.*]]: index, %[[I:.*]]: index) -> index
// CANON-NEXT: %[[T:.*]] = dependent_tensor.make () #tensor<[%[[M]], %[[N]]], f32> : tensor<?x?xf32>
// CANON-NEXT: %[[D:.*]] = dependent_tensor.dim %[[T]], %[[I]] : tensor<?x?xf32>
// CANON-NEXT: return %[[D]] : index
