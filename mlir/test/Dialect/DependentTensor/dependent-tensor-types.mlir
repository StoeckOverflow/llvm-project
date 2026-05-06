// RUN: mlir-opt %s | FileCheck %s

func.func @make_roundtrip(%m : index, %n : index) {
  %t = dependent_tensor.make %m, %n dims[m, n] : tensor<?x?xf32>
  return
}

// CHECK-LABEL: func.func @make_roundtrip
// CHECK-SAME: (%[[M:arg[0-9]+]]: index, %[[N:arg[0-9]+]]: index)
// CHECK-NEXT: %[[T:.*]] = dependent_tensor.make %[[M]], %[[N]] dims[m, n] : tensor<?x?xf32>
// CHECK-NEXT: return

// -----

func.func @make_from_constants() {
  %n = arith.constant 4 : index
  %m = arith.constant 8 : index
  %A = dependent_tensor.make %n, %m dims[n, m] : tensor<?x?xf32>
  return
}

// CHECK-LABEL: func.func @make_from_constants
// CHECK-NEXT: %[[N:.*]] = arith.constant 4 : index
// CHECK-NEXT: %[[M:.*]] = arith.constant 8 : index
// CHECK-NEXT: %[[A:.*]] = dependent_tensor.make %[[N]], %[[M]] dims[n, m] : tensor<?x?xf32>
// CHECK-NEXT: return

// -----

func.func @make_reordered(%k : index, %m : index) {
  %t = dependent_tensor.make %k, %m dims[k, m] : tensor<?x?xf32>
  return
}

// CHECK-LABEL: func.func @make_reordered
// CHECK-SAME: (%[[K:arg[0-9]+]]: index, %[[M:arg[0-9]+]]: index)
// CHECK-NEXT: %[[T:.*]] = dependent_tensor.make %[[K]], %[[M]] dims[k, m] : tensor<?x?xf32>
// CHECK-NEXT: return

// -----

func.func @primitive_roundtrip(%m : index, %n : index, %i : index, %j : index, %v : f32) {
  %t = dependent_tensor.make %m, %n dims[m, n] : tensor<?x?xf32>
  %d = dependent_tensor.dim %t, %i : tensor<?x?xf32>
  %e = dependent_tensor.extract %t[%i, %j] : tensor<?x?xf32>
  %u = dependent_tensor.insert %v into %t[%i, %j] result_dims[%m, %n] dims[m, n] : f32 into tensor<?x?xf32>
  return
}

// CHECK-LABEL: func.func @primitive_roundtrip
// CHECK-SAME: (%[[M:arg[0-9]+]]: index, %[[N:arg[0-9]+]]: index, %[[I:arg[0-9]+]]: index, %[[J:arg[0-9]+]]: index, %[[V:arg[0-9]+]]: f32)
// CHECK-NEXT: %[[T:.*]] = dependent_tensor.make %[[M]], %[[N]] dims[m, n] : tensor<?x?xf32>
// CHECK-NEXT: %[[D:.*]] = dependent_tensor.dim %[[T]], %[[I]] : tensor<?x?xf32>
// CHECK-NEXT: %[[E:.*]] = dependent_tensor.extract %[[T]][%[[I]], %[[J]]] : tensor<?x?xf32>
// CHECK-NEXT: %[[U:.*]] = dependent_tensor.insert %[[V]] into %[[T]][%[[I]], %[[J]]] result_dims[%[[M]], %[[N]]] dims[m, n] : f32 into tensor<?x?xf32>
// CHECK-NEXT: return
