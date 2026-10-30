// RUN: mlir-opt %s -inline | FileCheck %s --implicit-check-not=func.call
func.func private @read(%n: index, %flat: memref<f32>, %i: index) -> f32 {
  %c1 = arith.constant 1 : index
  %a = dependent_memref.reinterpret_cast %flat, #memref<[%n], f32, offset: 0, strides: [%c1]> : memref<f32> to memref<?xf32>
  %v = dependent_memref.load %a[%i] #memref<[%n], f32, offset: 0, strides: [%c1]> : memref<?xf32>
  return %v : f32
}
// CHECK-LABEL: func.func @caller
// CHECK-SAME: %[[N:arg[0-9]+]]: index
// CHECK: dependent_memref.reinterpret_cast {{.*}}#memref<[%[[N]]], f32
// CHECK: dependent_memref.load {{.*}}#memref<[%[[N]]], f32
func.func @caller(%n: index, %flat: memref<f32>, %i: index) -> f32 {
  %v = func.call @read(%n, %flat, %i) : (index, memref<f32>, index) -> f32
  return %v : f32
}
