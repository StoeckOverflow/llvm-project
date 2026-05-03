// RUN: mlir-opt %s | FileCheck %s

func.func @matmul_ok(%m : index, %k : index, %n : index) {
  %a = dependent_tensor.make %m, %k dims[m, k] : tensor<?x?xf32>
  %b = dependent_tensor.make %k, %n dims[k, n] : tensor<?x?xf32>
  %r = dependent_tensor.matmul %a, %b : tensor<?x?xf32>, tensor<?x?xf32> -> tensor<?x?xf32>
  return
}

// CHECK-LABEL: func.func @matmul_ok
// CHECK-SAME: (%[[M:arg[0-9]+]]: index, %[[K:arg[0-9]+]]: index, %[[N:arg[0-9]+]]: index)
// CHECK-NEXT: %[[A:.*]] = dependent_tensor.make %[[M]], %[[K]] dims[m, k] : tensor<?x?xf32>
// CHECK-NEXT: %[[B:.*]] = dependent_tensor.make %[[K]], %[[N]] dims[k, n] : tensor<?x?xf32>
// CHECK-NEXT: %[[R:.*]] = dependent_tensor.matmul %[[A]], %[[B]] : tensor<?x?xf32>, tensor<?x?xf32> -> tensor<?x?xf32>
// CHECK-NEXT: return
