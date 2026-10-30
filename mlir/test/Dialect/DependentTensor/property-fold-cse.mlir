// RUN: mlir-opt %s -cse | FileCheck %s --check-prefix=CSE
// RUN: mlir-opt %s -canonicalize -cse | FileCheck %s
// CHECK-LABEL: func.func @fold_property
// CHECK: %[[C:.*]] = arith.constant 5 : index
// CHECK-NEXT: %{{.*}} = dependent_tensor.make () #tensor<[%[[C]]], f32>
// Additional focused tests: properties are the only uses of %shape.
func.func @fold_property(%i: index) -> f32 {
  %two = arith.constant 2 : index
  %three = arith.constant 3 : index
  %shape = arith.addi %two, %three : index
  %t = dependent_tensor.make () #tensor<[%shape], f32> : tensor<?xf32>
  %v = dependent_tensor.extract %t[%i] : f32
  return %v : f32
}


// CHECK-LABEL: func.func @equal_constant_shapes
// CHECK: %[[C7:.*]] = arith.constant 7 : index
// CHECK-NEXT: %[[T:.*]] = dependent_tensor.make () #tensor<[%[[C7]]], f32>
// CHECK-NEXT: %[[X:.*]] = dependent_tensor.extract %[[T]]
// CHECK-NEXT: return %[[X]], %[[X]]
func.func @equal_constant_shapes(%i: index) -> (f32, f32) {
  %n = arith.constant 7 : index
  %m = arith.constant 7 : index
  %a = dependent_tensor.make () #tensor<[%n], f32> : tensor<?xf32>
  %b = dependent_tensor.make () #tensor<[%m], f32> : tensor<?xf32>
  %x = dependent_tensor.extract %a[%i] : f32
  %y = dependent_tensor.extract %b[%i] : f32
  return %x, %y : f32, f32
}
// CSE-LABEL: func.func @equal_constant_shapes
// CSE: %[[C7:.*]] = arith.constant 7 : index
// CSE-NEXT: %[[T:.*]] = dependent_tensor.make () #tensor<[%[[C7]]], f32>
// CSE-NEXT: %[[X:.*]] = dependent_tensor.extract %[[T]]
// CSE-NEXT: return %[[X]], %[[X]]

// Different constant values must keep both refinements and computations.
// CSE-LABEL: func.func @different_constant_shapes
// CSE: %[[C7:.*]] = arith.constant 7 : index
// CSE-NEXT: %[[C8:.*]] = arith.constant 8 : index
// CSE-NEXT: %[[A:.*]] = dependent_tensor.make () #tensor<[%[[C7]]], f32>
// CSE-NEXT: %[[B:.*]] = dependent_tensor.make () #tensor<[%[[C8]]], f32>
// CSE-NEXT: %[[X:.*]] = dependent_tensor.extract %[[A]]
// CSE-NEXT: %[[Y:.*]] = dependent_tensor.extract %[[B]]
// CSE-NEXT: return %[[X]], %[[Y]]
// CHECK-LABEL: func.func @different_constant_shapes
// CHECK: %[[C7:.*]] = arith.constant 7 : index
// CHECK-NEXT: %[[C8:.*]] = arith.constant 8 : index
// CHECK-NEXT: %[[A:.*]] = dependent_tensor.make () #tensor<[%[[C7]]], f32>
// CHECK-NEXT: %[[B:.*]] = dependent_tensor.make () #tensor<[%[[C8]]], f32>
// CHECK-NEXT: %[[X:.*]] = dependent_tensor.extract %[[A]]
// CHECK-NEXT: %[[Y:.*]] = dependent_tensor.extract %[[B]]
// CHECK-NEXT: return %[[X]], %[[Y]]
func.func @different_constant_shapes(%i: index) -> (f32, f32) {
  %n = arith.constant 7 : index
  %m = arith.constant 8 : index
  %a = dependent_tensor.make () #tensor<[%n], f32> : tensor<?xf32>
  %b = dependent_tensor.make () #tensor<[%m], f32> : tensor<?xf32>
  %x = dependent_tensor.extract %a[%i] : f32
  %y = dependent_tensor.extract %b[%i] : f32
  return %x, %y : f32, f32
}
