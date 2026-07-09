// RUN: mlir-opt %s -split-input-file -verify-dependent-tensor-refinements -verify-diagnostics | FileCheck %s

func.func @dependent_conv2d_signature(
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
    %Y : tensor<?x?x?x?xf32>) -> ()
    #types[
      %X : #tensor<[%n, %cin, %oh, %ow, %kh, %kw], f32>,
      %K : #tensor<[%cout, %cin, %kh, %kw], f32>,
      %Y : #tensor<[%n, %cout, %oh, %ow], f32>
    ] -> () {
  return
}

func.func @call_dependent_conv2d_signature(
    %n : index,
    %cin : index,
    %h : index,
    %w : index,
    %cout : index,
    %kh : index,
    %kw : index,
    %oh : index,
    %ow : index) -> () {
  %X = dependent_tensor.make () #tensor<[%n, %cin, %oh, %ow, %kh, %kw], f32> : tensor<?x?x?x?x?x?xf32>
  %K = dependent_tensor.make () #tensor<[%cout, %cin, %kh, %kw], f32> : tensor<?x?x?x?xf32>
  %Y = dependent_tensor.make () #tensor<[%n, %cout, %oh, %ow], f32> : tensor<?x?x?x?xf32>
  func.call @dependent_conv2d_signature(%n, %cin, %h, %w, %cout, %kh, %kw, %oh, %ow, %X, %K, %Y)
      : (index, index, index, index, index, index, index, index, index, tensor<?x?x?x?x?x?xf32>, tensor<?x?x?x?xf32>, tensor<?x?x?x?xf32>) -> ()
  return
}

// CHECK-LABEL: func.func @dependent_conv2d_signature
// CHECK-SAME: (%[[N:arg[0-9]+]]: index, %[[CIN:arg[0-9]+]]: index, %{{.*}}: index, %{{.*}}: index, %[[COUT:arg[0-9]+]]: index, %[[KH:arg[0-9]+]]: index, %[[KW:arg[0-9]+]]: index, %[[OH:arg[0-9]+]]: index, %[[OW:arg[0-9]+]]: index,
// CHECK-SAME:  %[[X:arg[0-9]+]]: tensor<?x?x?x?x?x?xf32>, %[[K:arg[0-9]+]]: tensor<?x?x?x?xf32>, %[[Y:arg[0-9]+]]: tensor<?x?x?x?xf32>) #types
// CHECK-SAME: [%[[X]] : #tensor<[%[[N]], %[[CIN]], %[[OH]], %[[OW]], %[[KH]], %[[KW]]], f32>, %[[K]] : #tensor<[%[[COUT]], %[[CIN]], %[[KH]], %[[KW]]], f32>, %[[Y]] : #tensor<[%[[N]], %[[COUT]], %[[OH]], %[[OW]]], f32>] -> ()
// CHECK-NEXT: return
// CHECK-LABEL: func.func @call_dependent_conv2d_signature
// CHECK: call @dependent_conv2d_signature
// CHECK-NEXT: return

// -----

func.func @dependent_conv2d_signature(
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
    %Y : tensor<?x?x?x?xf32>) -> ()
    #types[
      %X : #tensor<[%n, %cin, %oh, %ow, %kh, %kw], f32>,
      %K : #tensor<[%cout, %cin, %kh, %kw], f32>,
      %Y : #tensor<[%n, %cout, %oh, %ow], f32>
    ] -> () {
  return
}

func.func @bad_call_dependent_conv2d_signature(
    %n : index,
    %cin : index,
    %h : index,
    %w : index,
    %cout : index,
    %kh : index,
    %kw : index,
    %oh : index,
    %ow : index,
    %p : index) -> () {
  %X = dependent_tensor.make () #tensor<[%n, %p, %oh, %ow, %kh, %kw], f32> : tensor<?x?x?x?x?x?xf32>
  %K = dependent_tensor.make () #tensor<[%cout, %cin, %kh, %kw], f32> : tensor<?x?x?x?xf32>
  %Y = dependent_tensor.make () #tensor<[%n, %cout, %oh, %ow], f32> : tensor<?x?x?x?xf32>
  // expected-error@+1 {{operand #9 does not match callee dependency metadata}}
  func.call @dependent_conv2d_signature(%n, %cin, %h, %w, %cout, %kh, %kw, %oh, %ow, %X, %K, %Y)
      : (index, index, index, index, index, index, index, index, index, tensor<?x?x?x?x?x?xf32>, tensor<?x?x?x?xf32>, tensor<?x?x?x?xf32>) -> ()
  return
}
