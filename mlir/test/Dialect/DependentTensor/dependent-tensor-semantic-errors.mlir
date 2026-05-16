// RUN: mlir-opt %s --split-input-file --verify-each=false -pass-pipeline='builtin.module(test-dependent-tensor-corrupt-semantics,verify-dependent-tensor-semantics)' -verify-diagnostics

func.func @semantic_bad_dominance_property_owner() {
  %dim = arith.constant 1 : index
  // expected-error@below {{'dependent_tensor.make' op dependent result dimension value does not dominate owner}}
  %t = dependent_tensor.make () #tensor<[%dim], f32> : tensor<?xf32>
  %late = arith.constant 2 : index
  return
}

// -----

func.func @semantic_cycle_like_dimension() {
  %dim = arith.constant 1 : index
  // The test pass mutates this tensor's stored dimension to %late_dim. That
  // would make the tensor semantics depend on an index computed from the tensor
  // itself, and is rejected because the cyclic dimension value does not
  // dominate the owner.
  // expected-error@below {{'dependent_tensor.make' op dependent result dimension value does not dominate owner}}
  %t = dependent_tensor.make () #tensor<[%dim], f32> : tensor<?xf32>
  %c0 = arith.constant 0 : index
  %late_dim = dependent_tensor.dim %t, %c0 : tensor<?xf32>
  return
}

// -----

func.func @semantic_isolated_capture_source(%outer: index) {
  return
}

func.func @semantic_isolated_capture_victim() {
  %dim = arith.constant 1 : index
  // expected-error@below {{'dependent_tensor.make' op dependent result dimension value illegally crosses an IsolatedFromAbove boundary}}
  %t = dependent_tensor.make () #tensor<[%dim], f32> : tensor<?xf32>
  return
}

// -----

func.func @semantic_bad_scf_for_body_dim() {
  %dim = arith.constant 1 : index
  %lb = arith.constant 0 : index
  %ub = arith.constant 4 : index
  %step = arith.constant 1 : index
  %init = dependent_tensor.make () #tensor<[%dim], f32> : tensor<?xf32>
  // expected-error@below {{'scf.for' op dependent result dimension value does not dominate owner}}
  %result = scf.for %iv = %lb to %ub step %step iter_args(%arg = %init) -> (tensor<?xf32>) {
    %body_dim = arith.constant 2 : index
    %body_tensor = dependent_tensor.make () #tensor<[%body_dim], f32> : tensor<?xf32>
    scf.yield %arg : tensor<?xf32>
  }
  return
}

// -----

func.func @semantic_boundary_dim_parser_rejects(
    %m : index,
    %t : tensor<?xf32>) -> tensor<?xf32>
    // Function boundary metadata is parsed directly into function properties.
    // Non-entry-block-argument dims are rejected by the parser before the
    // semantic verifier pass can run.
    // expected-error@below {{dependent tensor boundary dims must be function arguments}}
    #types[%t : #tensor<[%c0], f32>] {
  %c0 = arith.constant 0 : index
  return %t : tensor<?xf32>
}
