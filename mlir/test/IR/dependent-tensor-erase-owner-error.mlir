// RUN: mlir-opt %s -split-input-file -test-dependent-tensor-erase-owner -verify-diagnostics

func.func @erase_owner_rejected(%seed : index) {
  // expected-error@+1 {{cannot erase anchor owner with live dependent tensor references}}
  %d = test.dependent_result_owner : index
  %t = "builtin.unrealized_conversion_cast"() : () -> tensor<[%d], f32>
  return
}

// -----

func.func @erase_owner_rejected_multiple_live_users() {
  // expected-error@+1 {{cannot erase anchor owner with live dependent tensor references}}
  %d = test.dependent_result_owner : index
  %t0 = "builtin.unrealized_conversion_cast"() : () -> tensor<[%d], f32>
  %t1 = "builtin.unrealized_conversion_cast"() : () -> tensor<[%d], f32>
  return
}
