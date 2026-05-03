// RUN: mlir-opt %s -verify-diagnostics

func.func @dependent_matmul_bad_contract(%m : index, %k0 : index, %k1 : index,
                                         %n : index,
                                         %a : tensor<[%m, %k0], f32>,
                                         %b : tensor<[%k1, %n], f32>) {
  // expected-error@+1 {{'test.dependent_matmul' op expected lhs dim 1 to equal rhs dim 0}}
  %r = test.dependent_matmul %a, %b
    : tensor<[%m, %k0], f32>, tensor<[%k1, %n], f32> -> tensor<[%m, %n], f32>
  return
}

// -----

func.func @dependent_matmul_bad_result_row(%m0 : index, %m1 : index,
                                           %k : index, %n : index,
                                           %a : tensor<[%m0, %k], f32>,
                                           %b : tensor<[%k, %n], f32>) {
  // expected-error@+1 {{'test.dependent_matmul' op expected lhs dim 0 to equal result dim 0}}
  %r = test.dependent_matmul %a, %b
    : tensor<[%m0, %k], f32>, tensor<[%k, %n], f32> -> tensor<[%m1, %n], f32>
  return
}

// -----

func.func @dependent_matmul_bad_result_col(%m : index, %k : index,
                                           %n0 : index, %n1 : index,
                                           %a : tensor<[%m, %k], f32>,
                                           %b : tensor<[%k, %n0], f32>) {
  // expected-error@+1 {{'test.dependent_matmul' op expected rhs dim 1 to equal result dim 1}}
  %r = test.dependent_matmul %a, %b
    : tensor<[%m, %k], f32>, tensor<[%k, %n0], f32> -> tensor<[%m, %n1], f32>
  return
}
