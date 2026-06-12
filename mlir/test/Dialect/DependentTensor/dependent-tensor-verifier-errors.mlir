// RUN: mlir-opt %s -split-input-file -verify-diagnostics

func.func @rank_dim_value_mismatch(%m : index, %n : index, %k : index) {
  // expected-error@+1 {{dependent tensor rank mismatch}}
  %t = dependent_tensor.make () #tensor<[%m, %n, %k], f32> : tensor<?x?xf32>
  return
}

// -----

func.func @non_dynamic_result_dim(%m : index, %n : index) {
  // expected-error@+1 {{'dependent_tensor.make' op requires dependent result dimensions to be dynamic}}
  %t = dependent_tensor.make () #tensor<[%m, %n], f32> : tensor<4x?xf32>
  return
}

// -----

func.func @make_element_type_mismatch(%m : index, %n : index) {
  // expected-error@+1 {{dependent tensor element type must match result type}}
  %t = dependent_tensor.make () #tensor<[%m, %n], i32> : tensor<?x?xf32>
  return
}

// -----

func.func @extract_rank_mismatch(%m : index, %n : index, %i : index) {
  %t = dependent_tensor.make () #tensor<[%m, %n], f32> : tensor<?x?xf32> // expected-note {{prior use here}}
  // expected-error@+1 {{use of value '%t' expects different type than prior uses: 'tensor<?xf32>' vs 'tensor<?x?xf32>'}}
  %e = dependent_tensor.extract %t[%i] : f32
  return
}

// -----

func.func @insert_rank_mismatch(%m : index, %n : index, %i : index, %v : f32) {
  %t = dependent_tensor.make () #tensor<[%m, %n], f32> : tensor<?x?xf32>
  // expected-error@+1 {{'dependent_tensor.insert' op requires one index operand per tensor dimension}}
  %u = dependent_tensor.insert %v into %t[%i] #tensor<[%m, %n], f32> : f32 into tensor<?x?xf32>
  return
}

// -----

func.func @insert_swapped_property(%m : index, %n : index, %i : index, %j : index, %v : f32) {
  %t = dependent_tensor.make () #tensor<[%m, %n], f32> : tensor<?x?xf32>
  // expected-error@+1 {{'dependent_tensor.insert' op stored result semantics must match destination semantics}}
  %u = dependent_tensor.insert %v into %t[%i, %j] #tensor<[%n, %m], f32> : f32 into tensor<?x?xf32>
  return
}


// -----

func.func @dim_assertion_nonconstant(%m : index, %n : index, %i : index) {
  %t = dependent_tensor.make () #tensor<[%m, %n], f32> : tensor<?x?xf32>
  // expected-error@+1 {{'dependent_tensor.dim' op requires constant dimension operand for #dim assertion}}
  %d = dependent_tensor.dim %t, %i, #dim %m : tensor<?x?xf32>
  return
}

// -----

func.func @dim_assertion_mismatch(%m : index, %n : index) {
  %c0 = arith.constant 0 : index
  %t = dependent_tensor.make () #tensor<[%m, %n], f32> : tensor<?x?xf32>
  // expected-error@+1 {{'dependent_tensor.dim' op #dim assertion must match source semantics}}
  %d = dependent_tensor.dim %t, %c0, #dim %n : tensor<?x?xf32>
  return
}

// -----

func.func @extract_refinement_rejected(%m : index, %n : index, %i : index, %j : index) {
  %t = dependent_tensor.make () #tensor<[%m, %n], f32> : tensor<?x?xf32>
  // expected-error@+1 {{expected ':'}}
  %e = dependent_tensor.extract %t[%i, %j] #tensor<[%n, %m], f32> : f32
  return
}

// -----

func.func @extract_result_type_mismatch(%m : index, %n : index, %i : index, %j : index) {
  %t = dependent_tensor.make () #tensor<[%m, %n], f32> : tensor<?x?xf32> // expected-note {{prior use here}}
  // expected-error@+1 {{use of value '%t' expects different type than prior uses: 'tensor<?x?xi32>' vs 'tensor<?x?xf32>'}}
  %e = dependent_tensor.extract %t[%i, %j] : i32
  return
}
