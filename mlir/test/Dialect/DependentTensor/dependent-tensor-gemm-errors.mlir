// RUN: mlir-opt %s -split-input-file -verify-diagnostics

func.func @gemm_bad_contraction(%m : index, %k0 : index, %k1 : index,
                                %n : index) {
  %a = dependent_tensor.make %m, %k0 dims[m, k0] : tensor<?x?xf32>
  %b = dependent_tensor.make %k1, %n dims[k1, n] : tensor<?x?xf32>
  %c = dependent_tensor.make %m, %n dims[m, n] : tensor<?x?xf32>
  // expected-error@+1 {{'dependent_tensor.gemm' op schema is incompatible with operand dimension labels}}
  %r = dependent_tensor.gemm %a, %b, %c dims[m, k, n] (m, k) x (k, n) + (m, n) -> (m, n)
    : tensor<?x?xf32>, tensor<?x?xf32>, tensor<?x?xf32> -> tensor<?x?xf32>
  return
}

// -----

func.func @gemm_bad_accumulator(%m : index, %k : index, %n : index, %x : index) {
  %a = dependent_tensor.make %m, %k dims[m, k] : tensor<?x?xf32>
  %b = dependent_tensor.make %k, %n dims[k, n] : tensor<?x?xf32>
  %c = dependent_tensor.make %x, %n dims[m, n] : tensor<?x?xf32>
  // expected-error@+1 {{'dependent_tensor.gemm' op expected lhs row dim to match accumulator/result row dim}}
  %r = dependent_tensor.gemm %a, %b, %c dims[m, k, n] (m, k) x (k, n) + (m, n) -> (m, n)
    : tensor<?x?xf32>, tensor<?x?xf32>, tensor<?x?xf32> -> tensor<?x?xf32>
  return
}

// -----

func.func @gemm_bad_dim_names(%m : index, %k : index, %n : index) {
  %a = dependent_tensor.make %m, %k dims[m, k] : tensor<?x?xf32>
  %b = dependent_tensor.make %k, %n dims[k, n] : tensor<?x?xf32>
  %c = dependent_tensor.make %m, %n dims[m, n] : tensor<?x?xf32>
  // expected-error@+1 {{'dependent_tensor.gemm' op requires unique dimension names}}
  %r = dependent_tensor.gemm %a, %b, %c dims[m, k, m] (m, k) x (k, m) + (m, m) -> (m, m)
    : tensor<?x?xf32>, tensor<?x?xf32>, tensor<?x?xf32> -> tensor<?x?xf32>
  return
}

// -----

func.func @gemm_bad_schema_rank(%m : index, %k : index, %n : index) {
  %a = dependent_tensor.make %m, %k dims[m, k] : tensor<?x?xf32>
  %b = dependent_tensor.make %k, %n dims[k, n] : tensor<?x?xf32>
  %c = dependent_tensor.make %m, %n dims[m, n] : tensor<?x?xf32>
  // expected-error@+1 {{'dependent_tensor.gemm' op requires rank-2 schema groups}}
  %r = dependent_tensor.gemm %a, %b, %c dims[m, k, n] (m, k, n) x (k, n) + (m, n) -> (m, n)
    : tensor<?x?xf32>, tensor<?x?xf32>, tensor<?x?xf32> -> tensor<?x?xf32>
  return
}

// -----

func.func @gemm_undeclared_dim_in_schema(%m : index, %k : index, %n : index) {
  %a = dependent_tensor.make %m, %k dims[m, k] : tensor<?x?xf32>
  %b = dependent_tensor.make %k, %n dims[k, n] : tensor<?x?xf32>
  %c = dependent_tensor.make %m, %n dims[m, n] : tensor<?x?xf32>
  // expected-error@+1 {{schema references undeclared dim name}}
  %r = dependent_tensor.gemm %a, %b, %c dims[m, k, n] (m, z) x (k, n) + (m, n) -> (m, n)
    : tensor<?x?xf32>, tensor<?x?xf32>, tensor<?x?xf32> -> tensor<?x?xf32>
  return
}
