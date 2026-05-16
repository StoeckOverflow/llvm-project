// RUN: mlir-opt %s --verify-each -pass-pipeline='builtin.module(func.func(test-dependent-tensor-corrupt-property-use-registration))' -verify-diagnostics

func.func @stale_property_use_registration(%old: index, %new: index) {
  // The test pass directly mutates the property slot from %old to %new without
  // calling refreshPropertySSAUses. The slot then says "%new", but the
  // PropertySSAUse node is still linked from %old's use-list.
  // expected-error@below {{'dependent_tensor.make' op has stale property SSA use-list membership for property slot #0}}
  %t = dependent_tensor.make () #tensor<[%old], f32> : tensor<?xf32>
  return
}
