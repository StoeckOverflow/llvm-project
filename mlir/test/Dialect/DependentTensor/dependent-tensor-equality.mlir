// RUN: mlir-opt %s -pass-pipeline='builtin.module(func.func(test-dependent-tensor-equality))'

func.func @same_seeds_different_names(
    %m : index, %k : index)
    -> (tensor<?x?xf32>, tensor<?x?xf32>)
    attributes {test.expect_semantics_equal = true} {
  %a = dependent_tensor.make %m, %k dims[m, k] : tensor<?x?xf32>
  %b = dependent_tensor.make %m, %k dims[x, y] : tensor<?x?xf32>
  return %a, %b : tensor<?x?xf32>, tensor<?x?xf32>
}

func.func @different_seeds_not_equal(
    %m : index, %k : index, %n : index)
    -> (tensor<?x?xf32>, tensor<?x?xf32>)
    attributes {test.expect_semantics_equal = false} {
  %a = dependent_tensor.make %m, %k dims[m, k] : tensor<?x?xf32>
  %b = dependent_tensor.make %k, %n dims[k, n] : tensor<?x?xf32>
  return %a, %b : tensor<?x?xf32>, tensor<?x?xf32>
}

func.func @different_rank_not_equal(
    %m : index, %k : index)
    -> (tensor<?x?xf32>, tensor<?xf32>)
    attributes {test.expect_semantics_equal = false} {
  %a = dependent_tensor.make %m, %k dims[m, k] : tensor<?x?xf32>
  %b = dependent_tensor.make %m dims[m] : tensor<?xf32>
  return %a, %b : tensor<?x?xf32>, tensor<?xf32>
}

func.func @equal_contracting_dims(
    %m : index, %k : index, %n : index)
    -> (tensor<?x?xf32>, tensor<?x?xf32>)
    attributes {
      test.expect_dim_equal = true,
      test.dim_pair = array<i32: 1, 0>
    } {
  %a = dependent_tensor.make %m, %k dims[m, k] : tensor<?x?xf32>
  %b = dependent_tensor.make %k, %n dims[k, n] : tensor<?x?xf32>
  return %a, %b : tensor<?x?xf32>, tensor<?x?xf32>
}

func.func @different_dims_not_equal(
    %m : index, %k : index, %n : index)
    -> (tensor<?x?xf32>, tensor<?x?xf32>)
    attributes {
      test.expect_dim_equal = false,
      test.dim_pair = array<i32: 0, 1>
    } {
  %a = dependent_tensor.make %m, %k dims[m, k] : tensor<?x?xf32>
  %b = dependent_tensor.make %k, %n dims[k, n] : tensor<?x?xf32>
  return %a, %b : tensor<?x?xf32>, tensor<?x?xf32>
}
