"builtin.module"() ({
  "llvm.func"() <{CConv = #llvm.cconv<ccc>, function_type = !llvm.func<void (i64, i64, i64, i64, i64, i64, i64, i64, i64, ptr, ptr, ptr)>, linkage = #llvm.linkage<external>, sym_name = "dependent_matmul_strided", visibility_ = 0 : i64}> ({
  ^bb0(%arg12: i64, %arg13: i64, %arg14: i64, %arg15: i64, %arg16: i64, %arg17: i64, %arg18: i64, %arg19: i64, %arg20: i64, %arg21: !llvm.ptr, %arg22: !llvm.ptr, %arg23: !llvm.ptr):
    "llvm.call"(%arg12, %arg13, %arg14, %arg15, %arg16, %arg17, %arg18, %arg19, %arg20, %arg21, %arg22, %arg23) <{CConv = #llvm.cconv<ccc>, TailCallKind = #llvm.tailcallkind<none>, callee = @dependent_matmul_strided_typed, fastmathFlags = #llvm.fastmath<none>, op_bundle_sizes = array<i32>, operandSegmentSizes = array<i32: 12, 0>}> : (i64, i64, i64, i64, i64, i64, i64, i64, i64, !llvm.ptr, !llvm.ptr, !llvm.ptr) -> ()
    "llvm.return"() : () -> ()
  }) : () -> ()
  "llvm.func"() <{CConv = #llvm.cconv<ccc>, function_type = !llvm.func<void (i64, i64, i64, i64, i64, i64, i64, i64, i64, ptr, ptr, ptr)>, linkage = #llvm.linkage<external>, sym_name = "dependent_matmul_strided_typed", visibility_ = 0 : i64}> ({
  ^bb0(%arg0: i64, %arg1: i64, %arg2: i64, %arg3: i64, %arg4: i64, %arg5: i64, %arg6: i64, %arg7: i64, %arg8: i64, %arg9: !llvm.ptr, %arg10: !llvm.ptr, %arg11: !llvm.ptr):
    %0 = "llvm.mlir.constant"() <{value = 0 : index}> : () -> i64
    %1 = "llvm.mlir.constant"() <{value = 1 : index}> : () -> i64
    %2 = "llvm.mlir.constant"() <{value = 0.000000e+00 : f32}> : () -> f32
    "llvm.br"(%0)[^bb1] : (i64) -> ()
  ^bb1(%3: i64):  // 2 preds: ^bb0, ^bb8
    %4 = "llvm.icmp"(%3, %arg0) <{predicate = 2 : i64}> : (i64, i64) -> i1
    "llvm.cond_br"(%4)[^bb2, ^bb9] <{operandSegmentSizes = array<i32: 1, 0, 0>}> : (i1) -> ()
  ^bb2:  // pred: ^bb1
    "llvm.br"(%0)[^bb3] : (i64) -> ()
  ^bb3(%5: i64):  // 2 preds: ^bb2, ^bb7
    %6 = "llvm.icmp"(%5, %arg1) <{predicate = 2 : i64}> : (i64, i64) -> i1
    "llvm.cond_br"(%6)[^bb4, ^bb8] <{operandSegmentSizes = array<i32: 1, 0, 0>}> : (i1) -> ()
  ^bb4:  // pred: ^bb3
    "llvm.br"(%0, %2)[^bb5] : (i64, f32) -> ()
  ^bb5(%7: i64, %8: f32):  // 2 preds: ^bb4, ^bb6
    %9 = "llvm.icmp"(%7, %arg2) <{predicate = 2 : i64}> : (i64, i64) -> i1
    "llvm.cond_br"(%9)[^bb6, ^bb7] <{operandSegmentSizes = array<i32: 1, 0, 0>}> : (i1) -> ()
  ^bb6:  // pred: ^bb5
    %10 = "llvm.mlir.constant"() <{value = 0 : i64}> : () -> i64
    %11 = "llvm.mul"(%3, %arg3) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %12 = "llvm.add"(%10, %11) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %13 = "llvm.mul"(%7, %arg4) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %14 = "llvm.add"(%12, %13) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %15 = "llvm.getelementptr"(%arg9, %14) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %16 = "llvm.load"(%15) <{ordering = 0 : i64}> : (!llvm.ptr) -> f32
    %17 = "llvm.mlir.constant"() <{value = 0 : i64}> : () -> i64
    %18 = "llvm.mul"(%7, %arg5) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %19 = "llvm.add"(%17, %18) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %20 = "llvm.mul"(%5, %arg6) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %21 = "llvm.add"(%19, %20) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %22 = "llvm.getelementptr"(%arg10, %21) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %23 = "llvm.load"(%22) <{ordering = 0 : i64}> : (!llvm.ptr) -> f32
    %24 = "llvm.fmul"(%16, %23) <{fastmathFlags = #llvm.fastmath<none>}> : (f32, f32) -> f32
    %25 = "llvm.fadd"(%8, %24) <{fastmathFlags = #llvm.fastmath<none>}> : (f32, f32) -> f32
    %26 = "llvm.add"(%7, %1) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    "llvm.br"(%26, %25)[^bb5] : (i64, f32) -> ()
  ^bb7:  // pred: ^bb5
    %27 = "llvm.mlir.constant"() <{value = 0 : i64}> : () -> i64
    %28 = "llvm.mul"(%3, %arg7) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %29 = "llvm.add"(%27, %28) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %30 = "llvm.mul"(%5, %arg8) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %31 = "llvm.add"(%29, %30) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %32 = "llvm.getelementptr"(%arg11, %31) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    "llvm.store"(%8, %32) <{ordering = 0 : i64}> : (f32, !llvm.ptr) -> ()
    %33 = "llvm.add"(%5, %1) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    "llvm.br"(%33)[^bb3] : (i64) -> ()
  ^bb8:  // pred: ^bb3
    %34 = "llvm.add"(%3, %1) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    "llvm.br"(%34)[^bb1] : (i64) -> ()
  ^bb9:  // pred: ^bb1
    "llvm.return"() : () -> ()
  }) : () -> ()
}) : () -> ()

