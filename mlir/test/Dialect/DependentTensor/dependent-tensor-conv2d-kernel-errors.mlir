// RUN: mlir-opt %s -split-input-file -verify-dependent-tensor-semantics -verify-diagnostics

func.func @dependent_conv2d_im2col_kernel(
    %n : index,
    %cin : index,
    %h : index,
    %w : index,
    %cout : index,
    %kh : index,
    %kw : index,
    %oh : index,
    %ow : index,
    %X : tensor<?x?x?x?x?x?xf32>,
    %K : tensor<?x?x?x?xf32>,
    %Yinit : tensor<?x?x?x?xf32>) -> tensor<?x?x?x?xf32>
    #types[
      %X : #tensor<[%n, %cin, %oh, %ow, %kh, %kw], f32>,
      %K : #tensor<[%cout, %cin, %kh, %kw], f32>,
      %Yinit : #tensor<[%n, %cout, %oh, %ow], f32>
    ] -> #tensor<[%n, %cout, %oh, %ow], f32> {
  return %Yinit : tensor<?x?x?x?xf32>
}

func.func @bad_conv_x_batch_dim(
    %n : index,
    %cin : index,
    %p : index,
    %h : index,
    %w : index,
    %cout : index,
    %kh : index,
    %kw : index,
    %oh : index,
    %ow : index) -> tensor<?x?x?x?xf32>
    #types[] -> #tensor<[%n, %cout, %oh, %ow], f32> {
  %X = dependent_tensor.make () #tensor<[%p, %cin, %oh, %ow, %kh, %kw], f32> : tensor<?x?x?x?x?x?xf32>
  %K = dependent_tensor.make () #tensor<[%cout, %cin, %kh, %kw], f32> : tensor<?x?x?x?xf32>
  %Y = dependent_tensor.make () #tensor<[%n, %cout, %oh, %ow], f32> : tensor<?x?x?x?xf32>
  // expected-error@+1 {{operand #9 does not match callee dependency metadata}}
  %R = func.call @dependent_conv2d_im2col_kernel(%n, %cin, %h, %w, %cout, %kh, %kw, %oh, %ow, %X, %K, %Y)
      : (index, index, index, index, index, index, index, index, index, tensor<?x?x?x?x?x?xf32>, tensor<?x?x?x?xf32>, tensor<?x?x?x?xf32>) -> tensor<?x?x?x?xf32>
  return %R : tensor<?x?x?x?xf32>
}

// -----

func.func @dependent_conv2d_im2col_kernel(
    %n : index,
    %cin : index,
    %h : index,
    %w : index,
    %cout : index,
    %kh : index,
    %kw : index,
    %oh : index,
    %ow : index,
    %X : tensor<?x?x?x?x?x?xf32>,
    %K : tensor<?x?x?x?xf32>,
    %Yinit : tensor<?x?x?x?xf32>) -> tensor<?x?x?x?xf32>
    #types[
      %X : #tensor<[%n, %cin, %oh, %ow, %kh, %kw], f32>,
      %K : #tensor<[%cout, %cin, %kh, %kw], f32>,
      %Yinit : #tensor<[%n, %cout, %oh, %ow], f32>
    ] -> #tensor<[%n, %cout, %oh, %ow], f32> {
  return %Yinit : tensor<?x?x?x?xf32>
}

func.func @bad_conv_x_channel_dim(
    %n : index,
    %cin : index,
    %p : index,
    %h : index,
    %w : index,
    %cout : index,
    %kh : index,
    %kw : index,
    %oh : index,
    %ow : index) -> tensor<?x?x?x?xf32>
    #types[] -> #tensor<[%n, %cout, %oh, %ow], f32> {
  %X = dependent_tensor.make () #tensor<[%n, %p, %oh, %ow, %kh, %kw], f32> : tensor<?x?x?x?x?x?xf32>
  %K = dependent_tensor.make () #tensor<[%cout, %cin, %kh, %kw], f32> : tensor<?x?x?x?xf32>
  %Y = dependent_tensor.make () #tensor<[%n, %cout, %oh, %ow], f32> : tensor<?x?x?x?xf32>
  // expected-error@+1 {{operand #9 does not match callee dependency metadata}}
  %R = func.call @dependent_conv2d_im2col_kernel(%n, %cin, %h, %w, %cout, %kh, %kw, %oh, %ow, %X, %K, %Y)
      : (index, index, index, index, index, index, index, index, index, tensor<?x?x?x?x?x?xf32>, tensor<?x?x?x?xf32>, tensor<?x?x?x?xf32>) -> tensor<?x?x?x?xf32>
  return %R : tensor<?x?x?x?xf32>
}

// -----

func.func @dependent_conv2d_im2col_kernel(
    %n : index,
    %cin : index,
    %h : index,
    %w : index,
    %cout : index,
    %kh : index,
    %kw : index,
    %oh : index,
    %ow : index,
    %X : tensor<?x?x?x?x?x?xf32>,
    %K : tensor<?x?x?x?xf32>,
    %Yinit : tensor<?x?x?x?xf32>) -> tensor<?x?x?x?xf32>
    #types[
      %X : #tensor<[%n, %cin, %oh, %ow, %kh, %kw], f32>,
      %K : #tensor<[%cout, %cin, %kh, %kw], f32>,
      %Yinit : #tensor<[%n, %cout, %oh, %ow], f32>
    ] -> #tensor<[%n, %cout, %oh, %ow], f32> {
  return %Yinit : tensor<?x?x?x?xf32>
}

func.func @bad_conv_kernel_output_channel_dim(
    %n : index,
    %cin : index,
    %h : index,
    %w : index,
    %cout : index,
    %p : index,
    %kh : index,
    %kw : index,
    %oh : index,
    %ow : index) -> tensor<?x?x?x?xf32>
    #types[] -> #tensor<[%n, %cout, %oh, %ow], f32> {
  %X = dependent_tensor.make () #tensor<[%n, %cin, %oh, %ow, %kh, %kw], f32> : tensor<?x?x?x?x?x?xf32>
  %K = dependent_tensor.make () #tensor<[%p, %cin, %kh, %kw], f32> : tensor<?x?x?x?xf32>
  %Y = dependent_tensor.make () #tensor<[%n, %cout, %oh, %ow], f32> : tensor<?x?x?x?xf32>
  // expected-error@+1 {{operand #10 does not match callee dependency metadata}}
  %R = func.call @dependent_conv2d_im2col_kernel(%n, %cin, %h, %w, %cout, %kh, %kw, %oh, %ow, %X, %K, %Y)
      : (index, index, index, index, index, index, index, index, index, tensor<?x?x?x?x?x?xf32>, tensor<?x?x?x?xf32>, tensor<?x?x?x?xf32>) -> tensor<?x?x?x?xf32>
  return %R : tensor<?x?x?x?xf32>
}

// -----

func.func @dependent_conv2d_im2col_kernel(
    %n : index,
    %cin : index,
    %h : index,
    %w : index,
    %cout : index,
    %kh : index,
    %kw : index,
    %oh : index,
    %ow : index,
    %X : tensor<?x?x?x?x?x?xf32>,
    %K : tensor<?x?x?x?xf32>,
    %Yinit : tensor<?x?x?x?xf32>) -> tensor<?x?x?x?xf32>
    #types[
      %X : #tensor<[%n, %cin, %oh, %ow, %kh, %kw], f32>,
      %K : #tensor<[%cout, %cin, %kh, %kw], f32>,
      %Yinit : #tensor<[%n, %cout, %oh, %ow], f32>
    ] -> #tensor<[%n, %cout, %oh, %ow], f32> {
  return %Yinit : tensor<?x?x?x?xf32>
}

func.func @bad_conv_kernel_width_dim(
    %n : index,
    %cin : index,
    %h : index,
    %w : index,
    %cout : index,
    %kh : index,
    %kw : index,
    %p : index,
    %oh : index,
    %ow : index) -> tensor<?x?x?x?xf32>
    #types[] -> #tensor<[%n, %cout, %oh, %ow], f32> {
  %X = dependent_tensor.make () #tensor<[%n, %cin, %oh, %ow, %kh, %kw], f32> : tensor<?x?x?x?x?x?xf32>
  %K = dependent_tensor.make () #tensor<[%cout, %cin, %kh, %p], f32> : tensor<?x?x?x?xf32>
  %Y = dependent_tensor.make () #tensor<[%n, %cout, %oh, %ow], f32> : tensor<?x?x?x?xf32>
  // expected-error@+1 {{operand #10 does not match callee dependency metadata}}
  %R = func.call @dependent_conv2d_im2col_kernel(%n, %cin, %h, %w, %cout, %kh, %kw, %oh, %ow, %X, %K, %Y)
      : (index, index, index, index, index, index, index, index, index, tensor<?x?x?x?x?x?xf32>, tensor<?x?x?x?xf32>, tensor<?x?x?x?xf32>) -> tensor<?x?x?x?xf32>
  return %R : tensor<?x?x?x?xf32>
}

// -----

func.func @dependent_conv2d_im2col_kernel(
    %n : index,
    %cin : index,
    %h : index,
    %w : index,
    %cout : index,
    %kh : index,
    %kw : index,
    %oh : index,
    %ow : index,
    %X : tensor<?x?x?x?x?x?xf32>,
    %K : tensor<?x?x?x?xf32>,
    %Yinit : tensor<?x?x?x?xf32>) -> tensor<?x?x?x?xf32>
    #types[
      %X : #tensor<[%n, %cin, %oh, %ow, %kh, %kw], f32>,
      %K : #tensor<[%cout, %cin, %kh, %kw], f32>,
      %Yinit : #tensor<[%n, %cout, %oh, %ow], f32>
    ] -> #tensor<[%n, %cout, %oh, %ow], f32> {
  return %Yinit : tensor<?x?x?x?xf32>
}

func.func @bad_conv_output_spatial_dim(
    %n : index,
    %cin : index,
    %h : index,
    %w : index,
    %cout : index,
    %kh : index,
    %kw : index,
    %oh : index,
    %ow : index,
    %p : index) -> tensor<?x?x?x?xf32>
    #types[] -> #tensor<[%n, %cout, %oh, %ow], f32> {
  %X = dependent_tensor.make () #tensor<[%n, %cin, %oh, %ow, %kh, %kw], f32> : tensor<?x?x?x?x?x?xf32>
  %K = dependent_tensor.make () #tensor<[%cout, %cin, %kh, %kw], f32> : tensor<?x?x?x?xf32>
  %Y = dependent_tensor.make () #tensor<[%n, %cout, %p, %ow], f32> : tensor<?x?x?x?xf32>
  // expected-error@+1 {{operand #11 does not match callee dependency metadata}}
  %R = func.call @dependent_conv2d_im2col_kernel(%n, %cin, %h, %w, %cout, %kh, %kw, %oh, %ow, %X, %K, %Y)
      : (index, index, index, index, index, index, index, index, index, tensor<?x?x?x?x?x?xf32>, tensor<?x?x?x?xf32>, tensor<?x?x?x?xf32>) -> tensor<?x?x?x?xf32>
  return %R : tensor<?x?x?x?xf32>
}

// -----

func.func @dependent_conv2d_im2col_kernel(
    %n : index,
    %cin : index,
    %h : index,
    %w : index,
    %cout : index,
    %kh : index,
    %kw : index,
    %oh : index,
    %ow : index,
    %X : tensor<?x?x?x?x?x?xf32>,
    %K : tensor<?x?x?x?xf32>,
    %Yinit : tensor<?x?x?x?xf32>) -> tensor<?x?x?x?xf32>
    #types[
      %X : #tensor<[%n, %cin, %oh, %ow, %kh, %kw], f32>,
      %K : #tensor<[%cout, %cin, %kh, %kw], f32>,
      %Yinit : #tensor<[%n, %cout, %oh, %ow], f32>
    ] -> #tensor<[%n, %cout, %oh, %ow], f32> {
  return %Yinit : tensor<?x?x?x?xf32>
}

func.func @bad_conv_output_channel_dim(
    %n : index,
    %cin : index,
    %h : index,
    %w : index,
    %cout : index,
    %p : index,
    %kh : index,
    %kw : index,
    %oh : index,
    %ow : index) -> tensor<?x?x?x?xf32>
    #types[] -> #tensor<[%n, %cout, %oh, %ow], f32> {
  %X = dependent_tensor.make () #tensor<[%n, %cin, %oh, %ow, %kh, %kw], f32> : tensor<?x?x?x?x?x?xf32>
  %K = dependent_tensor.make () #tensor<[%cout, %cin, %kh, %kw], f32> : tensor<?x?x?x?xf32>
  %Y = dependent_tensor.make () #tensor<[%n, %p, %oh, %ow], f32> : tensor<?x?x?x?xf32>
  // expected-error@+1 {{operand #11 does not match callee dependency metadata}}
  %R = func.call @dependent_conv2d_im2col_kernel(%n, %cin, %h, %w, %cout, %kh, %kw, %oh, %ow, %X, %K, %Y)
      : (index, index, index, index, index, index, index, index, index, tensor<?x?x?x?x?x?xf32>, tensor<?x?x?x?xf32>, tensor<?x?x?x?xf32>) -> tensor<?x?x?x?xf32>
  return %R : tensor<?x?x?x?xf32>
}

// -----

func.func @bad_conv_insert_semantics(
    %n : index,
    %cin : index,
    %cout : index,
    %kh : index,
    %kw : index,
    %oh : index,
    %ow : index,
    %Yinit : tensor<?x?x?x?xf32>) -> tensor<?x?x?x?xf32>
    #types[%Yinit : #tensor<[%n, %cout, %oh, %ow], f32>] -> #tensor<[%n, %cout, %oh, %ow], f32> {
  %c0 = arith.constant 0 : index
  %v = dependent_tensor.extract %Yinit[%c0, %c0, %c0, %c0] : f32
  // expected-error@+1 {{'dependent_tensor.insert' op stored result semantics must match destination semantics}}
  %bad = dependent_tensor.insert %v into %Yinit[%c0, %c0, %c0, %c0] #tensor<[%n, %cin, %kh, %kw], f32> : f32 into tensor<?x?x?x?xf32>
  return %bad : tensor<?x?x?x?xf32>
}
