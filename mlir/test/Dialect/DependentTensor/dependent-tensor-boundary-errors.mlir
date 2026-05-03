// RUN: mlir-opt %s -split-input-file -verify-dependent-tensor-semantics -verify-diagnostics

func.func @identity_with_metadata(
    %m : index,
    %n : index,
    %t : tensor<?x?xf32> {dependent_tensor.seed_args = array<i32: 0, 1>})
    -> (tensor<?x?xf32> {dependent_tensor.seed_args = array<i32: 0, 1>}) {
  return %t : tensor<?x?xf32>
}

func.func @bad_call_operand_metadata(%m : index, %n : index) {
  %t = dependent_tensor.make %n, %m dims[n, m] : tensor<?x?xf32>
  // expected-error@+1 {{operand #2 does not match callee dependency metadata}}
  %r = func.call @identity_with_metadata(%m, %n, %t) : (index, index, tensor<?x?xf32>) -> tensor<?x?xf32>
  return
}

// -----

func.func @identity_with_metadata(
    %m : index,
    %n : index,
    %t : tensor<?x?xf32> {dependent_tensor.seed_args = array<i32: 0, 1>})
    -> (tensor<?x?xf32> {dependent_tensor.seed_args = array<i32: 0, 1>}) {
  return %t : tensor<?x?xf32>
}

// -----

func.func @bad_return_metadata(
    %m : index,
    %n : index) -> (tensor<?x?xf32> {dependent_tensor.seed_args = array<i32: 0, 1>}) {
  %t = dependent_tensor.make %n, %m dims[n, m] : tensor<?x?xf32>
  // expected-error@+1 {{returned value does not match function result dependency metadata}}
  return %t : tensor<?x?xf32>
}
