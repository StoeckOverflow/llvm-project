// RUN: mlir-opt %s -split-input-file -verify-dependent-tensor-semantics -verify-diagnostics

func.func @identity_with_boundary(
    %m : index,
    %n : index,
    %t : tensor<?x?xf32>) -> tensor<?x?xf32>
    #types[%t : #tensor<[%m, %n], f32>] -> #tensor<[%m, %n], f32> {
  return %t : tensor<?x?xf32>
}

func.func @bad_call_operand_boundary(%m : index, %n : index) {
  %t = dependent_tensor.make () #tensor<[%n, %m], f32> : tensor<?x?xf32>
  // expected-error@+1 {{operand #2 does not match callee dependency metadata}}
  %r = func.call @identity_with_boundary(%m, %n, %t) : (index, index, tensor<?x?xf32>) -> tensor<?x?xf32>
  return
}

// -----

func.func @bad_return_boundary(
    %m : index,
    %n : index) -> tensor<?x?xf32>
    #types[] -> #tensor<[%m, %n], f32> {
  %t = dependent_tensor.make () #tensor<[%n, %m], f32> : tensor<?x?xf32>
  // expected-error@+1 {{returned value does not match function result dependency metadata}}
  return %t : tensor<?x?xf32>
}

// -----

func.func @old_seed_args_rejected(
    %m : index,
    %n : index,
    // expected-error@+1 {{dependent_tensor.seed_args is no longer supported}}
    %t : tensor<?x?xf32> {dependent_tensor.seed_args = array<i32: 0, 1>})
    -> tensor<?x?xf32> {
  return %t : tensor<?x?xf32>
}

// -----

func.func @bad_boundary_dim_not_arg(
    %m : index,
    %n : index) -> tensor<?x?xf32>
    // expected-error@+1 {{dependent tensor boundary dims must be function arguments}}
    #types[] -> #tensor<[%m, %c0], f32> {
  %c0 = arith.constant 0 : index
  %t = dependent_tensor.make () #tensor<[%m, %n], f32> : tensor<?x?xf32>
  return %t : tensor<?x?xf32>
}
