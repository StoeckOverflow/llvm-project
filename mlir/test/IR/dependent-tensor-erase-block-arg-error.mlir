// RUN: mlir-opt %s -test-dependent-tensor-erase-block-arg -verify-diagnostics

// expected-error@+1 {{cannot erase anchor value with live dependent tensor references}}
func.func @erase_block_arg_rejected(%seed : index) -> tensor<[%seed], f32> {
  %t = "builtin.unrealized_conversion_cast"() : () -> tensor<[%seed], f32>
  return %t : tensor<[%seed], f32>
}
