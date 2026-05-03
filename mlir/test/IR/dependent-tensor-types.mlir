// RUN: mlir-opt %s | FileCheck %s --check-prefix=CHECK

func.func @scope_owner_block_arg(%x : index) {
  %t = "builtin.unrealized_conversion_cast"() : () -> tensor<[%x], f32>
  return
}

// CHECK-LABEL: func.func @scope_owner_block_arg
// CHECK-SAME: (%[[X:arg[0-9]+]]: index)
// CHECK-NEXT: %[[T:.*]] = builtin.unrealized_conversion_cast to tensor<[%[[X]]], f32>
// CHECK-NEXT: return

// -----

func.func @result_owner_direct() {
  %d = test.dependent_result_owner : index
  %t = "builtin.unrealized_conversion_cast"() : () -> tensor<[%d], f32>
  return
}

// CHECK-LABEL: func.func @result_owner_direct
// CHECK-NEXT: %[[D:.*]] = test.dependent_result_owner : index
// CHECK-NEXT: %[[T:.*]] = builtin.unrealized_conversion_cast to tensor<[%[[D]]], f32>
// CHECK-NEXT: return

// -----

func.func @scope_owner_result_fallback() {
  %d = arith.constant 7 : index
  %t = "builtin.unrealized_conversion_cast"() : () -> tensor<[%d], f32>
  return
}

// CHECK-LABEL: func.func @scope_owner_result_fallback
// CHECK-NEXT: %[[D:.*]] = arith.constant 7 : index
// CHECK-NEXT: %[[T:.*]] = builtin.unrealized_conversion_cast to tensor<[%[[D]]], f32>
// CHECK-NEXT: return

// -----

func.func @scope_owner_multi_anchor(%x : index, %y : index) {
  %t = "builtin.unrealized_conversion_cast"() : () -> tensor<[%x, %y], f32>
  return
}

// CHECK-LABEL: func.func @scope_owner_multi_anchor
// CHECK-SAME: (%[[X:arg[0-9]+]]: index, %[[Y:arg[0-9]+]]: index)
// CHECK-NEXT: %[[T:.*]] = builtin.unrealized_conversion_cast to tensor<[%[[X]], %[[Y]]], f32>
// CHECK-NEXT: return

// -----

func.func @mixed_owner_multi_anchor(%x : index) {
  %d = test.dependent_result_owner : index
  %t = "builtin.unrealized_conversion_cast"() : () -> tensor<[%x, %d], f32>
  return
}

// CHECK-LABEL: func.func @mixed_owner_multi_anchor
// CHECK-SAME: (%[[X:arg[0-9]+]]: index)
// CHECK-NEXT: %[[D:.*]] = test.dependent_result_owner : index
// CHECK-NEXT: %[[T:.*]] = builtin.unrealized_conversion_cast to tensor<[%[[X]], %[[D]]], f32>
// CHECK-NEXT: return

// -----

// RUN: mlir-opt %s | FileCheck %s --check-prefix=INLINE
module {
  func.func @inline_constant_anchor() {
    %n = arith.constant 7 : index
    %t = "builtin.unrealized_conversion_cast"() : () -> tensor<[%n], f32>
    return
  }
}
// INLINE: %[[N:.*]] = arith.constant 7 : index
// INLINE-NEXT: %[[T:.*]] = builtin.unrealized_conversion_cast to tensor<[%[[N]]], f32>
// INLINE-NEXT: return
