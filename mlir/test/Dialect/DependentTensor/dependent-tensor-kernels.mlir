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
// CHECK-SAME: (%[[M:arg[0-9]+]]: index, %[[K:arg[0-9]+]]: index, %[[N:arg[0-9]+]]: index,
// CHECK-SAME:  %[[A:arg[0-9]+]]: tensor<?x?xf32>, %[[B:arg[0-9]+]]: tensor<?x?xf32>, %[[CINIT:arg[0-9]+]]: tensor<?x?xf32>) -> tensor<?x?xf32>
// CHECK-SAME:  #types[%[[A]] : #tensor<[%[[M]], %[[K]]], f32>, %[[B]] : #tensor<[%[[K]], %[[N]]], f32>, %[[CINIT]] : #tensor<[%[[M]], %[[N]]], f32>] -> #tensor<[%[[M]], %[[N]]], f32>
// CHECK-DAG: %[[C0:.*]] = arith.constant 0 : index
// CHECK-DAG: %[[C1:.*]] = arith.constant 1 : index
// CHECK: %[[COUT:.*]] = scf.for %[[I:.*]] = %[[C0]] to %[[M]] step %[[C1]] iter_args(%[[ROW:.*]] = %[[CINIT]]) -> (tensor<?x?xf32>) {
// CHECK:   %[[NEXT:.*]] = scf.for %[[J:.*]] = %[[C0]] to %[[N]] step %[[C1]] iter_args(%[[COL:.*]] = %[[ROW]]) -> (tensor<?x?xf32>) {
// CHECK:     %[[ZERO:.*]] = arith.constant 0.000000e+00 : f32
// CHECK:     %[[SUM:.*]] = scf.for %[[KK:.*]] = %[[C0]] to %[[K]] step %[[C1]] iter_args(%[[ACC:.*]] = %[[ZERO]]) -> (f32) {
// CHECK:       %[[AV:.*]] = dependent_tensor.extract %[[A]][%[[I]], %[[KK]]] #tensor<[%[[M]], %[[K]]], f32> : f32
// CHECK:       %[[BV:.*]] = dependent_tensor.extract %[[B]][%[[KK]], %[[J]]] #tensor<[%[[K]], %[[N]]], f32> : f32
// CHECK:       %[[PROD:.*]] = arith.mulf %[[AV]], %[[BV]] : f32
// CHECK:       %[[ACC_NEXT:.*]] = arith.addf %[[ACC]], %[[PROD]] : f32
// CHECK:       scf.yield %[[ACC_NEXT]] : f32
// CHECK:     }
// CHECK:     %[[UPDATED:.*]] = dependent_tensor.insert %[[SUM]] into %[[COL]][%[[I]], %[[J]]] #tensor<[%[[M]], %[[N]]], f32> : f32 into tensor<?x?xf32>
// CHECK:     scf.yield %[[UPDATED]] : tensor<?x?xf32>
// CHECK:   }
// CHECK:   scf.yield %[[NEXT]] : tensor<?x?xf32>
// CHECK: }
// CHECK: return %[[COUT]] : tensor<?x?xf32>
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
// CHECK-SAME: (%[[GM:arg[0-9]+]]: index, %[[GK:arg[0-9]+]]: index, %[[GN:arg[0-9]+]]: index,
// CHECK-SAME:  %[[GA:arg[0-9]+]]: tensor<?x?xf32>, %[[GB:arg[0-9]+]]: tensor<?x?xf32>, %[[GCINIT:arg[0-9]+]]: tensor<?x?xf32>) -> tensor<?x?xf32>
// CHECK-SAME:  #types[%[[GA]] : #tensor<[%[[GM]], %[[GK]]], f32>, %[[GB]] : #tensor<[%[[GK]], %[[GN]]], f32>, %[[GCINIT]] : #tensor<[%[[GM]], %[[GN]]], f32>] -> #tensor<[%[[GM]], %[[GN]]], f32>
// CHECK-DAG: %[[GC0:.*]] = arith.constant 0 : index
// CHECK-DAG: %[[GC1:.*]] = arith.constant 1 : index
// CHECK: %[[GCOUT:.*]] = scf.for %[[GI:.*]] = %[[GC0]] to %[[GM]] step %[[GC1]] iter_args(%[[GROW:.*]] = %[[GCINIT]]) -> (tensor<?x?xf32>) {
// CHECK:   %[[GNEXT:.*]] = scf.for %[[GJ:.*]] = %[[GC0]] to %[[GN]] step %[[GC1]] iter_args(%[[GCOL:.*]] = %[[GROW]]) -> (tensor<?x?xf32>) {
// CHECK:     %[[BIAS:.*]] = dependent_tensor.extract %[[GCOL]][%[[GI]], %[[GJ]]] #tensor<[%[[GM]], %[[GN]]], f32> : f32
// CHECK:     %[[GSUM:.*]] = scf.for %[[GKK:.*]] = %[[GC0]] to %[[GK]] step %[[GC1]] iter_args(%[[GACC:.*]] = %[[BIAS]]) -> (f32) {
// CHECK:       %[[GAV:.*]] = dependent_tensor.extract %[[GA]][%[[GI]], %[[GKK]]] #tensor<[%[[GM]], %[[GK]]], f32> : f32
// CHECK:       %[[GBV:.*]] = dependent_tensor.extract %[[GB]][%[[GKK]], %[[GJ]]] #tensor<[%[[GK]], %[[GN]]], f32> : f32
// CHECK:       %[[GPROD:.*]] = arith.mulf %[[GAV]], %[[GBV]] : f32
// CHECK:       %[[GACC_NEXT:.*]] = arith.addf %[[GACC]], %[[GPROD]] : f32
// CHECK:       scf.yield %[[GACC_NEXT]] : f32
// CHECK:     }
// CHECK:     %[[GUPDATED:.*]] = dependent_tensor.insert %[[GSUM]] into %[[GCOL]][%[[GI]], %[[GJ]]] #tensor<[%[[GM]], %[[GN]]], f32> : f32 into tensor<?x?xf32>
// CHECK:     scf.yield %[[GUPDATED]] : tensor<?x?xf32>
// CHECK:   }
// CHECK:   scf.yield %[[GNEXT]] : tensor<?x?xf32>
// CHECK: }
// CHECK: return %[[GCOUT]] : tensor<?x?xf32>
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
// CHECK-SAME: (%[[CM:arg[0-9]+]]: index, %[[CK:arg[0-9]+]]: index, %[[CN:arg[0-9]+]]: index) -> tensor<?x?xf32>
// CHECK-SAME: #types[] -> #tensor<[%[[CM]], %[[CN]]], f32>
// CHECK-NEXT: %[[CA:.*]] = dependent_tensor.make () #tensor<[%[[CM]], %[[CK]]], f32> : tensor<?x?xf32>
// CHECK-NEXT: %[[CB:.*]] = dependent_tensor.make () #tensor<[%[[CK]], %[[CN]]], f32> : tensor<?x?xf32>
// CHECK-NEXT: %[[CC:.*]] = dependent_tensor.make () #tensor<[%[[CM]], %[[CN]]], f32> : tensor<?x?xf32>
// CHECK-NEXT: %[[CR:.*]] = call @matmul_kernel(%[[CM]], %[[CK]], %[[CN]], %[[CA]], %[[CB]], %[[CC]]) : (index, index, index, tensor<?x?xf32>, tensor<?x?xf32>, tensor<?x?xf32>) -> tensor<?x?xf32>
// CHECK-NEXT: return %[[CR]] : tensor<?x?xf32>

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
// CHECK-SAME: (%[[DN:arg[0-9]+]]: index, %[[DH:arg[0-9]+]]: index, %[[DW:arg[0-9]+]]: index, %[[DC:arg[0-9]+]]: index, %[[DKH:arg[0-9]+]]: index, %[[DKW:arg[0-9]+]]: index, %[[DF:arg[0-9]+]]: index, %[[DOH:arg[0-9]+]]: index, %[[DOW:arg[0-9]+]]: index,
// CHECK-SAME:  %[[DX:arg[0-9]+]]: tensor<?x?x?x?xf32>, %[[DK:arg[0-9]+]]: tensor<?x?x?x?xf32>, %[[DYINIT:arg[0-9]+]]: tensor<?x?x?x?xf32>) -> tensor<?x?x?x?xf32>
// CHECK-SAME:  #types[%[[DX]] : #tensor<[%[[DN]], %[[DH]], %[[DW]], %[[DC]]], f32>, %[[DK]] : #tensor<[%[[DKH]], %[[DKW]], %[[DC]], %[[DF]]], f32>, %[[DYINIT]] : #tensor<[%[[DN]], %[[DOH]], %[[DOW]], %[[DF]]], f32>] -> #tensor<[%[[DN]], %[[DOH]], %[[DOW]], %[[DF]]], f32>
// CHECK-DAG: %[[DC0:.*]] = arith.constant 0 : index
// CHECK-DAG: %[[DC1:.*]] = arith.constant 1 : index
// CHECK: %[[DY0:.*]] = scf.for %[[DNI:.*]] = %[[DC0]] to %[[DN]] step %[[DC1]] iter_args(%[[DYN:.*]] = %[[DYINIT]]) -> (tensor<?x?x?x?xf32>) {
// CHECK:   %[[DY1:.*]] = scf.for %[[DOHI:.*]] = %[[DC0]] to %[[DOH]] step %[[DC1]] iter_args(%[[DYH:.*]] = %[[DYN]]) -> (tensor<?x?x?x?xf32>) {
// CHECK:     %[[DY2:.*]] = scf.for %[[DOWI:.*]] = %[[DC0]] to %[[DOW]] step %[[DC1]] iter_args(%[[DYW:.*]] = %[[DYH]]) -> (tensor<?x?x?x?xf32>) {
// CHECK:       %[[DY3:.*]] = scf.for %[[DFO:.*]] = %[[DC0]] to %[[DF]] step %[[DC1]] iter_args(%[[DYF:.*]] = %[[DYW]]) -> (tensor<?x?x?x?xf32>) {
// CHECK:         %[[DSUM0:.*]] = dependent_tensor.extract %[[DYF]][%[[DNI]], %[[DOHI]], %[[DOWI]], %[[DFO]]] #tensor<[%[[DN]], %[[DOH]], %[[DOW]], %[[DF]]], f32> : f32
// CHECK:         %[[DSUM_KH:.*]] = scf.for %[[DKHI:.*]] = %[[DC0]] to %[[DKH]] step %[[DC1]] iter_args(%[[DACC_KH:.*]] = %[[DSUM0]]) -> (f32) {
// CHECK:           %[[DSUM_KW:.*]] = scf.for %[[DKWI:.*]] = %[[DC0]] to %[[DKW]] step %[[DC1]] iter_args(%[[DACC_KW:.*]] = %[[DACC_KH]]) -> (f32) {
// CHECK:             %[[DSUM_C:.*]] = scf.for %[[DCI:.*]] = %[[DC0]] to %[[DC]] step %[[DC1]] iter_args(%[[DACC_C:.*]] = %[[DACC_KW]]) -> (f32) {
// CHECK:               %[[DXV:.*]] = dependent_tensor.extract %[[DX]][%[[DNI]], %[[DOHI]], %[[DOWI]], %[[DCI]]] #tensor<[%[[DN]], %[[DH]], %[[DW]], %[[DC]]], f32> : f32
// CHECK:               %[[DKV:.*]] = dependent_tensor.extract %[[DK]][%[[DKHI]], %[[DKWI]], %[[DCI]], %[[DFO]]] #tensor<[%[[DKH]], %[[DKW]], %[[DC]], %[[DF]]], f32> : f32
// CHECK:               %[[DPROD:.*]] = arith.mulf %[[DXV]], %[[DKV]] : f32
// CHECK:               %[[DACC_NEXT:.*]] = arith.addf %[[DACC_C]], %[[DPROD]] : f32
// CHECK:               scf.yield %[[DACC_NEXT]] : f32
// CHECK:             }
// CHECK:             scf.yield %[[DSUM_C]] : f32
// CHECK:           }
// CHECK:           scf.yield %[[DSUM_KW]] : f32
// CHECK:         }
// CHECK:         %[[DUPDATED:.*]] = dependent_tensor.insert %[[DSUM_KH]] into %[[DYF]][%[[DNI]], %[[DOHI]], %[[DOWI]], %[[DFO]]] #tensor<[%[[DN]], %[[DOH]], %[[DOW]], %[[DF]]], f32> : f32 into tensor<?x?x?x?xf32>
// CHECK:         scf.yield %[[DUPDATED]] : tensor<?x?x?x?xf32>
// CHECK:       }
// CHECK:       scf.yield %[[DY3]] : tensor<?x?x?x?xf32>
// CHECK:     }
// CHECK:     scf.yield %[[DY2]] : tensor<?x?x?x?xf32>
// CHECK:   }
// CHECK:   scf.yield %[[DY1]] : tensor<?x?x?x?xf32>
// CHECK: }
// CHECK: return %[[DY0]] : tensor<?x?x?x?xf32>

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
// CHECK-SAME: (%[[CN0:arg[0-9]+]]: index, %[[CH0:arg[0-9]+]]: index, %[[CW0:arg[0-9]+]]: index, %[[CC0:arg[0-9]+]]: index, %[[CKH0:arg[0-9]+]]: index, %[[CKW0:arg[0-9]+]]: index, %[[CF0:arg[0-9]+]]: index, %[[COH0:arg[0-9]+]]: index, %[[COW0:arg[0-9]+]]: index) -> tensor<?x?x?x?xf32>
// CHECK-SAME: #types[] -> #tensor<[%[[CN0]], %[[COH0]], %[[COW0]], %[[CF0]]], f32>
// CHECK-NEXT: %[[CX0:.*]] = dependent_tensor.make () #tensor<[%[[CN0]], %[[CH0]], %[[CW0]], %[[CC0]]], f32> : tensor<?x?x?x?xf32>
// CHECK-NEXT: %[[CK0:.*]] = dependent_tensor.make () #tensor<[%[[CKH0]], %[[CKW0]], %[[CC0]], %[[CF0]]], f32> : tensor<?x?x?x?xf32>
// CHECK-NEXT: %[[CY0:.*]] = dependent_tensor.make () #tensor<[%[[CN0]], %[[COH0]], %[[COW0]], %[[CF0]]], f32> : tensor<?x?x?x?xf32>
// CHECK-NEXT: %[[CR0:.*]] = call @conv2d_nhwc_hwcf_kernel(%[[CN0]], %[[CH0]], %[[CW0]], %[[CC0]], %[[CKH0]], %[[CKW0]], %[[CF0]], %[[COH0]], %[[COW0]], %[[CX0]], %[[CK0]], %[[CY0]]) : (index, index, index, index, index, index, index, index, index, tensor<?x?x?x?xf32>, tensor<?x?x?x?xf32>, tensor<?x?x?x?xf32>) -> tensor<?x?x?x?xf32>
// CHECK-NEXT: return %[[CR0]] : tensor<?x?x?x?xf32>
