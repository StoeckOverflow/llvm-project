// RUN: mlir-opt %s -split-input-file -verify-dependent-tensor-semantics -verify-diagnostics

func.func @matmul_kernel(
    %m : index,
    %k : index,
    %n : index,
    %A : tensor<?x?xf32>,
    %B : tensor<?x?xf32>,
    %Cinit : tensor<?x?xf32>) -> tensor<?x?xf32>
    #types[
      %A : #tensor<[%m, %k], f32>,
      %B : #tensor<[%k, %n], f32>,
      %Cinit : #tensor<[%m, %n], f32>
    ] -> #tensor<[%m, %n], f32> {
  return %Cinit : tensor<?x?xf32>
}

func.func @bad_matmul_contracting_dim(
    %m : index,
    %k : index,
    %p : index,
    %n : index) -> tensor<?x?xf32>
    #types[] -> #tensor<[%m, %n], f32> {
  %A = dependent_tensor.make () #tensor<[%m, %k], f32> : tensor<?x?xf32>
  %B = dependent_tensor.make () #tensor<[%p, %n], f32> : tensor<?x?xf32>
  %C = dependent_tensor.make () #tensor<[%m, %n], f32> : tensor<?x?xf32>
  // expected-error@+1 {{operand #4 does not match callee dependency metadata}}
  %R = func.call @matmul_kernel(%m, %k, %n, %A, %B, %C)
      : (index, index, index, tensor<?x?xf32>, tensor<?x?xf32>, tensor<?x?xf32>) -> tensor<?x?xf32>
  return %R : tensor<?x?xf32>
}

// -----

func.func @matmul_kernel(
    %m : index,
    %k : index,
    %n : index,
    %A : tensor<?x?xf32>,
    %B : tensor<?x?xf32>,
    %Cinit : tensor<?x?xf32>) -> tensor<?x?xf32>
    #types[
      %A : #tensor<[%m, %k], f32>,
      %B : #tensor<[%k, %n], f32>,
      %Cinit : #tensor<[%m, %n], f32>
    ] -> #tensor<[%m, %n], f32> {
  return %Cinit : tensor<?x?xf32>
}

func.func @bad_matmul_result_dim(
    %m : index,
    %k : index,
    %n : index,
    %p : index) -> tensor<?x?xf32>
    #types[] -> #tensor<[%m, %n], f32> {
  %A = dependent_tensor.make () #tensor<[%m, %k], f32> : tensor<?x?xf32>
  %B = dependent_tensor.make () #tensor<[%k, %n], f32> : tensor<?x?xf32>
  %C = dependent_tensor.make () #tensor<[%m, %p], f32> : tensor<?x?xf32>
  // expected-error@+1 {{operand #5 does not match callee dependency metadata}}
  %R = func.call @matmul_kernel(%m, %k, %n, %A, %B, %C)
      : (index, index, index, tensor<?x?xf32>, tensor<?x?xf32>, tensor<?x?xf32>) -> tensor<?x?xf32>
  return %R : tensor<?x?xf32>
}

// -----

func.func @kernel_insert_property_mismatch(
    %m : index,
    %k : index,
    %n : index,
    %A : tensor<?x?xf32>,
    %B : tensor<?x?xf32>,
    %Cinit : tensor<?x?xf32>) -> tensor<?x?xf32>
    #types[
      %A : #tensor<[%m, %k], f32>,
      %B : #tensor<[%k, %n], f32>,
      %Cinit : #tensor<[%m, %n], f32>
    ] -> #tensor<[%m, %n], f32> {
  %c0 = arith.constant 0 : index
  %v = dependent_tensor.extract %Cinit[%c0, %c0] : f32
  // expected-error@+1 {{'dependent_tensor.insert' op stored result semantics must match destination semantics}}
  %bad = dependent_tensor.insert %v into %Cinit[%c0, %c0] #tensor<[%m, %k], f32> : f32 into tensor<?x?xf32>
  return %bad : tensor<?x?xf32>
}

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
    %Yinit : tensor<?x?x?x?xf32>) -> tensor<?x?x?x?xf32>
    #types[
      %X : #tensor<[%n, %h, %w, %c], f32>,
      %K : #tensor<[%kh, %kw, %c, %f], f32>,
      %Yinit : #tensor<[%n, %oh, %ow, %f], f32>
    ] -> #tensor<[%n, %oh, %ow, %f], f32> {
  return %Yinit : tensor<?x?x?x?xf32>
}

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
    %ow : index) -> tensor<?x?x?x?xf32>
    #types[] -> #tensor<[%n, %oh, %ow, %f], f32> {
  %X = dependent_tensor.make () #tensor<[%n, %h, %w, %c], f32> : tensor<?x?x?x?xf32>
  %K = dependent_tensor.make () #tensor<[%kh, %kw, %p, %f], f32> : tensor<?x?x?x?xf32>
  %Y = dependent_tensor.make () #tensor<[%n, %oh, %ow, %f], f32> : tensor<?x?x?x?xf32>
  // expected-error@+1 {{operand #10 does not match callee dependency metadata}}
  %R = func.call @conv2d_nhwc_hwcf_kernel(%n, %h, %w, %c, %kh, %kw, %f, %oh, %ow, %X, %K, %Y)
      : (index, index, index, index, index, index, index, index, index, tensor<?x?x?x?xf32>, tensor<?x?x?x?xf32>, tensor<?x?x?x?xf32>) -> tensor<?x?x?x?xf32>
  return %R : tensor<?x?x?x?xf32>
}

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
    %Yinit : tensor<?x?x?x?xf32>) -> tensor<?x?x?x?xf32>
    #types[
      %X : #tensor<[%n, %h, %w, %c], f32>,
      %K : #tensor<[%kh, %kw, %c, %f], f32>,
      %Yinit : #tensor<[%n, %oh, %ow, %f], f32>
    ] -> #tensor<[%n, %oh, %ow, %f], f32> {
  return %Yinit : tensor<?x?x?x?xf32>
}

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
    %ow : index) -> tensor<?x?x?x?xf32>
    #types[] -> #tensor<[%n, %oh, %ow, %f], f32> {
  %X = dependent_tensor.make () #tensor<[%n, %h, %w, %c], f32> : tensor<?x?x?x?xf32>
  %K = dependent_tensor.make () #tensor<[%kh, %kw, %c, %f], f32> : tensor<?x?x?x?xf32>
  %Y = dependent_tensor.make () #tensor<[%n, %oh, %ow, %p], f32> : tensor<?x?x?x?xf32>
  // expected-error@+1 {{operand #11 does not match callee dependency metadata}}
  %R = func.call @conv2d_nhwc_hwcf_kernel(%n, %h, %w, %c, %kh, %kw, %f, %oh, %ow, %X, %K, %Y)
      : (index, index, index, index, index, index, index, index, index, tensor<?x?x?x?xf32>, tensor<?x?x?x?xf32>, tensor<?x?x?x?xf32>) -> tensor<?x?x?x?xf32>
  return %R : tensor<?x?x?x?xf32>
}
