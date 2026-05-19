// RUN: mlir-opt %s -split-input-file -verify-dependent-tensor-semantics -verify-diagnostics

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
  return %Cinit : tensor<?x?xf32>
}

func.func @bad_matmul_contracting_dim(
    %n : index,
    %k : index,
    %m : index,
    %p : index) -> tensor<?x?xf32>
    #types[] -> #tensor<[%n, %m], f32> {
  %A = dependent_tensor.make () #tensor<[%n, %k], f32> : tensor<?x?xf32>
  %B = dependent_tensor.make () #tensor<[%p, %m], f32> : tensor<?x?xf32>
  %C = dependent_tensor.make () #tensor<[%n, %m], f32> : tensor<?x?xf32>
  // expected-error@+1 {{operand #4 does not match callee dependency metadata}}
  %R = func.call @dependent_matmul_kernel(%n, %k, %m, %A, %B, %C)
      : (index, index, index, tensor<?x?xf32>, tensor<?x?xf32>, tensor<?x?xf32>) -> tensor<?x?xf32>
  return %R : tensor<?x?xf32>
}

// -----

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
  return %Cinit : tensor<?x?xf32>
}

func.func @bad_matmul_result_dim(
    %n : index,
    %k : index,
    %m : index,
    %p : index) -> tensor<?x?xf32>
    #types[] -> #tensor<[%n, %m], f32> {
  %A = dependent_tensor.make () #tensor<[%n, %k], f32> : tensor<?x?xf32>
  %B = dependent_tensor.make () #tensor<[%k, %m], f32> : tensor<?x?xf32>
  %C = dependent_tensor.make () #tensor<[%n, %p], f32> : tensor<?x?xf32>
  // expected-error@+1 {{operand #5 does not match callee dependency metadata}}
  %R = func.call @dependent_matmul_kernel(%n, %k, %m, %A, %B, %C)
      : (index, index, index, tensor<?x?xf32>, tensor<?x?xf32>, tensor<?x?xf32>) -> tensor<?x?xf32>
  return %R : tensor<?x?xf32>
}

// -----

func.func @bad_matmul_insert_semantics(
    %n : index,
    %k : index,
    %m : index,
    %Cinit : tensor<?x?xf32>) -> tensor<?x?xf32>
    #types[%Cinit : #tensor<[%n, %m], f32>] -> #tensor<[%n, %m], f32> {
  %c0 = arith.constant 0 : index
  %v = dependent_tensor.extract %Cinit[%c0, %c0] : f32
  // expected-error@+1 {{'dependent_tensor.insert' op stored result semantics must match destination semantics}}
  %bad = dependent_tensor.insert %v into %Cinit[%c0, %c0] #tensor<[%n, %k], f32> : f32 into tensor<?x?xf32>
  return %bad : tensor<?x?xf32>
}
