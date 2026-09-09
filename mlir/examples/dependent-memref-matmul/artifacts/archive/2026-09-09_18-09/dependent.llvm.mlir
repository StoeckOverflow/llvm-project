"builtin.module"() ({
  "llvm.func"() <{CConv = #llvm.cconv<ccc>, function_type = !llvm.func<ptr (i64, i64, i64, ptr, ptr, ptr)>, linkage = #llvm.linkage<external>, sym_name = "dependent_matmul_kernel", visibility_ = 0 : i64}> ({
  ^bb0(%arg0: i64, %arg1: i64, %arg2: i64, %arg3: !llvm.ptr, %arg4: !llvm.ptr, %arg5: !llvm.ptr):
    %0 = "llvm.mlir.constant"() <{value = 0 : index}> : () -> i64
    %1 = "llvm.mlir.constant"() <{value = 1 : index}> : () -> i64
    %2 = "llvm.mlir.constant"() <{value = 0.000000e+00 : f32}> : () -> f32
    "llvm.br"(%0, %arg5)[^bb1] : (i64, !llvm.ptr) -> ()
  ^bb1(%3: i64, %4: !llvm.ptr):  // 2 preds: ^bb0, ^bb8
    %5 = "llvm.icmp"(%3, %arg0) <{predicate = 2 : i64}> : (i64, i64) -> i1
    "llvm.cond_br"(%5)[^bb2, ^bb9] <{operandSegmentSizes = array<i32: 1, 0, 0>}> : (i1) -> ()
  ^bb2:  // pred: ^bb1
    "llvm.br"(%0, %4)[^bb3] : (i64, !llvm.ptr) -> ()
  ^bb3(%6: i64, %7: !llvm.ptr):  // 2 preds: ^bb2, ^bb7
    %8 = "llvm.icmp"(%6, %arg2) <{predicate = 2 : i64}> : (i64, i64) -> i1
    "llvm.cond_br"(%8)[^bb4, ^bb8] <{operandSegmentSizes = array<i32: 1, 0, 0>}> : (i1) -> ()
  ^bb4:  // pred: ^bb3
    "llvm.br"(%0, %2)[^bb5] : (i64, f32) -> ()
  ^bb5(%9: i64, %10: f32):  // 2 preds: ^bb4, ^bb6
    %11 = "llvm.icmp"(%9, %arg1) <{predicate = 2 : i64}> : (i64, i64) -> i1
    "llvm.cond_br"(%11)[^bb6, ^bb7] <{operandSegmentSizes = array<i32: 1, 0, 0>}> : (i1) -> ()
  ^bb6:  // pred: ^bb5
    %12 = "llvm.mul"(%3, %arg1) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %13 = "llvm.add"(%12, %9) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %14 = "llvm.getelementptr"(%arg3, %13) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %15 = "llvm.load"(%14) <{ordering = 0 : i64}> : (!llvm.ptr) -> f32
    %16 = "llvm.mul"(%9, %arg2) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %17 = "llvm.add"(%16, %6) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %18 = "llvm.getelementptr"(%arg4, %17) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %19 = "llvm.load"(%18) <{ordering = 0 : i64}> : (!llvm.ptr) -> f32
    %20 = "llvm.fmul"(%15, %19) <{fastmathFlags = #llvm.fastmath<none>}> : (f32, f32) -> f32
    %21 = "llvm.fadd"(%10, %20) <{fastmathFlags = #llvm.fastmath<none>}> : (f32, f32) -> f32
    %22 = "llvm.add"(%9, %1) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    "llvm.br"(%22, %21)[^bb5] : (i64, f32) -> ()
  ^bb7:  // pred: ^bb5
    %23 = "llvm.mul"(%3, %arg2) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %24 = "llvm.add"(%23, %6) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %25 = "llvm.getelementptr"(%7, %24) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    "llvm.store"(%10, %25) <{ordering = 0 : i64}> : (f32, !llvm.ptr) -> ()
    %26 = "llvm.add"(%6, %1) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    "llvm.br"(%26, %7)[^bb3] : (i64, !llvm.ptr) -> ()
  ^bb8:  // pred: ^bb3
    %27 = "llvm.add"(%3, %1) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    "llvm.br"(%27, %7)[^bb1] : (i64, !llvm.ptr) -> ()
  ^bb9:  // pred: ^bb1
    "llvm.return"(%4) : (!llvm.ptr) -> ()
  }) : () -> ()
}) : () -> ()

