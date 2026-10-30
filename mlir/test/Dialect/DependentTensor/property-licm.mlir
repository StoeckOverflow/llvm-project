// RUN: mlir-opt %s -loop-invariant-code-motion | FileCheck %s

// CHECK-LABEL: func.func @licm_property
// CHECK: scf.for %[[I:.*]] =
// CHECK: dependent_tensor.make () #tensor<[%[[I]]], f32>
// A property-only dependence on the induction variable must prevent hoisting.
func.func @licm_property(%n: index, %out: memref<?xf32>) {
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  scf.for %i = %c1 to %n step %c1 {
    %t = dependent_tensor.make () #tensor<[%i], f32> : tensor<?xf32>
    %v = dependent_tensor.extract %t[%c0] : f32
    memref.store %v, %out[%i] : memref<?xf32>
  }
  return
}

// CHECK-LABEL: func.func @licm_invariant
// CHECK: dependent_tensor.make
// CHECK: scf.for
// CHECK-NOT: dependent_tensor.make
// CHECK: return
func.func @licm_invariant(%n: index, %out: memref<?xf32>) {
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  scf.for %i = %c1 to %n step %c1 {
    %t = dependent_tensor.make () #tensor<[%n], f32> : tensor<?xf32>
    %v = dependent_tensor.extract %t[%c0] : f32
    memref.store %v, %out[%i] : memref<?xf32>
  }
  return
}
