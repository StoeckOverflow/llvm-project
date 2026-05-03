// RUN: mlir-opt %s | FileCheck %s

func.func @dependent_matmul_ok(%m : index, %k : index, %n : index,
                               %a : tensor<[%m, %k], f32>,
                               %b : tensor<[%k, %n], f32>) {
  %r = test.dependent_matmul %a, %b : tensor<[%m, %k], f32>, tensor<[%k, %n], f32> -> tensor<[%m, %n], f32>
  return
}

// CHECK-LABEL: func.func @dependent_matmul_ok
// CHECK-SAME: (%[[M:arg[0-9]+]]: index, %[[K:arg[0-9]+]]: index, %[[N:arg[0-9]+]]: index, %[[A:arg[0-9]+]]: tensor<[%[[M]], %[[K]]], f32>, %[[B:arg[0-9]+]]: tensor<[%[[K]], %[[N]]], f32>)
// CHECK-NEXT: %[[R:.*]] = test.dependent_matmul %[[A]], %[[B]] : tensor<[%[[M]], %[[K]]], f32>, tensor<[%[[K]], %[[N]]], f32> -> tensor<[%[[M]], %[[N]]], f32>
// CHECK-NEXT: return

// -----

func.func @dependent_matmul_mixed_ok(%m : index, %k : index,
                                     %a : tensor<[4, %k], f32>,
                                     %b : tensor<[%k, 8], f32>) {
  %r = test.dependent_matmul %a, %b : tensor<[4, %k], f32>, tensor<[%k, 8], f32> -> tensor<[4, 8], f32>
  return
}

// CHECK-LABEL: func.func @dependent_matmul_mixed_ok
// CHECK-SAME: (%[[M:arg[0-9]+]]: index, %[[K:arg[0-9]+]]: index, %[[A:arg[0-9]+]]: tensor<[4, %[[K]]], f32>, %[[B:arg[0-9]+]]: tensor<[%[[K]], 8], f32>)
// CHECK-NEXT: %[[R:.*]] = test.dependent_matmul %[[A]], %[[B]] : tensor<[4, %[[K]]], f32>, tensor<[%[[K]], 8], f32> -> tensor<[4, 8], f32>
// CHECK-NEXT: return
