// RUN: mlir-opt %s -verify-dependent-tensor-semantics | FileCheck %s

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
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  %Cout = scf.for %i = %c0 to %m step %c1 iter_args(%row = %Cinit) -> (tensor<?x?xf32>) {
    %next = scf.for %j = %c0 to %n step %c1 iter_args(%col = %row) -> (tensor<?x?xf32>) {
      %sum0 = arith.constant 0.000000e+00 : f32
      %sum = scf.for %kk = %c0 to %k step %c1 iter_args(%acc = %sum0) -> (f32) {
        %av = dependent_tensor.extract %A[%i, %kk] : f32
        %bv = dependent_tensor.extract %B[%kk, %j] : f32
        %prod = arith.mulf %av, %bv : f32
        %acc_next = arith.addf %acc, %prod : f32
        scf.yield %acc_next : f32
      }
      %updated = dependent_tensor.insert %sum into %col[%i, %j] #tensor<[%m, %n], f32> : f32 into tensor<?x?xf32>
      scf.yield %updated : tensor<?x?xf32>
    }
    scf.yield %next : tensor<?x?xf32>
  }
  return %Cout : tensor<?x?xf32>
}

// CHECK-LABEL: func.func @matmul_kernel
// CHECK-SAME: (%[[M:arg[0-9]+]]: index, %[[K:arg[0-9]+]]: index, %[[N:arg[0-9]+]]: index
// CHECK-SAME: #types[%{{.*}} : #tensor<[%[[M]], %[[K]]], f32>, %{{.*}} : #tensor<[%[[K]], %[[N]]], f32>, %{{.*}} : #tensor<[%[[M]], %[[N]]], f32>] -> #tensor<[%[[M]], %[[N]]], f32>
// CHECK: scf.for
// CHECK: dependent_tensor.extract
// CHECK: arith.mulf
// CHECK: arith.addf
// CHECK: dependent_tensor.insert
// CHECK-NOT: dependent_tensor.matmul
// CHECK-NOT: dependent_tensor.gemm

// -----

func.func @gemm_kernel(
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
  %c1 = arith.constant 1 : index
  %Cout = scf.for %i = %c0 to %m step %c1 iter_args(%row = %Cinit) -> (tensor<?x?xf32>) {
    %next = scf.for %j = %c0 to %n step %c1 iter_args(%col = %row) -> (tensor<?x?xf32>) {
      %bias = dependent_tensor.extract %col[%i, %j] : f32
      %sum = scf.for %kk = %c0 to %k step %c1 iter_args(%acc = %bias) -> (f32) {
        %av = dependent_tensor.extract %A[%i, %kk] : f32
        %bv = dependent_tensor.extract %B[%kk, %j] : f32
        %prod = arith.mulf %av, %bv : f32
        %acc_next = arith.addf %acc, %prod : f32
        scf.yield %acc_next : f32
      }
      %updated = dependent_tensor.insert %sum into %col[%i, %j] #tensor<[%m, %n], f32> : f32 into tensor<?x?xf32>
      scf.yield %updated : tensor<?x?xf32>
    }
    scf.yield %next : tensor<?x?xf32>
  }
  return %Cout : tensor<?x?xf32>
}

// CHECK-LABEL: func.func @gemm_kernel
// CHECK-SAME: #types[
// CHECK: dependent_tensor.extract
// CHECK: dependent_tensor.insert
// CHECK-NOT: dependent_tensor.matmul
// CHECK-NOT: dependent_tensor.gemm

// -----

func.func @call_matmul_kernel(
    %m : index,
    %k : index,
    %n : index) -> tensor<?x?xf32>
    #types[] -> #tensor<[%m, %n], f32> {
  %A = dependent_tensor.make () #tensor<[%m, %k], f32> : tensor<?x?xf32>
  %B = dependent_tensor.make () #tensor<[%k, %n], f32> : tensor<?x?xf32>
  %C = dependent_tensor.make () #tensor<[%m, %n], f32> : tensor<?x?xf32>
  %R = func.call @matmul_kernel(%m, %k, %n, %A, %B, %C)
      : (index, index, index, tensor<?x?xf32>, tensor<?x?xf32>, tensor<?x?xf32>) -> tensor<?x?xf32>
  return %R : tensor<?x?xf32>
}

// CHECK-LABEL: func.func @call_matmul_kernel
// CHECK-SAME: #types[] -> #tensor<[%{{.*}}, %{{.*}}], f32>
// CHECK: call @matmul_kernel

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
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  %Y0 = scf.for %ni = %c0 to %n step %c1 iter_args(%yn = %Yinit) -> (tensor<?x?x?x?xf32>) {
    %Y1 = scf.for %ohi = %c0 to %oh step %c1 iter_args(%yh = %yn) -> (tensor<?x?x?x?xf32>) {
      %Y2 = scf.for %owi = %c0 to %ow step %c1 iter_args(%yw = %yh) -> (tensor<?x?x?x?xf32>) {
        %Y3 = scf.for %fo = %c0 to %f step %c1 iter_args(%yf = %yw) -> (tensor<?x?x?x?xf32>) {
          %sum0 = dependent_tensor.extract %yf[%ni, %ohi, %owi, %fo] : f32
          %sum_kh = scf.for %khi = %c0 to %kh step %c1 iter_args(%acc_kh = %sum0) -> (f32) {
            %sum_kw = scf.for %kwi = %c0 to %kw step %c1 iter_args(%acc_kw = %acc_kh) -> (f32) {
              %sum_c = scf.for %ci = %c0 to %c step %c1 iter_args(%acc_c = %acc_kw) -> (f32) {
                %xv = dependent_tensor.extract %X[%ni, %ohi, %owi, %ci] : f32
                %kv = dependent_tensor.extract %K[%khi, %kwi, %ci, %fo] : f32
                %prod = arith.mulf %xv, %kv : f32
                %acc_next = arith.addf %acc_c, %prod : f32
                scf.yield %acc_next : f32
              }
              scf.yield %sum_c : f32
            }
            scf.yield %sum_kw : f32
          }
          %updated = dependent_tensor.insert %sum_kh into %yf[%ni, %ohi, %owi, %fo] #tensor<[%n, %oh, %ow, %f], f32> : f32 into tensor<?x?x?x?xf32>
          scf.yield %updated : tensor<?x?x?x?xf32>
        }
        scf.yield %Y3 : tensor<?x?x?x?xf32>
      }
      scf.yield %Y2 : tensor<?x?x?x?xf32>
    }
    scf.yield %Y1 : tensor<?x?x?x?xf32>
  }
  return %Y0 : tensor<?x?x?x?xf32>
}

// CHECK-LABEL: func.func @conv2d_nhwc_hwcf_kernel
// CHECK-SAME: {{#types\[%arg[0-9]+ : #tensor<\[%arg[0-9]+, %arg[0-9]+, %arg[0-9]+, %arg[0-9]+\], f32>, %arg[0-9]+ : #tensor<\[%arg[0-9]+, %arg[0-9]+, %arg[0-9]+, %arg[0-9]+\], f32>, %arg[0-9]+ : #tensor<\[%arg[0-9]+, %arg[0-9]+, %arg[0-9]+, %arg[0-9]+\], f32>\] -> #tensor<\[%arg[0-9]+, %arg[0-9]+, %arg[0-9]+, %arg[0-9]+\], f32>}}
// CHECK: dependent_tensor.extract
// CHECK: arith.mulf
// CHECK: arith.addf
// CHECK: dependent_tensor.insert

// -----

func.func @call_conv2d_nhwc_hwcf_kernel(
    %n : index,
    %h : index,
    %w : index,
    %c : index,
    %kh : index,
    %kw : index,
    %f : index,
    %oh : index,
    %ow : index) -> tensor<?x?x?x?xf32>
    #types[] -> #tensor<[%n, %oh, %ow, %f], f32> {
  %X = dependent_tensor.make () #tensor<[%n, %h, %w, %c], f32> : tensor<?x?x?x?xf32>
  %K = dependent_tensor.make () #tensor<[%kh, %kw, %c, %f], f32> : tensor<?x?x?x?xf32>
  %Y = dependent_tensor.make () #tensor<[%n, %oh, %ow, %f], f32> : tensor<?x?x?x?xf32>
  %R = func.call @conv2d_nhwc_hwcf_kernel(%n, %h, %w, %c, %kh, %kw, %f, %oh, %ow, %X, %K, %Y)
      : (index, index, index, index, index, index, index, index, index, tensor<?x?x?x?xf32>, tensor<?x?x?x?xf32>, tensor<?x?x?x?xf32>) -> tensor<?x?x?x?xf32>
  return %R : tensor<?x?x?x?xf32>
}

// CHECK-LABEL: func.func @call_conv2d_nhwc_hwcf_kernel
// CHECK-SAME: #types[] -> #tensor<[%{{.*}}, %{{.*}}, %{{.*}}, %{{.*}}], f32>
// CHECK: call @conv2d_nhwc_hwcf_kernel
