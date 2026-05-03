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

func.func @make_reordered(%k : index, %m : index) {
  %t = dependent_tensor.make %k, %m dims[k, m] : tensor<?x?xf32>
  return
}

// CHECK-LABEL: func.func @make_reordered
// CHECK-SAME: (%[[K:arg[0-9]+]]: index, %[[M:arg[0-9]+]]: index)
// CHECK-NEXT: %[[T:.*]] = dependent_tensor.make %[[K]], %[[M]] dims[k, m] : tensor<?x?xf32>
// CHECK-NEXT: return
