"builtin.module"() ({
  "llvm.func"() <{CConv = #llvm.cconv<ccc>, function_type = !llvm.func<struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)> (i64, i64, i64, i64, i64, i64, i64, i64, i64, ptr, ptr, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, ptr, ptr, i64, i64, i64, i64, i64, i64, i64, i64, i64, ptr, ptr, i64, i64, i64, i64, i64, i64, i64, i64, i64)>, linkage = #llvm.linkage<external>, sym_name = "baseline_conv2d_kernel", visibility_ = 0 : i64}> ({
  ^bb0(%arg0: i64, %arg1: i64, %arg2: i64, %arg3: i64, %arg4: i64, %arg5: i64, %arg6: i64, %arg7: i64, %arg8: i64, %arg9: !llvm.ptr, %arg10: !llvm.ptr, %arg11: i64, %arg12: i64, %arg13: i64, %arg14: i64, %arg15: i64, %arg16: i64, %arg17: i64, %arg18: i64, %arg19: i64, %arg20: i64, %arg21: i64, %arg22: i64, %arg23: i64, %arg24: !llvm.ptr, %arg25: !llvm.ptr, %arg26: i64, %arg27: i64, %arg28: i64, %arg29: i64, %arg30: i64, %arg31: i64, %arg32: i64, %arg33: i64, %arg34: i64, %arg35: !llvm.ptr, %arg36: !llvm.ptr, %arg37: i64, %arg38: i64, %arg39: i64, %arg40: i64, %arg41: i64, %arg42: i64, %arg43: i64, %arg44: i64, %arg45: i64):
    %0 = "llvm.mlir.poison"() : () -> !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>
    %1 = "llvm.insertvalue"(%0, %arg35) <{position = array<i64: 0>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>, !llvm.ptr) -> !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>
    %2 = "llvm.insertvalue"(%1, %arg36) <{position = array<i64: 1>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>, !llvm.ptr) -> !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>
    %3 = "llvm.insertvalue"(%2, %arg37) <{position = array<i64: 2>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>
    %4 = "llvm.insertvalue"(%3, %arg38) <{position = array<i64: 3, 0>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>
    %5 = "llvm.insertvalue"(%4, %arg42) <{position = array<i64: 4, 0>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>
    %6 = "llvm.insertvalue"(%5, %arg39) <{position = array<i64: 3, 1>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>
    %7 = "llvm.insertvalue"(%6, %arg43) <{position = array<i64: 4, 1>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>
    %8 = "llvm.insertvalue"(%7, %arg40) <{position = array<i64: 3, 2>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>
    %9 = "llvm.insertvalue"(%8, %arg44) <{position = array<i64: 4, 2>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>
    %10 = "llvm.insertvalue"(%9, %arg41) <{position = array<i64: 3, 3>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>
    %11 = "llvm.insertvalue"(%10, %arg45) <{position = array<i64: 4, 3>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>
    %12 = "llvm.mlir.poison"() : () -> !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>
    %13 = "llvm.insertvalue"(%12, %arg24) <{position = array<i64: 0>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>, !llvm.ptr) -> !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>
    %14 = "llvm.insertvalue"(%13, %arg25) <{position = array<i64: 1>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>, !llvm.ptr) -> !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>
    %15 = "llvm.insertvalue"(%14, %arg26) <{position = array<i64: 2>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>
    %16 = "llvm.insertvalue"(%15, %arg27) <{position = array<i64: 3, 0>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>
    %17 = "llvm.insertvalue"(%16, %arg31) <{position = array<i64: 4, 0>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>
    %18 = "llvm.insertvalue"(%17, %arg28) <{position = array<i64: 3, 1>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>
    %19 = "llvm.insertvalue"(%18, %arg32) <{position = array<i64: 4, 1>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>
    %20 = "llvm.insertvalue"(%19, %arg29) <{position = array<i64: 3, 2>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>
    %21 = "llvm.insertvalue"(%20, %arg33) <{position = array<i64: 4, 2>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>
    %22 = "llvm.insertvalue"(%21, %arg30) <{position = array<i64: 3, 3>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>
    %23 = "llvm.insertvalue"(%22, %arg34) <{position = array<i64: 4, 3>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>
    %24 = "llvm.mlir.poison"() : () -> !llvm.struct<(ptr, ptr, i64, array<6 x i64>, array<6 x i64>)>
    %25 = "llvm.insertvalue"(%24, %arg9) <{position = array<i64: 0>}> : (!llvm.struct<(ptr, ptr, i64, array<6 x i64>, array<6 x i64>)>, !llvm.ptr) -> !llvm.struct<(ptr, ptr, i64, array<6 x i64>, array<6 x i64>)>
    %26 = "llvm.insertvalue"(%25, %arg10) <{position = array<i64: 1>}> : (!llvm.struct<(ptr, ptr, i64, array<6 x i64>, array<6 x i64>)>, !llvm.ptr) -> !llvm.struct<(ptr, ptr, i64, array<6 x i64>, array<6 x i64>)>
    %27 = "llvm.insertvalue"(%26, %arg11) <{position = array<i64: 2>}> : (!llvm.struct<(ptr, ptr, i64, array<6 x i64>, array<6 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<6 x i64>, array<6 x i64>)>
    %28 = "llvm.insertvalue"(%27, %arg12) <{position = array<i64: 3, 0>}> : (!llvm.struct<(ptr, ptr, i64, array<6 x i64>, array<6 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<6 x i64>, array<6 x i64>)>
    %29 = "llvm.insertvalue"(%28, %arg18) <{position = array<i64: 4, 0>}> : (!llvm.struct<(ptr, ptr, i64, array<6 x i64>, array<6 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<6 x i64>, array<6 x i64>)>
    %30 = "llvm.insertvalue"(%29, %arg13) <{position = array<i64: 3, 1>}> : (!llvm.struct<(ptr, ptr, i64, array<6 x i64>, array<6 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<6 x i64>, array<6 x i64>)>
    %31 = "llvm.insertvalue"(%30, %arg19) <{position = array<i64: 4, 1>}> : (!llvm.struct<(ptr, ptr, i64, array<6 x i64>, array<6 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<6 x i64>, array<6 x i64>)>
    %32 = "llvm.insertvalue"(%31, %arg14) <{position = array<i64: 3, 2>}> : (!llvm.struct<(ptr, ptr, i64, array<6 x i64>, array<6 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<6 x i64>, array<6 x i64>)>
    %33 = "llvm.insertvalue"(%32, %arg20) <{position = array<i64: 4, 2>}> : (!llvm.struct<(ptr, ptr, i64, array<6 x i64>, array<6 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<6 x i64>, array<6 x i64>)>
    %34 = "llvm.insertvalue"(%33, %arg15) <{position = array<i64: 3, 3>}> : (!llvm.struct<(ptr, ptr, i64, array<6 x i64>, array<6 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<6 x i64>, array<6 x i64>)>
    %35 = "llvm.insertvalue"(%34, %arg21) <{position = array<i64: 4, 3>}> : (!llvm.struct<(ptr, ptr, i64, array<6 x i64>, array<6 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<6 x i64>, array<6 x i64>)>
    %36 = "llvm.insertvalue"(%35, %arg16) <{position = array<i64: 3, 4>}> : (!llvm.struct<(ptr, ptr, i64, array<6 x i64>, array<6 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<6 x i64>, array<6 x i64>)>
    %37 = "llvm.insertvalue"(%36, %arg22) <{position = array<i64: 4, 4>}> : (!llvm.struct<(ptr, ptr, i64, array<6 x i64>, array<6 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<6 x i64>, array<6 x i64>)>
    %38 = "llvm.insertvalue"(%37, %arg17) <{position = array<i64: 3, 5>}> : (!llvm.struct<(ptr, ptr, i64, array<6 x i64>, array<6 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<6 x i64>, array<6 x i64>)>
    %39 = "llvm.insertvalue"(%38, %arg23) <{position = array<i64: 4, 5>}> : (!llvm.struct<(ptr, ptr, i64, array<6 x i64>, array<6 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<6 x i64>, array<6 x i64>)>
    %40 = "llvm.mlir.constant"() <{value = 0 : index}> : () -> i64
    %41 = "llvm.mlir.constant"() <{value = 1 : index}> : () -> i64
    %42 = "llvm.mlir.constant"() <{value = 0.000000e+00 : f32}> : () -> f32
    "llvm.br"(%40, %11)[^bb1] : (i64, !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>) -> ()
  ^bb1(%43: i64, %44: !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>):  // 2 preds: ^bb0, ^bb20
    %45 = "llvm.icmp"(%43, %arg0) <{predicate = 2 : i64}> : (i64, i64) -> i1
    "llvm.cond_br"(%45)[^bb2, ^bb21] <{operandSegmentSizes = array<i32: 1, 0, 0>}> : (i1) -> ()
  ^bb2:  // pred: ^bb1
    "llvm.br"(%40, %44)[^bb3] : (i64, !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>) -> ()
  ^bb3(%46: i64, %47: !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>):  // 2 preds: ^bb2, ^bb19
    %48 = "llvm.icmp"(%46, %arg4) <{predicate = 2 : i64}> : (i64, i64) -> i1
    "llvm.cond_br"(%48)[^bb4, ^bb20] <{operandSegmentSizes = array<i32: 1, 0, 0>}> : (i1) -> ()
  ^bb4:  // pred: ^bb3
    "llvm.br"(%40, %47)[^bb5] : (i64, !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>) -> ()
  ^bb5(%49: i64, %50: !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>):  // 2 preds: ^bb4, ^bb18
    %51 = "llvm.icmp"(%49, %arg7) <{predicate = 2 : i64}> : (i64, i64) -> i1
    "llvm.cond_br"(%51)[^bb6, ^bb19] <{operandSegmentSizes = array<i32: 1, 0, 0>}> : (i1) -> ()
  ^bb6:  // pred: ^bb5
    "llvm.br"(%40, %50)[^bb7] : (i64, !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>) -> ()
  ^bb7(%52: i64, %53: !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>):  // 2 preds: ^bb6, ^bb17
    %54 = "llvm.icmp"(%52, %arg8) <{predicate = 2 : i64}> : (i64, i64) -> i1
    "llvm.cond_br"(%54)[^bb8, ^bb18] <{operandSegmentSizes = array<i32: 1, 0, 0>}> : (i1) -> ()
  ^bb8:  // pred: ^bb7
    "llvm.br"(%40, %42)[^bb9] : (i64, f32) -> ()
  ^bb9(%55: i64, %56: f32):  // 2 preds: ^bb8, ^bb16
    %57 = "llvm.icmp"(%55, %arg1) <{predicate = 2 : i64}> : (i64, i64) -> i1
    "llvm.cond_br"(%57)[^bb10, ^bb17] <{operandSegmentSizes = array<i32: 1, 0, 0>}> : (i1) -> ()
  ^bb10:  // pred: ^bb9
    "llvm.br"(%40, %56)[^bb11] : (i64, f32) -> ()
  ^bb11(%58: i64, %59: f32):  // 2 preds: ^bb10, ^bb15
    %60 = "llvm.icmp"(%58, %arg5) <{predicate = 2 : i64}> : (i64, i64) -> i1
    "llvm.cond_br"(%60)[^bb12, ^bb16] <{operandSegmentSizes = array<i32: 1, 0, 0>}> : (i1) -> ()
  ^bb12:  // pred: ^bb11
    "llvm.br"(%40, %59)[^bb13] : (i64, f32) -> ()
  ^bb13(%61: i64, %62: f32):  // 2 preds: ^bb12, ^bb14
    %63 = "llvm.icmp"(%61, %arg6) <{predicate = 2 : i64}> : (i64, i64) -> i1
    "llvm.cond_br"(%63)[^bb14, ^bb15] <{operandSegmentSizes = array<i32: 1, 0, 0>}> : (i1) -> ()
  ^bb14:  // pred: ^bb13
    %64 = "llvm.extractvalue"(%39) <{position = array<i64: 1>}> : (!llvm.struct<(ptr, ptr, i64, array<6 x i64>, array<6 x i64>)>) -> !llvm.ptr
    %65 = "llvm.extractvalue"(%39) <{position = array<i64: 2>}> : (!llvm.struct<(ptr, ptr, i64, array<6 x i64>, array<6 x i64>)>) -> i64
    %66 = "llvm.getelementptr"(%64, %65) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %67 = "llvm.extractvalue"(%39) <{position = array<i64: 4, 0>}> : (!llvm.struct<(ptr, ptr, i64, array<6 x i64>, array<6 x i64>)>) -> i64
    %68 = "llvm.mul"(%43, %67) <{overflowFlags = 3 : i32}> : (i64, i64) -> i64
    %69 = "llvm.extractvalue"(%39) <{position = array<i64: 4, 1>}> : (!llvm.struct<(ptr, ptr, i64, array<6 x i64>, array<6 x i64>)>) -> i64
    %70 = "llvm.mul"(%55, %69) <{overflowFlags = 3 : i32}> : (i64, i64) -> i64
    %71 = "llvm.add"(%68, %70) <{overflowFlags = 3 : i32}> : (i64, i64) -> i64
    %72 = "llvm.extractvalue"(%39) <{position = array<i64: 4, 2>}> : (!llvm.struct<(ptr, ptr, i64, array<6 x i64>, array<6 x i64>)>) -> i64
    %73 = "llvm.mul"(%49, %72) <{overflowFlags = 3 : i32}> : (i64, i64) -> i64
    %74 = "llvm.add"(%71, %73) <{overflowFlags = 3 : i32}> : (i64, i64) -> i64
    %75 = "llvm.extractvalue"(%39) <{position = array<i64: 4, 3>}> : (!llvm.struct<(ptr, ptr, i64, array<6 x i64>, array<6 x i64>)>) -> i64
    %76 = "llvm.mul"(%52, %75) <{overflowFlags = 3 : i32}> : (i64, i64) -> i64
    %77 = "llvm.add"(%74, %76) <{overflowFlags = 3 : i32}> : (i64, i64) -> i64
    %78 = "llvm.extractvalue"(%39) <{position = array<i64: 4, 4>}> : (!llvm.struct<(ptr, ptr, i64, array<6 x i64>, array<6 x i64>)>) -> i64
    %79 = "llvm.mul"(%58, %78) <{overflowFlags = 3 : i32}> : (i64, i64) -> i64
    %80 = "llvm.add"(%77, %79) <{overflowFlags = 3 : i32}> : (i64, i64) -> i64
    %81 = "llvm.extractvalue"(%39) <{position = array<i64: 4, 5>}> : (!llvm.struct<(ptr, ptr, i64, array<6 x i64>, array<6 x i64>)>) -> i64
    %82 = "llvm.mul"(%61, %81) <{overflowFlags = 3 : i32}> : (i64, i64) -> i64
    %83 = "llvm.add"(%80, %82) <{overflowFlags = 3 : i32}> : (i64, i64) -> i64
    %84 = "llvm.getelementptr"(%66, %83) <{elem_type = f32, noWrapFlags = 7 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %85 = "llvm.load"(%84) <{ordering = 0 : i64}> : (!llvm.ptr) -> f32
    %86 = "llvm.extractvalue"(%23) <{position = array<i64: 1>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>) -> !llvm.ptr
    %87 = "llvm.extractvalue"(%23) <{position = array<i64: 2>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>) -> i64
    %88 = "llvm.getelementptr"(%86, %87) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %89 = "llvm.extractvalue"(%23) <{position = array<i64: 4, 0>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>) -> i64
    %90 = "llvm.mul"(%46, %89) <{overflowFlags = 3 : i32}> : (i64, i64) -> i64
    %91 = "llvm.extractvalue"(%23) <{position = array<i64: 4, 1>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>) -> i64
    %92 = "llvm.mul"(%55, %91) <{overflowFlags = 3 : i32}> : (i64, i64) -> i64
    %93 = "llvm.add"(%90, %92) <{overflowFlags = 3 : i32}> : (i64, i64) -> i64
    %94 = "llvm.extractvalue"(%23) <{position = array<i64: 4, 2>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>) -> i64
    %95 = "llvm.mul"(%58, %94) <{overflowFlags = 3 : i32}> : (i64, i64) -> i64
    %96 = "llvm.add"(%93, %95) <{overflowFlags = 3 : i32}> : (i64, i64) -> i64
    %97 = "llvm.extractvalue"(%23) <{position = array<i64: 4, 3>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>) -> i64
    %98 = "llvm.mul"(%61, %97) <{overflowFlags = 3 : i32}> : (i64, i64) -> i64
    %99 = "llvm.add"(%96, %98) <{overflowFlags = 3 : i32}> : (i64, i64) -> i64
    %100 = "llvm.getelementptr"(%88, %99) <{elem_type = f32, noWrapFlags = 7 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %101 = "llvm.load"(%100) <{ordering = 0 : i64}> : (!llvm.ptr) -> f32
    %102 = "llvm.fmul"(%85, %101) <{fastmathFlags = #llvm.fastmath<none>}> : (f32, f32) -> f32
    %103 = "llvm.fadd"(%62, %102) <{fastmathFlags = #llvm.fastmath<none>}> : (f32, f32) -> f32
    %104 = "llvm.add"(%61, %41) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    "llvm.br"(%104, %103)[^bb13] : (i64, f32) -> ()
  ^bb15:  // pred: ^bb13
    %105 = "llvm.add"(%58, %41) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    "llvm.br"(%105, %62)[^bb11] : (i64, f32) -> ()
  ^bb16:  // pred: ^bb11
    %106 = "llvm.add"(%55, %41) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    "llvm.br"(%106, %59)[^bb9] : (i64, f32) -> ()
  ^bb17:  // pred: ^bb9
    %107 = "llvm.extractvalue"(%53) <{position = array<i64: 1>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>) -> !llvm.ptr
    %108 = "llvm.extractvalue"(%53) <{position = array<i64: 2>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>) -> i64
    %109 = "llvm.getelementptr"(%107, %108) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %110 = "llvm.extractvalue"(%53) <{position = array<i64: 4, 0>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>) -> i64
    %111 = "llvm.mul"(%43, %110) <{overflowFlags = 3 : i32}> : (i64, i64) -> i64
    %112 = "llvm.extractvalue"(%53) <{position = array<i64: 4, 1>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>) -> i64
    %113 = "llvm.mul"(%46, %112) <{overflowFlags = 3 : i32}> : (i64, i64) -> i64
    %114 = "llvm.add"(%111, %113) <{overflowFlags = 3 : i32}> : (i64, i64) -> i64
    %115 = "llvm.extractvalue"(%53) <{position = array<i64: 4, 2>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>) -> i64
    %116 = "llvm.mul"(%49, %115) <{overflowFlags = 3 : i32}> : (i64, i64) -> i64
    %117 = "llvm.add"(%114, %116) <{overflowFlags = 3 : i32}> : (i64, i64) -> i64
    %118 = "llvm.extractvalue"(%53) <{position = array<i64: 4, 3>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>) -> i64
    %119 = "llvm.mul"(%52, %118) <{overflowFlags = 3 : i32}> : (i64, i64) -> i64
    %120 = "llvm.add"(%117, %119) <{overflowFlags = 3 : i32}> : (i64, i64) -> i64
    %121 = "llvm.getelementptr"(%109, %120) <{elem_type = f32, noWrapFlags = 7 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    "llvm.store"(%56, %121) <{ordering = 0 : i64}> : (f32, !llvm.ptr) -> ()
    %122 = "llvm.add"(%52, %41) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    "llvm.br"(%122, %53)[^bb7] : (i64, !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>) -> ()
  ^bb18:  // pred: ^bb7
    %123 = "llvm.add"(%49, %41) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    "llvm.br"(%123, %53)[^bb5] : (i64, !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>) -> ()
  ^bb19:  // pred: ^bb5
    %124 = "llvm.add"(%46, %41) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    "llvm.br"(%124, %50)[^bb3] : (i64, !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>) -> ()
  ^bb20:  // pred: ^bb3
    %125 = "llvm.add"(%43, %41) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    "llvm.br"(%125, %47)[^bb1] : (i64, !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>) -> ()
  ^bb21:  // pred: ^bb1
    "llvm.return"(%44) : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>) -> ()
  }) : () -> ()
}) : () -> ()

