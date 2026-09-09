"builtin.module"() ({
  "llvm.func"() <{CConv = #llvm.cconv<ccc>, function_type = !llvm.func<void (i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, ptr, ptr, ptr)>, linkage = #llvm.linkage<external>, sym_name = "memref_contraction_rank_4", visibility_ = 0 : i64}> ({
  ^bb0(%arg0: i64, %arg1: i64, %arg2: i64, %arg3: i64, %arg4: i64, %arg5: i64, %arg6: i64, %arg7: i64, %arg8: i64, %arg9: i64, %arg10: i64, %arg11: i64, %arg12: i64, %arg13: i64, %arg14: i64, %arg15: i64, %arg16: i64, %arg17: i64, %arg18: i64, %arg19: i64, %arg20: i64, %arg21: i64, %arg22: i64, %arg23: i64, %arg24: i64, %arg25: i64, %arg26: i64, %arg27: i64, %arg28: i64, %arg29: i64, %arg30: i64, %arg31: i64, %arg32: i64, %arg33: i64, %arg34: i64, %arg35: i64, %arg36: !llvm.ptr, %arg37: !llvm.ptr, %arg38: !llvm.ptr):
    %0 = "llvm.mlir.constant"() <{value = 0 : index}> : () -> i64
    %1 = "llvm.mlir.constant"() <{value = 1 : index}> : () -> i64
    %2 = "llvm.mlir.constant"() <{value = 0.000000e+00 : f32}> : () -> f32
    "llvm.br"(%0)[^bb1] : (i64) -> ()
  ^bb1(%3: i64):  // 2 preds: ^bb0, ^bb35
    %4 = "llvm.icmp"(%3, %arg0) <{predicate = 2 : i64}> : (i64, i64) -> i1
    "llvm.cond_br"(%4)[^bb2, ^bb36] <{operandSegmentSizes = array<i32: 1, 0, 0>}> : (i1) -> ()
  ^bb2:  // pred: ^bb1
    "llvm.br"(%0)[^bb3] : (i64) -> ()
  ^bb3(%5: i64):  // 2 preds: ^bb2, ^bb34
    %6 = "llvm.icmp"(%5, %arg1) <{predicate = 2 : i64}> : (i64, i64) -> i1
    "llvm.cond_br"(%6)[^bb4, ^bb35] <{operandSegmentSizes = array<i32: 1, 0, 0>}> : (i1) -> ()
  ^bb4:  // pred: ^bb3
    "llvm.br"(%0)[^bb5] : (i64) -> ()
  ^bb5(%7: i64):  // 2 preds: ^bb4, ^bb33
    %8 = "llvm.icmp"(%7, %arg2) <{predicate = 2 : i64}> : (i64, i64) -> i1
    "llvm.cond_br"(%8)[^bb6, ^bb34] <{operandSegmentSizes = array<i32: 1, 0, 0>}> : (i1) -> ()
  ^bb6:  // pred: ^bb5
    "llvm.br"(%0)[^bb7] : (i64) -> ()
  ^bb7(%9: i64):  // 2 preds: ^bb6, ^bb32
    %10 = "llvm.icmp"(%9, %arg3) <{predicate = 2 : i64}> : (i64, i64) -> i1
    "llvm.cond_br"(%10)[^bb8, ^bb33] <{operandSegmentSizes = array<i32: 1, 0, 0>}> : (i1) -> ()
  ^bb8:  // pred: ^bb7
    "llvm.br"(%0)[^bb9] : (i64) -> ()
  ^bb9(%11: i64):  // 2 preds: ^bb8, ^bb31
    %12 = "llvm.icmp"(%11, %arg4) <{predicate = 2 : i64}> : (i64, i64) -> i1
    "llvm.cond_br"(%12)[^bb10, ^bb32] <{operandSegmentSizes = array<i32: 1, 0, 0>}> : (i1) -> ()
  ^bb10:  // pred: ^bb9
    "llvm.br"(%0)[^bb11] : (i64) -> ()
  ^bb11(%13: i64):  // 2 preds: ^bb10, ^bb30
    %14 = "llvm.icmp"(%13, %arg5) <{predicate = 2 : i64}> : (i64, i64) -> i1
    "llvm.cond_br"(%14)[^bb12, ^bb31] <{operandSegmentSizes = array<i32: 1, 0, 0>}> : (i1) -> ()
  ^bb12:  // pred: ^bb11
    "llvm.br"(%0)[^bb13] : (i64) -> ()
  ^bb13(%15: i64):  // 2 preds: ^bb12, ^bb29
    %16 = "llvm.icmp"(%15, %arg6) <{predicate = 2 : i64}> : (i64, i64) -> i1
    "llvm.cond_br"(%16)[^bb14, ^bb30] <{operandSegmentSizes = array<i32: 1, 0, 0>}> : (i1) -> ()
  ^bb14:  // pred: ^bb13
    "llvm.br"(%0)[^bb15] : (i64) -> ()
  ^bb15(%17: i64):  // 2 preds: ^bb14, ^bb28
    %18 = "llvm.icmp"(%17, %arg7) <{predicate = 2 : i64}> : (i64, i64) -> i1
    "llvm.cond_br"(%18)[^bb16, ^bb29] <{operandSegmentSizes = array<i32: 1, 0, 0>}> : (i1) -> ()
  ^bb16:  // pred: ^bb15
    "llvm.br"(%0, %2)[^bb17] : (i64, f32) -> ()
  ^bb17(%19: i64, %20: f32):  // 2 preds: ^bb16, ^bb27
    %21 = "llvm.icmp"(%19, %arg8) <{predicate = 2 : i64}> : (i64, i64) -> i1
    "llvm.cond_br"(%21)[^bb18, ^bb28] <{operandSegmentSizes = array<i32: 1, 0, 0>}> : (i1) -> ()
  ^bb18:  // pred: ^bb17
    "llvm.br"(%0, %20)[^bb19] : (i64, f32) -> ()
  ^bb19(%22: i64, %23: f32):  // 2 preds: ^bb18, ^bb26
    %24 = "llvm.icmp"(%22, %arg9) <{predicate = 2 : i64}> : (i64, i64) -> i1
    "llvm.cond_br"(%24)[^bb20, ^bb27] <{operandSegmentSizes = array<i32: 1, 0, 0>}> : (i1) -> ()
  ^bb20:  // pred: ^bb19
    "llvm.br"(%0, %23)[^bb21] : (i64, f32) -> ()
  ^bb21(%25: i64, %26: f32):  // 2 preds: ^bb20, ^bb25
    %27 = "llvm.icmp"(%25, %arg10) <{predicate = 2 : i64}> : (i64, i64) -> i1
    "llvm.cond_br"(%27)[^bb22, ^bb26] <{operandSegmentSizes = array<i32: 1, 0, 0>}> : (i1) -> ()
  ^bb22:  // pred: ^bb21
    "llvm.br"(%0, %26)[^bb23] : (i64, f32) -> ()
  ^bb23(%28: i64, %29: f32):  // 2 preds: ^bb22, ^bb24
    %30 = "llvm.icmp"(%28, %arg11) <{predicate = 2 : i64}> : (i64, i64) -> i1
    "llvm.cond_br"(%30)[^bb24, ^bb25] <{operandSegmentSizes = array<i32: 1, 0, 0>}> : (i1) -> ()
  ^bb24:  // pred: ^bb23
    %31 = "llvm.mul"(%3, %arg12) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %32 = "llvm.mul"(%5, %arg13) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %33 = "llvm.add"(%31, %32) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %34 = "llvm.mul"(%7, %arg14) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %35 = "llvm.add"(%33, %34) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %36 = "llvm.mul"(%9, %arg15) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %37 = "llvm.add"(%35, %36) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %38 = "llvm.mul"(%19, %arg16) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %39 = "llvm.add"(%37, %38) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %40 = "llvm.mul"(%22, %arg17) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %41 = "llvm.add"(%39, %40) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %42 = "llvm.mul"(%25, %arg18) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %43 = "llvm.add"(%41, %42) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %44 = "llvm.mul"(%28, %arg19) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %45 = "llvm.add"(%43, %44) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %46 = "llvm.getelementptr"(%arg36, %45) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %47 = "llvm.load"(%46) <{ordering = 0 : i64}> : (!llvm.ptr) -> f32
    %48 = "llvm.mul"(%19, %arg20) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %49 = "llvm.mul"(%22, %arg21) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %50 = "llvm.add"(%48, %49) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %51 = "llvm.mul"(%25, %arg22) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %52 = "llvm.add"(%50, %51) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %53 = "llvm.mul"(%28, %arg23) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %54 = "llvm.add"(%52, %53) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %55 = "llvm.mul"(%11, %arg24) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %56 = "llvm.add"(%54, %55) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %57 = "llvm.mul"(%13, %arg25) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %58 = "llvm.add"(%56, %57) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %59 = "llvm.mul"(%15, %arg26) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %60 = "llvm.add"(%58, %59) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %61 = "llvm.mul"(%17, %arg27) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %62 = "llvm.add"(%60, %61) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %63 = "llvm.getelementptr"(%arg37, %62) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %64 = "llvm.load"(%63) <{ordering = 0 : i64}> : (!llvm.ptr) -> f32
    %65 = "llvm.fmul"(%47, %64) <{fastmathFlags = #llvm.fastmath<none>}> : (f32, f32) -> f32
    %66 = "llvm.fadd"(%29, %65) <{fastmathFlags = #llvm.fastmath<none>}> : (f32, f32) -> f32
    %67 = "llvm.add"(%28, %1) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    "llvm.br"(%67, %66)[^bb23] : (i64, f32) -> ()
  ^bb25:  // pred: ^bb23
    %68 = "llvm.add"(%25, %1) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    "llvm.br"(%68, %29)[^bb21] : (i64, f32) -> ()
  ^bb26:  // pred: ^bb21
    %69 = "llvm.add"(%22, %1) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    "llvm.br"(%69, %26)[^bb19] : (i64, f32) -> ()
  ^bb27:  // pred: ^bb19
    %70 = "llvm.add"(%19, %1) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    "llvm.br"(%70, %23)[^bb17] : (i64, f32) -> ()
  ^bb28:  // pred: ^bb17
    %71 = "llvm.mul"(%3, %arg28) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %72 = "llvm.mul"(%5, %arg29) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %73 = "llvm.add"(%71, %72) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %74 = "llvm.mul"(%7, %arg30) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %75 = "llvm.add"(%73, %74) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %76 = "llvm.mul"(%9, %arg31) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %77 = "llvm.add"(%75, %76) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %78 = "llvm.mul"(%11, %arg32) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %79 = "llvm.add"(%77, %78) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %80 = "llvm.mul"(%13, %arg33) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %81 = "llvm.add"(%79, %80) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %82 = "llvm.mul"(%15, %arg34) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %83 = "llvm.add"(%81, %82) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %84 = "llvm.mul"(%17, %arg35) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %85 = "llvm.add"(%83, %84) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %86 = "llvm.getelementptr"(%arg38, %85) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    "llvm.store"(%20, %86) <{ordering = 0 : i64}> : (f32, !llvm.ptr) -> ()
    %87 = "llvm.add"(%17, %1) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    "llvm.br"(%87)[^bb15] : (i64) -> ()
  ^bb29:  // pred: ^bb15
    %88 = "llvm.add"(%15, %1) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    "llvm.br"(%88)[^bb13] : (i64) -> ()
  ^bb30:  // pred: ^bb13
    %89 = "llvm.add"(%13, %1) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    "llvm.br"(%89)[^bb11] : (i64) -> ()
  ^bb31:  // pred: ^bb11
    %90 = "llvm.add"(%11, %1) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    "llvm.br"(%90)[^bb9] : (i64) -> ()
  ^bb32:  // pred: ^bb9
    %91 = "llvm.add"(%9, %1) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    "llvm.br"(%91)[^bb7] : (i64) -> ()
  ^bb33:  // pred: ^bb7
    %92 = "llvm.add"(%7, %1) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    "llvm.br"(%92)[^bb5] : (i64) -> ()
  ^bb34:  // pred: ^bb5
    %93 = "llvm.add"(%5, %1) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    "llvm.br"(%93)[^bb3] : (i64) -> ()
  ^bb35:  // pred: ^bb3
    %94 = "llvm.add"(%3, %1) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    "llvm.br"(%94)[^bb1] : (i64) -> ()
  ^bb36:  // pred: ^bb1
    "llvm.return"() : () -> ()
  }) : () -> ()
}) : () -> ()

