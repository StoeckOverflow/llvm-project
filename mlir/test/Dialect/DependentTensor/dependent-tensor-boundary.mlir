// RUN: mlir-opt %s -verify-dependent-tensor-semantics | FileCheck %s

func.func @identity_with_boundary(
    %m : index,
    %n : index,
    %t : tensor<?x?xf32>)
    -> tensor<?x?xf32>
    #types[%t : #tensor<[%m, %n], f32>] -> #tensor<[%m, %n], f32> {
  return %t : tensor<?x?xf32>
}

func.func @call_and_return_boundary(
    %m : index,
    %n : index) -> tensor<?x?xf32>
    #types[] -> #tensor<[%m, %n], f32> {
  %t = dependent_tensor.make () #tensor<[%m, %n], f32> : tensor<?x?xf32>
  %r = func.call @identity_with_boundary(%m, %n, %t) : (index, index, tensor<?x?xf32>) -> tensor<?x?xf32>
  return %r : tensor<?x?xf32>
}

func.func @return_insert_boundary(
    %m : index,
    %n : index,
    %i : index,
    %j : index,
    %v : f32) -> tensor<?x?xf32>
    #types[] -> #tensor<[%m, %n], f32> {
  %t = dependent_tensor.make () #tensor<[%m, %n], f32> : tensor<?x?xf32>
  %r = dependent_tensor.insert %v into %t[%i, %j] #tensor<[%m, %n], f32> : f32 into tensor<?x?xf32>
  return %r : tensor<?x?xf32>
}

func.func @multi_result_boundary(
    %m : index,
    %n : index,
    %a : tensor<?xf32>,
    %b : tensor<?xf32>)
    -> (tensor<?xf32>, tensor<?xf32>)
    #types[
      %a : #tensor<[%m], f32>,
      %b : #tensor<[%n], f32>
    ] -> [#tensor<[%m], f32>, #tensor<[%n], f32>] {
  return %a, %b : tensor<?xf32>, tensor<?xf32>
}

// CHECK-LABEL: func.func @identity_with_boundary
// CHECK-SAME: (%[[ID_M:arg[0-9]+]]: index, %[[ID_N:arg[0-9]+]]: index, %[[ID_T:arg[0-9]+]]: tensor<?x?xf32>) -> tensor<?x?xf32>
// CHECK-SAME: #types[%[[ID_T]] : #tensor<[%[[ID_M]], %[[ID_N]]], f32>] -> #tensor<[%[[ID_M]], %[[ID_N]]], f32>
// CHECK-NEXT: return %[[ID_T]] : tensor<?x?xf32>
// CHECK-LABEL: func.func @call_and_return_boundary
// CHECK-SAME: (%[[CALL_M:arg[0-9]+]]: index, %[[CALL_N:arg[0-9]+]]: index) -> tensor<?x?xf32>
// CHECK-SAME: #types[] -> #tensor<[%[[CALL_M]], %[[CALL_N]]], f32>
// CHECK-NEXT: %[[CALL_T:.*]] = dependent_tensor.make () #tensor<[%[[CALL_M]], %[[CALL_N]]], f32> : tensor<?x?xf32>
// CHECK-NEXT: %[[CALL_R:.*]] = call @identity_with_boundary(%[[CALL_M]], %[[CALL_N]], %[[CALL_T]]) : (index, index, tensor<?x?xf32>) -> tensor<?x?xf32>
// CHECK-NEXT: return %[[CALL_R]] : tensor<?x?xf32>
// CHECK-LABEL: func.func @return_insert_boundary
// CHECK-SAME: (%[[INS_M:arg[0-9]+]]: index, %[[INS_N:arg[0-9]+]]: index, %[[INS_I:arg[0-9]+]]: index, %[[INS_J:arg[0-9]+]]: index, %[[INS_V:arg[0-9]+]]: f32) -> tensor<?x?xf32>
// CHECK-SAME: #types[] -> #tensor<[%[[INS_M]], %[[INS_N]]], f32>
// CHECK-NEXT: %[[INS_T:.*]] = dependent_tensor.make () #tensor<[%[[INS_M]], %[[INS_N]]], f32> : tensor<?x?xf32>
// CHECK-NEXT: %[[INS_R:.*]] = dependent_tensor.insert %[[INS_V]] into %[[INS_T]][%[[INS_I]], %[[INS_J]]] #tensor<[%[[INS_M]], %[[INS_N]]], f32> : f32 into tensor<?x?xf32>
// CHECK-NEXT: return %[[INS_R]] : tensor<?x?xf32>
// CHECK-LABEL: func.func @multi_result_boundary
// CHECK-SAME: (%[[MR_M:arg[0-9]+]]: index, %[[MR_N:arg[0-9]+]]: index, %[[MR_A:arg[0-9]+]]: tensor<?xf32>, %[[MR_B:arg[0-9]+]]: tensor<?xf32>) -> (tensor<?xf32>, tensor<?xf32>)
// CHECK-SAME: #types[%[[MR_A]] : #tensor<[%[[MR_M]]], f32>, %[[MR_B]] : #tensor<[%[[MR_N]]], f32>] -> [#tensor<[%[[MR_M]]], f32>, #tensor<[%[[MR_N]]], f32>]
// CHECK-NEXT: return %[[MR_A]], %[[MR_B]] : tensor<?xf32>, tensor<?xf32>
