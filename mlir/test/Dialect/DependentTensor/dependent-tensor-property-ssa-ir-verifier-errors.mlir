// RUN: mlir-opt %s --split-input-file -pass-pipeline='builtin.module(test-dependent-tensor-corrupt-semantics)' -verify-diagnostics

// Valid function boundary metadata references entry block arguments nested
// under the function owner. The generic owner-site verifier must leave this to
// dialect-specific boundary semantics instead of treating it as an illegal
// owner-site property use.
func.func @generic_verifier_accepts_valid_boundary_metadata(
    %dim: index, %t: tensor<?xf32>)
    #types[%t : #tensor<[%dim], f32>] {
  return
}

// -----

func.func @semantic_func_boundary_isolated_capture_source(%outer: index) {
  return
}

// The test pass mutates this initially-valid boundary property ref to point at
// an argument of the sibling function above. That proves the generic IR
// verifier, not only the dependent-tensor semantic pass, rejects property SSA
// captures by an IsolatedFromAbove owner.
// expected-error@below {{'func.func' op property SSA value illegally crosses an IsolatedFromAbove boundary}}
func.func @semantic_func_boundary_isolated_capture_victim(
    %dim: index, %t: tensor<?xf32>)
    #types[%t : #tensor<[%dim], f32>] {
  return
}
