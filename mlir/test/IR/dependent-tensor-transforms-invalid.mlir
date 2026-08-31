// RUN: not mlir-opt %s -pass-pipeline='builtin.module(func.func(test-dependent-tensor-replace-op-uses-no-refresh))' --split-input-file 2>&1 | FileCheck %s --check-prefix=STALE
// RUN: not mlir-opt %s -pass-pipeline='builtin.module(func.func(test-dependent-tensor-erase-function-signature))' --split-input-file 2>&1 | FileCheck %s --check-prefix=SIGERR

func.func @stale_insert_destination_refinement() {
  %m = arith.constant 4 : index
  %n = arith.constant 8 : index
  %c0 = arith.constant 0 : index
  %v = arith.constant 0.000000e+00 : f32
  %lhs = dependent_tensor.make () #tensor<[%m], f32> : tensor<?xf32>
  %rhs = dependent_tensor.make () #tensor<[%n], f32> : tensor<?xf32>
  %r = dependent_tensor.insert %v into %lhs[%c0] #tensor<[%m], f32> : f32 into tensor<?xf32>
  return
}

// STALE: stored result refinements must match destination refinements

// -----

func.func @erase_func_boundary_live_dim_arg(%m : index, %t : tensor<?xf32>)
    -> tensor<?xf32> #types[%t : #tensor<[%m], f32>] -> #tensor<[%m], f32> {
  return %t : tensor<?xf32>
}

// SIGERR: cannot erase function argument #0 because it is used by surviving dependent type argument boundary refinements
