// RUN: mlir-opt %s -split-input-file -verify-dependent-tensor-semantics -verify-diagnostics

func.func @identity_with_boundary(
    %m : index,
    %n : index,
    %t : tensor<?x?xf32>) -> tensor<?x?xf32> {
  return %t : tensor<?x?xf32>
} dependent_tensor_boundary args[2 dims[%m, %n] names[m, n]] results[0 dims[%m, %n] names[m, n]]

func.func @bad_call_operand_boundary(%m : index, %n : index) {
  %t = dependent_tensor.make %n, %m dims[n, m] : tensor<?x?xf32>
  // expected-error@+1 {{operand #2 does not match callee dependency metadata}}
  %r = func.call @identity_with_boundary(%m, %n, %t) : (index, index, tensor<?x?xf32>) -> tensor<?x?xf32>
  return
}

// -----

func.func @bad_return_boundary(
    %m : index,
    %n : index) -> tensor<?x?xf32> {
  %t = dependent_tensor.make %n, %m dims[n, m] : tensor<?x?xf32>
  // expected-error@+1 {{returned value does not match function result dependency metadata}}
  return %t : tensor<?x?xf32>
} dependent_tensor_boundary args[] results[0 dims[%m, %n] names[m, n]]

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
    %n : index) -> tensor<?x?xf32> {
  %c0 = arith.constant 0 : index
  %t = dependent_tensor.make %m, %n dims[m, n] : tensor<?x?xf32>
  return %t : tensor<?x?xf32>
  // expected-error@+1 {{dependent tensor boundary dims must be function arguments}}
} dependent_tensor_boundary args[] results[0 dims[%m, %c0] names[m, n]]
