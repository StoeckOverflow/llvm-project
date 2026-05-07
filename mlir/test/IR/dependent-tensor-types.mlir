// RUN: mlir-opt %s | FileCheck %s --check-prefix=CHECK

func.func @scope_owner_block_arg(%x : index) {
  %t = dependent_tensor.make () #tensor<[%x], f32> : tensor<?xf32>
  return
}

// CHECK-LABEL: func.func @scope_owner_block_arg
// CHECK-SAME: (%[[X:arg[0-9]+]]: index)
// CHECK-NEXT: %[[T:.*]] = dependent_tensor.make () #tensor<[%[[X]]], f32> : tensor<?xf32>
// CHECK-NEXT: return

// -----

func.func @result_owner_direct() {
  %d = arith.constant 7 : index
  %t = dependent_tensor.make () #tensor<[%d], f32> : tensor<?xf32>
  return
}

// CHECK-LABEL: func.func @result_owner_direct
// CHECK-NEXT: %[[D:.*]] = arith.constant 7 : index
// CHECK-NEXT: %[[T:.*]] = dependent_tensor.make () #tensor<[%[[D]]], f32> : tensor<?xf32>
// CHECK-NEXT: return

// -----

func.func @scope_owner_result_fallback() {
  %d = arith.constant 7 : index
  %t = dependent_tensor.make () #tensor<[%d], f32> : tensor<?xf32>
  return
}

// CHECK-LABEL: func.func @scope_owner_result_fallback
// CHECK-NEXT: %[[D:.*]] = arith.constant 7 : index
// CHECK-NEXT: %[[T:.*]] = dependent_tensor.make () #tensor<[%[[D]]], f32> : tensor<?xf32>
// CHECK-NEXT: return

// -----

func.func @scope_owner_multi_anchor(%x : index, %y : index) {
  %t = dependent_tensor.make () #tensor<[%x, %y], f32> : tensor<?x?xf32>
  return
}

// CHECK-LABEL: func.func @scope_owner_multi_anchor
// CHECK-SAME: (%[[X:arg[0-9]+]]: index, %[[Y:arg[0-9]+]]: index)
// CHECK-NEXT: %[[T:.*]] = dependent_tensor.make () #tensor<[%[[X]], %[[Y]]], f32> : tensor<?x?xf32>
// CHECK-NEXT: return

// -----

func.func @mixed_owner_multi_anchor(%x : index) {
  %d = arith.constant 7 : index
  %t = dependent_tensor.make () #tensor<[%x, %d], f32> : tensor<?x?xf32>
  return
}

// CHECK-LABEL: func.func @mixed_owner_multi_anchor
// CHECK-SAME: (%[[X:arg[0-9]+]]: index)
// CHECK-NEXT: %[[D:.*]] = arith.constant 7 : index
// CHECK-NEXT: %[[T:.*]] = dependent_tensor.make () #tensor<[%[[X]], %[[D]]], f32> : tensor<?x?xf32>
// CHECK-NEXT: return

// -----

// RUN: mlir-opt %s | FileCheck %s --check-prefix=INLINE
module {
  func.func @inline_constant_anchor() {
    %n = arith.constant 7 : index
    %t = dependent_tensor.make () #tensor<[%n], f32> : tensor<?xf32>
    return
  }
}
// INLINE: %[[N:.*]] = arith.constant 7 : index
// INLINE-NEXT: %[[T:.*]] = dependent_tensor.make () #tensor<[%[[N]]], f32> : tensor<?xf32>
// INLINE-NEXT: return
