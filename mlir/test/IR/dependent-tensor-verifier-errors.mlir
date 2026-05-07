// RUN: mlir-opt %s -split-input-file -verify-diagnostics

func.func @wrong_rank(%m : index, %n : index) {
  // expected-error@+1 {{dependent tensor rank mismatch}}
  %t = dependent_tensor.make () #tensor<[%m, %n], f32> : tensor<?xf32>
  return
}

// -----

func.func @static_dependent_dim(%m : index, %n : index) {
  // expected-error@+1 {{'dependent_tensor.make' op requires dependent result dimensions to be dynamic}}
  %t = dependent_tensor.make () #tensor<[%m, %n], f32> : tensor<4x?xf32>
  return
}

// -----

func.func @non_index_dim(%m : i32) {
  // expected-note@-1 {{prior use here}}
  // expected-error@+1 {{use of value '%m' expects different type than prior uses: 'index' vs 'i32'}}
  %t = dependent_tensor.make () #tensor<[%m], f32> : tensor<?xf32>
  return
}
