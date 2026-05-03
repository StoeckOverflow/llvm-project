// RUN: mlir-opt %s -test-dependent-tensor-mark-dead -verify-diagnostics

func.func @dead_anchor(%x : index) {
  // expected-error@+1 {{dead dependent tensor anchor}}
  %t = "builtin.unrealized_conversion_cast"() : () -> tensor<[%x], f32>
  return
}
