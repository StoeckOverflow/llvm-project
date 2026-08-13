// RUN: mlir-opt %s -split-input-file -verify-dependent-tensor-refinements -verify-diagnostics | FileCheck %s

func.func @split_scf_loop_type_refs(%m : index) -> tensor<?xf32>
    #types[] -> #tensor<[%m], f32> {
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  %init = dependent_tensor.make () #tensor<[%m], f32> : tensor<?xf32>
  %r = scf.for %i = %c0 to %m step %c1 iter_args(%arg = %init)
      -> (tensor<?xf32>)
      #types[%arg : #tensor<[%m], f32>] -> #tensor<[%m], f32>
 {
    scf.yield %arg : tensor<?xf32>
  }
  return %r : tensor<?xf32>
}

// CHECK-LABEL: func.func @split_scf_loop_type_refs
// CHECK: scf.for {{.*}} iter_args(%[[ARG:.*]] = {{.*}}) -> (tensor<?xf32>) #types[%[[ARG]] : #tensor<[%{{.*}}], f32>] -> #tensor<[%{{.*}}], f32> {

// -----

func.func @split_multiple_scf_loop_type_refs(%m : index, %n : index)
    -> (tensor<?xf32>, tensor<?xf32>)
    #types[] -> [#tensor<[%m], f32>, #tensor<[%n], f32>] {
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  %lhs = dependent_tensor.make () #tensor<[%m], f32> : tensor<?xf32>
  %rhs = dependent_tensor.make () #tensor<[%n], f32> : tensor<?xf32>
  %r0, %r1 = scf.for %i = %c0 to %m step %c1
      iter_args(%a = %lhs, %b = %rhs) -> (tensor<?xf32>, tensor<?xf32>)
      #types[%a : #tensor<[%m], f32>, %b : #tensor<[%n], f32>] -> [#tensor<[%m], f32>, #tensor<[%n], f32>]
 {
    scf.yield %a, %b : tensor<?xf32>, tensor<?xf32>
  }
  return %r0, %r1 : tensor<?xf32>, tensor<?xf32>
}

// CHECK-LABEL: func.func @split_multiple_scf_loop_type_refs
// CHECK: scf.for {{.*}} iter_args(%[[A:.*]] = {{.*}}, %[[B:.*]] = {{.*}}) -> (tensor<?xf32>, tensor<?xf32>) #types[%[[A]] : #tensor<[%{{.*}}], f32>, %[[B]] : #tensor<[%{{.*}}], f32>] -> [#tensor<[%{{.*}}], f32>, #tensor<[%{{.*}}], f32>] {

// -----

func.func @distinct_actual_and_region_refs(%actual_in : index,
                                           %actual_out : index,
                                           %region_in : index,
                                           %region_out : index,
                                           %init : tensor<?xf32>,
                                           %yielded : tensor<?xf32>) {
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  %r = scf.for %i = %c0 to %actual_in step %c1 iter_args(%arg = %init)
      -> (tensor<?xf32>)
      #types[%arg : #tensor<[%actual_in], f32>] -> #tensor<[%actual_out], f32>
 {
    scf.yield %yielded : tensor<?xf32>
  }
  return
}

// CHECK-LABEL: func.func @distinct_actual_and_region_refs
// CHECK: scf.for {{.*}} iter_args(%[[ARG:.*]] = {{.*}}) -> (tensor<?xf32>) #types[%[[ARG]] : #tensor<[%{{.*}}], f32>] -> #tensor<[%{{.*}}], f32> {

// -----

func.func @split_affine_loop_type_refs(%m : index) -> tensor<?xf32>
    #types[] -> #tensor<[%m], f32> {
  %init = dependent_tensor.make () #tensor<[%m], f32> : tensor<?xf32>
  %r = affine.for %i = 0 to %m iter_args(%arg = %init)
      -> (tensor<?xf32>)
      #types[%arg : #tensor<[%m], f32>] -> #tensor<[%m], f32>
 {
    affine.yield %arg : tensor<?xf32>
  }
  return %r : tensor<?xf32>
}

// CHECK-LABEL: func.func @split_affine_loop_type_refs
// CHECK: affine.for {{.*}} iter_args(%[[ARG:.*]] = {{.*}}) -> (tensor<?xf32>) #types[%[[ARG]] : #tensor<[%{{.*}}], f32>] -> #tensor<[%{{.*}}], f32> {

// -----

func.func @body_local_yield_ref_rejected(%m : index) -> tensor<?xf32>
    #types[] -> #tensor<[%m], f32> {
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  %init = dependent_tensor.make () #tensor<[%m], f32> : tensor<?xf32>
  // expected-error@+1 {{loop result type reference does not match yielded refinements}}
  %r = scf.for %i = %c0 to %m step %c1 iter_args(%arg = %init)
      -> (tensor<?xf32>)
      #types[%arg : #tensor<[%m], f32>] -> #tensor<[%m], f32> {
    %body_dim = arith.constant 4 : index
    %next = dependent_tensor.make () #tensor<[%body_dim], f32> : tensor<?xf32>
    scf.yield %next : tensor<?xf32>
  }
  return %r : tensor<?xf32>
}

// -----

func.func @duplicate_loop_type_ref(%m : index, %t : tensor<?xf32>) {
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  %r = scf.for %i = %c0 to %m step %c1 iter_args(%arg = %t)
      -> (tensor<?xf32>)
      // expected-error@+1 {{duplicate dependent tensor loop boundary value}}
      #types[%arg : #tensor<[%m], f32>, %arg : #tensor<[%m], f32>] -> [#tensor<[%m], f32>, #tensor<[%m], f32>] {
    scf.yield %arg : tensor<?xf32>
  }
  return
}

// -----

func.func @obsolete_region_type_ref_rejected(%m : index, %t : tensor<?xf32>) {
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  %r = scf.for %i = %c0 to %m step %c1 iter_args(%arg = %t)
      -> (tensor<?xf32>)
      // expected-error@+1 {{expected '{' to begin a region}}
      #types[%arg : #tensor<[%m], f32>] -> #tensor<[%m], f32>
      #region_types[%arg : #tensor<[%m], f32> -> #tensor<[%m], f32>] {
    scf.yield %arg : tensor<?xf32>
  }
  return
}

// -----

func.func @unknown_loop_type_ref_value(%m : index, %t : tensor<?xf32>) {
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  %r = scf.for %i = %c0 to %m step %c1 iter_args(%arg = %t)
      -> (tensor<?xf32>)
      // expected-error@+1 {{dependent tensor loop boundary values must be loop iter args}}
      #types[%t : #tensor<[%m], f32>] -> #tensor<[%m], f32> {
    scf.yield %arg : tensor<?xf32>
  }
  return
}

// -----

// expected-note@+1 {{prior use here}}
func.func @non_index_type_ref_dim(%bad : f32, %t : tensor<?xf32>) {
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  %r = scf.for %i = %c0 to %c0 step %c1 iter_args(%arg = %t)
      -> (tensor<?xf32>)
      // expected-error@+1 {{expects different type}}
      #types[%arg : #tensor<[%bad], f32>] -> #tensor<[%bad], f32> {
    scf.yield %arg : tensor<?xf32>
  }
  return
}


// -----

func.func @old_loop_type_syntax_rejected(%m : index, %t : tensor<?xf32>) {
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  %r = scf.for %i = %c0 to %m step %c1 iter_args(%arg = %t)
      -> (tensor<?xf32>)
      // expected-error@+1 {{expected SSA operand}}
      #types[%arg : #tensor<[%m], f32> -> #tensor<[%m], f32>] {
    scf.yield %arg : tensor<?xf32>
  }
  return
}
