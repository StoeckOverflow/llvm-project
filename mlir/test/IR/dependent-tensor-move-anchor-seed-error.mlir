// RUN: mlir-opt %s -test-dependent-tensor-move-anchor-seed -verify-diagnostics

func.func @move_anchor_seed_rejected() {
  // expected-error@+1 {{cannot move scope-owned anchor value with live dependent tensor references}}
  %seed = "builtin.unrealized_conversion_cast"() : () -> index
  %extra = "builtin.unrealized_conversion_cast"() : () -> index
  %t = "builtin.unrealized_conversion_cast"() : () -> tensor<[%seed], f32>
  return
}
