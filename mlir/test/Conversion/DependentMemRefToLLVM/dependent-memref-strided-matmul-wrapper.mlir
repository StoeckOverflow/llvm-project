// RUN: mlir-opt %s -lower-dependent-memref-to-llvm -reconcile-unrealized-casts -split-input-file -mlir-print-op-generic | FileCheck %s

func.func @matmul_strided(%n : index, %m : index, %k : index,
                          %as0 : index, %as1 : index, %bs0 : index, %bs1 : index,
                          %cs0 : index, %cs1 : index,
                          %Aflat : memref<f32>, %Bflat : memref<f32>, %Cflat : memref<f32>) {
  %A = dependent_memref.reinterpret_cast %Aflat, #memref<[%n, %k], f32, offset: 0, strides: [%as0, %as1]> : memref<f32> to memref<?x?xf32>
  %B = dependent_memref.reinterpret_cast %Bflat, #memref<[%k, %m], f32, offset: 0, strides: [%bs0, %bs1]> : memref<f32> to memref<?x?xf32>
  %C = dependent_memref.reinterpret_cast %Cflat, #memref<[%n, %m], f32, offset: 0, strides: [%cs0, %cs1]> : memref<f32> to memref<?x?xf32>
  func.call @matmul_strided_typed(%n, %m, %k, %as0, %as1, %bs0, %bs1, %cs0, %cs1, %A, %B, %C) : (index, index, index, index, index, index, index, index, index, memref<?x?xf32>, memref<?x?xf32>, memref<?x?xf32>) -> ()
  return
}

func.func @matmul_strided_typed(%n : index, %m : index, %k : index,
                                %as0 : index, %as1 : index, %bs0 : index, %bs1 : index,
                                %cs0 : index, %cs1 : index,
                                %A : memref<?x?xf32>, %B : memref<?x?xf32>, %C : memref<?x?xf32>) {
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  %zero = arith.constant 0.0 : f32
  scf.for %i = %c0 to %n step %c1 {
    scf.for %j = %c0 to %m step %c1 {
      %sum = scf.for %p = %c0 to %k step %c1 iter_args(%acc = %zero) -> (f32) {
        %a = dependent_memref.load %A[%i, %p] #memref<[%n, %k], f32, offset: 0, strides: [%as0, %as1]> : memref<?x?xf32> -> f32
        %b = dependent_memref.load %B[%p, %j] #memref<[%k, %m], f32, offset: 0, strides: [%bs0, %bs1]> : memref<?x?xf32> -> f32
        %mul = arith.mulf %a, %b : f32
        %next = arith.addf %acc, %mul : f32
        scf.yield %next : f32
      }
      dependent_memref.store %sum, %C[%i, %j] #memref<[%n, %m], f32, offset: 0, strides: [%cs0, %cs1]> : memref<?x?xf32>, f32
    }
  }
  return
}

// CHECK-LABEL: "llvm.func"() <{{.*}}function_type = !llvm.func<void (i64, i64, i64, i64, i64, i64, i64, i64, i64, ptr, ptr, ptr)>{{.*}}sym_name = "matmul_strided"
// CHECK-NOT: "dependent_memref.
// CHECK-NOT: "llvm.insertvalue"
// CHECK-NOT: "llvm.extractvalue"
// CHECK-NOT: !llvm.struct
// CHECK: ^bb0(%[[N:.*]]: i64, %[[M:.*]]: i64, %[[K:.*]]: i64, %[[AS0:.*]]: i64, %[[AS1:.*]]: i64, %[[BS0:.*]]: i64, %[[BS1:.*]]: i64, %[[CS0:.*]]: i64, %[[CS1:.*]]: i64, %[[A:.*]]: !llvm.ptr, %[[B:.*]]: !llvm.ptr, %[[C:.*]]: !llvm.ptr):
// CHECK-NEXT: "llvm.call"(%[[N]], %[[M]], %[[K]], %[[AS0]], %[[AS1]], %[[BS0]], %[[BS1]], %[[CS0]], %[[CS1]], %[[A]], %[[B]], %[[C]]) <{{.*}}callee = @matmul_strided_typed{{.*}}> : (i64, i64, i64, i64, i64, i64, i64, i64, i64, !llvm.ptr, !llvm.ptr, !llvm.ptr) -> ()
// CHECK-NEXT: "llvm.return"() : () -> ()

// CHECK-LABEL: "llvm.func"() <{{.*}}function_type = !llvm.func<void (i64, i64, i64, i64, i64, i64, i64, i64, i64, ptr, ptr, ptr)>{{.*}}sym_name = "matmul_strided_typed"
// CHECK-NOT: "dependent_memref.
// CHECK-NOT: "arith.
// CHECK-NOT: "llvm.insertvalue"
// CHECK-NOT: "llvm.extractvalue"
// CHECK: ^bb0(%[[TN:.*]]: i64, %[[TM:.*]]: i64, %[[TK:.*]]: i64, %[[TAS0:.*]]: i64, %[[TAS1:.*]]: i64, %[[TBS0:.*]]: i64, %[[TBS1:.*]]: i64, %[[TCS0:.*]]: i64, %[[TCS1:.*]]: i64, %[[TA:.*]]: !llvm.ptr, %[[TB:.*]]: !llvm.ptr, %[[TC:.*]]: !llvm.ptr):
// CHECK: %[[ZERO:.*]] = "llvm.mlir.constant"() <{value = 0 : index}> : () -> i64
// CHECK: %[[ONE:.*]] = "llvm.mlir.constant"() <{value = 1 : index}> : () -> i64
// CHECK: %[[FZERO:.*]] = "llvm.mlir.constant"() <{value = 0.000000e+00 : f32}> : () -> f32
// CHECK: "llvm.br"(%[[ZERO]])[^bb1] : (i64) -> ()
// CHECK: ^bb1(%[[I:.*]]: i64):
// CHECK: "llvm.icmp"(%[[I]], %[[TN]]) <{predicate = 2 : i64}> : (i64, i64) -> i1
// CHECK: "llvm.br"(%[[ZERO]])[^bb3] : (i64) -> ()
// CHECK: ^bb3(%[[J:.*]]: i64):
// CHECK: "llvm.icmp"(%[[J]], %[[TM]]) <{predicate = 2 : i64}> : (i64, i64) -> i1
// CHECK: "llvm.br"(%[[ZERO]], %[[FZERO]])[^bb5] : (i64, f32) -> ()
// CHECK: ^bb5(%[[P:.*]]: i64, %[[ACC:.*]]: f32):
// CHECK: "llvm.icmp"(%[[P]], %[[TK]]) <{predicate = 2 : i64}> : (i64, i64) -> i1
// CHECK: %[[AI:.*]] = "llvm.mul"(%[[I]], %[[TAS0]]) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
// CHECK-NEXT: %[[AP:.*]] = "llvm.mul"(%[[P]], %[[TAS1]]) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
// CHECK-NEXT: %[[AIDX:.*]] = "llvm.add"(%[[AI]], %[[AP]]) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
// CHECK-NEXT: %[[APTR:.*]] = "llvm.getelementptr"(%[[TA]], %[[AIDX]]) <{elem_type = f32{{.*}}> : (!llvm.ptr, i64) -> !llvm.ptr
// CHECK-NEXT: %[[AVAL:.*]] = "llvm.load"(%[[APTR]]) <{ordering = 0 : i64}> : (!llvm.ptr) -> f32
// CHECK-NEXT: %[[BP:.*]] = "llvm.mul"(%[[P]], %[[TBS0]]) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
// CHECK-NEXT: %[[BJ:.*]] = "llvm.mul"(%[[J]], %[[TBS1]]) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
// CHECK-NEXT: %[[BIDX:.*]] = "llvm.add"(%[[BP]], %[[BJ]]) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
// CHECK-NEXT: %[[BPTR:.*]] = "llvm.getelementptr"(%[[TB]], %[[BIDX]]) <{elem_type = f32{{.*}}> : (!llvm.ptr, i64) -> !llvm.ptr
// CHECK-NEXT: %[[BVAL:.*]] = "llvm.load"(%[[BPTR]]) <{ordering = 0 : i64}> : (!llvm.ptr) -> f32
// CHECK-NEXT: %[[PROD:.*]] = "llvm.fmul"(%[[AVAL]], %[[BVAL]]) <{fastmathFlags = #llvm.fastmath<none>}> : (f32, f32) -> f32
// CHECK-NEXT: %[[NEXT:.*]] = "llvm.fadd"(%[[ACC]], %[[PROD]]) <{fastmathFlags = #llvm.fastmath<none>}> : (f32, f32) -> f32
// CHECK: %[[CI:.*]] = "llvm.mul"(%[[I]], %[[TCS0]]) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
// CHECK-NEXT: %[[CJ:.*]] = "llvm.mul"(%[[J]], %[[TCS1]]) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
// CHECK-NEXT: %[[CIDX:.*]] = "llvm.add"(%[[CI]], %[[CJ]]) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
// CHECK-NEXT: %[[CPTR:.*]] = "llvm.getelementptr"(%[[TC]], %[[CIDX]]) <{elem_type = f32{{.*}}> : (!llvm.ptr, i64) -> !llvm.ptr
// CHECK-NEXT: "llvm.store"(%{{.*}}, %[[CPTR]]) <{ordering = 0 : i64}> : (f32, !llvm.ptr) -> ()
// CHECK: "llvm.return"() : () -> ()
