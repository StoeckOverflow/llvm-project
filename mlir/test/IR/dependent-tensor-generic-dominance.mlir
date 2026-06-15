// RUN: mlir-opt %s --split-input-file -pass-pipeline='builtin.module(test-dependent-tensor-corrupt-generic-property-uses)' -verify-diagnostics

func.func @generic_property_dominance_verifier() {
  %dim = arith.constant 1 : index
  // expected-error@+2 {{property SSA value does not dominate this operation}}
  // expected-note@+1 {{property SSA use is owned by this operation}}
  %t = dependent_tensor.make () #tensor<[%dim], f32> : tensor<?xf32>
  // expected-note@+1 {{property SSA value defined here (op in the same block)}}
  %late = arith.constant 2 : index
  return
}

// -----

func.func @generic_property_isolated_capture_verifier_source(%outer: index) {
  return
}

// expected-note@+1 {{required by region isolation constraints}}
func.func @generic_property_isolated_capture_verifier_victim() {
  %dim = arith.constant 1 : index
  // expected-error@+1 {{using property SSA value defined outside the region}}
  %t = dependent_tensor.make () #tensor<[%dim], f32> : tensor<?xf32>
  return
}
