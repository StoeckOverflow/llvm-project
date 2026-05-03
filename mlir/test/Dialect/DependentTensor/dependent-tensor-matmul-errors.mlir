// RUN: mlir-opt %s -verify-diagnostics

func.func @matmul_bad_contract(%m : index, %k0 : index, %k1 : index,
                               %n : index) {
  %a = dependent_tensor.make %m, %k0 dims[m, k0] : tensor<?x?xf32>
  %b = dependent_tensor.make %k1, %n dims[k1, n] : tensor<?x?xf32>
  // expected-error@+1 {{'dependent_tensor.matmul' op expected lhs dim 1 to equal rhs dim 0}}
  %r = dependent_tensor.matmul %a, %b : tensor<?x?xf32>, tensor<?x?xf32> -> tensor<?x?xf32>
  return
}
