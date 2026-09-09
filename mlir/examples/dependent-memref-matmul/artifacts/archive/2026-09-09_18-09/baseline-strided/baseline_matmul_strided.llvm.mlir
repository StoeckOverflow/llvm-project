"builtin.module"() ({
  "llvm.func"() <{CConv = #llvm.cconv<ccc>, function_type = !llvm.func<void (i64, i64, i64, i64, i64, i64, i64, i64, i64, ptr, ptr, i64, ptr, ptr, i64, ptr, ptr, i64)>, linkage = #llvm.linkage<external>, sym_name = "baseline_matmul_strided", visibility_ = 0 : i64}> ({
  ^bb0(%arg0: i64, %arg1: i64, %arg2: i64, %arg3: i64, %arg4: i64, %arg5: i64, %arg6: i64, %arg7: i64, %arg8: i64, %arg9: !llvm.ptr, %arg10: !llvm.ptr, %arg11: i64, %arg12: !llvm.ptr, %arg13: !llvm.ptr, %arg14: i64, %arg15: !llvm.ptr, %arg16: !llvm.ptr, %arg17: i64):
    %0 = "llvm.mlir.poison"() : () -> !llvm.struct<(ptr, ptr, i64)>
    %1 = "llvm.insertvalue"(%0, %arg15) <{position = array<i64: 0>}> : (!llvm.struct<(ptr, ptr, i64)>, !llvm.ptr) -> !llvm.struct<(ptr, ptr, i64)>
    %2 = "llvm.insertvalue"(%1, %arg16) <{position = array<i64: 1>}> : (!llvm.struct<(ptr, ptr, i64)>, !llvm.ptr) -> !llvm.struct<(ptr, ptr, i64)>
    %3 = "llvm.insertvalue"(%2, %arg17) <{position = array<i64: 2>}> : (!llvm.struct<(ptr, ptr, i64)>, i64) -> !llvm.struct<(ptr, ptr, i64)>
    %4 = "llvm.mlir.poison"() : () -> !llvm.struct<(ptr, ptr, i64)>
    %5 = "llvm.insertvalue"(%4, %arg12) <{position = array<i64: 0>}> : (!llvm.struct<(ptr, ptr, i64)>, !llvm.ptr) -> !llvm.struct<(ptr, ptr, i64)>
    %6 = "llvm.insertvalue"(%5, %arg13) <{position = array<i64: 1>}> : (!llvm.struct<(ptr, ptr, i64)>, !llvm.ptr) -> !llvm.struct<(ptr, ptr, i64)>
    %7 = "llvm.insertvalue"(%6, %arg14) <{position = array<i64: 2>}> : (!llvm.struct<(ptr, ptr, i64)>, i64) -> !llvm.struct<(ptr, ptr, i64)>
    %8 = "llvm.mlir.poison"() : () -> !llvm.struct<(ptr, ptr, i64)>
    %9 = "llvm.insertvalue"(%8, %arg9) <{position = array<i64: 0>}> : (!llvm.struct<(ptr, ptr, i64)>, !llvm.ptr) -> !llvm.struct<(ptr, ptr, i64)>
    %10 = "llvm.insertvalue"(%9, %arg10) <{position = array<i64: 1>}> : (!llvm.struct<(ptr, ptr, i64)>, !llvm.ptr) -> !llvm.struct<(ptr, ptr, i64)>
    %11 = "llvm.insertvalue"(%10, %arg11) <{position = array<i64: 2>}> : (!llvm.struct<(ptr, ptr, i64)>, i64) -> !llvm.struct<(ptr, ptr, i64)>
    %12 = "llvm.mlir.poison"() : () -> !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %13 = "llvm.extractvalue"(%11) <{position = array<i64: 0>}> : (!llvm.struct<(ptr, ptr, i64)>) -> !llvm.ptr
    %14 = "llvm.extractvalue"(%11) <{position = array<i64: 1>}> : (!llvm.struct<(ptr, ptr, i64)>) -> !llvm.ptr
    %15 = "llvm.insertvalue"(%12, %13) <{position = array<i64: 0>}> : (!llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>, !llvm.ptr) -> !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %16 = "llvm.insertvalue"(%15, %14) <{position = array<i64: 1>}> : (!llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>, !llvm.ptr) -> !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %17 = "llvm.mlir.constant"() <{value = 0 : index}> : () -> i64
    %18 = "llvm.insertvalue"(%16, %17) <{position = array<i64: 2>}> : (!llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %19 = "llvm.insertvalue"(%18, %arg0) <{position = array<i64: 3, 0>}> : (!llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %20 = "llvm.insertvalue"(%19, %arg3) <{position = array<i64: 4, 0>}> : (!llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %21 = "llvm.insertvalue"(%20, %arg2) <{position = array<i64: 3, 1>}> : (!llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %22 = "llvm.insertvalue"(%21, %arg4) <{position = array<i64: 4, 1>}> : (!llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %23 = "llvm.mlir.poison"() : () -> !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %24 = "llvm.extractvalue"(%7) <{position = array<i64: 0>}> : (!llvm.struct<(ptr, ptr, i64)>) -> !llvm.ptr
    %25 = "llvm.extractvalue"(%7) <{position = array<i64: 1>}> : (!llvm.struct<(ptr, ptr, i64)>) -> !llvm.ptr
    %26 = "llvm.insertvalue"(%23, %24) <{position = array<i64: 0>}> : (!llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>, !llvm.ptr) -> !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %27 = "llvm.insertvalue"(%26, %25) <{position = array<i64: 1>}> : (!llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>, !llvm.ptr) -> !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %28 = "llvm.mlir.constant"() <{value = 0 : index}> : () -> i64
    %29 = "llvm.insertvalue"(%27, %28) <{position = array<i64: 2>}> : (!llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %30 = "llvm.insertvalue"(%29, %arg2) <{position = array<i64: 3, 0>}> : (!llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %31 = "llvm.insertvalue"(%30, %arg5) <{position = array<i64: 4, 0>}> : (!llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %32 = "llvm.insertvalue"(%31, %arg1) <{position = array<i64: 3, 1>}> : (!llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %33 = "llvm.insertvalue"(%32, %arg6) <{position = array<i64: 4, 1>}> : (!llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %34 = "llvm.mlir.poison"() : () -> !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %35 = "llvm.extractvalue"(%3) <{position = array<i64: 0>}> : (!llvm.struct<(ptr, ptr, i64)>) -> !llvm.ptr
    %36 = "llvm.extractvalue"(%3) <{position = array<i64: 1>}> : (!llvm.struct<(ptr, ptr, i64)>) -> !llvm.ptr
    %37 = "llvm.insertvalue"(%34, %35) <{position = array<i64: 0>}> : (!llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>, !llvm.ptr) -> !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %38 = "llvm.insertvalue"(%37, %36) <{position = array<i64: 1>}> : (!llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>, !llvm.ptr) -> !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %39 = "llvm.mlir.constant"() <{value = 0 : index}> : () -> i64
    %40 = "llvm.insertvalue"(%38, %39) <{position = array<i64: 2>}> : (!llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %41 = "llvm.insertvalue"(%40, %arg0) <{position = array<i64: 3, 0>}> : (!llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %42 = "llvm.insertvalue"(%41, %arg7) <{position = array<i64: 4, 0>}> : (!llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %43 = "llvm.insertvalue"(%42, %arg1) <{position = array<i64: 3, 1>}> : (!llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %44 = "llvm.insertvalue"(%43, %arg8) <{position = array<i64: 4, 1>}> : (!llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>, i64) -> !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %45 = "llvm.mlir.constant"() <{value = 0.000000e+00 : f32}> : () -> f32
    %46 = "llvm.mlir.constant"() <{value = 0 : index}> : () -> i64
    %47 = "llvm.mlir.constant"() <{value = 1 : index}> : () -> i64
    "llvm.br"(%46)[^bb1] : (i64) -> ()
  ^bb1(%48: i64):  // 2 preds: ^bb0, ^bb8
    %49 = "llvm.icmp"(%48, %arg0) <{predicate = 2 : i64}> : (i64, i64) -> i1
    "llvm.cond_br"(%49)[^bb2, ^bb9] <{operandSegmentSizes = array<i32: 1, 0, 0>}> : (i1) -> ()
  ^bb2:  // pred: ^bb1
    "llvm.br"(%46)[^bb3] : (i64) -> ()
  ^bb3(%50: i64):  // 2 preds: ^bb2, ^bb7
    %51 = "llvm.icmp"(%50, %arg1) <{predicate = 2 : i64}> : (i64, i64) -> i1
    "llvm.cond_br"(%51)[^bb4, ^bb8] <{operandSegmentSizes = array<i32: 1, 0, 0>}> : (i1) -> ()
  ^bb4:  // pred: ^bb3
    "llvm.br"(%46, %45)[^bb5] : (i64, f32) -> ()
  ^bb5(%52: i64, %53: f32):  // 2 preds: ^bb4, ^bb6
    %54 = "llvm.icmp"(%52, %arg2) <{predicate = 2 : i64}> : (i64, i64) -> i1
    "llvm.cond_br"(%54)[^bb6, ^bb7] <{operandSegmentSizes = array<i32: 1, 0, 0>}> : (i1) -> ()
  ^bb6:  // pred: ^bb5
    %55 = "llvm.extractvalue"(%22) <{position = array<i64: 1>}> : (!llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>) -> !llvm.ptr
    %56 = "llvm.extractvalue"(%22) <{position = array<i64: 4, 0>}> : (!llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>) -> i64
    %57 = "llvm.mul"(%48, %56) <{overflowFlags = 3 : i32}> : (i64, i64) -> i64
    %58 = "llvm.extractvalue"(%22) <{position = array<i64: 4, 1>}> : (!llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>) -> i64
    %59 = "llvm.mul"(%52, %58) <{overflowFlags = 3 : i32}> : (i64, i64) -> i64
    %60 = "llvm.add"(%57, %59) <{overflowFlags = 3 : i32}> : (i64, i64) -> i64
    %61 = "llvm.getelementptr"(%55, %60) <{elem_type = f32, noWrapFlags = 7 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %62 = "llvm.load"(%61) <{ordering = 0 : i64}> : (!llvm.ptr) -> f32
    %63 = "llvm.extractvalue"(%33) <{position = array<i64: 1>}> : (!llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>) -> !llvm.ptr
    %64 = "llvm.extractvalue"(%33) <{position = array<i64: 4, 0>}> : (!llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>) -> i64
    %65 = "llvm.mul"(%52, %64) <{overflowFlags = 3 : i32}> : (i64, i64) -> i64
    %66 = "llvm.extractvalue"(%33) <{position = array<i64: 4, 1>}> : (!llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>) -> i64
    %67 = "llvm.mul"(%50, %66) <{overflowFlags = 3 : i32}> : (i64, i64) -> i64
    %68 = "llvm.add"(%65, %67) <{overflowFlags = 3 : i32}> : (i64, i64) -> i64
    %69 = "llvm.getelementptr"(%63, %68) <{elem_type = f32, noWrapFlags = 7 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %70 = "llvm.load"(%69) <{ordering = 0 : i64}> : (!llvm.ptr) -> f32
    %71 = "llvm.fmul"(%62, %70) <{fastmathFlags = #llvm.fastmath<none>}> : (f32, f32) -> f32
    %72 = "llvm.fadd"(%53, %71) <{fastmathFlags = #llvm.fastmath<none>}> : (f32, f32) -> f32
    %73 = "llvm.add"(%52, %47) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    "llvm.br"(%73, %72)[^bb5] : (i64, f32) -> ()
  ^bb7:  // pred: ^bb5
    %74 = "llvm.extractvalue"(%44) <{position = array<i64: 1>}> : (!llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>) -> !llvm.ptr
    %75 = "llvm.extractvalue"(%44) <{position = array<i64: 4, 0>}> : (!llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>) -> i64
    %76 = "llvm.mul"(%48, %75) <{overflowFlags = 3 : i32}> : (i64, i64) -> i64
    %77 = "llvm.extractvalue"(%44) <{position = array<i64: 4, 1>}> : (!llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>) -> i64
    %78 = "llvm.mul"(%50, %77) <{overflowFlags = 3 : i32}> : (i64, i64) -> i64
    %79 = "llvm.add"(%76, %78) <{overflowFlags = 3 : i32}> : (i64, i64) -> i64
    %80 = "llvm.getelementptr"(%74, %79) <{elem_type = f32, noWrapFlags = 7 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    "llvm.store"(%53, %80) <{ordering = 0 : i64}> : (f32, !llvm.ptr) -> ()
    %81 = "llvm.add"(%50, %47) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    "llvm.br"(%81)[^bb3] : (i64) -> ()
  ^bb8:  // pred: ^bb3
    %82 = "llvm.add"(%48, %47) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    "llvm.br"(%82)[^bb1] : (i64) -> ()
  ^bb9:  // pred: ^bb1
    "llvm.return"() : () -> ()
  }) : () -> ()
}) : () -> ()

