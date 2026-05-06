// RUN: mlir-opt %s -pass-pipeline='builtin.module(func.func(dependent-tensor-clone-local-producer))' | FileCheck %s --check-prefix=CLONE
// RUN: mlir-opt %s -pass-pipeline='builtin.module(func.func(dependent-tensor-replace-dim-value))' | FileCheck %s --check-prefix=REMAP

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

func.func @replace_dim_value() {
  %dim = arith.constant 1 : index
  %replacement = arith.constant 2 : index
  %other = arith.constant 3 : index
  %t = dependent_tensor.make %dim, %other dims[m, n] : tensor<?x?xf32>
  return
}

// REMAP-LABEL: func.func @replace_dim_value
// REMAP-NEXT: %[[S:.*]] = arith.constant 1 : index
// REMAP-NEXT: %[[R:.*]] = arith.constant 2 : index
// REMAP-NEXT: %[[O:.*]] = arith.constant 3 : index
// REMAP-NEXT: %[[T:.*]] = dependent_tensor.make %[[R]], %[[O]] dims[m, n] : tensor<?x?xf32>
// REMAP-NEXT: return

// -----

func.func @clone_insert() {
  %m = arith.constant 1 : index
  %n = arith.constant 2 : index
  %i = arith.constant 0 : index
  %v = arith.constant 0.000000e+00 : f32
  %t = dependent_tensor.make %m, %n dims[m, n] : tensor<?x?xf32>
  %r = dependent_tensor.insert %v into %t[%i, %i] result_dims[%m, %n] dims[m, n] : f32 into tensor<?x?xf32>
  return
}

// CLONE-LABEL: func.func @clone_insert
// CLONE: %[[T0:.*]] = dependent_tensor.make
// CLONE: %[[R0:.*]] = dependent_tensor.insert {{.*}} into %[[T0]]{{.*}}result_dims
// CLONE: %[[T1:.*]] = dependent_tensor.make
// CLONE: %[[R1:.*]] = dependent_tensor.insert {{.*}} into %[[T1]]{{.*}}result_dims
