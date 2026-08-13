// RUN: mlir-opt %s -split-input-file -verify-dependent-tensor-refinements -verify-diagnostics | FileCheck %s

func.func @dependent_conv2d_kernel(
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
    %Y : tensor<?x?x?x?xf32>) -> tensor<?x?x?x?xf32>
    #types[
      %X : #tensor<[%n, %cin, %oh, %ow, %kh, %kw], f32>,
      %K : #tensor<[%cout, %cin, %kh, %kw], f32>,
      %Y : #tensor<[%n, %cout, %oh, %ow], f32>
    ] -> #tensor<[%n, %cout, %oh, %ow], f32> {
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  %Y_final = scf.for %n_idx = %c0 to %n step %c1 iter_args(%Yn = %Y)
      -> (tensor<?x?x?x?xf32>)
      #types[%Yn : #tensor<[%n, %cout, %oh, %ow], f32>] -> #tensor<[%n, %cout, %oh, %ow], f32>
 {
    %Y_co = scf.for %co = %c0 to %cout step %c1 iter_args(%Yco = %Yn)
        -> (tensor<?x?x?x?xf32>)
        #types[%Yco : #tensor<[%n, %cout, %oh, %ow], f32>] -> #tensor<[%n, %cout, %oh, %ow], f32>
 {
      %Y_oh = scf.for %oh_idx = %c0 to %oh step %c1 iter_args(%Yoh = %Yco)
          -> (tensor<?x?x?x?xf32>)
          #types[%Yoh : #tensor<[%n, %cout, %oh, %ow], f32>] -> #tensor<[%n, %cout, %oh, %ow], f32>
 {
        %Y_ow = scf.for %ow_idx = %c0 to %ow step %c1 iter_args(%Yow = %Yoh)
            -> (tensor<?x?x?x?xf32>)
            #types[%Yow : #tensor<[%n, %cout, %oh, %ow], f32>] -> #tensor<[%n, %cout, %oh, %ow], f32>
 {
          %x = dependent_tensor.extract %X[%n_idx, %c0, %oh_idx, %ow_idx, %c0, %c0] : f32
          %k = dependent_tensor.extract %K[%co, %c0, %c0, %c0] : f32
          %value = arith.mulf %x, %k : f32
          %updated = dependent_tensor.insert %value into %Yow[%n_idx, %co, %oh_idx, %ow_idx] #tensor<[%n, %cout, %oh, %ow], f32> : f32 into tensor<?x?x?x?xf32>
          scf.yield %updated : tensor<?x?x?x?xf32>
        }
        scf.yield %Y_ow : tensor<?x?x?x?xf32>
      }
      scf.yield %Y_oh : tensor<?x?x?x?xf32>
    }
    scf.yield %Y_co : tensor<?x?x?x?xf32>
  }
  return %Y_final : tensor<?x?x?x?xf32>
}

// CHECK-LABEL: func.func @dependent_conv2d_kernel
// CHECK-SAME: (%[[N:arg[0-9]+]]: index, %[[CIN:arg[0-9]+]]: index, %{{.*}}: index, %{{.*}}: index, %[[COUT:arg[0-9]+]]: index, %[[KH:arg[0-9]+]]: index, %[[KW:arg[0-9]+]]: index, %[[OH:arg[0-9]+]]: index, %[[OW:arg[0-9]+]]: index,
// CHECK-SAME:  %[[X:arg[0-9]+]]: tensor<?x?x?x?x?x?xf32>, %[[K:arg[0-9]+]]: tensor<?x?x?x?xf32>, %[[Y:arg[0-9]+]]: tensor<?x?x?x?xf32>) -> tensor<?x?x?x?xf32>
// CHECK-SAME: #types[%[[X]] : #tensor<[%[[N]], %[[CIN]], %[[OH]], %[[OW]], %[[KH]], %[[KW]]], f32>, %[[K]] : #tensor<[%[[COUT]], %[[CIN]], %[[KH]], %[[KW]]], f32>, %[[Y]] : #tensor<[%[[N]], %[[COUT]], %[[OH]], %[[OW]]], f32>] -> #tensor<[%[[N]], %[[COUT]], %[[OH]], %[[OW]]], f32>
// CHECK: %[[Y_FINAL:.*]] = scf.for %[[N_IDX:.*]] = %{{.*}} to %[[N]] step %{{.*}} iter_args(%[[YN:.*]] = %[[Y]]) -> (tensor<?x?x?x?xf32>) #types[%[[YN]] : #tensor<[%[[N]], %[[COUT]], %[[OH]], %[[OW]]], f32>] -> #tensor<[%[[N]], %[[COUT]], %[[OH]], %[[OW]]], f32> {
// CHECK:   %[[Y_CO:.*]] = scf.for %[[CO:.*]] = %{{.*}} to %[[COUT]] step %{{.*}} iter_args(%[[YCO:.*]] = %[[YN]]) -> (tensor<?x?x?x?xf32>) #types[%[[YCO]] : #tensor<[%[[N]], %[[COUT]], %[[OH]], %[[OW]]], f32>] -> #tensor<[%[[N]], %[[COUT]], %[[OH]], %[[OW]]], f32> {
// CHECK:     %[[Y_OH:.*]] = scf.for %[[OH_IDX:.*]] = %{{.*}} to %[[OH]] step %{{.*}} iter_args(%[[YOH:.*]] = %[[YCO]]) -> (tensor<?x?x?x?xf32>) #types[%[[YOH]] : #tensor<[%[[N]], %[[COUT]], %[[OH]], %[[OW]]], f32>] -> #tensor<[%[[N]], %[[COUT]], %[[OH]], %[[OW]]], f32> {
// CHECK:       %[[Y_OW:.*]] = scf.for %[[OW_IDX:.*]] = %{{.*}} to %[[OW]] step %{{.*}} iter_args(%[[YOW:.*]] = %[[YOH]]) -> (tensor<?x?x?x?xf32>) #types[%[[YOW]] : #tensor<[%[[N]], %[[COUT]], %[[OH]], %[[OW]]], f32>] -> #tensor<[%[[N]], %[[COUT]], %[[OH]], %[[OW]]], f32> {
// CHECK:         %[[XV:.*]] = dependent_tensor.extract %[[X]][%[[N_IDX]], %{{.*}}, %[[OH_IDX]], %[[OW_IDX]], %{{.*}}, %{{.*}}] : f32
// CHECK:         %[[KV:.*]] = dependent_tensor.extract %[[K]][%[[CO]], %{{.*}}, %{{.*}}, %{{.*}}] : f32
// CHECK:         %[[UPDATED:.*]] = dependent_tensor.insert %{{.*}} into %[[YOW]][%[[N_IDX]], %[[CO]], %[[OH_IDX]], %[[OW_IDX]]] #tensor<[%[[N]], %[[COUT]], %[[OH]], %[[OW]]], f32> : f32 into tensor<?x?x?x?xf32>
// CHECK:         scf.yield %[[UPDATED]] : tensor<?x?x?x?xf32>
// CHECK:       }
// CHECK:       scf.yield %[[Y_OW]] : tensor<?x?x?x?xf32>
// CHECK:     }
// CHECK:     scf.yield %[[Y_OH]] : tensor<?x?x?x?xf32>
// CHECK:   }
// CHECK:   scf.yield %[[Y_CO]] : tensor<?x?x?x?xf32>
// CHECK: }
// CHECK: return %[[Y_FINAL]] : tensor<?x?x?x?xf32>

// -----

func.func @dependent_conv2d_kernel_inner_yield_mismatch(
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
    %Y : tensor<?x?x?x?xf32>) -> tensor<?x?x?x?xf32>
    #types[%X : #tensor<[%n, %cin, %oh, %ow, %kh, %kw], f32>, %K : #tensor<[%cout, %cin, %kh, %kw], f32>, %Y : #tensor<[%n, %cout, %oh, %ow], f32>] -> #tensor<[%n, %cout, %oh, %ow], f32> {
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  %Y_final = scf.for %n_idx = %c0 to %n step %c1 iter_args(%Yn = %Y)
      -> (tensor<?x?x?x?xf32>)
      #types[%Yn : #tensor<[%n, %cout, %oh, %ow], f32>] -> #tensor<[%n, %cout, %oh, %ow], f32>
 {
    // expected-error@+1 {{'scf.for' op loop result type reference does not match yielded refinements}}
    %Y_ow = scf.for %ow_idx = %c0 to %ow step %c1 iter_args(%Yow = %Yn)
        -> (tensor<?x?x?x?xf32>)
        #types[%Yow : #tensor<[%n, %cout, %oh, %ow], f32>] -> #tensor<[%n, %cout, %oh, %ow], f32>
 {
      %bad = dependent_tensor.make () #tensor<[%n, %cout, %ow, %oh], f32> : tensor<?x?x?x?xf32>
      scf.yield %bad : tensor<?x?x?x?xf32>
    }
    scf.yield %Y_ow : tensor<?x?x?x?xf32>
  }
  return %Y_final : tensor<?x?x?x?xf32>
}

// -----

func.func @dependent_conv2d_kernel_outer_yield_mismatch(
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
    %Y : tensor<?x?x?x?xf32>) -> tensor<?x?x?x?xf32>
    #types[%X : #tensor<[%n, %cin, %oh, %ow, %kh, %kw], f32>, %K : #tensor<[%cout, %cin, %kh, %kw], f32>, %Y : #tensor<[%n, %cout, %oh, %ow], f32>] -> #tensor<[%n, %cout, %oh, %ow], f32> {
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  // expected-error@+1 {{'scf.for' op loop result type reference does not match yielded refinements}}
  %Y_final = scf.for %n_idx = %c0 to %n step %c1 iter_args(%Yn = %Y)
      -> (tensor<?x?x?x?xf32>)
      #types[%Yn : #tensor<[%n, %cout, %oh, %ow], f32>] -> #tensor<[%n, %cout, %oh, %ow], f32>
 {
    %bad = dependent_tensor.make () #tensor<[%n, %cout, %ow, %oh], f32> : tensor<?x?x?x?xf32>
    scf.yield %bad : tensor<?x?x?x?xf32>
  }
  return %Y_final : tensor<?x?x?x?xf32>
}

// -----

func.func @dependent_conv2d_kernel_return_mismatch(
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
    %Y : tensor<?x?x?x?xf32>) -> tensor<?x?x?x?xf32>
    #types[%X : #tensor<[%n, %cin, %oh, %ow, %kh, %kw], f32>, %K : #tensor<[%cout, %cin, %kh, %kw], f32>, %Y : #tensor<[%n, %cout, %oh, %ow], f32>] -> #tensor<[%n, %cout, %oh, %ow], f32> {
  %bad = dependent_tensor.make () #tensor<[%n, %cout, %ow, %oh], f32> : tensor<?x?x?x?xf32>
  // expected-error@+1 {{'func.return' op returned value does not match function result dependency metadata}}
  return %bad : tensor<?x?x?x?xf32>
}

// -----

func.func @dependent_conv2d_kernel_loop_result_metadata_mismatch(
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
    %Y : tensor<?x?x?x?xf32>) -> tensor<?x?x?x?xf32>
    #types[%X : #tensor<[%n, %cin, %oh, %ow, %kh, %kw], f32>, %K : #tensor<[%cout, %cin, %kh, %kw], f32>, %Y : #tensor<[%n, %cout, %oh, %ow], f32>] -> #tensor<[%n, %cout, %oh, %ow], f32> {
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  %Y_final = scf.for %n_idx = %c0 to %n step %c1 iter_args(%Yn = %Y)
      -> (tensor<?x?x?x?xf32>)
      #types[%Yn : #tensor<[%n, %cout, %oh, %ow], f32>] -> #tensor<[%n, %cout, %ow, %oh], f32>
 {
    scf.yield %Yn : tensor<?x?x?x?xf32>
  }
  // expected-error@+1 {{'func.return' op returned value does not match function result dependency metadata}}
  return %Y_final : tensor<?x?x?x?xf32>
}
