"builtin.module"() ({
  "llvm.func"() <{CConv = #llvm.cconv<ccc>, function_type = !llvm.func<void (i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, ptr, ptr, ptr)>, linkage = #llvm.linkage<external>, sym_name = "dependent_conv2d_strided", visibility_ = 0 : i64}> ({
  ^bb0(%arg0: i64, %arg1: i64, %arg2: i64, %arg3: i64, %arg4: i64, %arg5: i64, %arg6: i64, %arg7: i64, %arg8: i64, %arg9: i64, %arg10: i64, %arg11: i64, %arg12: i64, %arg13: i64, %arg14: i64, %arg15: i64, %arg16: i64, %arg17: i64, %arg18: i64, %arg19: !llvm.ptr, %arg20: !llvm.ptr, %arg21: !llvm.ptr):
    %0 = "llvm.mlir.constant"() <{value = 0 : index}> : () -> i64
    %1 = "llvm.mlir.constant"() <{value = 1 : index}> : () -> i64
    %2 = "llvm.mlir.constant"() <{value = 0.000000e+00 : f32}> : () -> f32
    "llvm.br"(%0)[^bb1] : (i64) -> ()
  ^bb1(%3: i64):  // 2 preds: ^bb0, ^bb20
    %4 = "llvm.icmp"(%3, %arg0) <{predicate = 2 : i64}> : (i64, i64) -> i1
    "llvm.cond_br"(%4)[^bb2, ^bb21] <{operandSegmentSizes = array<i32: 1, 0, 0>}> : (i1) -> ()
  ^bb2:  // pred: ^bb1
    "llvm.br"(%0)[^bb3] : (i64) -> ()
  ^bb3(%5: i64):  // 2 preds: ^bb2, ^bb19
    %6 = "llvm.icmp"(%5, %arg4) <{predicate = 2 : i64}> : (i64, i64) -> i1
    "llvm.cond_br"(%6)[^bb4, ^bb20] <{operandSegmentSizes = array<i32: 1, 0, 0>}> : (i1) -> ()
  ^bb4:  // pred: ^bb3
    "llvm.br"(%0)[^bb5] : (i64) -> ()
  ^bb5(%7: i64):  // 2 preds: ^bb4, ^bb18
    %8 = "llvm.icmp"(%7, %arg7) <{predicate = 2 : i64}> : (i64, i64) -> i1
    "llvm.cond_br"(%8)[^bb6, ^bb19] <{operandSegmentSizes = array<i32: 1, 0, 0>}> : (i1) -> ()
  ^bb6:  // pred: ^bb5
    "llvm.br"(%0)[^bb7] : (i64) -> ()
  ^bb7(%9: i64):  // 2 preds: ^bb6, ^bb17
    %10 = "llvm.icmp"(%9, %arg8) <{predicate = 2 : i64}> : (i64, i64) -> i1
    "llvm.cond_br"(%10)[^bb8, ^bb18] <{operandSegmentSizes = array<i32: 1, 0, 0>}> : (i1) -> ()
  ^bb8:  // pred: ^bb7
    "llvm.br"(%0, %2)[^bb9] : (i64, f32) -> ()
  ^bb9(%11: i64, %12: f32):  // 2 preds: ^bb8, ^bb16
    %13 = "llvm.icmp"(%11, %arg1) <{predicate = 2 : i64}> : (i64, i64) -> i1
    "llvm.cond_br"(%13)[^bb10, ^bb17] <{operandSegmentSizes = array<i32: 1, 0, 0>}> : (i1) -> ()
  ^bb10:  // pred: ^bb9
    "llvm.br"(%0, %12)[^bb11] : (i64, f32) -> ()
  ^bb11(%14: i64, %15: f32):  // 2 preds: ^bb10, ^bb15
    %16 = "llvm.icmp"(%14, %arg5) <{predicate = 2 : i64}> : (i64, i64) -> i1
    "llvm.cond_br"(%16)[^bb12, ^bb16] <{operandSegmentSizes = array<i32: 1, 0, 0>}> : (i1) -> ()
  ^bb12:  // pred: ^bb11
    "llvm.br"(%0, %15)[^bb13] : (i64, f32) -> ()
  ^bb13(%17: i64, %18: f32):  // 2 preds: ^bb12, ^bb14
    %19 = "llvm.icmp"(%17, %arg6) <{predicate = 2 : i64}> : (i64, i64) -> i1
    "llvm.cond_br"(%19)[^bb14, ^bb15] <{operandSegmentSizes = array<i32: 1, 0, 0>}> : (i1) -> ()
  ^bb14:  // pred: ^bb13
    %20 = "llvm.mul"(%3, %arg9) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %21 = "llvm.mul"(%11, %arg10) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %22 = "llvm.add"(%20, %21) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %23 = "llvm.mul"(%7, %arg11) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %24 = "llvm.add"(%22, %23) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %25 = "llvm.mul"(%9, %arg12) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %26 = "llvm.add"(%24, %25) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %27 = "llvm.mul"(%14, %arg11) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %28 = "llvm.add"(%26, %27) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %29 = "llvm.mul"(%17, %arg12) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %30 = "llvm.add"(%28, %29) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %31 = "llvm.getelementptr"(%arg19, %30) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %32 = "llvm.load"(%31) <{ordering = 0 : i64}> : (!llvm.ptr) -> f32
    %33 = "llvm.mul"(%5, %arg13) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %34 = "llvm.mul"(%11, %arg14) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %35 = "llvm.add"(%33, %34) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %36 = "llvm.mul"(%14, %arg15) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %37 = "llvm.add"(%35, %36) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %38 = "llvm.mul"(%17, %arg12) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %39 = "llvm.add"(%37, %38) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %40 = "llvm.getelementptr"(%arg20, %39) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %41 = "llvm.load"(%40) <{ordering = 0 : i64}> : (!llvm.ptr) -> f32
    %42 = "llvm.fmul"(%32, %41) <{fastmathFlags = #llvm.fastmath<none>}> : (f32, f32) -> f32
    %43 = "llvm.fadd"(%18, %42) <{fastmathFlags = #llvm.fastmath<none>}> : (f32, f32) -> f32
    %44 = "llvm.add"(%17, %1) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    "llvm.br"(%44, %43)[^bb13] : (i64, f32) -> ()
  ^bb15:  // pred: ^bb13
    %45 = "llvm.add"(%14, %1) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    "llvm.br"(%45, %18)[^bb11] : (i64, f32) -> ()
  ^bb16:  // pred: ^bb11
    %46 = "llvm.add"(%11, %1) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    "llvm.br"(%46, %15)[^bb9] : (i64, f32) -> ()
  ^bb17:  // pred: ^bb9
    %47 = "llvm.mul"(%3, %arg16) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %48 = "llvm.mul"(%5, %arg17) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %49 = "llvm.add"(%47, %48) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %50 = "llvm.mul"(%7, %arg18) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %51 = "llvm.add"(%49, %50) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %52 = "llvm.mul"(%9, %arg12) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %53 = "llvm.add"(%51, %52) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %54 = "llvm.getelementptr"(%arg21, %53) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    "llvm.store"(%12, %54) <{ordering = 0 : i64}> : (f32, !llvm.ptr) -> ()
    %55 = "llvm.add"(%9, %1) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    "llvm.br"(%55)[^bb7] : (i64) -> ()
  ^bb18:  // pred: ^bb7
    %56 = "llvm.add"(%7, %1) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    "llvm.br"(%56)[^bb5] : (i64) -> ()
  ^bb19:  // pred: ^bb5
    %57 = "llvm.add"(%5, %1) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    "llvm.br"(%57)[^bb3] : (i64) -> ()
  ^bb20:  // pred: ^bb3
    %58 = "llvm.add"(%3, %1) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    "llvm.br"(%58)[^bb1] : (i64) -> ()
  ^bb21:  // pred: ^bb1
    "llvm.return"() : () -> ()
  }) : () -> ()
}) : () -> ()

