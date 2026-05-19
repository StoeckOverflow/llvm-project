// RUN: mlir-opt %s --verify-each -pass-pipeline='builtin.module(func.func(test-dependent-tensor-corrupt-property-operand-attachment))' -verify-diagnostics

func.func @stale_property_operand_attachment(%old: index, %new: index) {
  // The test pass detaches the embedded property operand while leaving the
  // property value intact. There is no sidecar registration to refresh; the
  // verifier checks that embedded property operands remain attached.
  // expected-error@below {{'dependent_tensor.make' op has property operand with incorrect or missing owner}}
  %t = dependent_tensor.make () #tensor<[%old], f32> : tensor<?xf32>
  return
}
