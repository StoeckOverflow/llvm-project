"builtin.module"() ({
  "llvm.func"() <{CConv = #llvm.cconv<ccc>, function_type = !llvm.func<ptr (i64, i64, i64, i64, i64, i64, i64, i64, i64, ptr, ptr, ptr)>, linkage = #llvm.linkage<external>, sym_name = "dependent_conv2d_kernel", visibility_ = 0 : i64}> ({
  ^bb0(%arg0: i64, %arg1: i64, %arg2: i64, %arg3: i64, %arg4: i64, %arg5: i64, %arg6: i64, %arg7: i64, %arg8: i64, %arg9: !llvm.ptr, %arg10: !llvm.ptr, %arg11: !llvm.ptr):
    %0 = "llvm.mlir.constant"() <{value = 0 : index}> : () -> i64
    %1 = "llvm.mlir.constant"() <{value = 1 : index}> : () -> i64
    %2 = "llvm.mlir.constant"() <{value = 0.000000e+00 : f32}> : () -> f32
    "llvm.br"(%0, %arg11)[^bb1] : (i64, !llvm.ptr) -> ()
  ^bb1(%3: i64, %4: !llvm.ptr):  // 2 preds: ^bb0, ^bb20
    %5 = "llvm.icmp"(%3, %arg0) <{predicate = 2 : i64}> : (i64, i64) -> i1
    "llvm.cond_br"(%5)[^bb2, ^bb21] <{operandSegmentSizes = array<i32: 1, 0, 0>}> : (i1) -> ()
  ^bb2:  // pred: ^bb1
    "llvm.br"(%0, %4)[^bb3] : (i64, !llvm.ptr) -> ()
  ^bb3(%6: i64, %7: !llvm.ptr):  // 2 preds: ^bb2, ^bb19
    %8 = "llvm.icmp"(%6, %arg4) <{predicate = 2 : i64}> : (i64, i64) -> i1
    "llvm.cond_br"(%8)[^bb4, ^bb20] <{operandSegmentSizes = array<i32: 1, 0, 0>}> : (i1) -> ()
  ^bb4:  // pred: ^bb3
    "llvm.br"(%0, %7)[^bb5] : (i64, !llvm.ptr) -> ()
  ^bb5(%9: i64, %10: !llvm.ptr):  // 2 preds: ^bb4, ^bb18
    %11 = "llvm.icmp"(%9, %arg7) <{predicate = 2 : i64}> : (i64, i64) -> i1
    "llvm.cond_br"(%11)[^bb6, ^bb19] <{operandSegmentSizes = array<i32: 1, 0, 0>}> : (i1) -> ()
  ^bb6:  // pred: ^bb5
    "llvm.br"(%0, %10)[^bb7] : (i64, !llvm.ptr) -> ()
  ^bb7(%12: i64, %13: !llvm.ptr):  // 2 preds: ^bb6, ^bb17
    %14 = "llvm.icmp"(%12, %arg8) <{predicate = 2 : i64}> : (i64, i64) -> i1
    "llvm.cond_br"(%14)[^bb8, ^bb18] <{operandSegmentSizes = array<i32: 1, 0, 0>}> : (i1) -> ()
  ^bb8:  // pred: ^bb7
    "llvm.br"(%0, %2)[^bb9] : (i64, f32) -> ()
  ^bb9(%15: i64, %16: f32):  // 2 preds: ^bb8, ^bb16
    %17 = "llvm.icmp"(%15, %arg1) <{predicate = 2 : i64}> : (i64, i64) -> i1
    "llvm.cond_br"(%17)[^bb10, ^bb17] <{operandSegmentSizes = array<i32: 1, 0, 0>}> : (i1) -> ()
  ^bb10:  // pred: ^bb9
    "llvm.br"(%0, %16)[^bb11] : (i64, f32) -> ()
  ^bb11(%18: i64, %19: f32):  // 2 preds: ^bb10, ^bb15
    %20 = "llvm.icmp"(%18, %arg5) <{predicate = 2 : i64}> : (i64, i64) -> i1
    "llvm.cond_br"(%20)[^bb12, ^bb16] <{operandSegmentSizes = array<i32: 1, 0, 0>}> : (i1) -> ()
  ^bb12:  // pred: ^bb11
    "llvm.br"(%0, %19)[^bb13] : (i64, f32) -> ()
  ^bb13(%21: i64, %22: f32):  // 2 preds: ^bb12, ^bb14
    %23 = "llvm.icmp"(%21, %arg6) <{predicate = 2 : i64}> : (i64, i64) -> i1
    "llvm.cond_br"(%23)[^bb14, ^bb15] <{operandSegmentSizes = array<i32: 1, 0, 0>}> : (i1) -> ()
  ^bb14:  // pred: ^bb13
    %24 = "llvm.mul"(%arg5, %arg6) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %25 = "llvm.mul"(%arg8, %24) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %26 = "llvm.mul"(%arg7, %25) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %27 = "llvm.mul"(%arg1, %26) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %28 = "llvm.mul"(%3, %27) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %29 = "llvm.mul"(%15, %26) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %30 = "llvm.add"(%28, %29) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %31 = "llvm.mul"(%9, %25) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %32 = "llvm.add"(%30, %31) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %33 = "llvm.mul"(%12, %24) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %34 = "llvm.add"(%32, %33) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %35 = "llvm.mul"(%18, %arg6) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %36 = "llvm.add"(%34, %35) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %37 = "llvm.add"(%36, %21) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %38 = "llvm.getelementptr"(%arg9, %37) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %39 = "llvm.load"(%38) <{ordering = 0 : i64}> : (!llvm.ptr) -> f32
    %40 = "llvm.mul"(%arg5, %arg6) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %41 = "llvm.mul"(%arg1, %40) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %42 = "llvm.mul"(%6, %41) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %43 = "llvm.mul"(%15, %40) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %44 = "llvm.add"(%42, %43) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %45 = "llvm.mul"(%18, %arg6) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %46 = "llvm.add"(%44, %45) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %47 = "llvm.add"(%46, %21) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %48 = "llvm.getelementptr"(%arg10, %47) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %49 = "llvm.load"(%48) <{ordering = 0 : i64}> : (!llvm.ptr) -> f32
    %50 = "llvm.fmul"(%39, %49) <{fastmathFlags = #llvm.fastmath<none>}> : (f32, f32) -> f32
    %51 = "llvm.fadd"(%22, %50) <{fastmathFlags = #llvm.fastmath<none>}> : (f32, f32) -> f32
    %52 = "llvm.add"(%21, %1) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    "llvm.br"(%52, %51)[^bb13] : (i64, f32) -> ()
  ^bb15:  // pred: ^bb13
    %53 = "llvm.add"(%18, %1) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    "llvm.br"(%53, %22)[^bb11] : (i64, f32) -> ()
  ^bb16:  // pred: ^bb11
    %54 = "llvm.add"(%15, %1) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    "llvm.br"(%54, %19)[^bb9] : (i64, f32) -> ()
  ^bb17:  // pred: ^bb9
    %55 = "llvm.mul"(%arg7, %arg8) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %56 = "llvm.mul"(%arg4, %55) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %57 = "llvm.mul"(%3, %56) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %58 = "llvm.mul"(%6, %55) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %59 = "llvm.add"(%57, %58) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %60 = "llvm.mul"(%9, %arg8) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %61 = "llvm.add"(%59, %60) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %62 = "llvm.add"(%61, %12) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %63 = "llvm.getelementptr"(%13, %62) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    "llvm.store"(%16, %63) <{ordering = 0 : i64}> : (f32, !llvm.ptr) -> ()
    %64 = "llvm.add"(%12, %1) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    "llvm.br"(%64, %13)[^bb7] : (i64, !llvm.ptr) -> ()
  ^bb18:  // pred: ^bb7
    %65 = "llvm.add"(%9, %1) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    "llvm.br"(%65, %13)[^bb5] : (i64, !llvm.ptr) -> ()
  ^bb19:  // pred: ^bb5
    %66 = "llvm.add"(%6, %1) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    "llvm.br"(%66, %10)[^bb3] : (i64, !llvm.ptr) -> ()
  ^bb20:  // pred: ^bb3
    %67 = "llvm.add"(%3, %1) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    "llvm.br"(%67, %7)[^bb1] : (i64, !llvm.ptr) -> ()
  ^bb21:  // pred: ^bb1
    "llvm.return"(%4) : (!llvm.ptr) -> ()
  }) : () -> ()
}) : () -> ()

