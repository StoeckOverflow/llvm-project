"builtin.module"() ({
  "llvm.func"() <{CConv = #llvm.cconv<ccc>, function_type = !llvm.func<void (i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, ptr, ptr, ptr)>, linkage = #llvm.linkage<external>, sym_name = "memref_contraction_rank_2", visibility_ = 0 : i64}> ({
  ^bb0(%arg0: i64, %arg1: i64, %arg2: i64, %arg3: i64, %arg4: i64, %arg5: i64, %arg6: i64, %arg7: i64, %arg8: i64, %arg9: i64, %arg10: i64, %arg11: i64, %arg12: i64, %arg13: i64, %arg14: i64, %arg15: i64, %arg16: i64, %arg17: i64, %arg18: !llvm.ptr, %arg19: !llvm.ptr, %arg20: !llvm.ptr):
    %0 = "llvm.mlir.constant"() <{value = 0 : index}> : () -> i64
    %1 = "llvm.mlir.constant"() <{value = 1 : index}> : () -> i64
    %2 = "llvm.mlir.constant"() <{value = 0.000000e+00 : f32}> : () -> f32
    "llvm.br"(%0)[^bb1] : (i64) -> ()
  ^bb1(%3: i64):  // 2 preds: ^bb0, ^bb17
    %4 = "llvm.icmp"(%3, %arg0) <{predicate = 2 : i64}> : (i64, i64) -> i1
    "llvm.cond_br"(%4)[^bb2, ^bb18] <{operandSegmentSizes = array<i32: 1, 0, 0>}> : (i1) -> ()
  ^bb2:  // pred: ^bb1
    "llvm.br"(%0)[^bb3] : (i64) -> ()
  ^bb3(%5: i64):  // 2 preds: ^bb2, ^bb16
    %6 = "llvm.icmp"(%5, %arg1) <{predicate = 2 : i64}> : (i64, i64) -> i1
    "llvm.cond_br"(%6)[^bb4, ^bb17] <{operandSegmentSizes = array<i32: 1, 0, 0>}> : (i1) -> ()
  ^bb4:  // pred: ^bb3
    "llvm.br"(%0)[^bb5] : (i64) -> ()
  ^bb5(%7: i64):  // 2 preds: ^bb4, ^bb15
    %8 = "llvm.icmp"(%7, %arg2) <{predicate = 2 : i64}> : (i64, i64) -> i1
    "llvm.cond_br"(%8)[^bb6, ^bb16] <{operandSegmentSizes = array<i32: 1, 0, 0>}> : (i1) -> ()
  ^bb6:  // pred: ^bb5
    "llvm.br"(%0)[^bb7] : (i64) -> ()
  ^bb7(%9: i64):  // 2 preds: ^bb6, ^bb14
    %10 = "llvm.icmp"(%9, %arg3) <{predicate = 2 : i64}> : (i64, i64) -> i1
    "llvm.cond_br"(%10)[^bb8, ^bb15] <{operandSegmentSizes = array<i32: 1, 0, 0>}> : (i1) -> ()
  ^bb8:  // pred: ^bb7
    "llvm.br"(%0, %2)[^bb9] : (i64, f32) -> ()
  ^bb9(%11: i64, %12: f32):  // 2 preds: ^bb8, ^bb13
    %13 = "llvm.icmp"(%11, %arg4) <{predicate = 2 : i64}> : (i64, i64) -> i1
    "llvm.cond_br"(%13)[^bb10, ^bb14] <{operandSegmentSizes = array<i32: 1, 0, 0>}> : (i1) -> ()
  ^bb10:  // pred: ^bb9
    "llvm.br"(%0, %12)[^bb11] : (i64, f32) -> ()
  ^bb11(%14: i64, %15: f32):  // 2 preds: ^bb10, ^bb12
    %16 = "llvm.icmp"(%14, %arg5) <{predicate = 2 : i64}> : (i64, i64) -> i1
    "llvm.cond_br"(%16)[^bb12, ^bb13] <{operandSegmentSizes = array<i32: 1, 0, 0>}> : (i1) -> ()
  ^bb12:  // pred: ^bb11
    %17 = "llvm.mul"(%3, %arg6) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %18 = "llvm.mul"(%5, %arg7) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %19 = "llvm.add"(%17, %18) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %20 = "llvm.mul"(%11, %arg8) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %21 = "llvm.add"(%19, %20) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %22 = "llvm.mul"(%14, %arg9) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %23 = "llvm.add"(%21, %22) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %24 = "llvm.getelementptr"(%arg18, %23) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %25 = "llvm.load"(%24) <{ordering = 0 : i64}> : (!llvm.ptr) -> f32
    %26 = "llvm.mul"(%11, %arg10) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %27 = "llvm.mul"(%14, %arg11) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %28 = "llvm.add"(%26, %27) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %29 = "llvm.mul"(%7, %arg12) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %30 = "llvm.add"(%28, %29) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %31 = "llvm.mul"(%9, %arg13) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %32 = "llvm.add"(%30, %31) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %33 = "llvm.getelementptr"(%arg19, %32) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %34 = "llvm.load"(%33) <{ordering = 0 : i64}> : (!llvm.ptr) -> f32
    %35 = "llvm.fmul"(%25, %34) <{fastmathFlags = #llvm.fastmath<none>}> : (f32, f32) -> f32
    %36 = "llvm.fadd"(%15, %35) <{fastmathFlags = #llvm.fastmath<none>}> : (f32, f32) -> f32
    %37 = "llvm.add"(%14, %1) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    "llvm.br"(%37, %36)[^bb11] : (i64, f32) -> ()
  ^bb13:  // pred: ^bb11
    %38 = "llvm.add"(%11, %1) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    "llvm.br"(%38, %15)[^bb9] : (i64, f32) -> ()
  ^bb14:  // pred: ^bb9
    %39 = "llvm.mul"(%3, %arg14) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %40 = "llvm.mul"(%5, %arg15) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %41 = "llvm.add"(%39, %40) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %42 = "llvm.mul"(%7, %arg16) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %43 = "llvm.add"(%41, %42) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %44 = "llvm.mul"(%9, %arg17) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %45 = "llvm.add"(%43, %44) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %46 = "llvm.getelementptr"(%arg20, %45) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    "llvm.store"(%12, %46) <{ordering = 0 : i64}> : (f32, !llvm.ptr) -> ()
    %47 = "llvm.add"(%9, %1) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    "llvm.br"(%47)[^bb7] : (i64) -> ()
  ^bb15:  // pred: ^bb7
    %48 = "llvm.add"(%7, %1) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    "llvm.br"(%48)[^bb5] : (i64) -> ()
  ^bb16:  // pred: ^bb5
    %49 = "llvm.add"(%5, %1) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    "llvm.br"(%49)[^bb3] : (i64) -> ()
  ^bb17:  // pred: ^bb3
    %50 = "llvm.add"(%3, %1) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    "llvm.br"(%50)[^bb1] : (i64) -> ()
  ^bb18:  // pred: ^bb1
    "llvm.return"() : () -> ()
  }) : () -> ()
}) : () -> ()

