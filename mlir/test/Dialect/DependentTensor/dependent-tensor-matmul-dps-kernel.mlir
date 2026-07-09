// RUN: mlir-opt %s -split-input-file -verify-dependent-tensor-refinements -verify-diagnostics | FileCheck %s

func.func @dependent_matmul_kernel_dps(
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
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  scf.for %i = %c0 to %n step %c1 {
    scf.for %j = %c0 to %m step %c1 {
      %sum0 = dependent_tensor.extract %C[%i, %j] : f32
      %sum = scf.for %p = %c0 to %k step %c1 iter_args(%acc = %sum0) -> (f32) {
        %a = dependent_tensor.extract %A[%i, %p] : f32
        %b = dependent_tensor.extract %B[%p, %j] : f32
        %mul = arith.mulf %a, %b : f32
        %next_acc = arith.addf %acc, %mul : f32
        scf.yield %next_acc : f32
      }
      %updated = dependent_tensor.insert %sum into %C[%i, %j] #tensor<[%n, %m], f32> : f32 into tensor<?x?xf32>
    }
  }
  return
}

func.func @call_dependent_matmul_kernel_dps(
    %n : index,
    %k : index,
    %m : index) -> () {
  %A = dependent_tensor.make () #tensor<[%n, %k], f32> : tensor<?x?xf32>
  %B = dependent_tensor.make () #tensor<[%k, %m], f32> : tensor<?x?xf32>
  %C = dependent_tensor.make () #tensor<[%n, %m], f32> : tensor<?x?xf32>
  func.call @dependent_matmul_kernel_dps(%n, %k, %m, %A, %B, %C)
      : (index, index, index, tensor<?x?xf32>, tensor<?x?xf32>, tensor<?x?xf32>) -> ()
  return
}

// CHECK-LABEL: func.func @dependent_matmul_kernel_dps
// CHECK-SAME: (%[[N:arg[0-9]+]]: index, %[[K:arg[0-9]+]]: index, %[[M:arg[0-9]+]]: index,
// CHECK-SAME:  %[[A:arg[0-9]+]]: tensor<?x?xf32>, %[[B:arg[0-9]+]]: tensor<?x?xf32>, %[[C:arg[0-9]+]]: tensor<?x?xf32>) #types
// CHECK-SAME: [%[[A]] : #tensor<[%[[N]], %[[K]]], f32>, %[[B]] : #tensor<[%[[K]], %[[M]]], f32>, %[[C]] : #tensor<[%[[N]], %[[M]]], f32>] -> ()
// CHECK: scf.for %[[I:.*]] = %{{.*}} to %[[N]] step %{{.*}} {
// CHECK-NOT: #types
// CHECK:   scf.for %[[J:.*]] = %{{.*}} to %[[M]] step %{{.*}} {
// CHECK-NOT: #types
// CHECK:     %[[SUM0:.*]] = dependent_tensor.extract %[[C]][%[[I]], %[[J]]] : f32
// CHECK:     %[[SUM:.*]] = scf.for %[[P:.*]] = %{{.*}} to %[[K]] step %{{.*}} iter_args(%[[ACC:.*]] = %[[SUM0]]) -> (f32) {
// CHECK:       %[[AV:.*]] = dependent_tensor.extract %[[A]][%[[I]], %[[P]]] : f32
// CHECK:       %[[BV:.*]] = dependent_tensor.extract %[[B]][%[[P]], %[[J]]] : f32
// CHECK:       scf.yield %{{.*}} : f32
// CHECK:     }
// CHECK:     %[[UPDATED:.*]] = dependent_tensor.insert %[[SUM]] into %[[C]][%[[I]], %[[J]]] #tensor<[%[[N]], %[[M]]], f32> : f32 into tensor<?x?xf32>
// CHECK:   }
// CHECK: }
// CHECK: return
// CHECK-LABEL: func.func @call_dependent_matmul_kernel_dps
// CHECK: %[[CALL_A:.*]] = dependent_tensor.make () #tensor<[%{{.*}}, %{{.*}}], f32> : tensor<?x?xf32>
// CHECK: %[[CALL_B:.*]] = dependent_tensor.make () #tensor<[%{{.*}}, %{{.*}}], f32> : tensor<?x?xf32>
// CHECK: %[[CALL_C:.*]] = dependent_tensor.make () #tensor<[%{{.*}}, %{{.*}}], f32> : tensor<?x?xf32>
// CHECK: call @dependent_matmul_kernel_dps(%{{.*}}, %{{.*}}, %{{.*}}, %[[CALL_A]], %[[CALL_B]], %[[CALL_C]]) : (index, index, index, tensor<?x?xf32>, tensor<?x?xf32>, tensor<?x?xf32>) -> ()
// CHECK-NEXT: return

// -----

func.func @dependent_matmul_kernel_dps(
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

func.func @bad_call_dependent_matmul_kernel_dps(
    %n : index,
    %k : index,
    %m : index,
    %p : index) -> () {
  %A = dependent_tensor.make () #tensor<[%n, %p], f32> : tensor<?x?xf32>
  %B = dependent_tensor.make () #tensor<[%k, %m], f32> : tensor<?x?xf32>
  %C = dependent_tensor.make () #tensor<[%n, %m], f32> : tensor<?x?xf32>
  // expected-error@+1 {{operand #3 does not match callee dependency metadata}}
  func.call @dependent_matmul_kernel_dps(%n, %k, %m, %A, %B, %C)
      : (index, index, index, tensor<?x?xf32>, tensor<?x?xf32>, tensor<?x?xf32>) -> ()
  return
}
