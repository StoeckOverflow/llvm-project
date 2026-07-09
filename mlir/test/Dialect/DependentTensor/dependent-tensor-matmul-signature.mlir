// RUN: mlir-opt %s -split-input-file -verify-dependent-tensor-refinements -verify-diagnostics | FileCheck %s

func.func @dependent_matmul_dps_signature(
    %n : index,
    %k : index,
    %m : index,
    %A : tensor<?x?xf32>,
    %B : tensor<?x?xf32>,
    %C : tensor<?x?xf32>) -> ()
    #types[
      %A : #tensor<[%n, %k], f32>,
      %B : #tensor<[%k, %m], f32>,
      %C : #tensor<[%n, %m], f32>
    ] -> () {
  return
}

func.func @call_dependent_matmul_dps_signature(
    %n : index,
    %k : index,
    %m : index) -> () {
  %A = dependent_tensor.make () #tensor<[%n, %k], f32> : tensor<?x?xf32>
  %B = dependent_tensor.make () #tensor<[%k, %m], f32> : tensor<?x?xf32>
  %C = dependent_tensor.make () #tensor<[%n, %m], f32> : tensor<?x?xf32>
  func.call @dependent_matmul_dps_signature(%n, %k, %m, %A, %B, %C)
      : (index, index, index, tensor<?x?xf32>, tensor<?x?xf32>, tensor<?x?xf32>) -> ()
  return
}

// CHECK-LABEL: func.func @dependent_matmul_dps_signature
// CHECK-SAME: (%[[N:arg[0-9]+]]: index, %[[K:arg[0-9]+]]: index, %[[M:arg[0-9]+]]: index,
// CHECK-SAME:  %[[A:arg[0-9]+]]: tensor<?x?xf32>, %[[B:arg[0-9]+]]: tensor<?x?xf32>, %[[C:arg[0-9]+]]: tensor<?x?xf32>) #types
// CHECK-SAME: [%[[A]] : #tensor<[%[[N]], %[[K]]], f32>, %[[B]] : #tensor<[%[[K]], %[[M]]], f32>, %[[C]] : #tensor<[%[[N]], %[[M]]], f32>] -> ()
// CHECK-NEXT: return
// CHECK-LABEL: func.func @call_dependent_matmul_dps_signature
// CHECK: %[[CALL_A:.*]] = dependent_tensor.make () #tensor<[%{{.*}}, %{{.*}}], f32> : tensor<?x?xf32>
// CHECK: %[[CALL_B:.*]] = dependent_tensor.make () #tensor<[%{{.*}}, %{{.*}}], f32> : tensor<?x?xf32>
// CHECK: %[[CALL_C:.*]] = dependent_tensor.make () #tensor<[%{{.*}}, %{{.*}}], f32> : tensor<?x?xf32>
// CHECK: call @dependent_matmul_dps_signature(%{{.*}}, %{{.*}}, %{{.*}}, %[[CALL_A]], %[[CALL_B]], %[[CALL_C]]) : (index, index, index, tensor<?x?xf32>, tensor<?x?xf32>, tensor<?x?xf32>) -> ()
// CHECK-NEXT: return

// -----

func.func @dependent_matmul_dps_signature(
    %n : index,
    %k : index,
    %m : index,
    %A : tensor<?x?xf32>,
    %B : tensor<?x?xf32>,
    %C : tensor<?x?xf32>) -> ()
    #types[
      %A : #tensor<[%n, %k], f32>,
      %B : #tensor<[%k, %m], f32>,
      %C : #tensor<[%n, %m], f32>
    ] -> () {
  return
}

func.func @bad_call_dependent_matmul_dps_signature(
    %n : index,
    %k : index,
    %m : index,
    %p : index) -> () {
  %A = dependent_tensor.make () #tensor<[%n, %p], f32> : tensor<?x?xf32>
  %B = dependent_tensor.make () #tensor<[%k, %m], f32> : tensor<?x?xf32>
  %C = dependent_tensor.make () #tensor<[%n, %m], f32> : tensor<?x?xf32>
  // expected-error@+1 {{operand #3 does not match callee dependency metadata}}
  func.call @dependent_matmul_dps_signature(%n, %k, %m, %A, %B, %C)
      : (index, index, index, tensor<?x?xf32>, tensor<?x?xf32>, tensor<?x?xf32>) -> ()
  return
}
