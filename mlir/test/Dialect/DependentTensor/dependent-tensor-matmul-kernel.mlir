// RUN: mlir-opt %s -verify-dependent-tensor-semantics | FileCheck %s

func.func @dependent_matmul_kernel(
    %n : index,
    %k : index,
    %m : index,
    %A : tensor<?x?xf32>,
    %B : tensor<?x?xf32>,
    %Cinit : tensor<?x?xf32>) -> tensor<?x?xf32>
    #types[
      %A : #tensor<[%n, %k], f32>,
      %B : #tensor<[%k, %m], f32>,
      %Cinit : #tensor<[%n, %m], f32>
    ] -> #tensor<[%n, %m], f32> {
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  %Cout = scf.for %i = %c0 to %n step %c1 iter_args(%row = %Cinit) -> (tensor<?x?xf32>) {
    %next = scf.for %j = %c0 to %m step %c1 iter_args(%col = %row) -> (tensor<?x?xf32>) {
      %sum0 = dependent_tensor.extract %col[%i, %j] #tensor<[%n, %m], f32> : f32
      %sum = scf.for %p = %c0 to %k step %c1 iter_args(%acc = %sum0) -> (f32) {
        %a = dependent_tensor.extract %A[%i, %p] #tensor<[%n, %k], f32> : f32
        %b = dependent_tensor.extract %B[%p, %j] #tensor<[%k, %m], f32> : f32
        %mul = arith.mulf %a, %b : f32
        %next_acc = arith.addf %acc, %mul : f32
        scf.yield %next_acc : f32
      }
      %updated = dependent_tensor.insert %sum into %col[%i, %j] #tensor<[%n, %m], f32> : f32 into tensor<?x?xf32>
      scf.yield %updated : tensor<?x?xf32>
    }
    scf.yield %next : tensor<?x?xf32>
  }
  return %Cout : tensor<?x?xf32>
}

// CHECK-LABEL: func.func @dependent_matmul_kernel
// CHECK-SAME: (%[[N:arg[0-9]+]]: index, %[[K:arg[0-9]+]]: index, %[[M:arg[0-9]+]]: index,
// CHECK-SAME:  %[[A:arg[0-9]+]]: tensor<?x?xf32>, %[[B:arg[0-9]+]]: tensor<?x?xf32>, %[[CINIT:arg[0-9]+]]: tensor<?x?xf32>) -> tensor<?x?xf32>
// CHECK-SAME:  #types[%[[A]] : #tensor<[%[[N]], %[[K]]], f32>, %[[B]] : #tensor<[%[[K]], %[[M]]], f32>, %[[CINIT]] : #tensor<[%[[N]], %[[M]]], f32>] -> #tensor<[%[[N]], %[[M]]], f32>
// CHECK-DAG: %[[C0:.*]] = arith.constant 0 : index
// CHECK-DAG: %[[C1:.*]] = arith.constant 1 : index
// CHECK: %[[COUT:.*]] = scf.for %[[I:.*]] = %[[C0]] to %[[N]] step %[[C1]] iter_args(%[[ROW:.*]] = %[[CINIT]]) -> (tensor<?x?xf32>) {
// CHECK:   %[[NEXT:.*]] = scf.for %[[J:.*]] = %[[C0]] to %[[M]] step %[[C1]] iter_args(%[[COL:.*]] = %[[ROW]]) -> (tensor<?x?xf32>) {
// CHECK:     %[[SUM0:.*]] = dependent_tensor.extract %[[COL]][%[[I]], %[[J]]] #tensor<[%[[N]], %[[M]]], f32> : f32
// CHECK:     %[[SUM:.*]] = scf.for %[[P:.*]] = %[[C0]] to %[[K]] step %[[C1]] iter_args(%[[ACC:.*]] = %[[SUM0]]) -> (f32) {
// CHECK:       %[[AV:.*]] = dependent_tensor.extract %[[A]][%[[I]], %[[P]]] #tensor<[%[[N]], %[[K]]], f32> : f32
// CHECK:       %[[BV:.*]] = dependent_tensor.extract %[[B]][%[[P]], %[[J]]] #tensor<[%[[K]], %[[M]]], f32> : f32
// CHECK:       %[[PROD:.*]] = arith.mulf %[[AV]], %[[BV]] : f32
// CHECK:       %[[ACC_NEXT:.*]] = arith.addf %[[ACC]], %[[PROD]] : f32
// CHECK:       scf.yield %[[ACC_NEXT]] : f32
// CHECK:     }
// CHECK:     %[[UPDATED:.*]] = dependent_tensor.insert %[[SUM]] into %[[COL]][%[[I]], %[[J]]] #tensor<[%[[N]], %[[M]]], f32> : f32 into tensor<?x?xf32>
// CHECK:     scf.yield %[[UPDATED]] : tensor<?x?xf32>
// CHECK:   }
// CHECK:   scf.yield %[[NEXT]] : tensor<?x?xf32>
// CHECK: }
// CHECK: return %[[COUT]] : tensor<?x?xf32>
// CHECK-NOT: dependent_tensor.matmul
// CHECK-NOT: dependent_tensor.gemm

// -----

func.func @affine_dependent_matmul_kernel(
    %n : index,
    %k : index,
    %m : index,
    %A : tensor<?x?xf32>,
    %B : tensor<?x?xf32>,
    %Cinit : tensor<?x?xf32>) -> tensor<?x?xf32>
    #types[
      %A : #tensor<[%n, %k], f32>,
      %B : #tensor<[%k, %m], f32>,
      %Cinit : #tensor<[%n, %m], f32>
    ] -> #tensor<[%n, %m], f32> {
  %Cout = affine.for %i = 0 to %n iter_args(%row = %Cinit) -> (tensor<?x?xf32>) {
    %next = affine.for %j = 0 to %m iter_args(%col = %row) -> (tensor<?x?xf32>) {
      %sum0 = arith.constant 0.000000e+00 : f32
      %sum = affine.for %p = 0 to %k iter_args(%acc = %sum0) -> (f32) {
        %a = dependent_tensor.extract %A[%i, %p] #tensor<[%n, %k], f32> : f32
        %b = dependent_tensor.extract %B[%p, %j] #tensor<[%k, %m], f32> : f32
        %mul = arith.mulf %a, %b : f32
        %next_acc = arith.addf %acc, %mul : f32
        affine.yield %next_acc : f32
      }
      %updated = dependent_tensor.insert %sum into %col[%i, %j] #tensor<[%n, %m], f32> : f32 into tensor<?x?xf32>
      affine.yield %updated : tensor<?x?xf32>
    }
    affine.yield %next : tensor<?x?xf32>
  }
  return %Cout : tensor<?x?xf32>
}

// CHECK-LABEL: func.func @affine_dependent_matmul_kernel
// CHECK-SAME: (%[[AN:arg[0-9]+]]: index, %[[AK:arg[0-9]+]]: index, %[[AM:arg[0-9]+]]: index,
// CHECK-SAME:  %[[AA:arg[0-9]+]]: tensor<?x?xf32>, %[[AB:arg[0-9]+]]: tensor<?x?xf32>, %[[ACINIT:arg[0-9]+]]: tensor<?x?xf32>) -> tensor<?x?xf32>
// CHECK-SAME:  #types[%[[AA]] : #tensor<[%[[AN]], %[[AK]]], f32>, %[[AB]] : #tensor<[%[[AK]], %[[AM]]], f32>, %[[ACINIT]] : #tensor<[%[[AN]], %[[AM]]], f32>] -> #tensor<[%[[AN]], %[[AM]]], f32>
// CHECK: %[[ACOUT:.*]] = affine.for %[[AI:.*]] = 0 to %[[AN]] iter_args(%[[AROW:.*]] = %[[ACINIT]]) -> (tensor<?x?xf32>) {
// CHECK:   %[[ANEXT:.*]] = affine.for %[[AJ:.*]] = 0 to %[[AM]] iter_args(%[[ACOL:.*]] = %[[AROW]]) -> (tensor<?x?xf32>) {
// CHECK:     %[[AZERO:.*]] = arith.constant 0.000000e+00 : f32
// CHECK:     %[[ASUM:.*]] = affine.for %[[AP:.*]] = 0 to %[[AK]] iter_args(%[[AACC:.*]] = %[[AZERO]]) -> (f32) {
// CHECK:       %[[AAV:.*]] = dependent_tensor.extract %[[AA]][%[[AI]], %[[AP]]] #tensor<[%[[AN]], %[[AK]]], f32> : f32
// CHECK:       %[[ABV:.*]] = dependent_tensor.extract %[[AB]][%[[AP]], %[[AJ]]] #tensor<[%[[AK]], %[[AM]]], f32> : f32
// CHECK:       %[[APROD:.*]] = arith.mulf %[[AAV]], %[[ABV]] : f32
// CHECK:       %[[AACC_NEXT:.*]] = arith.addf %[[AACC]], %[[APROD]] : f32
// CHECK:       affine.yield %[[AACC_NEXT]] : f32
// CHECK:     }
// CHECK:     %[[AUPDATED:.*]] = dependent_tensor.insert %[[ASUM]] into %[[ACOL]][%[[AI]], %[[AJ]]] #tensor<[%[[AN]], %[[AM]]], f32> : f32 into tensor<?x?xf32>
// CHECK:     affine.yield %[[AUPDATED]] : tensor<?x?xf32>
// CHECK:   }
// CHECK:   affine.yield %[[ANEXT]] : tensor<?x?xf32>
// CHECK: }
// CHECK: return %[[ACOUT]] : tensor<?x?xf32>
// CHECK-NOT: dependent_tensor.matmul
// CHECK-NOT: dependent_tensor.gemm

// -----

// This call verifies dependent-dimension refinement across the function
// boundary. Loop index range checking is intentionally outside this test.
func.func @call_dependent_matmul_kernel(
    %n : index,
    %k : index,
    %m : index) -> tensor<?x?xf32>
    #types[] -> #tensor<[%n, %m], f32> {
  %A = dependent_tensor.make () #tensor<[%n, %k], f32> : tensor<?x?xf32>
  %B = dependent_tensor.make () #tensor<[%k, %m], f32> : tensor<?x?xf32>
  %C = dependent_tensor.make () #tensor<[%n, %m], f32> : tensor<?x?xf32>
  %R = func.call @dependent_matmul_kernel(%n, %k, %m, %A, %B, %C)
      : (index, index, index, tensor<?x?xf32>, tensor<?x?xf32>, tensor<?x?xf32>) -> tensor<?x?xf32>
  return %R : tensor<?x?xf32>
}

// CHECK-LABEL: func.func @call_dependent_matmul_kernel
// CHECK-SAME: (%[[CN:arg[0-9]+]]: index, %[[CK:arg[0-9]+]]: index, %[[CM:arg[0-9]+]]: index) -> tensor<?x?xf32>
// CHECK-SAME: #types[] -> #tensor<[%[[CN]], %[[CM]]], f32>
// CHECK-NEXT: %[[CA:.*]] = dependent_tensor.make () #tensor<[%[[CN]], %[[CK]]], f32> : tensor<?x?xf32>
// CHECK-NEXT: %[[CB:.*]] = dependent_tensor.make () #tensor<[%[[CK]], %[[CM]]], f32> : tensor<?x?xf32>
// CHECK-NEXT: %[[CC:.*]] = dependent_tensor.make () #tensor<[%[[CN]], %[[CM]]], f32> : tensor<?x?xf32>
// CHECK-NEXT: %[[CR:.*]] = call @dependent_matmul_kernel(%[[CN]], %[[CK]], %[[CM]], %[[CA]], %[[CB]], %[[CC]]) : (index, index, index, tensor<?x?xf32>, tensor<?x?xf32>, tensor<?x?xf32>) -> tensor<?x?xf32>
// CHECK-NEXT: return %[[CR]] : tensor<?x?xf32>
