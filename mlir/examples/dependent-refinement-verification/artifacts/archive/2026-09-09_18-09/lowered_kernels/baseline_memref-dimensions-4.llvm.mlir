"builtin.module"() ({
  "llvm.func"() <{CConv = #llvm.cconv<ccc>, function_type = !llvm.func<void (i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, ptr, ptr, i64, i64, i64, ptr, ptr, i64, i64, i64, ptr, ptr, i64, i64, i64)>, linkage = #llvm.linkage<external>, sym_name = "baseline_memref_contraction_rank_2", visibility_ = 0 : i64}> ({
  ^bb0(%arg0: i64, %arg1: i64, %arg2: i64, %arg3: i64, %arg4: i64, %arg5: i64, %arg6: i64, %arg7: i64, %arg8: i64, %arg9: i64, %arg10: i64, %arg11: i64, %arg12: i64, %arg13: i64, %arg14: i64, %arg15: i64, %arg16: i64, %arg17: i64, %arg18: !llvm.ptr, %arg19: !llvm.ptr, %arg20: i64, %arg21: i64, %arg22: i64, %arg23: !llvm.ptr, %arg24: !llvm.ptr, %arg25: i64, %arg26: i64, %arg27: i64, %arg28: !llvm.ptr, %arg29: !llvm.ptr, %arg30: i64, %arg31: i64, %arg32: i64):
    %0 = "llvm.mlir.poison"() : () -> !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>
    %1 = "llvm.insertvalue"(%0, %arg28) <{position = array<i64: 0>}> : (!llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>, !llvm.ptr) -> !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>
    %2 = "llvm.insertvalue"(%1, %arg29) <{position = array<i64: 1>}> : (!llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>, !llvm.ptr) -> !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>
    %3 = "llvm.insertvalue"(%2, %arg30) <{position = array<i64: 2>}> : (!llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>
    %4 = "llvm.insertvalue"(%3, %arg31) <{position = array<i64: 3, 0>}> : (!llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>
    %5 = "llvm.insertvalue"(%4, %arg32) <{position = array<i64: 4, 0>}> : (!llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>
    %6 = "llvm.mlir.poison"() : () -> !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>
    %7 = "llvm.insertvalue"(%6, %arg23) <{position = array<i64: 0>}> : (!llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>, !llvm.ptr) -> !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>
    %8 = "llvm.insertvalue"(%7, %arg24) <{position = array<i64: 1>}> : (!llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>, !llvm.ptr) -> !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>
    %9 = "llvm.insertvalue"(%8, %arg25) <{position = array<i64: 2>}> : (!llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>
    %10 = "llvm.insertvalue"(%9, %arg26) <{position = array<i64: 3, 0>}> : (!llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>
    %11 = "llvm.insertvalue"(%10, %arg27) <{position = array<i64: 4, 0>}> : (!llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>
    %12 = "llvm.mlir.poison"() : () -> !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>
    %13 = "llvm.insertvalue"(%12, %arg18) <{position = array<i64: 0>}> : (!llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>, !llvm.ptr) -> !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>
    %14 = "llvm.insertvalue"(%13, %arg19) <{position = array<i64: 1>}> : (!llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>, !llvm.ptr) -> !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>
    %15 = "llvm.insertvalue"(%14, %arg20) <{position = array<i64: 2>}> : (!llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>
    %16 = "llvm.insertvalue"(%15, %arg21) <{position = array<i64: 3, 0>}> : (!llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>
    %17 = "llvm.insertvalue"(%16, %arg22) <{position = array<i64: 4, 0>}> : (!llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>
    %18 = "llvm.mlir.constant"() <{value = 0 : index}> : () -> i64
    %19 = "llvm.mlir.constant"() <{value = 1 : index}> : () -> i64
    %20 = "llvm.mlir.constant"() <{value = 0.000000e+00 : f32}> : () -> f32
    %21 = "llvm.mlir.poison"() : () -> !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>
    %22 = "llvm.extractvalue"(%17) <{position = array<i64: 0>}> : (!llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>) -> !llvm.ptr
    %23 = "llvm.extractvalue"(%17) <{position = array<i64: 1>}> : (!llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>) -> !llvm.ptr
    %24 = "llvm.insertvalue"(%21, %22) <{position = array<i64: 0>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>, !llvm.ptr) -> !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>
    %25 = "llvm.insertvalue"(%24, %23) <{position = array<i64: 1>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>, !llvm.ptr) -> !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>
    %26 = "llvm.mlir.constant"() <{value = 0 : index}> : () -> i64
    %27 = "llvm.insertvalue"(%25, %26) <{position = array<i64: 2>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>
    %28 = "llvm.insertvalue"(%27, %arg0) <{position = array<i64: 3, 0>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>
    %29 = "llvm.insertvalue"(%28, %arg6) <{position = array<i64: 4, 0>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>
    %30 = "llvm.insertvalue"(%29, %arg1) <{position = array<i64: 3, 1>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>
    %31 = "llvm.insertvalue"(%30, %arg7) <{position = array<i64: 4, 1>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>
    %32 = "llvm.insertvalue"(%31, %arg4) <{position = array<i64: 3, 2>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>
    %33 = "llvm.insertvalue"(%32, %arg8) <{position = array<i64: 4, 2>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>
    %34 = "llvm.insertvalue"(%33, %arg5) <{position = array<i64: 3, 3>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>
    %35 = "llvm.insertvalue"(%34, %arg9) <{position = array<i64: 4, 3>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>
    %36 = "llvm.mlir.poison"() : () -> !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>
    %37 = "llvm.extractvalue"(%11) <{position = array<i64: 0>}> : (!llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>) -> !llvm.ptr
    %38 = "llvm.extractvalue"(%11) <{position = array<i64: 1>}> : (!llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>) -> !llvm.ptr
    %39 = "llvm.insertvalue"(%36, %37) <{position = array<i64: 0>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>, !llvm.ptr) -> !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>
    %40 = "llvm.insertvalue"(%39, %38) <{position = array<i64: 1>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>, !llvm.ptr) -> !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>
    %41 = "llvm.mlir.constant"() <{value = 0 : index}> : () -> i64
    %42 = "llvm.insertvalue"(%40, %41) <{position = array<i64: 2>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>
    %43 = "llvm.insertvalue"(%42, %arg4) <{position = array<i64: 3, 0>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>
    %44 = "llvm.insertvalue"(%43, %arg10) <{position = array<i64: 4, 0>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>
    %45 = "llvm.insertvalue"(%44, %arg5) <{position = array<i64: 3, 1>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>
    %46 = "llvm.insertvalue"(%45, %arg11) <{position = array<i64: 4, 1>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>
    %47 = "llvm.insertvalue"(%46, %arg2) <{position = array<i64: 3, 2>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>
    %48 = "llvm.insertvalue"(%47, %arg12) <{position = array<i64: 4, 2>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>
    %49 = "llvm.insertvalue"(%48, %arg3) <{position = array<i64: 3, 3>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>
    %50 = "llvm.insertvalue"(%49, %arg13) <{position = array<i64: 4, 3>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>
    %51 = "llvm.mlir.poison"() : () -> !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>
    %52 = "llvm.extractvalue"(%5) <{position = array<i64: 0>}> : (!llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>) -> !llvm.ptr
    %53 = "llvm.extractvalue"(%5) <{position = array<i64: 1>}> : (!llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>) -> !llvm.ptr
    %54 = "llvm.insertvalue"(%51, %52) <{position = array<i64: 0>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>, !llvm.ptr) -> !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>
    %55 = "llvm.insertvalue"(%54, %53) <{position = array<i64: 1>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>, !llvm.ptr) -> !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>
    %56 = "llvm.mlir.constant"() <{value = 0 : index}> : () -> i64
    %57 = "llvm.insertvalue"(%55, %56) <{position = array<i64: 2>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>
    %58 = "llvm.insertvalue"(%57, %arg0) <{position = array<i64: 3, 0>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>
    %59 = "llvm.insertvalue"(%58, %arg14) <{position = array<i64: 4, 0>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>
    %60 = "llvm.insertvalue"(%59, %arg1) <{position = array<i64: 3, 1>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>
    %61 = "llvm.insertvalue"(%60, %arg15) <{position = array<i64: 4, 1>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>
    %62 = "llvm.insertvalue"(%61, %arg2) <{position = array<i64: 3, 2>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>
    %63 = "llvm.insertvalue"(%62, %arg16) <{position = array<i64: 4, 2>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>
    %64 = "llvm.insertvalue"(%63, %arg3) <{position = array<i64: 3, 3>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>
    %65 = "llvm.insertvalue"(%64, %arg17) <{position = array<i64: 4, 3>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>
    "llvm.br"(%18)[^bb1] : (i64) -> ()
  ^bb1(%66: i64):  // 2 preds: ^bb0, ^bb17
    %67 = "llvm.icmp"(%66, %arg0) <{predicate = 2 : i64}> : (i64, i64) -> i1
    "llvm.cond_br"(%67)[^bb2, ^bb18] <{operandSegmentSizes = array<i32: 1, 0, 0>}> : (i1) -> ()
  ^bb2:  // pred: ^bb1
    "llvm.br"(%18)[^bb3] : (i64) -> ()
  ^bb3(%68: i64):  // 2 preds: ^bb2, ^bb16
    %69 = "llvm.icmp"(%68, %arg1) <{predicate = 2 : i64}> : (i64, i64) -> i1
    "llvm.cond_br"(%69)[^bb4, ^bb17] <{operandSegmentSizes = array<i32: 1, 0, 0>}> : (i1) -> ()
  ^bb4:  // pred: ^bb3
    "llvm.br"(%18)[^bb5] : (i64) -> ()
  ^bb5(%70: i64):  // 2 preds: ^bb4, ^bb15
    %71 = "llvm.icmp"(%70, %arg2) <{predicate = 2 : i64}> : (i64, i64) -> i1
    "llvm.cond_br"(%71)[^bb6, ^bb16] <{operandSegmentSizes = array<i32: 1, 0, 0>}> : (i1) -> ()
  ^bb6:  // pred: ^bb5
    "llvm.br"(%18)[^bb7] : (i64) -> ()
  ^bb7(%72: i64):  // 2 preds: ^bb6, ^bb14
    %73 = "llvm.icmp"(%72, %arg3) <{predicate = 2 : i64}> : (i64, i64) -> i1
    "llvm.cond_br"(%73)[^bb8, ^bb15] <{operandSegmentSizes = array<i32: 1, 0, 0>}> : (i1) -> ()
  ^bb8:  // pred: ^bb7
    "llvm.br"(%18, %20)[^bb9] : (i64, f32) -> ()
  ^bb9(%74: i64, %75: f32):  // 2 preds: ^bb8, ^bb13
    %76 = "llvm.icmp"(%74, %arg4) <{predicate = 2 : i64}> : (i64, i64) -> i1
    "llvm.cond_br"(%76)[^bb10, ^bb14] <{operandSegmentSizes = array<i32: 1, 0, 0>}> : (i1) -> ()
  ^bb10:  // pred: ^bb9
    "llvm.br"(%18, %75)[^bb11] : (i64, f32) -> ()
  ^bb11(%77: i64, %78: f32):  // 2 preds: ^bb10, ^bb12
    %79 = "llvm.icmp"(%77, %arg5) <{predicate = 2 : i64}> : (i64, i64) -> i1
    "llvm.cond_br"(%79)[^bb12, ^bb13] <{operandSegmentSizes = array<i32: 1, 0, 0>}> : (i1) -> ()
  ^bb12:  // pred: ^bb11
    %80 = "llvm.extractvalue"(%35) <{position = array<i64: 1>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>) -> !llvm.ptr
    %81 = "llvm.extractvalue"(%35) <{position = array<i64: 2>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>) -> i64
    %82 = "llvm.getelementptr"(%80, %81) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %83 = "llvm.extractvalue"(%35) <{position = array<i64: 4, 0>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>) -> i64
    %84 = "llvm.mul"(%66, %83) <{overflowFlags = 3 : i32}> : (i64, i64) -> i64
    %85 = "llvm.extractvalue"(%35) <{position = array<i64: 4, 1>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>) -> i64
    %86 = "llvm.mul"(%68, %85) <{overflowFlags = 3 : i32}> : (i64, i64) -> i64
    %87 = "llvm.add"(%84, %86) <{overflowFlags = 3 : i32}> : (i64, i64) -> i64
    %88 = "llvm.extractvalue"(%35) <{position = array<i64: 4, 2>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>) -> i64
    %89 = "llvm.mul"(%74, %88) <{overflowFlags = 3 : i32}> : (i64, i64) -> i64
    %90 = "llvm.add"(%87, %89) <{overflowFlags = 3 : i32}> : (i64, i64) -> i64
    %91 = "llvm.extractvalue"(%35) <{position = array<i64: 4, 3>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>) -> i64
    %92 = "llvm.mul"(%77, %91) <{overflowFlags = 3 : i32}> : (i64, i64) -> i64
    %93 = "llvm.add"(%90, %92) <{overflowFlags = 3 : i32}> : (i64, i64) -> i64
    %94 = "llvm.getelementptr"(%82, %93) <{elem_type = f32, noWrapFlags = 7 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %95 = "llvm.load"(%94) <{ordering = 0 : i64}> : (!llvm.ptr) -> f32
    %96 = "llvm.extractvalue"(%50) <{position = array<i64: 1>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>) -> !llvm.ptr
    %97 = "llvm.extractvalue"(%50) <{position = array<i64: 2>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>) -> i64
    %98 = "llvm.getelementptr"(%96, %97) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %99 = "llvm.extractvalue"(%50) <{position = array<i64: 4, 0>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>) -> i64
    %100 = "llvm.mul"(%74, %99) <{overflowFlags = 3 : i32}> : (i64, i64) -> i64
    %101 = "llvm.extractvalue"(%50) <{position = array<i64: 4, 1>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>) -> i64
    %102 = "llvm.mul"(%77, %101) <{overflowFlags = 3 : i32}> : (i64, i64) -> i64
    %103 = "llvm.add"(%100, %102) <{overflowFlags = 3 : i32}> : (i64, i64) -> i64
    %104 = "llvm.extractvalue"(%50) <{position = array<i64: 4, 2>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>) -> i64
    %105 = "llvm.mul"(%70, %104) <{overflowFlags = 3 : i32}> : (i64, i64) -> i64
    %106 = "llvm.add"(%103, %105) <{overflowFlags = 3 : i32}> : (i64, i64) -> i64
    %107 = "llvm.extractvalue"(%50) <{position = array<i64: 4, 3>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>) -> i64
    %108 = "llvm.mul"(%72, %107) <{overflowFlags = 3 : i32}> : (i64, i64) -> i64
    %109 = "llvm.add"(%106, %108) <{overflowFlags = 3 : i32}> : (i64, i64) -> i64
    %110 = "llvm.getelementptr"(%98, %109) <{elem_type = f32, noWrapFlags = 7 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %111 = "llvm.load"(%110) <{ordering = 0 : i64}> : (!llvm.ptr) -> f32
    %112 = "llvm.fmul"(%95, %111) <{fastmathFlags = #llvm.fastmath<none>}> : (f32, f32) -> f32
    %113 = "llvm.fadd"(%78, %112) <{fastmathFlags = #llvm.fastmath<none>}> : (f32, f32) -> f32
    %114 = "llvm.add"(%77, %19) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    "llvm.br"(%114, %113)[^bb11] : (i64, f32) -> ()
  ^bb13:  // pred: ^bb11
    %115 = "llvm.add"(%74, %19) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    "llvm.br"(%115, %78)[^bb9] : (i64, f32) -> ()
  ^bb14:  // pred: ^bb9
    %116 = "llvm.extractvalue"(%65) <{position = array<i64: 1>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>) -> !llvm.ptr
    %117 = "llvm.extractvalue"(%65) <{position = array<i64: 2>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>) -> i64
    %118 = "llvm.getelementptr"(%116, %117) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %119 = "llvm.extractvalue"(%65) <{position = array<i64: 4, 0>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>) -> i64
    %120 = "llvm.mul"(%66, %119) <{overflowFlags = 3 : i32}> : (i64, i64) -> i64
    %121 = "llvm.extractvalue"(%65) <{position = array<i64: 4, 1>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>) -> i64
    %122 = "llvm.mul"(%68, %121) <{overflowFlags = 3 : i32}> : (i64, i64) -> i64
    %123 = "llvm.add"(%120, %122) <{overflowFlags = 3 : i32}> : (i64, i64) -> i64
    %124 = "llvm.extractvalue"(%65) <{position = array<i64: 4, 2>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>) -> i64
    %125 = "llvm.mul"(%70, %124) <{overflowFlags = 3 : i32}> : (i64, i64) -> i64
    %126 = "llvm.add"(%123, %125) <{overflowFlags = 3 : i32}> : (i64, i64) -> i64
    %127 = "llvm.extractvalue"(%65) <{position = array<i64: 4, 3>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>) -> i64
    %128 = "llvm.mul"(%72, %127) <{overflowFlags = 3 : i32}> : (i64, i64) -> i64
    %129 = "llvm.add"(%126, %128) <{overflowFlags = 3 : i32}> : (i64, i64) -> i64
    %130 = "llvm.getelementptr"(%118, %129) <{elem_type = f32, noWrapFlags = 7 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    "llvm.store"(%75, %130) <{ordering = 0 : i64}> : (f32, !llvm.ptr) -> ()
    %131 = "llvm.add"(%72, %19) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    "llvm.br"(%131)[^bb7] : (i64) -> ()
  ^bb15:  // pred: ^bb7
    %132 = "llvm.add"(%70, %19) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    "llvm.br"(%132)[^bb5] : (i64) -> ()
  ^bb16:  // pred: ^bb5
    %133 = "llvm.add"(%68, %19) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    "llvm.br"(%133)[^bb3] : (i64) -> ()
  ^bb17:  // pred: ^bb3
    %134 = "llvm.add"(%66, %19) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    "llvm.br"(%134)[^bb1] : (i64) -> ()
  ^bb18:  // pred: ^bb1
    "llvm.return"() : () -> ()
  }) : () -> ()
}) : () -> ()

