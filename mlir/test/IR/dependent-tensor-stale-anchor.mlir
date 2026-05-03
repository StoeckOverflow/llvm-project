// RUN: mlir-opt %s -test-dependent-tensor-bump-generation -verify-diagnostics

func.func @stale_anchor(%x : index) {
  // expected-error@+1 {{stale dependent tensor anchor generation}}
  %t = "builtin.unrealized_conversion_cast"() : () -> tensor<[%x], f32>
  return
}
