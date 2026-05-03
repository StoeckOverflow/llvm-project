// RUN: mlir-opt %s -pass-pipeline='builtin.module(func.func(dependent-tensor-clone-local-producer))' | FileCheck %s --check-prefix=CLONE
// RUN: mlir-opt %s -pass-pipeline='builtin.module(func.func(dependent-tensor-replace-seed))' | FileCheck %s --check-prefix=REMAP

func.func @clone_make() {
  %m = arith.constant 1 : index
  %n = arith.constant 2 : index
  %t = dependent_tensor.make %m, %n dims[m, n] : tensor<?x?xf32>
  return
}

// CLONE-LABEL: func.func @clone_make
// CLONE-NEXT: %[[M0:.*]] = arith.constant 1 : index
// CLONE-NEXT: %[[N0:.*]] = arith.constant 2 : index
// CLONE-NEXT: %[[T0:.*]] = dependent_tensor.make %[[M0]], %[[N0]] dims[m, n] : tensor<?x?xf32>
// CLONE-NEXT: %[[M1:.*]] = arith.constant 1 : index
// CLONE-NEXT: %[[N1:.*]] = arith.constant 2 : index
// CLONE-NEXT: %[[T1:.*]] = dependent_tensor.make %[[M1]], %[[N1]] dims[m, n] : tensor<?x?xf32>
// CLONE-NEXT: return

// -----

func.func @replace_seed() {
  %seed = arith.constant 1 : index
  %replacement = arith.constant 2 : index
  %other = arith.constant 3 : index
  %t = dependent_tensor.make %seed, %other dims[m, n] : tensor<?x?xf32>
  return
}

// REMAP-LABEL: func.func @replace_seed
// REMAP-NEXT: %[[S:.*]] = arith.constant 1 : index
// REMAP-NEXT: %[[R:.*]] = arith.constant 2 : index
// REMAP-NEXT: %[[O:.*]] = arith.constant 3 : index
// REMAP-NEXT: %[[T:.*]] = dependent_tensor.make %[[R]], %[[O]] dims[m, n] : tensor<?x?xf32>
// REMAP-NEXT: return

// -----

func.func @clone_gemm() {
  %m = arith.constant 1 : index
  %k = arith.constant 2 : index
  %n = arith.constant 3 : index
  %a = dependent_tensor.make %m, %k dims[m, k] : tensor<?x?xf32>
  %b = dependent_tensor.make %k, %n dims[k, n] : tensor<?x?xf32>
  %c = dependent_tensor.make %m, %n dims[m, n] : tensor<?x?xf32>
  %r = dependent_tensor.gemm %a, %b, %c dims[m, k, n] (m, k) x (k, n) + (m, n) -> (m, n)
    : tensor<?x?xf32>, tensor<?x?xf32>, tensor<?x?xf32> -> tensor<?x?xf32>
  return
}

// CLONE-LABEL: func.func @clone_gemm
// CLONE: %[[A0:.*]] = dependent_tensor.make
// CLONE: %[[B0:.*]] = dependent_tensor.make
// CLONE: %[[C0:.*]] = dependent_tensor.make
// CLONE: %[[R0:.*]] = dependent_tensor.gemm %[[A0]], %[[B0]], %[[C0]] dims[m, k, n] (m, k) x (k, n) + (m, n) -> (m, n) : tensor<?x?xf32>, tensor<?x?xf32>, tensor<?x?xf32> -> tensor<?x?xf32>
// CLONE: %[[A1:.*]] = dependent_tensor.make
// CLONE: %[[B1:.*]] = dependent_tensor.make
// CLONE: %[[C1:.*]] = dependent_tensor.make
// CLONE: %[[R1:.*]] = dependent_tensor.gemm %[[A1]], %[[B1]], %[[C1]] dims[m, k, n] (m, k) x (k, n) + (m, n) -> (m, n) : tensor<?x?xf32>, tensor<?x?xf32>, tensor<?x?xf32> -> tensor<?x?xf32>
