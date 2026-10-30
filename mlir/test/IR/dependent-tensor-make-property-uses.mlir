// RUN: mlir-opt %s -pass-pipeline='builtin.module(func.func(test-dependent-tensor-check-property-uses))' | FileCheck %s

func.func @check_make_dims_property_only(%m : index, %n : index) -> tensor<?x?xf32>
    #types[] -> #tensor<[%m, %n], f32> {
  %t = dependent_tensor.make () #tensor<[%m, %n], f32> : tensor<?x?xf32>
  return %t : tensor<?x?xf32>
}

// CHECK-LABEL: func.func @check_make_dims_property_only
// CHECK-SAME: (%[[M:arg[0-9]+]]: index, %[[N:arg[0-9]+]]: index) -> tensor<?x?xf32>
// CHECK-SAME: #types[] -> #tensor<[%[[M]], %[[N]]], f32>
// CHECK: dependent_tensor.make () #tensor<[%[[M]], %[[N]]], f32> : tensor<?x?xf32>

// -----

func.func @check_refinements_are_direct_property_uses(%m : index, %i : index,
                                                      %v : f32) {
  %c0 = arith.constant 0 : index
  %t = dependent_tensor.make () #tensor<[%m], f32> : tensor<?xf32>
  %d = dependent_tensor.dim %t, %c0, #dim %m : tensor<?xf32>
  %r = dependent_tensor.insert %v into %t[%i] #tensor<[%m], f32> : f32 into tensor<?xf32>
  return
}

// CHECK-LABEL: func.func @check_refinements_are_direct_property_uses
// CHECK-SAME: (%[[M:arg[0-9]+]]: index
// CHECK: dependent_tensor.make () #tensor<[%[[M]]], f32> : tensor<?xf32>
// CHECK: dependent_tensor.dim %{{.*}}, %{{.*}}, #dim %[[M]] : tensor<?xf32>
// CHECK: dependent_tensor.insert %{{.*}} into %{{.*}}[%{{.*}}] #tensor<[%[[M]]], f32> : f32 into tensor<?xf32>

// -----

func.func @check_property_use_list_api(%n: index, %i: index) -> tensor<?xf32>
    #types[] -> #tensor<[%n], f32> {
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  %t = dependent_tensor.make () #tensor<[%n], f32> : tensor<?xf32>
  %r = scf.for %iv = %c0 to %n step %c1 iter_args(%a = %t) -> tensor<?xf32>
      #types[%a : #tensor<[%n], f32>] -> #tensor<[%n], f32> {
    scf.yield %a : tensor<?xf32>
  }
  return %r : tensor<?xf32>
}

func.func @check_repeated_property_users(%n: index) {
  %a = dependent_tensor.make () #tensor<[%n, %n], f32> : tensor<?x?xf32>
  %b = dependent_tensor.make () #tensor<[%n], f32> : tensor<?xf32>
  return
}

// CHECK-LABEL: func.func @check_property_use_list_api
// CHECK-LABEL: func.func @check_repeated_property_users
