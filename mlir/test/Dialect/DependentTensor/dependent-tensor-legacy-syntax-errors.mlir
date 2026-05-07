// RUN: mlir-opt %s -split-input-file -verify-diagnostics

func.func @old_make_syntax(%m : index, %n : index) {
  // expected-error@+1 {{expected '('}}
  %t = dependent_tensor.make %m, %n dims[m, n] : tensor<?x?xf32>
  return
}

// -----

func.func @old_insert_syntax(%m : index, %n : index, %i : index, %j : index,
                             %v : f32) {
  %t = dependent_tensor.make () #tensor<[%m, %n], f32> : tensor<?x?xf32>
  // expected-error@+1 {{expected '#tensor'}}
  %u = dependent_tensor.insert %v into %t[%i, %j] result_dims[%m, %n] dims[m, n] : f32 into tensor<?x?xf32>
  return
}

// -----

func.func @old_boundary_syntax(%m : index, %n : index,
                               %t : tensor<?x?xf32>) -> tensor<?x?xf32> {
  return %t : tensor<?x?xf32>
  // expected-error@+1 {{custom op 'dependent_tensor_boundary' is unknown}}
} dependent_tensor_boundary args[2 dims[%m, %n] names[m, n]] results[0 dims[%m, %n] names[m, n]]
