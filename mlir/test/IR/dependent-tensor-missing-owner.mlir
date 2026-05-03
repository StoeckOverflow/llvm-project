// RUN: mlir-opt %s -test-dependent-tensor-reset-owner-properties -verify-diagnostics

func.func @missing_owner(%x : index) {
  // expected-error@+1 {{missing dependent tensor anchor owner}}
  %t = "builtin.unrealized_conversion_cast"() : () -> tensor<[%x], f32>
  return
}
