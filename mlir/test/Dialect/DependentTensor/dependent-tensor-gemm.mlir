// RUN: mlir-opt %s | FileCheck %s

func.func @gemm_ok(%m : index, %k : index, %n : index) {
  %a = dependent_tensor.make %m, %k dims[m, k] : tensor<?x?xf32>
  %b = dependent_tensor.make %k, %n dims[k, n] : tensor<?x?xf32>
  %c = dependent_tensor.make %m, %n dims[m, n] : tensor<?x?xf32>
  %r = dependent_tensor.gemm %a, %b, %c dims[m, k, n] (m, k) x (k, n) + (m, n) -> (m, n)
    : tensor<?x?xf32>, tensor<?x?xf32>, tensor<?x?xf32> -> tensor<?x?xf32>
  return
}

// CHECK-LABEL: func.func @gemm_ok
// CHECK-SAME: (%[[M:arg[0-9]+]]: index, %[[K:arg[0-9]+]]: index, %[[N:arg[0-9]+]]: index)
// CHECK-NEXT: %[[A:.*]] = dependent_tensor.make %[[M]], %[[K]] dims[m, k] : tensor<?x?xf32>
// CHECK-NEXT: %[[B:.*]] = dependent_tensor.make %[[K]], %[[N]] dims[k, n] : tensor<?x?xf32>
// CHECK-NEXT: %[[C:.*]] = dependent_tensor.make %[[M]], %[[N]] dims[m, n] : tensor<?x?xf32>
// CHECK-NEXT: %[[R:.*]] = dependent_tensor.gemm %[[A]], %[[B]], %[[C]] dims[m, k, n] (m, k) x (k, n) + (m, n) -> (m, n) : tensor<?x?xf32>, tensor<?x?xf32>, tensor<?x?xf32> -> tensor<?x?xf32>
// CHECK-NEXT: return
