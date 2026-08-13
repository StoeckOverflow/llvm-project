// RUN: mlir-opt %s -convert-dependent-tensor-to-dependent-memref -lower-dependent-memref-to-llvm -split-input-file -mlir-print-op-generic | FileCheck %s

func.func @dependent_matmul_kernel(
    %n : index,
    %k : index,
    %m : index,
    %A : tensor<?x?xf32>,
    %B : tensor<?x?xf32>,
    %C : tensor<?x?xf32>) -> tensor<?x?xf32>
    #types[
      %A : #tensor<[%n, %k], f32>,
      %B : #tensor<[%k, %m], f32>,
      %C : #tensor<[%n, %m], f32>
    ] -> #tensor<[%n, %m], f32> {
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  %zero = arith.constant 0.0 : f32
  %C_final = scf.for %i = %c0 to %n step %c1 iter_args(%Ci = %C)
      -> (tensor<?x?xf32>)
      #types[%Ci : #tensor<[%n, %m], f32>] -> #tensor<[%n, %m], f32>
 {
    %C_row = scf.for %j = %c0 to %m step %c1 iter_args(%Cj = %Ci)
        -> (tensor<?x?xf32>)
        #types[%Cj : #tensor<[%n, %m], f32>] -> #tensor<[%n, %m], f32>
 {
      %sum = scf.for %kk = %c0 to %k step %c1 iter_args(%sum_iter = %zero)
          -> (f32) {
        %a = dependent_tensor.extract %A[%i, %kk] : f32
        %b = dependent_tensor.extract %B[%kk, %j] : f32
        %mul = arith.mulf %a, %b : f32
        %next = arith.addf %sum_iter, %mul : f32
        scf.yield %next : f32
      }
      %updated = dependent_tensor.insert %sum into %Cj[%i, %j] #tensor<[%n, %m], f32> : f32 into tensor<?x?xf32>
      scf.yield %updated : tensor<?x?xf32>
    }
    scf.yield %C_row : tensor<?x?xf32>
  }
  return %C_final : tensor<?x?xf32>
}

// CHECK-LABEL: "llvm.func"() <{{.*}}function_type = !llvm.func<ptr (i64, i64, i64, ptr, ptr, ptr)>{{.*}}sym_name = "dependent_matmul_kernel"
// CHECK-NOT: "dependent_tensor.
// CHECK-NOT: "dependent_memref.
// CHECK-NOT: "arith.
// CHECK: "llvm.icmp"(%{{.*}}, %{{.*}}) <{predicate = 2 : i64}> : (i64, i64) -> i1
// CHECK: "llvm.getelementptr"(%{{.*}}, %{{.*}}) <{elem_type = f32{{.*}}> : (!llvm.ptr, i64) -> !llvm.ptr
// CHECK: "llvm.load"(%{{.*}}) <{ordering = 0 : i64}> : (!llvm.ptr) -> f32
// CHECK: "llvm.getelementptr"(%{{.*}}, %{{.*}}) <{elem_type = f32{{.*}}> : (!llvm.ptr, i64) -> !llvm.ptr
// CHECK: "llvm.load"(%{{.*}}) <{ordering = 0 : i64}> : (!llvm.ptr) -> f32
// CHECK: "llvm.fmul"(%{{.*}}, %{{.*}}) <{fastmathFlags = #llvm.fastmath<none>}> : (f32, f32) -> f32
// CHECK: "llvm.fadd"(%{{.*}}, %{{.*}}) <{fastmathFlags = #llvm.fastmath<none>}> : (f32, f32) -> f32
// CHECK: "llvm.getelementptr"(%{{.*}}, %{{.*}}) <{elem_type = f32{{.*}}> : (!llvm.ptr, i64) -> !llvm.ptr
// CHECK: "llvm.store"(%{{.*}}, %{{.*}}) <{ordering = 0 : i64}> : (f32, !llvm.ptr) -> ()
// CHECK: "llvm.return"(%{{.*}}) : (!llvm.ptr) -> ()
