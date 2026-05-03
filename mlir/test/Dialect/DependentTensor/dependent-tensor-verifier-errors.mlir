// RUN: mlir-opt %s -verify-diagnostics

func.func @rank_seed_mismatch(%m : index, %n : index, %k : index) {
  // expected-error@+1 {{'dependent_tensor.make' op requires one index seed operand per result dimension}}
  %t = dependent_tensor.make %m, %n, %k dims[m, n, k] : tensor<?x?xf32>
  return
}

// -----

func.func @non_dynamic_result_dim(%m : index, %n : index) {
  // expected-error@+1 {{'dependent_tensor.make' op requires dependent result dimensions to be dynamic}}
  %t = dependent_tensor.make %m, %n dims[m, n] : tensor<4x?xf32>
  return
}

// -----

func.func @duplicate_dim_names(%m : index, %n : index) {
  // expected-error@+1 {{'dependent_tensor.make' op requires unique dimension names}}
  %t = dependent_tensor.make %m, %n dims[m, m] : tensor<?x?xf32>
  return
}
