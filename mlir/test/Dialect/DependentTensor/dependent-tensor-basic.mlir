// RUN: mlir-opt %s -split-input-file -verify-dependent-tensor-refinements -verify-diagnostics | FileCheck %s

func.func @basic_primitives(%m : index, %n : index, %i : index, %j : index,
                            %v : f32) -> tensor<?x?xf32>
    #types[] -> #tensor<[%m, %n], f32> {
  %c0 = arith.constant 0 : index
  %t = dependent_tensor.make () #tensor<[%m, %n], f32> : tensor<?x?xf32>
  %d0 = dependent_tensor.dim %t, %c0, #dim %m : tensor<?x?xf32>
  %old = dependent_tensor.extract %t[%i, %j] : f32
  %r = dependent_tensor.insert %v into %t[%i, %j] #tensor<[%m, %n], f32> : f32 into tensor<?x?xf32>
  return %r : tensor<?x?xf32>
}

// CHECK-LABEL: func.func @basic_primitives
// CHECK-SAME: (%[[M:arg[0-9]+]]: index, %[[N:arg[0-9]+]]: index, %[[I:arg[0-9]+]]: index, %[[J:arg[0-9]+]]: index, %[[V:arg[0-9]+]]: f32) -> tensor<?x?xf32>
// CHECK-SAME: #types[] -> #tensor<[%[[M]], %[[N]]], f32>
// CHECK-NEXT: %[[C0:.*]] = arith.constant 0 : index
// CHECK-NEXT: %[[T:.*]] = dependent_tensor.make () #tensor<[%[[M]], %[[N]]], f32> : tensor<?x?xf32>
// CHECK-NEXT: %[[D0:.*]] = dependent_tensor.dim %[[T]], %[[C0]], #dim %[[M]] : tensor<?x?xf32>
// CHECK-NEXT: %[[OLD:.*]] = dependent_tensor.extract %[[T]][%[[I]], %[[J]]] : f32
// CHECK-NEXT: %[[R:.*]] = dependent_tensor.insert %[[V]] into %[[T]][%[[I]], %[[J]]] #tensor<[%[[M]], %[[N]]], f32> : f32 into tensor<?x?xf32>
// CHECK-NEXT: return %[[R]] : tensor<?x?xf32>

// -----

func.func @identity_with_boundary(%m : index, %n : index, %t : tensor<?x?xf32>)
    -> tensor<?x?xf32>
    #types[%t : #tensor<[%m, %n], f32>] -> #tensor<[%m, %n], f32> {
  return %t : tensor<?x?xf32>
}

func.func @call_refinement(%m : index, %n : index) -> tensor<?x?xf32>
    #types[] -> #tensor<[%m, %n], f32> {
  %t = dependent_tensor.make () #tensor<[%m, %n], f32> : tensor<?x?xf32>
  %r = func.call @identity_with_boundary(%m, %n, %t)
      : (index, index, tensor<?x?xf32>) -> tensor<?x?xf32>
  return %r : tensor<?x?xf32>
}

// CHECK-LABEL: func.func @identity_with_boundary
// CHECK-SAME: #types[%{{.*}} : #tensor<[%{{.*}}, %{{.*}}], f32>] -> #tensor<[%{{.*}}, %{{.*}}], f32>
// CHECK-LABEL: func.func @call_refinement
// CHECK-SAME: #types[] -> #tensor<[%{{.*}}, %{{.*}}], f32>
// CHECK: call @identity_with_boundary
// CHECK-NEXT: return

// -----

// Explicit loop-boundary typing remains covered here; kernel tests use DPS-style loops.
func.func @loop_boundaries(%m : index, %n : index, %v : f32) -> tensor<?x?xf32>
    #types[] -> #tensor<[%m, %n], f32> {
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  %init = dependent_tensor.make () #tensor<[%m, %n], f32> : tensor<?x?xf32>
  %scf_result = scf.for %i = %c0 to %m step %c1 iter_args(%arg = %init)
      -> (tensor<?x?xf32>)
      #types[%arg : #tensor<[%m, %n], f32>] -> #tensor<[%m, %n], f32>
 {
    %updated = dependent_tensor.insert %v into %arg[%i, %c0] #tensor<[%m, %n], f32> : f32 into tensor<?x?xf32>
    scf.yield %updated : tensor<?x?xf32>
  }
  %affine_result = affine.for %j = 0 to %n iter_args(%arg = %scf_result)
      -> (tensor<?x?xf32>)
      #types[%arg : #tensor<[%m, %n], f32>] -> #tensor<[%m, %n], f32>
 {
    %updated = dependent_tensor.insert %v into %arg[%c0, %j] #tensor<[%m, %n], f32> : f32 into tensor<?x?xf32>
    affine.yield %updated : tensor<?x?xf32>
  }
  return %affine_result : tensor<?x?xf32>
}

// CHECK-LABEL: func.func @loop_boundaries
// CHECK-SAME: #types[] -> #tensor<[%{{.*}}, %{{.*}}], f32>
// CHECK: scf.for %{{.*}} iter_args(%[[SCF_ARG:.*]] = %{{.*}}) -> (tensor<?x?xf32>) #types[%[[SCF_ARG]] : #tensor<[%{{.*}}, %{{.*}}], f32>] -> #tensor<[%{{.*}}, %{{.*}}], f32>
// CHECK: scf.yield %{{.*}} : tensor<?x?xf32>
// CHECK: affine.for %{{.*}} iter_args(%[[AFFINE_ARG:.*]] = %{{.*}}) -> (tensor<?x?xf32>) #types[%[[AFFINE_ARG]] : #tensor<[%{{.*}}, %{{.*}}], f32>] -> #tensor<[%{{.*}}, %{{.*}}], f32>
// CHECK: affine.yield %{{.*}} : tensor<?x?xf32>
// CHECK: return %{{.*}} : tensor<?x?xf32>

// -----

func.func @make_rank_mismatch(%m : index, %n : index, %k : index) {
  // expected-error@+1 {{dependent tensor rank mismatch}}
  %t = dependent_tensor.make () #tensor<[%m, %n, %k], f32> : tensor<?x?xf32>
  return
}

// -----

func.func @make_element_type_mismatch(%m : index) {
  // expected-error@+1 {{dependent tensor element type must match result type}}
  %t = dependent_tensor.make () #tensor<[%m], i32> : tensor<?xf32>
  return
}

// -----

func.func @extract_requires_dependent_source(%t : tensor<?xf32>, %i : index) {
  // expected-error@+1 {{'dependent_tensor.extract' op requires source with dependent_tensor refinements}}
  %v = dependent_tensor.extract %t[%i] : f32
  return
}

// -----

func.func @extract_refinement_rejected(%m : index, %i : index) {
  %t = dependent_tensor.make () #tensor<[%m], f32> : tensor<?xf32>
  // expected-error@+1 {{expected ':'}}
  %v = dependent_tensor.extract %t[%i] #tensor<[%m], f32> : f32
  return
}

// -----

func.func @insert_inherits_destination_refinements(%m : index, %n : index,
                                                %i : index, %j : index,
                                                %v : f32) -> tensor<?x?xf32>
    #types[] -> #tensor<[%m, %n], f32> {
  %t = dependent_tensor.make () #tensor<[%m, %n], f32> : tensor<?x?xf32>
  %r = dependent_tensor.insert %v into %t[%i, %j] #tensor<[%m, %n], f32> : f32 into tensor<?x?xf32>
  return %r : tensor<?x?xf32>
}

// -----
func.func @insert_refinement_dim_mismatch(%m : index, %n : index,
                                           %i : index, %j : index, %v : f32) {
  %t = dependent_tensor.make () #tensor<[%m, %n], f32> : tensor<?x?xf32>
  // expected-error@+1 {{stored result refinements must match destination refinements}}
  %r = dependent_tensor.insert %v into %t[%i, %j] #tensor<[%n, %m], f32> : f32 into tensor<?x?xf32>
  return
}

// -----

func.func @insert_requires_refinement(%m : index, %i : index, %v : f32) {
  %t = dependent_tensor.make () #tensor<[%m], f32> : tensor<?xf32>
  // expected-error@+1 {{expected '#tensor'}}
  %r = dependent_tensor.insert %v into %t[%i] : f32 into tensor<?xf32>
  return
}

// -----

func.func @insert_refinement_rank_mismatch(%m : index, %n : index,
                                            %i : index, %j : index, %v : f32) {
  %t = dependent_tensor.make () #tensor<[%m, %n], f32> : tensor<?x?xf32>
  // expected-error@+1 {{dependent tensor rank mismatch}}
  %r = dependent_tensor.insert %v into %t[%i, %j] #tensor<[%m], f32> : f32 into tensor<?x?xf32>
  return
}

// -----

func.func @insert_refinement_element_type_mismatch(%m : index, %n : index,
                                                   %i : index, %j : index,
                                                   %v : f32) {
  %t = dependent_tensor.make () #tensor<[%m, %n], f32> : tensor<?x?xf32>
  // expected-error@+1 {{dependent tensor element type must match value type}}
  %r = dependent_tensor.insert %v into %t[%i, %j] #tensor<[%m, %n], i32> : f32 into tensor<?x?xf32>
  return
}

// -----

func.func @dim_assertion_mismatch(%m : index, %n : index) {
  %c0 = arith.constant 0 : index
  %t = dependent_tensor.make () #tensor<[%m, %n], f32> : tensor<?x?xf32>
  // expected-error@+1 {{#dim assertion must match source refinements}}
  %d = dependent_tensor.dim %t, %c0, #dim %n : tensor<?x?xf32>
  return
}

// -----

func.func @dim_assertion_non_constant(%m : index, %n : index, %dim : index) {
  %t = dependent_tensor.make () #tensor<[%m, %n], f32> : tensor<?x?xf32>
  // expected-error@+1 {{requires constant dimension operand for #dim assertion}}
  %d = dependent_tensor.dim %t, %dim, #dim %m : tensor<?x?xf32>
  return
}

// -----
func.func @loop_boundary_rank_mismatch(%m : index, %n : index, %v : f32) {
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  %init = dependent_tensor.make () #tensor<[%m, %n], f32> : tensor<?x?xf32>
  // expected-error@+3 {{dependent tensor loop operand type reference rank mismatch}}
  %r = scf.for %i = %c0 to %m step %c1 iter_args(%arg = %init)
      -> (tensor<?x?xf32>)
      #types[%arg : #tensor<[%m], f32>] -> #tensor<[%m, %n], f32>
 {
    scf.yield %arg : tensor<?x?xf32>
  }
  return
}

// -----

func.func @loop_boundary_element_type_mismatch(%m : index, %n : index, %v : f32) {
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  %init = dependent_tensor.make () #tensor<[%m, %n], f32> : tensor<?x?xf32>
  // expected-error@+3 {{dependent tensor loop operand type reference element type must match value type}}
  %r = scf.for %i = %c0 to %m step %c1 iter_args(%arg = %init)
      -> (tensor<?x?xf32>)
      #types[%arg : #tensor<[%m, %n], i32>] -> #tensor<[%m, %n], f32>
 {
    scf.yield %arg : tensor<?x?xf32>
  }
  return
}

// -----

func.func @loop_boundary_dim_mismatch(%m : index, %n : index, %v : f32) {
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  %init = dependent_tensor.make () #tensor<[%m, %n], f32> : tensor<?x?xf32>
  // expected-error@+1 {{loop operand type reference does not match init refinements}}
  %r = affine.for %i = 0 to %m iter_args(%arg = %init)
      -> (tensor<?x?xf32>)
      #types[%arg : #tensor<[%n, %m], f32>] -> #tensor<[%m, %n], f32>
 {
    affine.yield %arg : tensor<?x?xf32>
  }
  return
}

// -----

func.func @loop_boundary_yield_mismatch(%m : index, %n : index, %v : f32) {
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  %init = dependent_tensor.make () #tensor<[%m, %n], f32> : tensor<?x?xf32>
  // expected-error@+1 {{'scf.for' op loop result type reference does not match yielded refinements}}
  %r = scf.for %i = %c0 to %m step %c1 iter_args(%arg = %init)
      -> (tensor<?x?xf32>)
      #types[%arg : #tensor<[%m, %n], f32>] -> #tensor<[%m, %n], f32>
 {
    %bad = dependent_tensor.make () #tensor<[%n, %m], f32> : tensor<?x?xf32>
    scf.yield %bad : tensor<?x?xf32>
  }
  return
}

// -----
func.func @loop_result_boundary_rank_mismatch(%m : index, %n : index) {
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  %init = dependent_tensor.make () #tensor<[%m, %n], f32> : tensor<?x?xf32>
  // expected-error@+3 {{dependent tensor loop result type reference rank mismatch}}
  %r = scf.for %i = %c0 to %m step %c1 iter_args(%arg = %init)
      -> (tensor<?x?xf32>)
      #types[%arg : #tensor<[%m, %n], f32>] -> #tensor<[%m], f32>
 {
    scf.yield %arg : tensor<?x?xf32>
  }
  return
}

// -----

func.func @loop_result_boundary_element_type_mismatch(%m : index, %n : index) {
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  %init = dependent_tensor.make () #tensor<[%m, %n], f32> : tensor<?x?xf32>
  // expected-error@+3 {{dependent tensor loop result type reference element type must match value type}}
  %r = scf.for %i = %c0 to %m step %c1 iter_args(%arg = %init)
      -> (tensor<?x?xf32>)
      #types[%arg : #tensor<[%m, %n], f32>] -> #tensor<[%m, %n], i32>
 {
    scf.yield %arg : tensor<?x?xf32>
  }
  return
}

// -----

func.func @loop_result_boundary_dim_mismatch(%m : index, %n : index) {
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  %init = dependent_tensor.make () #tensor<[%m, %n], f32> : tensor<?x?xf32>
  // expected-error@+1 {{loop result type reference does not match yielded refinements}}
  %r = affine.for %i = 0 to %m iter_args(%arg = %init)
      -> (tensor<?x?xf32>)
      #types[%arg : #tensor<[%m, %n], f32>] -> #tensor<[%n, %m], f32>
 {
    affine.yield %arg : tensor<?x?xf32>
  }
  return
}

// -----

func.func @return_boundary_mismatch(%m : index, %n : index) -> tensor<?x?xf32>
    #types[] -> #tensor<[%m, %n], f32> {
  %t = dependent_tensor.make () #tensor<[%n, %m], f32> : tensor<?x?xf32>
  // expected-error@+1 {{returned value does not match function result dependency metadata}}
  return %t : tensor<?x?xf32>
}

// -----

func.func @call_contract(%m : index, %n : index, %t : tensor<?x?xf32>)
    -> tensor<?x?xf32>
    #types[%t : #tensor<[%m, %n], f32>] -> #tensor<[%m, %n], f32> {
  return %t : tensor<?x?xf32>
}

func.func @call_operand_mismatch(%m : index, %n : index) -> tensor<?x?xf32>
    #types[] -> #tensor<[%m, %n], f32> {
  %t = dependent_tensor.make () #tensor<[%n, %m], f32> : tensor<?x?xf32>
  // expected-error@+1 {{operand #2 does not match callee dependency metadata}}
  %r = func.call @call_contract(%m, %n, %t)
      : (index, index, tensor<?x?xf32>) -> tensor<?x?xf32>
  return %r : tensor<?x?xf32>
}
