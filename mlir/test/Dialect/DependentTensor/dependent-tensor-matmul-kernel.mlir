// RUN: mlir-opt %s -split-input-file -verify-dependent-tensor-refinements -verify-diagnostics | FileCheck %s

func.func @dependent_matmul_kernel(
    %n : index,
    %k : index,
    %m : index,
    %A : tensor<?x?xf32>,
    %B : tensor<?x?xf32>,
    %C : tensor<?x?xf32>) -> tensor<?x?xf32>
    #types[
      %A : #tensor<[%n, %k], f32>,
      %B : #tensor<[%k, %m], f32>,
      %C : #tensor<[%n, %m], f32>
    ] -> #tensor<[%n, %m], f32> {
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  %zero = arith.constant 0.0 : f32
  %C_final = scf.for %i = %c0 to %n step %c1 iter_args(%Ci = %C)
      -> (tensor<?x?xf32>)
      #types[%Ci : #tensor<[%n, %m], f32>] -> #tensor<[%n, %m], f32>
 {
    %C_row = scf.for %j = %c0 to %m step %c1 iter_args(%Cj = %Ci)
        -> (tensor<?x?xf32>)
        #types[%Cj : #tensor<[%n, %m], f32>] -> #tensor<[%n, %m], f32>
 {
      %sum = scf.for %kk = %c0 to %k step %c1 iter_args(%sum_iter = %zero)
          -> (f32) {
        %a = dependent_tensor.extract %A[%i, %kk] : f32
        %b = dependent_tensor.extract %B[%kk, %j] : f32
        %mul = arith.mulf %a, %b : f32
        %next = arith.addf %sum_iter, %mul : f32
        scf.yield %next : f32
      }
      %updated = dependent_tensor.insert %sum into %Cj[%i, %j] #tensor<[%n, %m], f32> : f32 into tensor<?x?xf32>
      scf.yield %updated : tensor<?x?xf32>
    }
    scf.yield %C_row : tensor<?x?xf32>
  }
  return %C_final : tensor<?x?xf32>
}

// CHECK-LABEL: func.func @dependent_matmul_kernel
// CHECK-SAME: (%[[N:arg[0-9]+]]: index, %[[K:arg[0-9]+]]: index, %[[M:arg[0-9]+]]: index,
// CHECK-SAME:  %[[A:arg[0-9]+]]: tensor<?x?xf32>, %[[B:arg[0-9]+]]: tensor<?x?xf32>, %[[C:arg[0-9]+]]: tensor<?x?xf32>) -> tensor<?x?xf32>
// CHECK-SAME: #types[%[[A]] : #tensor<[%[[N]], %[[K]]], f32>, %[[B]] : #tensor<[%[[K]], %[[M]]], f32>, %[[C]] : #tensor<[%[[N]], %[[M]]], f32>] -> #tensor<[%[[N]], %[[M]]], f32>
// CHECK: %[[C_FINAL:.*]] = scf.for %[[I:.*]] = %{{.*}} to %[[N]] step %{{.*}} iter_args(%[[CI:.*]] = %[[C]]) -> (tensor<?x?xf32>) #types[%[[CI]] : #tensor<[%[[N]], %[[M]]], f32>] -> #tensor<[%[[N]], %[[M]]], f32> {
// CHECK:   %[[C_ROW:.*]] = scf.for %[[J:.*]] = %{{.*}} to %[[M]] step %{{.*}} iter_args(%[[CJ:.*]] = %[[CI]]) -> (tensor<?x?xf32>) #types[%[[CJ]] : #tensor<[%[[N]], %[[M]]], f32>] -> #tensor<[%[[N]], %[[M]]], f32> {
// CHECK:     %[[SUM:.*]] = scf.for %[[KK:.*]] = %{{.*}} to %[[K]] step %{{.*}} iter_args(%[[SUM_ITER:.*]] = %{{.*}}) -> (f32) {
// CHECK:       %[[AV:.*]] = dependent_tensor.extract %[[A]][%[[I]], %[[KK]]] : f32
// CHECK:       %[[BV:.*]] = dependent_tensor.extract %[[B]][%[[KK]], %[[J]]] : f32
// CHECK:       scf.yield %{{.*}} : f32
// CHECK:     }
// CHECK:     %[[UPDATED:.*]] = dependent_tensor.insert %[[SUM]] into %[[CJ]][%[[I]], %[[J]]] #tensor<[%[[N]], %[[M]]], f32> : f32 into tensor<?x?xf32>
// CHECK:     scf.yield %[[UPDATED]] : tensor<?x?xf32>
// CHECK:   }
// CHECK:   scf.yield %[[C_ROW]] : tensor<?x?xf32>
// CHECK: }
// CHECK: return %[[C_FINAL]] : tensor<?x?xf32>

// -----

func.func @dependent_matmul_kernel_inner_yield_mismatch(
    %n : index,
    %k : index,
    %m : index,
    %A : tensor<?x?xf32>,
    %B : tensor<?x?xf32>,
    %C : tensor<?x?xf32>) -> tensor<?x?xf32>
    #types[%A : #tensor<[%n, %k], f32>, %B : #tensor<[%k, %m], f32>, %C : #tensor<[%n, %m], f32>] -> #tensor<[%n, %m], f32> {
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  %C_final = scf.for %i = %c0 to %n step %c1 iter_args(%Ci = %C)
      -> (tensor<?x?xf32>)
      #types[%Ci : #tensor<[%n, %m], f32>] -> #tensor<[%n, %m], f32>
 {
    // expected-error@+1 {{'scf.for' op loop result type reference does not match yielded refinements}}
    %C_row = scf.for %j = %c0 to %m step %c1 iter_args(%Cj = %Ci)
        -> (tensor<?x?xf32>)
        #types[%Cj : #tensor<[%n, %m], f32>] -> #tensor<[%n, %m], f32>
 {
      %bad = dependent_tensor.make () #tensor<[%m, %n], f32> : tensor<?x?xf32>
      scf.yield %bad : tensor<?x?xf32>
    }
    scf.yield %C_row : tensor<?x?xf32>
  }
  return %C_final : tensor<?x?xf32>
}

// -----

func.func @dependent_matmul_kernel_outer_yield_mismatch(
    %n : index,
    %k : index,
    %m : index,
    %A : tensor<?x?xf32>,
    %B : tensor<?x?xf32>,
    %C : tensor<?x?xf32>) -> tensor<?x?xf32>
    #types[%A : #tensor<[%n, %k], f32>, %B : #tensor<[%k, %m], f32>, %C : #tensor<[%n, %m], f32>] -> #tensor<[%n, %m], f32> {
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  // expected-error@+1 {{'scf.for' op loop result type reference does not match yielded refinements}}
  %C_final = scf.for %i = %c0 to %n step %c1 iter_args(%Ci = %C)
      -> (tensor<?x?xf32>)
      #types[%Ci : #tensor<[%n, %m], f32>] -> #tensor<[%n, %m], f32>
 {
    %bad = dependent_tensor.make () #tensor<[%m, %n], f32> : tensor<?x?xf32>
    scf.yield %bad : tensor<?x?xf32>
  }
  return %C_final : tensor<?x?xf32>
}

// -----

func.func @dependent_matmul_kernel_return_mismatch(
    %n : index,
    %k : index,
    %m : index,
    %A : tensor<?x?xf32>,
    %B : tensor<?x?xf32>,
    %C : tensor<?x?xf32>) -> tensor<?x?xf32>
    #types[%A : #tensor<[%n, %k], f32>, %B : #tensor<[%k, %m], f32>, %C : #tensor<[%n, %m], f32>] -> #tensor<[%n, %m], f32> {
  %bad = dependent_tensor.make () #tensor<[%m, %n], f32> : tensor<?x?xf32>
  // expected-error@+1 {{'func.return' op returned value does not match function result dependency metadata}}
  return %bad : tensor<?x?xf32>
}

// -----

func.func @dependent_matmul_kernel_loop_result_metadata_mismatch(
    %n : index,
    %k : index,
    %m : index,
    %A : tensor<?x?xf32>,
    %B : tensor<?x?xf32>,
    %C : tensor<?x?xf32>) -> tensor<?x?xf32>
    #types[%A : #tensor<[%n, %k], f32>, %B : #tensor<[%k, %m], f32>, %C : #tensor<[%n, %m], f32>] -> #tensor<[%n, %m], f32> {
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  %C_final = scf.for %i = %c0 to %n step %c1 iter_args(%Ci = %C)
      -> (tensor<?x?xf32>)
      #types[%Ci : #tensor<[%n, %m], f32>] -> #tensor<[%m, %n], f32>
 {
    scf.yield %Ci : tensor<?x?xf32>
  }
  // expected-error@+1 {{'func.return' op returned value does not match function result dependency metadata}}
  return %C_final : tensor<?x?xf32>
}
