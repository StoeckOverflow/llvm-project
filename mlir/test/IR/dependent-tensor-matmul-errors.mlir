// RUN: mlir-opt %s -split-input-file -verify-dependent-tensor-semantics -verify-diagnostics

func.func @dependent_matmul_bad_result_row(
    %m0 : index,
    %m1 : index,
    %n : index) -> tensor<?x?xf32>
    #types[] -> #tensor<[%m1, %n], f32> {
  %c = dependent_tensor.make () #tensor<[%m0, %n], f32> : tensor<?x?xf32>
  // expected-error@+1 {{'func.return' op returned value does not match function result dependency metadata}}
  return %c : tensor<?x?xf32>
}

// -----

func.func @dependent_matmul_bad_result_col(
    %m : index,
    %n0 : index,
    %n1 : index) -> tensor<?x?xf32>
    #types[] -> #tensor<[%m, %n1], f32> {
  %c = dependent_tensor.make () #tensor<[%m, %n0], f32> : tensor<?x?xf32>
  // expected-error@+1 {{'func.return' op returned value does not match function result dependency metadata}}
  return %c : tensor<?x?xf32>
}
