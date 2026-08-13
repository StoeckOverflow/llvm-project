// RUN: mlir-opt %s --split-input-file --verify-each=false -pass-pipeline='builtin.module(test-dependent-tensor-corrupt-refinements,verify-dependent-tensor-refinements)' -verify-diagnostics

func.func @refinement_bad_dominance_property_owner() {
  %dim = arith.constant 1 : index
  // expected-error@below {{'dependent_tensor.make' op dependent result dimension value does not dominate owner}}
  %t = dependent_tensor.make () #tensor<[%dim], f32> : tensor<?xf32>
  %late = arith.constant 2 : index
  return
}

// -----

func.func @refinement_cycle_like_dimension() {
  %dim = arith.constant 1 : index
  // expected-error@below {{'dependent_tensor.make' op dependent result dimension value does not dominate owner}}
  %t = dependent_tensor.make () #tensor<[%dim], f32> : tensor<?xf32>
  %c0 = arith.constant 0 : index
  %late_dim = dependent_tensor.dim %t, %c0 : tensor<?xf32>
  return
}

// -----

func.func @refinement_isolated_capture_source(%outer: index) {
  return
}

func.func @refinement_isolated_capture_victim() {
  %dim = arith.constant 1 : index
  // expected-error@below {{'dependent_tensor.make' op dependent result dimension value illegally crosses an IsolatedFromAbove boundary}}
  %t = dependent_tensor.make () #tensor<[%dim], f32> : tensor<?xf32>
  return
}

// -----

func.func @refinement_func_boundary_isolated_capture_source(%outer: index) {
  return
}

// expected-error@below {{'func.func' op dependent argument dimension value illegally crosses an IsolatedFromAbove boundary}}
func.func @refinement_func_boundary_isolated_capture_victim(
    %dim: index, %t: tensor<?xf32>)
    #types[%t : #tensor<[%dim], f32>] {
  return
}

// -----

func.func @refinement_bad_scf_for_body_dim() {
  %dim = arith.constant 1 : index
  %lb = arith.constant 0 : index
  %ub = arith.constant 4 : index
  %step = arith.constant 1 : index
  %init = dependent_tensor.make () #tensor<[%dim], f32> : tensor<?xf32>
  // expected-error@below {{'scf.for' op dependent block argument dimension value does not dominate owner}}
  %result = scf.for %iv = %lb to %ub step %step iter_args(%arg = %init) -> (tensor<?xf32>) {
    %body_dim = arith.constant 2 : index
    %body_tensor = dependent_tensor.make () #tensor<[%body_dim], f32> : tensor<?xf32>
    scf.yield %arg : tensor<?xf32>
  }
  return
}

// -----

func.func @refinement_bad_affine_for_yield_dim() {
  %n = arith.constant 4 : index
  %m = arith.constant 8 : index
  %k = arith.constant 16 : index
  %init = dependent_tensor.make () #tensor<[%n, %m], f32> : tensor<?x?xf32>
  %result = affine.for %iv = 0 to 4 iter_args(%arg = %init) -> (tensor<?x?xf32>) {
    %bad = dependent_tensor.make () #tensor<[%n, %k], f32> : tensor<?x?xf32>
    affine.yield %bad : tensor<?x?xf32>
  }
  return
}
