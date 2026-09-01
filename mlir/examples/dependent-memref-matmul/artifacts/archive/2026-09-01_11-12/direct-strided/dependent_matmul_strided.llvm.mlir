"builtin.module"() ({
  "llvm.func"() <{CConv = #llvm.cconv<ccc>, function_type = !llvm.func<void (i64, i64, i64, i64, i64, i64, i64, i64, i64, ptr, ptr, ptr)>, linkage = #llvm.linkage<external>, sym_name = "dependent_matmul_strided", visibility_ = 0 : i64}> ({
  ^bb0(%arg0: i64, %arg1: i64, %arg2: i64, %arg3: i64, %arg4: i64, %arg5: i64, %arg6: i64, %arg7: i64, %arg8: i64, %arg9: !llvm.ptr, %arg10: !llvm.ptr, %arg11: !llvm.ptr):
    %0 = "llvm.mlir.constant"() <{value = 0.000000e+00 : f32}> : () -> f32
    %1 = "llvm.mlir.constant"() <{value = 0 : index}> : () -> i64
    %2 = "llvm.mlir.constant"() <{value = 1 : index}> : () -> i64
    "llvm.br"(%1)[^bb1] : (i64) -> ()
  ^bb1(%3: i64):  // 2 preds: ^bb0, ^bb8
    %4 = "llvm.icmp"(%3, %arg0) <{predicate = 2 : i64}> : (i64, i64) -> i1
    "llvm.cond_br"(%4)[^bb2, ^bb9] <{operandSegmentSizes = array<i32: 1, 0, 0>}> : (i1) -> ()
  ^bb2:  // pred: ^bb1
    "llvm.br"(%1)[^bb3] : (i64) -> ()
  ^bb3(%5: i64):  // 2 preds: ^bb2, ^bb7
    %6 = "llvm.icmp"(%5, %arg1) <{predicate = 2 : i64}> : (i64, i64) -> i1
    "llvm.cond_br"(%6)[^bb4, ^bb8] <{operandSegmentSizes = array<i32: 1, 0, 0>}> : (i1) -> ()
  ^bb4:  // pred: ^bb3
    "llvm.br"(%1, %0)[^bb5] : (i64, f32) -> ()
  ^bb5(%7: i64, %8: f32):  // 2 preds: ^bb4, ^bb6
    %9 = "llvm.icmp"(%7, %arg2) <{predicate = 2 : i64}> : (i64, i64) -> i1
    "llvm.cond_br"(%9)[^bb6, ^bb7] <{operandSegmentSizes = array<i32: 1, 0, 0>}> : (i1) -> ()
  ^bb6:  // pred: ^bb5
    %10 = "llvm.mul"(%3, %arg3) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %11 = "llvm.mul"(%7, %arg4) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %12 = "llvm.add"(%10, %11) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %13 = "llvm.getelementptr"(%arg9, %12) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %14 = "llvm.load"(%13) <{ordering = 0 : i64}> : (!llvm.ptr) -> f32
    %15 = "llvm.mul"(%7, %arg5) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %16 = "llvm.mul"(%5, %arg6) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %17 = "llvm.add"(%15, %16) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %18 = "llvm.getelementptr"(%arg10, %17) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %19 = "llvm.load"(%18) <{ordering = 0 : i64}> : (!llvm.ptr) -> f32
    %20 = "llvm.fmul"(%14, %19) <{fastmathFlags = #llvm.fastmath<none>}> : (f32, f32) -> f32
    %21 = "llvm.fadd"(%8, %20) <{fastmathFlags = #llvm.fastmath<none>}> : (f32, f32) -> f32
    %22 = "llvm.add"(%7, %2) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    "llvm.br"(%22, %21)[^bb5] : (i64, f32) -> ()
  ^bb7:  // pred: ^bb5
    %23 = "llvm.mul"(%3, %arg7) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %24 = "llvm.mul"(%5, %arg8) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %25 = "llvm.add"(%23, %24) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %26 = "llvm.getelementptr"(%arg11, %25) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    "llvm.store"(%8, %26) <{ordering = 0 : i64}> : (f32, !llvm.ptr) -> ()
    %27 = "llvm.add"(%5, %2) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    "llvm.br"(%27)[^bb3] : (i64) -> ()
  ^bb8:  // pred: ^bb3
    %28 = "llvm.add"(%3, %2) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    "llvm.br"(%28)[^bb1] : (i64) -> ()
  ^bb9:  // pred: ^bb1
    "llvm.return"() : () -> ()
  }) : () -> ()
}) : () -> ()

