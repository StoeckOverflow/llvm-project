// RUN: mlir-opt %s -split-input-file -verify-diagnostics | FileCheck %s

func.func @memref_loop_boundaries(%m : index, %n : index, %s0 : index, %s1 : index)
    -> memref<?x?xf32>
    #types[] -> #memref<[%m, %n], f32, offset: 0, strides: [%s0, %s1]> {
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  %init = dependent_memref.alloc #memref<[%m, %n], f32, offset: 0, strides: [%s0, %s1]> : memref<?x?xf32>
  %scf_result = scf.for %i = %c0 to %m step %c1 iter_args(%arg = %init)
      -> (memref<?x?xf32>)
      #types[%arg : #memref<[%m, %n], f32, offset: 0, strides: [%s0, %s1]>]
          -> #memref<[%m, %n], f32, offset: 0, strides: [%s0, %s1]> {
    scf.yield %arg : memref<?x?xf32>
  }
  %affine_result = affine.for %j = 0 to %n iter_args(%arg = %scf_result)
      -> (memref<?x?xf32>)
      #types[%arg : #memref<[%m, %n], f32, offset: 0, strides: [%s0, %s1]>]
          -> #memref<[%m, %n], f32, offset: 0, strides: [%s0, %s1]> {
    affine.yield %arg : memref<?x?xf32>
  }
  return %affine_result : memref<?x?xf32>
}

// CHECK-LABEL: func.func @memref_loop_boundaries
// CHECK: scf.for {{.*}} iter_args(%[[SCF_ARG:.*]] = {{.*}}) -> (memref<?x?xf32>) #types[%[[SCF_ARG]] : #memref<[%{{.*}}, %{{.*}}], f32, offset: 0, strides: [%{{.*}}, %{{.*}}]>] -> #memref<[%{{.*}}, %{{.*}}], f32, offset: 0, strides: [%{{.*}}, %{{.*}}]>
// CHECK: affine.for {{.*}} iter_args(%[[AFFINE_ARG:.*]] = {{.*}}) -> (memref<?x?xf32>) #types[%[[AFFINE_ARG]] : #memref<[%{{.*}}, %{{.*}}], f32, offset: 0, strides: [%{{.*}}, %{{.*}}]>] -> #memref<[%{{.*}}, %{{.*}}], f32, offset: 0, strides: [%{{.*}}, %{{.*}}]>

// -----

func.func @memref_loop_boundary_dim_mismatch(%m : index, %n : index, %s0 : index, %s1 : index) {
  %init = dependent_memref.alloc #memref<[%m, %n], f32, offset: 0, strides: [%s0, %s1]> : memref<?x?xf32>
  // expected-error@+1 {{loop operand type reference does not match init refinements}}
  %r = affine.for %i = 0 to %m iter_args(%arg = %init)
      -> (memref<?x?xf32>)
      #types[%arg : #memref<[%n, %m], f32, offset: 0, strides: [%s0, %s1]>]
          -> #memref<[%m, %n], f32, offset: 0, strides: [%s0, %s1]> {
    affine.yield %arg : memref<?x?xf32>
  }
  return
}

// -----

func.func @memref_loop_boundary_stride_mismatch(%m : index, %n : index, %s0 : index, %s1 : index) {
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  %init = dependent_memref.alloc #memref<[%m, %n], f32, offset: 0, strides: [%s0, %s1]> : memref<?x?xf32>
  // expected-error@+1 {{loop operand type reference does not match init refinements}}
  %r = scf.for %i = %c0 to %m step %c1 iter_args(%arg = %init)
      -> (memref<?x?xf32>)
      #types[%arg : #memref<[%m, %n], f32, offset: 0, strides: [%s1, %s0]>]
          -> #memref<[%m, %n], f32, offset: 0, strides: [%s0, %s1]> {
    scf.yield %arg : memref<?x?xf32>
  }
  return
}

// -----

func.func @memref_loop_boundary_yield_mismatch(%m : index, %n : index, %s0 : index, %s1 : index) {
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  %init = dependent_memref.alloc #memref<[%m, %n], f32, offset: 0, strides: [%s0, %s1]> : memref<?x?xf32>
  // expected-error@+1 {{'scf.for' op loop result type reference does not match yielded refinements}}
  %r = scf.for %i = %c0 to %m step %c1 iter_args(%arg = %init)
      -> (memref<?x?xf32>)
      #types[%arg : #memref<[%m, %n], f32, offset: 0, strides: [%s0, %s1]>]
          -> #memref<[%m, %n], f32, offset: 0, strides: [%s0, %s1]> {
    %bad = dependent_memref.alloc #memref<[%n, %m], f32, offset: 0, strides: [%s0, %s1]> : memref<?x?xf32>
    scf.yield %bad : memref<?x?xf32>
  }
  return
}

// -----

func.func @memref_loop_result_boundary_stride_mismatch(%m : index, %n : index, %s0 : index, %s1 : index) {
  %init = dependent_memref.alloc #memref<[%m, %n], f32, offset: 0, strides: [%s0, %s1]> : memref<?x?xf32>
  // expected-error@+1 {{loop result type reference does not match yielded refinements}}
  %r = affine.for %i = 0 to %m iter_args(%arg = %init)
      -> (memref<?x?xf32>)
      #types[%arg : #memref<[%m, %n], f32, offset: 0, strides: [%s0, %s1]>]
          -> #memref<[%m, %n], f32, offset: 0, strides: [%s1, %s0]> {
    affine.yield %arg : memref<?x?xf32>
  }
  return
}
