// RUN: mlir-opt %s -split-input-file -verify-diagnostics | FileCheck %s

func.func @boundary(%n : index, %m : index, %s0 : index, %s1 : index,
                    %A : memref<?x?xf32>)
    #types[%A : #memref<[%n, %m], f32, offset: 0, strides: [%s0, %s1]>] {
  %v = arith.constant 0.0 : f32
  dependent_memref.store %v, %A[%n, %m]
      #memref<[%n, %m], f32, offset: 0, strides: [%s0, %s1]> : memref<?x?xf32>
  return
}

// CHECK-LABEL: func.func @boundary

// -----

// expected-error@below {{requires dependent result dimensions to correspond to dynamic memref dims}}
func.func @bad_static_result(%n : index) -> memref<4xf32>
    #types[] -> #memref<[%n], f32> {
  %0 = memref.alloc() : memref<4xf32>
  return %0 : memref<4xf32>
}


// -----

// expected-error@below {{has duplicate dependent argument refinements}}
func.func @duplicate_arg_refinement(%n : index, %A : memref<?xf32>)
    #types[
      %A : #memref<[%n], f32>,
      %A : #memref<[%n], f32>
    ] {
  return
}

// -----

// expected-error@below {{requires dependent argument dimensions to correspond to dynamic memref dims}}
func.func @bad_static_arg(%n : index, %A : memref<4xf32>)
    #types[%A : #memref<[%n], f32>] {
  return
}

// -----

// expected-error@+2 {{dependent memref stride count must match rank}}
func.func @bad_op_stride_count(%n : index, %m : index, %s0 : index) {
  %0 = dependent_memref.alloc #memref<[%n, %m], f32, offset: 0, strides: [%s0]> : memref<?x?xf32>
  return
}


// -----

func.func @identity_with_boundary(%m : index, %n : index, %s0 : index, %s1 : index,
                                  %A : memref<?x?xf32>) -> memref<?x?xf32>
    #types[%A : #memref<[%m, %n], f32, offset: 0, strides: [%s0, %s1]>]
        -> #memref<[%m, %n], f32, offset: 0, strides: [%s0, %s1]> {
  return %A : memref<?x?xf32>
}

func.func @call_refinement(%m : index, %n : index, %s0 : index, %s1 : index)
    -> memref<?x?xf32>
    #types[] -> #memref<[%m, %n], f32, offset: 0, strides: [%s0, %s1]> {
  %A = dependent_memref.alloc #memref<[%m, %n], f32, offset: 0, strides: [%s0, %s1]> : memref<?x?xf32>
  %r = func.call @identity_with_boundary(%m, %n, %s0, %s1, %A)
      : (index, index, index, index, memref<?x?xf32>) -> memref<?x?xf32>
  return %r : memref<?x?xf32>
}

// -----

func.func @return_boundary_mismatch(%m : index, %n : index) -> memref<?x?xf32>
    #types[] -> #memref<[%m, %n], f32> {
  %A = dependent_memref.alloc #memref<[%n, %m], f32> : memref<?x?xf32>
  // expected-error@+1 {{returned value does not match function result dependency metadata}}
  return %A : memref<?x?xf32>
}

// -----

func.func @call_contract(%m : index, %n : index, %A : memref<?x?xf32>)
    -> memref<?x?xf32>
    #types[%A : #memref<[%m, %n], f32>] -> #memref<[%m, %n], f32> {
  return %A : memref<?x?xf32>
}

func.func @call_operand_mismatch(%m : index, %n : index) -> memref<?x?xf32>
    #types[] -> #memref<[%m, %n], f32> {
  %A = dependent_memref.alloc #memref<[%n, %m], f32> : memref<?x?xf32>
  // expected-error@+1 {{operand #2 does not match callee dependency metadata}}
  %r = func.call @call_contract(%m, %n, %A)
      : (index, index, memref<?x?xf32>) -> memref<?x?xf32>
  return %r : memref<?x?xf32>
}
