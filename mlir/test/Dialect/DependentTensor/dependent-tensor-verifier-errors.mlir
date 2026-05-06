// RUN: mlir-opt %s -verify-diagnostics

func.func @rank_dim_value_mismatch(%m : index, %n : index, %k : index) {
  // expected-error@+1 {{'dependent_tensor.make' op requires one index dimension operand per result dimension}}
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

// -----

func.func @extract_rank_mismatch(%m : index, %n : index, %i : index) {
  %t = dependent_tensor.make %m, %n dims[m, n] : tensor<?x?xf32>
  // expected-error@+1 {{'dependent_tensor.extract' op requires one index operand per tensor dimension}}
  %e = dependent_tensor.extract %t[%i] : tensor<?x?xf32>
  return
}

// -----

func.func @insert_rank_mismatch(%m : index, %n : index, %i : index, %v : f32) {
  %t = dependent_tensor.make %m, %n dims[m, n] : tensor<?x?xf32>
  // expected-error@+1 {{'dependent_tensor.insert' op requires one index operand per tensor dimension}}
  %u = dependent_tensor.insert %v into %t[%i] result_dims[%m, %n] dims[m, n] : f32 into tensor<?x?xf32>
  return
}

// -----

func.func @insert_swapped_property(%m : index, %n : index, %i : index, %j : index, %v : f32) {
  %t = dependent_tensor.make %m, %n dims[m, n] : tensor<?x?xf32>
  // expected-error@+1 {{'dependent_tensor.insert' op stored result semantics must match destination semantics}}
  %u = dependent_tensor.insert %v into %t[%i, %j] result_dims[%n, %m] dims[n, m] : f32 into tensor<?x?xf32>
  return
}
