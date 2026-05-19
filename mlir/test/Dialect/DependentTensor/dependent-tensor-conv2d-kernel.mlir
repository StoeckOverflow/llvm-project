// RUN: mlir-opt %s -verify-dependent-tensor-semantics | FileCheck %s

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
  %Y0 = scf.for %n_idx = %c0 to %n step %c1 iter_args(%yn = %Yinit) -> (tensor<?x?x?x?xf32>) {
    %Y1 = scf.for %co = %c0 to %cout step %c1 iter_args(%yc = %yn) -> (tensor<?x?x?x?xf32>) {
      %Y2 = scf.for %oh_idx = %c0 to %oh step %c1 iter_args(%yh = %yc) -> (tensor<?x?x?x?xf32>) {
        %Y3 = scf.for %ow_idx = %c0 to %ow step %c1 iter_args(%yw = %yh) -> (tensor<?x?x?x?xf32>) {
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

// CHECK-LABEL: func.func @dependent_conv2d_im2col_kernel
// CHECK-SAME: (%[[N:arg[0-9]+]]: index, %[[CIN:arg[0-9]+]]: index, %[[H:arg[0-9]+]]: index, %[[W:arg[0-9]+]]: index, %[[COUT:arg[0-9]+]]: index, %[[KH:arg[0-9]+]]: index, %[[KW:arg[0-9]+]]: index, %[[OH:arg[0-9]+]]: index, %[[OW:arg[0-9]+]]: index,
// CHECK-SAME:  %[[X:arg[0-9]+]]: tensor<?x?x?x?x?x?xf32>, %[[K:arg[0-9]+]]: tensor<?x?x?x?xf32>, %[[YINIT:arg[0-9]+]]: tensor<?x?x?x?xf32>) -> tensor<?x?x?x?xf32>
// CHECK-SAME: #types[%[[X]] : #tensor<[%[[N]], %[[CIN]], %[[OH]], %[[OW]], %[[KH]], %[[KW]]], f32>, %[[K]] : #tensor<[%[[COUT]], %[[CIN]], %[[KH]], %[[KW]]], f32>, %[[YINIT]] : #tensor<[%[[N]], %[[COUT]], %[[OH]], %[[OW]]], f32>] -> #tensor<[%[[N]], %[[COUT]], %[[OH]], %[[OW]]], f32>
// CHECK-DAG: %[[C0:.*]] = arith.constant 0 : index
// CHECK-DAG: %[[C1:.*]] = arith.constant 1 : index
// CHECK: %[[Y0:.*]] = scf.for %[[NI:.*]] = %[[C0]] to %[[N]] step %[[C1]] iter_args(%[[YN:.*]] = %[[YINIT]]) -> (tensor<?x?x?x?xf32>) {
// CHECK:   %[[Y1:.*]] = scf.for %[[CO:.*]] = %[[C0]] to %[[COUT]] step %[[C1]] iter_args(%[[YC:.*]] = %[[YN]]) -> (tensor<?x?x?x?xf32>) {
// CHECK:     %[[Y2:.*]] = scf.for %[[OHI:.*]] = %[[C0]] to %[[OH]] step %[[C1]] iter_args(%[[YH:.*]] = %[[YC]]) -> (tensor<?x?x?x?xf32>) {
// CHECK:       %[[Y3:.*]] = scf.for %[[OWI:.*]] = %[[C0]] to %[[OW]] step %[[C1]] iter_args(%[[YW:.*]] = %[[YH]]) -> (tensor<?x?x?x?xf32>) {
// CHECK:         %[[SUM0:.*]] = dependent_tensor.extract %[[YW]][%[[NI]], %[[CO]], %[[OHI]], %[[OWI]]] #tensor<[%[[N]], %[[COUT]], %[[OH]], %[[OW]]], f32> : f32
// CHECK:         %[[SUM_CI:.*]] = scf.for %[[CI:.*]] = %[[C0]] to %[[CIN]] step %[[C1]] iter_args(%[[ACC_CI:.*]] = %[[SUM0]]) -> (f32) {
// CHECK:           %[[SUM_KH:.*]] = scf.for %[[KHI:.*]] = %[[C0]] to %[[KH]] step %[[C1]] iter_args(%[[ACC_KH:.*]] = %[[ACC_CI]]) -> (f32) {
// CHECK:             %[[SUM_KW:.*]] = scf.for %[[KWI:.*]] = %[[C0]] to %[[KW]] step %[[C1]] iter_args(%[[ACC_KW:.*]] = %[[ACC_KH]]) -> (f32) {
// CHECK:               %[[XV:.*]] = dependent_tensor.extract %[[X]][%[[NI]], %[[CI]], %[[OHI]], %[[OWI]], %[[KHI]], %[[KWI]]] #tensor<[%[[N]], %[[CIN]], %[[OH]], %[[OW]], %[[KH]], %[[KW]]], f32> : f32
// CHECK:               %[[KV:.*]] = dependent_tensor.extract %[[K]][%[[CO]], %[[CI]], %[[KHI]], %[[KWI]]] #tensor<[%[[COUT]], %[[CIN]], %[[KH]], %[[KW]]], f32> : f32
// CHECK:               %[[PROD:.*]] = arith.mulf %[[XV]], %[[KV]] : f32
// CHECK:               %[[NEXT:.*]] = arith.addf %[[ACC_KW]], %[[PROD]] : f32
// CHECK:               scf.yield %[[NEXT]] : f32
// CHECK:             }
// CHECK:             scf.yield %[[SUM_KW]] : f32
// CHECK:           }
// CHECK:           scf.yield %[[SUM_KH]] : f32
// CHECK:         }
// CHECK:         %[[UPDATED:.*]] = dependent_tensor.insert %[[SUM_CI]] into %[[YW]][%[[NI]], %[[CO]], %[[OHI]], %[[OWI]]] #tensor<[%[[N]], %[[COUT]], %[[OH]], %[[OW]]], f32> : f32 into tensor<?x?x?x?xf32>
// CHECK:         scf.yield %[[UPDATED]] : tensor<?x?x?x?xf32>
// CHECK:       }
// CHECK:       scf.yield %[[Y3]] : tensor<?x?x?x?xf32>
// CHECK:     }
// CHECK:     scf.yield %[[Y2]] : tensor<?x?x?x?xf32>
// CHECK:   }
// CHECK:   scf.yield %[[Y1]] : tensor<?x?x?x?xf32>
// CHECK: }
// CHECK: return %[[Y0]] : tensor<?x?x?x?xf32>
// CHECK-NOT: dependent_tensor.conv
// CHECK-NOT: dependent_tensor.conv2d

// -----

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

// CHECK-LABEL: func.func @call_dependent_conv2d_im2col_kernel
// CHECK-SAME: (%[[CN:arg[0-9]+]]: index, %[[CCIN:arg[0-9]+]]: index, %[[CH:arg[0-9]+]]: index, %[[CW:arg[0-9]+]]: index, %[[CCOUT:arg[0-9]+]]: index, %[[CKH:arg[0-9]+]]: index, %[[CKW:arg[0-9]+]]: index, %[[COH:arg[0-9]+]]: index, %[[COW:arg[0-9]+]]: index) -> tensor<?x?x?x?xf32>
// CHECK-SAME: #types[] -> #tensor<[%[[CN]], %[[CCOUT]], %[[COH]], %[[COW]]], f32>
// CHECK-NEXT: %[[CX:.*]] = dependent_tensor.make () #tensor<[%[[CN]], %[[CCIN]], %[[COH]], %[[COW]], %[[CKH]], %[[CKW]]], f32> : tensor<?x?x?x?x?x?xf32>
// CHECK-NEXT: %[[CK:.*]] = dependent_tensor.make () #tensor<[%[[CCOUT]], %[[CCIN]], %[[CKH]], %[[CKW]]], f32> : tensor<?x?x?x?xf32>
// CHECK-NEXT: %[[CY:.*]] = dependent_tensor.make () #tensor<[%[[CN]], %[[CCOUT]], %[[COH]], %[[COW]]], f32> : tensor<?x?x?x?xf32>
// CHECK-NEXT: %[[CR:.*]] = call @dependent_conv2d_im2col_kernel(%[[CN]], %[[CCIN]], %[[CH]], %[[CW]], %[[CCOUT]], %[[CKH]], %[[CKW]], %[[COH]], %[[COW]], %[[CX]], %[[CK]], %[[CY]]) : (index, index, index, index, index, index, index, index, index, tensor<?x?x?x?x?x?xf32>, tensor<?x?x?x?xf32>, tensor<?x?x?x?xf32>) -> tensor<?x?x?x?xf32>
// CHECK-NEXT: return %[[CR]] : tensor<?x?x?x?xf32>
