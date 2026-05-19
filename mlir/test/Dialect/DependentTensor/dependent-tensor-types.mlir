// RUN: mlir-opt %s | FileCheck %s

func.func @make_roundtrip(%m : index, %n : index) {
  %t = dependent_tensor.make () #tensor<[%m, %n], f32> : tensor<?x?xf32>
  return
}

// CHECK-LABEL: func.func @make_roundtrip
// CHECK-SAME: (%[[M:arg[0-9]+]]: index, %[[N:arg[0-9]+]]: index)
// CHECK-NEXT: %[[T:.*]] = dependent_tensor.make () #tensor<[%[[M]], %[[N]]], f32> : tensor<?x?xf32>
// CHECK-NEXT: return

// -----

func.func @make_from_constants() {
  %n = arith.constant 4 : index
  %m = arith.constant 8 : index
  %A = dependent_tensor.make () #tensor<[%n, %m], f32> : tensor<?x?xf32>
  return
}

// CHECK-LABEL: func.func @make_from_constants
// CHECK-NEXT: %[[N:.*]] = arith.constant 4 : index
// CHECK-NEXT: %[[M:.*]] = arith.constant 8 : index
// CHECK-NEXT: %[[A:.*]] = dependent_tensor.make () #tensor<[%[[N]], %[[M]]], f32> : tensor<?x?xf32>
// CHECK-NEXT: return

// -----

func.func @make_reordered(%k : index, %m : index) {
  %t = dependent_tensor.make () #tensor<[%k, %m], f32> : tensor<?x?xf32>
  return
}

// CHECK-LABEL: func.func @make_reordered
// CHECK-SAME: (%[[K:arg[0-9]+]]: index, %[[M:arg[0-9]+]]: index)
// CHECK-NEXT: %[[T:.*]] = dependent_tensor.make () #tensor<[%[[K]], %[[M]]], f32> : tensor<?x?xf32>
// CHECK-NEXT: return

// -----

func.func @primitive_roundtrip(%m : index, %n : index, %i : index, %j : index, %v : f32) {
  %t = dependent_tensor.make () #tensor<[%m, %n], f32> : tensor<?x?xf32>
  %d = dependent_tensor.dim %t, %i : tensor<?x?xf32>
  %e = dependent_tensor.extract %t[%i, %j] #tensor<[%m, %n], f32> : f32
  %u = dependent_tensor.insert %v into %t[%i, %j] #tensor<[%m, %n], f32> : f32 into tensor<?x?xf32>
  return
}

// CHECK-LABEL: func.func @primitive_roundtrip
// CHECK-SAME: (%[[M:arg[0-9]+]]: index, %[[N:arg[0-9]+]]: index, %[[I:arg[0-9]+]]: index, %[[J:arg[0-9]+]]: index, %[[V:arg[0-9]+]]: f32)
// CHECK-NEXT: %[[T:.*]] = dependent_tensor.make () #tensor<[%[[M]], %[[N]]], f32> : tensor<?x?xf32>
// CHECK-NEXT: %[[D:.*]] = dependent_tensor.dim %[[T]], %[[I]] : tensor<?x?xf32>
// CHECK-NEXT: %[[E:.*]] = dependent_tensor.extract %[[T]][%[[I]], %[[J]]] #tensor<[%[[M]], %[[N]]], f32> : f32
// CHECK-NEXT: %[[U:.*]] = dependent_tensor.insert %[[V]] into %[[T]][%[[I]], %[[J]]] #tensor<[%[[M]], %[[N]]], f32> : f32 into tensor<?x?xf32>
// CHECK-NEXT: return

// -----

func.func @dim_assertion_roundtrip(%m : index, %n : index) {
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  %t = dependent_tensor.make () #tensor<[%m, %n], f32> : tensor<?x?xf32>
  %d0 = dependent_tensor.dim %t, %c0, #dim %m : tensor<?x?xf32>
  %d1 = dependent_tensor.dim %t, %c1, #dim %n : tensor<?x?xf32>
  return
}

// CHECK-LABEL: func.func @dim_assertion_roundtrip
// CHECK-SAME: (%[[M:arg[0-9]+]]: index, %[[N:arg[0-9]+]]: index)
// CHECK-NEXT: %[[C0:.*]] = arith.constant 0 : index
// CHECK-NEXT: %[[C1:.*]] = arith.constant 1 : index
// CHECK-NEXT: %[[T:.*]] = dependent_tensor.make () #tensor<[%[[M]], %[[N]]], f32> : tensor<?x?xf32>
// CHECK-NEXT: %[[D0:.*]] = dependent_tensor.dim %[[T]], %[[C0]], #dim %[[M]] : tensor<?x?xf32>
// CHECK-NEXT: %[[D1:.*]] = dependent_tensor.dim %[[T]], %[[C1]], #dim %[[N]] : tensor<?x?xf32>
// CHECK-NEXT: return
