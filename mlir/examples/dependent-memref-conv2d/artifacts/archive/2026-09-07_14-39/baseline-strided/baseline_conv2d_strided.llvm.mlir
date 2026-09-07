"builtin.module"() ({
  "llvm.func"() <{CConv = #llvm.cconv<ccc>, function_type = !llvm.func<void (i64, i64, i64, i64, i64, i64, i64, i64, i64, ptr, ptr, i64, i64, i64, ptr, ptr, i64, i64, i64, ptr, ptr, i64, i64, i64)>, linkage = #llvm.linkage<external>, sym_name = "baseline_conv2d_strided", visibility_ = 0 : i64}> ({
  ^bb0(%arg0: i64, %arg1: i64, %arg2: i64, %arg3: i64, %arg4: i64, %arg5: i64, %arg6: i64, %arg7: i64, %arg8: i64, %arg9: !llvm.ptr, %arg10: !llvm.ptr, %arg11: i64, %arg12: i64, %arg13: i64, %arg14: !llvm.ptr, %arg15: !llvm.ptr, %arg16: i64, %arg17: i64, %arg18: i64, %arg19: !llvm.ptr, %arg20: !llvm.ptr, %arg21: i64, %arg22: i64, %arg23: i64):
    %0 = "llvm.mlir.poison"() : () -> !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>
    %1 = "llvm.insertvalue"(%0, %arg19) <{position = array<i64: 0>}> : (!llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>, !llvm.ptr) -> !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>
    %2 = "llvm.insertvalue"(%1, %arg20) <{position = array<i64: 1>}> : (!llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>, !llvm.ptr) -> !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>
    %3 = "llvm.insertvalue"(%2, %arg21) <{position = array<i64: 2>}> : (!llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>
    %4 = "llvm.insertvalue"(%3, %arg22) <{position = array<i64: 3, 0>}> : (!llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>
    %5 = "llvm.insertvalue"(%4, %arg23) <{position = array<i64: 4, 0>}> : (!llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>
    %6 = "llvm.mlir.poison"() : () -> !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>
    %7 = "llvm.insertvalue"(%6, %arg14) <{position = array<i64: 0>}> : (!llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>, !llvm.ptr) -> !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>
    %8 = "llvm.insertvalue"(%7, %arg15) <{position = array<i64: 1>}> : (!llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>, !llvm.ptr) -> !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>
    %9 = "llvm.insertvalue"(%8, %arg16) <{position = array<i64: 2>}> : (!llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>
    %10 = "llvm.insertvalue"(%9, %arg17) <{position = array<i64: 3, 0>}> : (!llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>
    %11 = "llvm.insertvalue"(%10, %arg18) <{position = array<i64: 4, 0>}> : (!llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>
    %12 = "llvm.mlir.poison"() : () -> !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>
    %13 = "llvm.insertvalue"(%12, %arg9) <{position = array<i64: 0>}> : (!llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>, !llvm.ptr) -> !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>
    %14 = "llvm.insertvalue"(%13, %arg10) <{position = array<i64: 1>}> : (!llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>, !llvm.ptr) -> !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>
    %15 = "llvm.insertvalue"(%14, %arg11) <{position = array<i64: 2>}> : (!llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>
    %16 = "llvm.insertvalue"(%15, %arg12) <{position = array<i64: 3, 0>}> : (!llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>
    %17 = "llvm.insertvalue"(%16, %arg13) <{position = array<i64: 4, 0>}> : (!llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>
    %18 = "llvm.mlir.constant"() <{value = 0 : index}> : () -> i64
    %19 = "llvm.mlir.constant"() <{value = 1 : index}> : () -> i64
    %20 = "llvm.mlir.constant"() <{value = 0.000000e+00 : f32}> : () -> f32
    %21 = "llvm.mul"(%arg2, %arg3) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %22 = "llvm.mul"(%arg1, %21) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %23 = "llvm.mul"(%arg5, %arg6) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %24 = "llvm.mul"(%arg1, %23) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %25 = "llvm.mul"(%arg7, %arg8) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %26 = "llvm.mul"(%arg4, %25) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %27 = "llvm.mlir.poison"() : () -> !llvm.struct<(ptr, ptr, i64, array<6 x i64>, array<6 x i64>)>
    %28 = "llvm.extractvalue"(%17) <{position = array<i64: 0>}> : (!llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>) -> !llvm.ptr
    %29 = "llvm.extractvalue"(%17) <{position = array<i64: 1>}> : (!llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>) -> !llvm.ptr
    %30 = "llvm.insertvalue"(%27, %28) <{position = array<i64: 0>}> : (!llvm.struct<(ptr, ptr, i64, array<6 x i64>, array<6 x i64>)>, !llvm.ptr) -> !llvm.struct<(ptr, ptr, i64, array<6 x i64>, array<6 x i64>)>
    %31 = "llvm.insertvalue"(%30, %29) <{position = array<i64: 1>}> : (!llvm.struct<(ptr, ptr, i64, array<6 x i64>, array<6 x i64>)>, !llvm.ptr) -> !llvm.struct<(ptr, ptr, i64, array<6 x i64>, array<6 x i64>)>
    %32 = "llvm.insertvalue"(%31, %18) <{position = array<i64: 2>}> : (!llvm.struct<(ptr, ptr, i64, array<6 x i64>, array<6 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<6 x i64>, array<6 x i64>)>
    %33 = "llvm.insertvalue"(%32, %arg0) <{position = array<i64: 3, 0>}> : (!llvm.struct<(ptr, ptr, i64, array<6 x i64>, array<6 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<6 x i64>, array<6 x i64>)>
    %34 = "llvm.insertvalue"(%33, %22) <{position = array<i64: 4, 0>}> : (!llvm.struct<(ptr, ptr, i64, array<6 x i64>, array<6 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<6 x i64>, array<6 x i64>)>
    %35 = "llvm.insertvalue"(%34, %arg1) <{position = array<i64: 3, 1>}> : (!llvm.struct<(ptr, ptr, i64, array<6 x i64>, array<6 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<6 x i64>, array<6 x i64>)>
    %36 = "llvm.insertvalue"(%35, %21) <{position = array<i64: 4, 1>}> : (!llvm.struct<(ptr, ptr, i64, array<6 x i64>, array<6 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<6 x i64>, array<6 x i64>)>
    %37 = "llvm.insertvalue"(%36, %arg7) <{position = array<i64: 3, 2>}> : (!llvm.struct<(ptr, ptr, i64, array<6 x i64>, array<6 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<6 x i64>, array<6 x i64>)>
    %38 = "llvm.insertvalue"(%37, %arg3) <{position = array<i64: 4, 2>}> : (!llvm.struct<(ptr, ptr, i64, array<6 x i64>, array<6 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<6 x i64>, array<6 x i64>)>
    %39 = "llvm.insertvalue"(%38, %arg8) <{position = array<i64: 3, 3>}> : (!llvm.struct<(ptr, ptr, i64, array<6 x i64>, array<6 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<6 x i64>, array<6 x i64>)>
    %40 = "llvm.insertvalue"(%39, %19) <{position = array<i64: 4, 3>}> : (!llvm.struct<(ptr, ptr, i64, array<6 x i64>, array<6 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<6 x i64>, array<6 x i64>)>
    %41 = "llvm.insertvalue"(%40, %arg5) <{position = array<i64: 3, 4>}> : (!llvm.struct<(ptr, ptr, i64, array<6 x i64>, array<6 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<6 x i64>, array<6 x i64>)>
    %42 = "llvm.insertvalue"(%41, %arg3) <{position = array<i64: 4, 4>}> : (!llvm.struct<(ptr, ptr, i64, array<6 x i64>, array<6 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<6 x i64>, array<6 x i64>)>
    %43 = "llvm.insertvalue"(%42, %arg6) <{position = array<i64: 3, 5>}> : (!llvm.struct<(ptr, ptr, i64, array<6 x i64>, array<6 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<6 x i64>, array<6 x i64>)>
    %44 = "llvm.insertvalue"(%43, %19) <{position = array<i64: 4, 5>}> : (!llvm.struct<(ptr, ptr, i64, array<6 x i64>, array<6 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<6 x i64>, array<6 x i64>)>
    %45 = "llvm.mlir.poison"() : () -> !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>
    %46 = "llvm.extractvalue"(%11) <{position = array<i64: 0>}> : (!llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>) -> !llvm.ptr
    %47 = "llvm.extractvalue"(%11) <{position = array<i64: 1>}> : (!llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>) -> !llvm.ptr
    %48 = "llvm.insertvalue"(%45, %46) <{position = array<i64: 0>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>, !llvm.ptr) -> !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>
    %49 = "llvm.insertvalue"(%48, %47) <{position = array<i64: 1>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>, !llvm.ptr) -> !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>
    %50 = "llvm.insertvalue"(%49, %18) <{position = array<i64: 2>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>
    %51 = "llvm.insertvalue"(%50, %arg4) <{position = array<i64: 3, 0>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>
    %52 = "llvm.insertvalue"(%51, %24) <{position = array<i64: 4, 0>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>
    %53 = "llvm.insertvalue"(%52, %arg1) <{position = array<i64: 3, 1>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>
    %54 = "llvm.insertvalue"(%53, %23) <{position = array<i64: 4, 1>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>
    %55 = "llvm.insertvalue"(%54, %arg5) <{position = array<i64: 3, 2>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>
    %56 = "llvm.insertvalue"(%55, %arg6) <{position = array<i64: 4, 2>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>
    %57 = "llvm.insertvalue"(%56, %arg6) <{position = array<i64: 3, 3>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>
    %58 = "llvm.insertvalue"(%57, %19) <{position = array<i64: 4, 3>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>
    %59 = "llvm.mlir.poison"() : () -> !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>
    %60 = "llvm.extractvalue"(%5) <{position = array<i64: 0>}> : (!llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>) -> !llvm.ptr
    %61 = "llvm.extractvalue"(%5) <{position = array<i64: 1>}> : (!llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>) -> !llvm.ptr
    %62 = "llvm.insertvalue"(%59, %60) <{position = array<i64: 0>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>, !llvm.ptr) -> !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>
    %63 = "llvm.insertvalue"(%62, %61) <{position = array<i64: 1>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>, !llvm.ptr) -> !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>
    %64 = "llvm.insertvalue"(%63, %18) <{position = array<i64: 2>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>
    %65 = "llvm.insertvalue"(%64, %arg0) <{position = array<i64: 3, 0>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>
    %66 = "llvm.insertvalue"(%65, %26) <{position = array<i64: 4, 0>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>
    %67 = "llvm.insertvalue"(%66, %arg4) <{position = array<i64: 3, 1>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>
    %68 = "llvm.insertvalue"(%67, %25) <{position = array<i64: 4, 1>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>
    %69 = "llvm.insertvalue"(%68, %arg7) <{position = array<i64: 3, 2>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>
    %70 = "llvm.insertvalue"(%69, %arg8) <{position = array<i64: 4, 2>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>
    %71 = "llvm.insertvalue"(%70, %arg8) <{position = array<i64: 3, 3>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>
    %72 = "llvm.insertvalue"(%71, %19) <{position = array<i64: 4, 3>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>
    "llvm.br"(%18)[^bb1] : (i64) -> ()
  ^bb1(%73: i64):  // 2 preds: ^bb0, ^bb20
    %74 = "llvm.icmp"(%73, %arg0) <{predicate = 2 : i64}> : (i64, i64) -> i1
    "llvm.cond_br"(%74)[^bb2, ^bb21] <{operandSegmentSizes = array<i32: 1, 0, 0>}> : (i1) -> ()
  ^bb2:  // pred: ^bb1
    "llvm.br"(%18)[^bb3] : (i64) -> ()
  ^bb3(%75: i64):  // 2 preds: ^bb2, ^bb19
    %76 = "llvm.icmp"(%75, %arg4) <{predicate = 2 : i64}> : (i64, i64) -> i1
    "llvm.cond_br"(%76)[^bb4, ^bb20] <{operandSegmentSizes = array<i32: 1, 0, 0>}> : (i1) -> ()
  ^bb4:  // pred: ^bb3
    "llvm.br"(%18)[^bb5] : (i64) -> ()
  ^bb5(%77: i64):  // 2 preds: ^bb4, ^bb18
    %78 = "llvm.icmp"(%77, %arg7) <{predicate = 2 : i64}> : (i64, i64) -> i1
    "llvm.cond_br"(%78)[^bb6, ^bb19] <{operandSegmentSizes = array<i32: 1, 0, 0>}> : (i1) -> ()
  ^bb6:  // pred: ^bb5
    "llvm.br"(%18)[^bb7] : (i64) -> ()
  ^bb7(%79: i64):  // 2 preds: ^bb6, ^bb17
    %80 = "llvm.icmp"(%79, %arg8) <{predicate = 2 : i64}> : (i64, i64) -> i1
    "llvm.cond_br"(%80)[^bb8, ^bb18] <{operandSegmentSizes = array<i32: 1, 0, 0>}> : (i1) -> ()
  ^bb8:  // pred: ^bb7
    "llvm.br"(%18, %20)[^bb9] : (i64, f32) -> ()
  ^bb9(%81: i64, %82: f32):  // 2 preds: ^bb8, ^bb16
    %83 = "llvm.icmp"(%81, %arg1) <{predicate = 2 : i64}> : (i64, i64) -> i1
    "llvm.cond_br"(%83)[^bb10, ^bb17] <{operandSegmentSizes = array<i32: 1, 0, 0>}> : (i1) -> ()
  ^bb10:  // pred: ^bb9
    "llvm.br"(%18, %82)[^bb11] : (i64, f32) -> ()
  ^bb11(%84: i64, %85: f32):  // 2 preds: ^bb10, ^bb15
    %86 = "llvm.icmp"(%84, %arg5) <{predicate = 2 : i64}> : (i64, i64) -> i1
    "llvm.cond_br"(%86)[^bb12, ^bb16] <{operandSegmentSizes = array<i32: 1, 0, 0>}> : (i1) -> ()
  ^bb12:  // pred: ^bb11
    "llvm.br"(%18, %85)[^bb13] : (i64, f32) -> ()
  ^bb13(%87: i64, %88: f32):  // 2 preds: ^bb12, ^bb14
    %89 = "llvm.icmp"(%87, %arg6) <{predicate = 2 : i64}> : (i64, i64) -> i1
    "llvm.cond_br"(%89)[^bb14, ^bb15] <{operandSegmentSizes = array<i32: 1, 0, 0>}> : (i1) -> ()
  ^bb14:  // pred: ^bb13
    %90 = "llvm.extractvalue"(%44) <{position = array<i64: 1>}> : (!llvm.struct<(ptr, ptr, i64, array<6 x i64>, array<6 x i64>)>) -> !llvm.ptr
    %91 = "llvm.extractvalue"(%44) <{position = array<i64: 2>}> : (!llvm.struct<(ptr, ptr, i64, array<6 x i64>, array<6 x i64>)>) -> i64
    %92 = "llvm.getelementptr"(%90, %91) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %93 = "llvm.extractvalue"(%44) <{position = array<i64: 4, 0>}> : (!llvm.struct<(ptr, ptr, i64, array<6 x i64>, array<6 x i64>)>) -> i64
    %94 = "llvm.mul"(%73, %93) <{overflowFlags = 3 : i32}> : (i64, i64) -> i64
    %95 = "llvm.extractvalue"(%44) <{position = array<i64: 4, 1>}> : (!llvm.struct<(ptr, ptr, i64, array<6 x i64>, array<6 x i64>)>) -> i64
    %96 = "llvm.mul"(%81, %95) <{overflowFlags = 3 : i32}> : (i64, i64) -> i64
    %97 = "llvm.add"(%94, %96) <{overflowFlags = 3 : i32}> : (i64, i64) -> i64
    %98 = "llvm.extractvalue"(%44) <{position = array<i64: 4, 2>}> : (!llvm.struct<(ptr, ptr, i64, array<6 x i64>, array<6 x i64>)>) -> i64
    %99 = "llvm.mul"(%77, %98) <{overflowFlags = 3 : i32}> : (i64, i64) -> i64
    %100 = "llvm.add"(%97, %99) <{overflowFlags = 3 : i32}> : (i64, i64) -> i64
    %101 = "llvm.extractvalue"(%44) <{position = array<i64: 4, 3>}> : (!llvm.struct<(ptr, ptr, i64, array<6 x i64>, array<6 x i64>)>) -> i64
    %102 = "llvm.mul"(%79, %101) <{overflowFlags = 3 : i32}> : (i64, i64) -> i64
    %103 = "llvm.add"(%100, %102) <{overflowFlags = 3 : i32}> : (i64, i64) -> i64
    %104 = "llvm.extractvalue"(%44) <{position = array<i64: 4, 4>}> : (!llvm.struct<(ptr, ptr, i64, array<6 x i64>, array<6 x i64>)>) -> i64
    %105 = "llvm.mul"(%84, %104) <{overflowFlags = 3 : i32}> : (i64, i64) -> i64
    %106 = "llvm.add"(%103, %105) <{overflowFlags = 3 : i32}> : (i64, i64) -> i64
    %107 = "llvm.extractvalue"(%44) <{position = array<i64: 4, 5>}> : (!llvm.struct<(ptr, ptr, i64, array<6 x i64>, array<6 x i64>)>) -> i64
    %108 = "llvm.mul"(%87, %107) <{overflowFlags = 3 : i32}> : (i64, i64) -> i64
    %109 = "llvm.add"(%106, %108) <{overflowFlags = 3 : i32}> : (i64, i64) -> i64
    %110 = "llvm.getelementptr"(%92, %109) <{elem_type = f32, noWrapFlags = 7 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %111 = "llvm.load"(%110) <{ordering = 0 : i64}> : (!llvm.ptr) -> f32
    %112 = "llvm.extractvalue"(%58) <{position = array<i64: 1>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>) -> !llvm.ptr
    %113 = "llvm.extractvalue"(%58) <{position = array<i64: 2>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>) -> i64
    %114 = "llvm.getelementptr"(%112, %113) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %115 = "llvm.extractvalue"(%58) <{position = array<i64: 4, 0>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>) -> i64
    %116 = "llvm.mul"(%75, %115) <{overflowFlags = 3 : i32}> : (i64, i64) -> i64
    %117 = "llvm.extractvalue"(%58) <{position = array<i64: 4, 1>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>) -> i64
    %118 = "llvm.mul"(%81, %117) <{overflowFlags = 3 : i32}> : (i64, i64) -> i64
    %119 = "llvm.add"(%116, %118) <{overflowFlags = 3 : i32}> : (i64, i64) -> i64
    %120 = "llvm.extractvalue"(%58) <{position = array<i64: 4, 2>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>) -> i64
    %121 = "llvm.mul"(%84, %120) <{overflowFlags = 3 : i32}> : (i64, i64) -> i64
    %122 = "llvm.add"(%119, %121) <{overflowFlags = 3 : i32}> : (i64, i64) -> i64
    %123 = "llvm.extractvalue"(%58) <{position = array<i64: 4, 3>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>) -> i64
    %124 = "llvm.mul"(%87, %123) <{overflowFlags = 3 : i32}> : (i64, i64) -> i64
    %125 = "llvm.add"(%122, %124) <{overflowFlags = 3 : i32}> : (i64, i64) -> i64
    %126 = "llvm.getelementptr"(%114, %125) <{elem_type = f32, noWrapFlags = 7 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %127 = "llvm.load"(%126) <{ordering = 0 : i64}> : (!llvm.ptr) -> f32
    %128 = "llvm.fmul"(%111, %127) <{fastmathFlags = #llvm.fastmath<none>}> : (f32, f32) -> f32
    %129 = "llvm.fadd"(%88, %128) <{fastmathFlags = #llvm.fastmath<none>}> : (f32, f32) -> f32
    %130 = "llvm.add"(%87, %19) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    "llvm.br"(%130, %129)[^bb13] : (i64, f32) -> ()
  ^bb15:  // pred: ^bb13
    %131 = "llvm.add"(%84, %19) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    "llvm.br"(%131, %88)[^bb11] : (i64, f32) -> ()
  ^bb16:  // pred: ^bb11
    %132 = "llvm.add"(%81, %19) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    "llvm.br"(%132, %85)[^bb9] : (i64, f32) -> ()
  ^bb17:  // pred: ^bb9
    %133 = "llvm.extractvalue"(%72) <{position = array<i64: 1>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>) -> !llvm.ptr
    %134 = "llvm.extractvalue"(%72) <{position = array<i64: 2>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>) -> i64
    %135 = "llvm.getelementptr"(%133, %134) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %136 = "llvm.extractvalue"(%72) <{position = array<i64: 4, 0>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>) -> i64
    %137 = "llvm.mul"(%73, %136) <{overflowFlags = 3 : i32}> : (i64, i64) -> i64
    %138 = "llvm.extractvalue"(%72) <{position = array<i64: 4, 1>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>) -> i64
    %139 = "llvm.mul"(%75, %138) <{overflowFlags = 3 : i32}> : (i64, i64) -> i64
    %140 = "llvm.add"(%137, %139) <{overflowFlags = 3 : i32}> : (i64, i64) -> i64
    %141 = "llvm.extractvalue"(%72) <{position = array<i64: 4, 2>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>) -> i64
    %142 = "llvm.mul"(%77, %141) <{overflowFlags = 3 : i32}> : (i64, i64) -> i64
    %143 = "llvm.add"(%140, %142) <{overflowFlags = 3 : i32}> : (i64, i64) -> i64
    %144 = "llvm.extractvalue"(%72) <{position = array<i64: 4, 3>}> : (!llvm.struct<(ptr, ptr, i64, array<4 x i64>, array<4 x i64>)>) -> i64
    %145 = "llvm.mul"(%79, %144) <{overflowFlags = 3 : i32}> : (i64, i64) -> i64
    %146 = "llvm.add"(%143, %145) <{overflowFlags = 3 : i32}> : (i64, i64) -> i64
    %147 = "llvm.getelementptr"(%135, %146) <{elem_type = f32, noWrapFlags = 7 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    "llvm.store"(%82, %147) <{ordering = 0 : i64}> : (f32, !llvm.ptr) -> ()
    %148 = "llvm.add"(%79, %19) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    "llvm.br"(%148)[^bb7] : (i64) -> ()
  ^bb18:  // pred: ^bb7
    %149 = "llvm.add"(%77, %19) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    "llvm.br"(%149)[^bb5] : (i64) -> ()
  ^bb19:  // pred: ^bb5
    %150 = "llvm.add"(%75, %19) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    "llvm.br"(%150)[^bb3] : (i64) -> ()
  ^bb20:  // pred: ^bb3
    %151 = "llvm.add"(%73, %19) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    "llvm.br"(%151)[^bb1] : (i64) -> ()
  ^bb21:  // pred: ^bb1
    "llvm.return"() : () -> ()
  }) : () -> ()
}) : () -> ()

