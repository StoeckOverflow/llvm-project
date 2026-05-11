// RUN: mlir-opt %s -pass-pipeline='builtin.module(func.func(dependent-tensor-clone-local-producer))' | FileCheck %s --check-prefix=CLONE
// RUN: mlir-opt %s -pass-pipeline='builtin.module(func.func(dependent-tensor-replace-dim-value))' | FileCheck %s --check-prefix=REMAP
// RUN: mlir-opt %s -pass-pipeline='builtin.module(func.func(dependent-tensor-replace-op-uses))' | FileCheck %s --check-prefix=OPREMAP
// RUN: mlir-opt %s -pass-pipeline='builtin.module(func.func(dependent-tensor-replace-first-block-arg))' | FileCheck %s --check-prefix=ARGREMAP
// RUN: mlir-opt %s -pass-pipeline='builtin.module(func.func(dependent-tensor-check-property-uses))'
// RUN: mlir-opt %s -pass-pipeline='builtin.module(func.func(dependent-tensor-replace-dim-value),verify-dependent-tensor-semantics)'

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
// CLONE: %[[T0:.*]] = dependent_tensor.make
// CLONE: %[[R0:.*]] = dependent_tensor.insert {{.*}} into %[[T0]]{{.*}}#tensor
// CLONE: %[[T1:.*]] = dependent_tensor.make
// CLONE: %[[R1:.*]] = dependent_tensor.insert {{.*}} into %[[T1]]{{.*}}#tensor

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
