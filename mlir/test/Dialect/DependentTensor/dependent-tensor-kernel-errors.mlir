// RUN: mlir-opt %s -split-input-file -verify-dependent-tensor-semantics -verify-diagnostics

func.func @matmul_kernel(
    %m : index,
    %k : index,
    %n : index,
    %A : tensor<?x?xf32>,
    %B : tensor<?x?xf32>,
    %Cinit : tensor<?x?xf32>) -> tensor<?x?xf32> {
  return %Cinit : tensor<?x?xf32>
} dependent_tensor_boundary args[
    3 dims[%m, %k] names[m, k],
    4 dims[%k, %n] names[k, n],
    5 dims[%m, %n] names[m, n]
  ] results[0 dims[%m, %n] names[m, n]]

func.func @bad_matmul_contracting_dim(
    %m : index,
    %k : index,
    %p : index,
    %n : index) -> tensor<?x?xf32> {
  %A = dependent_tensor.make %m, %k dims[m, k] : tensor<?x?xf32>
  %B = dependent_tensor.make %p, %n dims[p, n] : tensor<?x?xf32>
  %C = dependent_tensor.make %m, %n dims[m, n] : tensor<?x?xf32>
  // expected-error@+1 {{operand #4 does not match callee dependency metadata}}
  %R = func.call @matmul_kernel(%m, %k, %n, %A, %B, %C)
      : (index, index, index, tensor<?x?xf32>, tensor<?x?xf32>, tensor<?x?xf32>) -> tensor<?x?xf32>
  return %R : tensor<?x?xf32>
} dependent_tensor_boundary args[] results[0 dims[%m, %n] names[m, n]]

// -----

func.func @matmul_kernel(
    %m : index,
    %k : index,
    %n : index,
    %A : tensor<?x?xf32>,
    %B : tensor<?x?xf32>,
    %Cinit : tensor<?x?xf32>) -> tensor<?x?xf32> {
  return %Cinit : tensor<?x?xf32>
} dependent_tensor_boundary args[
    3 dims[%m, %k] names[m, k],
    4 dims[%k, %n] names[k, n],
    5 dims[%m, %n] names[m, n]
  ] results[0 dims[%m, %n] names[m, n]]

func.func @bad_matmul_result_dim(
    %m : index,
    %k : index,
    %n : index,
    %p : index) -> tensor<?x?xf32> {
  %A = dependent_tensor.make %m, %k dims[m, k] : tensor<?x?xf32>
  %B = dependent_tensor.make %k, %n dims[k, n] : tensor<?x?xf32>
  %C = dependent_tensor.make %m, %p dims[m, p] : tensor<?x?xf32>
  // expected-error@+1 {{operand #5 does not match callee dependency metadata}}
  %R = func.call @matmul_kernel(%m, %k, %n, %A, %B, %C)
      : (index, index, index, tensor<?x?xf32>, tensor<?x?xf32>, tensor<?x?xf32>) -> tensor<?x?xf32>
  return %R : tensor<?x?xf32>
} dependent_tensor_boundary args[] results[0 dims[%m, %n] names[m, n]]

// -----

func.func @kernel_insert_property_mismatch(
    %m : index,
    %k : index,
    %n : index,
    %A : tensor<?x?xf32>,
    %B : tensor<?x?xf32>,
    %Cinit : tensor<?x?xf32>) -> tensor<?x?xf32> {
  %c0 = arith.constant 0 : index
  %v = dependent_tensor.extract %Cinit[%c0, %c0] : tensor<?x?xf32>
  // expected-error@+1 {{'dependent_tensor.insert' op stored result semantics must match destination semantics}}
  %bad = dependent_tensor.insert %v into %Cinit[%c0, %c0] result_dims[%m, %k] dims[m, k] : f32 into tensor<?x?xf32>
  return %bad : tensor<?x?xf32>
} dependent_tensor_boundary args[
    3 dims[%m, %k] names[m, k],
    4 dims[%k, %n] names[k, n],
    5 dims[%m, %n] names[m, n]
  ] results[0 dims[%m, %n] names[m, n]]

// -----

func.func @conv2d_nhwc_hwcf_kernel(
    %n : index,
    %h : index,
    %w : index,
    %c : index,
    %kh : index,
    %kw : index,
    %f : index,
    %oh : index,
    %ow : index,
    %X : tensor<?x?x?x?xf32>,
    %K : tensor<?x?x?x?xf32>,
    %Yinit : tensor<?x?x?x?xf32>) -> tensor<?x?x?x?xf32> {
  return %Yinit : tensor<?x?x?x?xf32>
} dependent_tensor_boundary args[
    9 dims[%n, %h, %w, %c] names[N, H, W, C],
    10 dims[%kh, %kw, %c, %f] names[KH, KW, C, F],
    11 dims[%n, %oh, %ow, %f] names[N, OH, OW, F]
  ] results[0 dims[%n, %oh, %ow, %f] names[N, OH, OW, F]]

func.func @bad_conv_channel_dim(
    %n : index,
    %h : index,
    %w : index,
    %c : index,
    %p : index,
    %kh : index,
    %kw : index,
    %f : index,
    %oh : index,
    %ow : index) -> tensor<?x?x?x?xf32> {
  %X = dependent_tensor.make %n, %h, %w, %c dims[N, H, W, C] : tensor<?x?x?x?xf32>
  %K = dependent_tensor.make %kh, %kw, %p, %f dims[KH, KW, P, F] : tensor<?x?x?x?xf32>
  %Y = dependent_tensor.make %n, %oh, %ow, %f dims[N, OH, OW, F] : tensor<?x?x?x?xf32>
  // expected-error@+1 {{operand #10 does not match callee dependency metadata}}
  %R = func.call @conv2d_nhwc_hwcf_kernel(%n, %h, %w, %c, %kh, %kw, %f, %oh, %ow, %X, %K, %Y)
      : (index, index, index, index, index, index, index, index, index, tensor<?x?x?x?xf32>, tensor<?x?x?x?xf32>, tensor<?x?x?x?xf32>) -> tensor<?x?x?x?xf32>
  return %R : tensor<?x?x?x?xf32>
} dependent_tensor_boundary args[] results[0 dims[%n, %oh, %ow, %f] names[N, OH, OW, F]]

// -----

func.func @conv2d_nhwc_hwcf_kernel(
    %n : index,
    %h : index,
    %w : index,
    %c : index,
    %kh : index,
    %kw : index,
    %f : index,
    %oh : index,
    %ow : index,
    %X : tensor<?x?x?x?xf32>,
    %K : tensor<?x?x?x?xf32>,
    %Yinit : tensor<?x?x?x?xf32>) -> tensor<?x?x?x?xf32> {
  return %Yinit : tensor<?x?x?x?xf32>
} dependent_tensor_boundary args[
    9 dims[%n, %h, %w, %c] names[N, H, W, C],
    10 dims[%kh, %kw, %c, %f] names[KH, KW, C, F],
    11 dims[%n, %oh, %ow, %f] names[N, OH, OW, F]
  ] results[0 dims[%n, %oh, %ow, %f] names[N, OH, OW, F]]

func.func @bad_conv_result_channel_dim(
    %n : index,
    %h : index,
    %w : index,
    %c : index,
    %kh : index,
    %kw : index,
    %f : index,
    %p : index,
    %oh : index,
    %ow : index) -> tensor<?x?x?x?xf32> {
  %X = dependent_tensor.make %n, %h, %w, %c dims[N, H, W, C] : tensor<?x?x?x?xf32>
  %K = dependent_tensor.make %kh, %kw, %c, %f dims[KH, KW, C, F] : tensor<?x?x?x?xf32>
  %Y = dependent_tensor.make %n, %oh, %ow, %p dims[N, OH, OW, P] : tensor<?x?x?x?xf32>
  // expected-error@+1 {{operand #11 does not match callee dependency metadata}}
  %R = func.call @conv2d_nhwc_hwcf_kernel(%n, %h, %w, %c, %kh, %kw, %f, %oh, %ow, %X, %K, %Y)
      : (index, index, index, index, index, index, index, index, index, tensor<?x?x?x?xf32>, tensor<?x?x?x?xf32>, tensor<?x?x?x?xf32>) -> tensor<?x?x?x?xf32>
  return %R : tensor<?x?x?x?xf32>
} dependent_tensor_boundary args[] results[0 dims[%n, %oh, %ow, %f] names[N, OH, OW, F]]
