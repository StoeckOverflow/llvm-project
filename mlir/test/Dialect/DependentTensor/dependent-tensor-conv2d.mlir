// RUN: mlir-opt %s | FileCheck %s
// RUN: mlir-opt %s -verify-dependent-tensor-semantics

func.func @conv2d_nhwc_hwcf_written_with_primitives(
    %n : index, %h : index, %w : index, %c : index,
    %kh : index, %kw : index, %f : index, %oh : index, %ow : index) {
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  %input = dependent_tensor.make () #tensor<[%n, %h, %w, %c], f32> : tensor<?x?x?x?xf32>
  %filter = dependent_tensor.make () #tensor<[%kh, %kw, %c, %f], f32> : tensor<?x?x?x?xf32>
  %init = dependent_tensor.make () #tensor<[%n, %oh, %ow, %f], f32> : tensor<?x?x?x?xf32>
  %out_n = scf.for %ni = %c0 to %n step %c1 iter_args(%out0 = %init) -> (tensor<?x?x?x?xf32>) {
    %out_oh = scf.for %ohi = %c0 to %oh step %c1 iter_args(%out1 = %out0) -> (tensor<?x?x?x?xf32>) {
      %out_ow = scf.for %owi = %c0 to %ow step %c1 iter_args(%out2 = %out1) -> (tensor<?x?x?x?xf32>) {
        %out_f = scf.for %fi = %c0 to %f step %c1 iter_args(%out3 = %out2) -> (tensor<?x?x?x?xf32>) {
          %sum0 = dependent_tensor.extract %out3[%ni, %ohi, %owi, %fi] : f32
          %sum_kh = scf.for %khi = %c0 to %kh step %c1 iter_args(%acc0 = %sum0) -> (f32) {
            %sum_kw = scf.for %kwi = %c0 to %kw step %c1 iter_args(%acc1 = %acc0) -> (f32) {
              %sum_c = scf.for %ci = %c0 to %c step %c1 iter_args(%acc2 = %acc1) -> (f32) {
                %iv = dependent_tensor.extract %input[%ni, %ohi, %owi, %ci] : f32
                %fv = dependent_tensor.extract %filter[%khi, %kwi, %ci, %fi] : f32
                %prod = arith.mulf %iv, %fv : f32
                %next = arith.addf %acc2, %prod : f32
                scf.yield %next : f32
              }
              scf.yield %sum_c : f32
            }
            scf.yield %sum_kw : f32
          }
          %updated = dependent_tensor.insert %sum_kh into %out3[%ni, %ohi, %owi, %fi] #tensor<[%n, %oh, %ow, %f], f32> : f32 into tensor<?x?x?x?xf32>
          scf.yield %updated : tensor<?x?x?x?xf32>
        }
        scf.yield %out_f : tensor<?x?x?x?xf32>
      }
      scf.yield %out_ow : tensor<?x?x?x?xf32>
    }
    scf.yield %out_oh : tensor<?x?x?x?xf32>
  }
  return
}

// CHECK-LABEL: func.func @conv2d_nhwc_hwcf_written_with_primitives
// CHECK-SAME: (%[[N:arg[0-9]+]]: index, %[[H:arg[0-9]+]]: index, %[[W:arg[0-9]+]]: index, %[[C:arg[0-9]+]]: index, %[[KH:arg[0-9]+]]: index, %[[KW:arg[0-9]+]]: index, %[[F:arg[0-9]+]]: index, %[[OH:arg[0-9]+]]: index, %[[OW:arg[0-9]+]]: index)
// CHECK-DAG: %[[C0:.*]] = arith.constant 0 : index
// CHECK-DAG: %[[C1:.*]] = arith.constant 1 : index
// CHECK: %[[INPUT:.*]] = dependent_tensor.make () #tensor<[%[[N]], %[[H]], %[[W]], %[[C]]], f32> : tensor<?x?x?x?xf32>
// CHECK-NEXT: %[[FILTER:.*]] = dependent_tensor.make () #tensor<[%[[KH]], %[[KW]], %[[C]], %[[F]]], f32> : tensor<?x?x?x?xf32>
// CHECK-NEXT: %[[INIT:.*]] = dependent_tensor.make () #tensor<[%[[N]], %[[OH]], %[[OW]], %[[F]]], f32> : tensor<?x?x?x?xf32>
// CHECK: %[[OUT_N:.*]] = scf.for %[[NI:.*]] = %[[C0]] to %[[N]] step %[[C1]] iter_args(%[[OUT0:.*]] = %[[INIT]]) -> (tensor<?x?x?x?xf32>) {
// CHECK:   %[[OUT_OH:.*]] = scf.for %[[OHI:.*]] = %[[C0]] to %[[OH]] step %[[C1]] iter_args(%[[OUT1:.*]] = %[[OUT0]]) -> (tensor<?x?x?x?xf32>) {
// CHECK:     %[[OUT_OW:.*]] = scf.for %[[OWI:.*]] = %[[C0]] to %[[OW]] step %[[C1]] iter_args(%[[OUT2:.*]] = %[[OUT1]]) -> (tensor<?x?x?x?xf32>) {
// CHECK:       %[[OUT_F:.*]] = scf.for %[[FI:.*]] = %[[C0]] to %[[F]] step %[[C1]] iter_args(%[[OUT3:.*]] = %[[OUT2]]) -> (tensor<?x?x?x?xf32>) {
// CHECK:         %[[SUM0:.*]] = dependent_tensor.extract %[[OUT3]][%[[NI]], %[[OHI]], %[[OWI]], %[[FI]]] : f32
// CHECK:         %[[SUM_KH:.*]] = scf.for %[[KHI:.*]] = %[[C0]] to %[[KH]] step %[[C1]] iter_args(%[[ACC0:.*]] = %[[SUM0]]) -> (f32) {
// CHECK:           %[[SUM_KW:.*]] = scf.for %[[KWI:.*]] = %[[C0]] to %[[KW]] step %[[C1]] iter_args(%[[ACC1:.*]] = %[[ACC0]]) -> (f32) {
// CHECK:             %[[SUM_C:.*]] = scf.for %[[CI:.*]] = %[[C0]] to %[[C]] step %[[C1]] iter_args(%[[ACC2:.*]] = %[[ACC1]]) -> (f32) {
// CHECK:               %[[IV:.*]] = dependent_tensor.extract %[[INPUT]][%[[NI]], %[[OHI]], %[[OWI]], %[[CI]]] : f32
// CHECK:               %[[FV:.*]] = dependent_tensor.extract %[[FILTER]][%[[KHI]], %[[KWI]], %[[CI]], %[[FI]]] : f32
// CHECK:               %[[PROD:.*]] = arith.mulf %[[IV]], %[[FV]] : f32
// CHECK:               %[[NEXT:.*]] = arith.addf %[[ACC2]], %[[PROD]] : f32
// CHECK:               scf.yield %[[NEXT]] : f32
// CHECK:             }
// CHECK:             scf.yield %[[SUM_C]] : f32
// CHECK:           }
// CHECK:           scf.yield %[[SUM_KW]] : f32
// CHECK:         }
// CHECK:         %[[UPDATED:.*]] = dependent_tensor.insert %[[SUM_KH]] into %[[OUT3]][%[[NI]], %[[OHI]], %[[OWI]], %[[FI]]] #tensor<[%[[N]], %[[OH]], %[[OW]], %[[F]]], f32> : f32 into tensor<?x?x?x?xf32>
// CHECK:         scf.yield %[[UPDATED]] : tensor<?x?x?x?xf32>
// CHECK:       }
// CHECK:       scf.yield %[[OUT_F]] : tensor<?x?x?x?xf32>
// CHECK:     }
// CHECK:     scf.yield %[[OUT_OW]] : tensor<?x?x?x?xf32>
// CHECK:   }
// CHECK:   scf.yield %[[OUT_OH]] : tensor<?x?x?x?xf32>
// CHECK: }
// CHECK-NEXT: return
// CHECK-NOT: dependent_tensor.conv2d_nhwc_hwcf
