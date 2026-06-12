// RUN: mlir-opt %s -split-input-file -verify-dependent-tensor-semantics -verify-diagnostics | FileCheck %s

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
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  %Y0 = scf.for %n_idx = %c0 to %n step %c1 iter_args(%yn = %Yinit)
      -> (tensor<?x?x?x?xf32>)
      #types[%yn : #tensor<[%n, %cout, %oh, %ow], f32>] -> #tensor<[%n, %cout, %oh, %ow], f32> {
    %Y1 = scf.for %co = %c0 to %cout step %c1 iter_args(%yc = %yn)
        -> (tensor<?x?x?x?xf32>)
        #types[%yc : #tensor<[%n, %cout, %oh, %ow], f32>] -> #tensor<[%n, %cout, %oh, %ow], f32> {
      %Y2 = scf.for %oh_idx = %c0 to %oh step %c1 iter_args(%yh = %yc)
          -> (tensor<?x?x?x?xf32>)
          #types[%yh : #tensor<[%n, %cout, %oh, %ow], f32>] -> #tensor<[%n, %cout, %oh, %ow], f32> {
        %Y3 = scf.for %ow_idx = %c0 to %ow step %c1 iter_args(%yw = %yh)
            -> (tensor<?x?x?x?xf32>)
            #types[%yw : #tensor<[%n, %cout, %oh, %ow], f32>] -> #tensor<[%n, %cout, %oh, %ow], f32> {
          %sum0 = dependent_tensor.extract %yw[%n_idx, %co, %oh_idx, %ow_idx] : f32
          %sum_ci = scf.for %ci = %c0 to %cin step %c1 iter_args(%acc_ci = %sum0) -> (f32) {
            %sum_kh = scf.for %kh_idx = %c0 to %kh step %c1 iter_args(%acc_kh = %acc_ci) -> (f32) {
              %sum_kw = scf.for %kw_idx = %c0 to %kw step %c1 iter_args(%acc_kw = %acc_kh) -> (f32) {
                %x = dependent_tensor.extract %X[%n_idx, %ci, %oh_idx, %ow_idx, %kh_idx, %kw_idx] : f32
                %k = dependent_tensor.extract %K[%co, %ci, %kh_idx, %kw_idx] : f32
                %mul = arith.mulf %x, %k : f32
                %next = arith.addf %acc_kw, %mul : f32
                scf.yield %next : f32
              }
              scf.yield %sum_kw : f32
            }
            scf.yield %sum_kh : f32
          }
          %updated = dependent_tensor.insert %sum_ci into %yw[%n_idx, %co, %oh_idx, %ow_idx] #tensor<[%n, %cout, %oh, %ow], f32> : f32 into tensor<?x?x?x?xf32>
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

func.func @call_dependent_conv2d_im2col_kernel(
    %n : index,
    %cin : index,
    %h : index,
    %w : index,
    %cout : index,
    %kh : index,
    %kw : index,
    %oh : index,
    %ow : index) -> tensor<?x?x?x?xf32>
    #types[] -> #tensor<[%n, %cout, %oh, %ow], f32> {
  %X = dependent_tensor.make () #tensor<[%n, %cin, %oh, %ow, %kh, %kw], f32> : tensor<?x?x?x?x?x?xf32>
  %K = dependent_tensor.make () #tensor<[%cout, %cin, %kh, %kw], f32> : tensor<?x?x?x?xf32>
  %Y = dependent_tensor.make () #tensor<[%n, %cout, %oh, %ow], f32> : tensor<?x?x?x?xf32>
  %R = func.call @dependent_conv2d_im2col_kernel(%n, %cin, %h, %w, %cout, %kh, %kw, %oh, %ow, %X, %K, %Y)
      : (index, index, index, index, index, index, index, index, index, tensor<?x?x?x?x?x?xf32>, tensor<?x?x?x?xf32>, tensor<?x?x?x?xf32>) -> tensor<?x?x?x?xf32>
  return %R : tensor<?x?x?x?xf32>
}

// CHECK-LABEL: func.func @dependent_conv2d_im2col_kernel
// CHECK-SAME: (%[[N:arg[0-9]+]]: index, %[[CIN:arg[0-9]+]]: index, %{{.*}}: index, %{{.*}}: index, %[[COUT:arg[0-9]+]]: index, %[[KH:arg[0-9]+]]: index, %[[KW:arg[0-9]+]]: index, %[[OH:arg[0-9]+]]: index, %[[OW:arg[0-9]+]]: index,
// CHECK-SAME:  %[[X:arg[0-9]+]]: tensor<?x?x?x?x?x?xf32>, %[[K:arg[0-9]+]]: tensor<?x?x?x?xf32>, %[[YINIT:arg[0-9]+]]: tensor<?x?x?x?xf32>) -> tensor<?x?x?x?xf32>
// CHECK-SAME: #types[%[[X]] : #tensor<[%[[N]], %[[CIN]], %[[OH]], %[[OW]], %[[KH]], %[[KW]]], f32>, %[[K]] : #tensor<[%[[COUT]], %[[CIN]], %[[KH]], %[[KW]]], f32>, %[[YINIT]] : #tensor<[%[[N]], %[[COUT]], %[[OH]], %[[OW]]], f32>] -> #tensor<[%[[N]], %[[COUT]], %[[OH]], %[[OW]]], f32>
// CHECK: scf.for %{{.*}} iter_args(%[[YN:.*]] = %[[YINIT]]) -> (tensor<?x?x?x?xf32>) #types[%[[YN]] : #tensor<[%[[N]], %[[COUT]], %[[OH]], %[[OW]]], f32>] -> #tensor<[%[[N]], %[[COUT]], %[[OH]], %[[OW]]], f32>
// CHECK: dependent_tensor.extract %{{.*}}[%{{.*}}, %{{.*}}, %{{.*}}, %{{.*}}] : f32
// CHECK: dependent_tensor.extract %[[X]][%{{.*}}, %{{.*}}, %{{.*}}, %{{.*}}, %{{.*}}, %{{.*}}] : f32
// CHECK: dependent_tensor.extract %[[K]][%{{.*}}, %{{.*}}, %{{.*}}, %{{.*}}] : f32
// CHECK: dependent_tensor.insert %{{.*}} into %{{.*}}[%{{.*}}, %{{.*}}, %{{.*}}, %{{.*}}] #tensor<[%[[N]], %[[COUT]], %[[OH]], %[[OW]]], f32> : f32 into tensor<?x?x?x?xf32>
// CHECK: return %{{.*}} : tensor<?x?x?x?xf32>
// CHECK-LABEL: func.func @call_dependent_conv2d_im2col_kernel
// CHECK-SAME: #types[] -> #tensor<[%{{.*}}, %{{.*}}, %{{.*}}, %{{.*}}], f32>
// CHECK: call @dependent_conv2d_im2col_kernel
// CHECK-NEXT: return

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

func.func @bad_call_dependent_conv2d_im2col_kernel(
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
  %X = dependent_tensor.make () #tensor<[%n, %p, %oh, %ow, %kh, %kw], f32> : tensor<?x?x?x?x?x?xf32>
  %K = dependent_tensor.make () #tensor<[%cout, %cin, %kh, %kw], f32> : tensor<?x?x?x?xf32>
  %Y = dependent_tensor.make () #tensor<[%n, %cout, %oh, %ow], f32> : tensor<?x?x?x?xf32>
  // expected-error@+1 {{operand #9 does not match callee dependency metadata}}
  %R = func.call @dependent_conv2d_im2col_kernel(%n, %cin, %h, %w, %cout, %kh, %kw, %oh, %ow, %X, %K, %Y)
      : (index, index, index, index, index, index, index, index, index, tensor<?x?x?x?x?x?xf32>, tensor<?x?x?x?xf32>, tensor<?x?x?x?xf32>) -> tensor<?x?x?x?xf32>
  return %R : tensor<?x?x?x?xf32>
}
