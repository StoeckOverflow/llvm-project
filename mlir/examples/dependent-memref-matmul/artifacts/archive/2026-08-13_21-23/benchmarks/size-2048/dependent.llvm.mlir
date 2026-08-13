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
    %12 = "llvm.mlir.constant"() <{value = 1 : i64}> : () -> i64
    %13 = "llvm.mul"(%arg1, %12) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %14 = "llvm.mlir.constant"() <{value = 0 : i64}> : () -> i64
    %15 = "llvm.mul"(%3, %13) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %16 = "llvm.add"(%14, %15) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %17 = "llvm.mul"(%9, %12) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %18 = "llvm.add"(%16, %17) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %19 = "llvm.getelementptr"(%arg3, %18) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %20 = "llvm.load"(%19) <{ordering = 0 : i64}> : (!llvm.ptr) -> f32
    %21 = "llvm.mlir.constant"() <{value = 1 : i64}> : () -> i64
    %22 = "llvm.mul"(%arg2, %21) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %23 = "llvm.mlir.constant"() <{value = 0 : i64}> : () -> i64
    %24 = "llvm.mul"(%9, %22) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %25 = "llvm.add"(%23, %24) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %26 = "llvm.mul"(%6, %21) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %27 = "llvm.add"(%25, %26) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %28 = "llvm.getelementptr"(%arg4, %27) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    %29 = "llvm.load"(%28) <{ordering = 0 : i64}> : (!llvm.ptr) -> f32
    %30 = "llvm.fmul"(%20, %29) <{fastmathFlags = #llvm.fastmath<none>}> : (f32, f32) -> f32
    %31 = "llvm.fadd"(%10, %30) <{fastmathFlags = #llvm.fastmath<none>}> : (f32, f32) -> f32
    %32 = "llvm.add"(%9, %1) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    "llvm.br"(%32, %31)[^bb5] : (i64, f32) -> ()
  ^bb7:  // pred: ^bb5
    %33 = "llvm.mlir.constant"() <{value = 1 : i64}> : () -> i64
    %34 = "llvm.mul"(%arg2, %33) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %35 = "llvm.mlir.constant"() <{value = 0 : i64}> : () -> i64
    %36 = "llvm.mul"(%3, %34) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %37 = "llvm.add"(%35, %36) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %38 = "llvm.mul"(%6, %33) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %39 = "llvm.add"(%37, %38) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    %40 = "llvm.getelementptr"(%7, %39) <{elem_type = f32, noWrapFlags = 0 : i32, rawConstantIndices = array<i32: -2147483648>}> : (!llvm.ptr, i64) -> !llvm.ptr
    "llvm.store"(%10, %40) <{ordering = 0 : i64}> : (f32, !llvm.ptr) -> ()
    %41 = "llvm.add"(%6, %1) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    "llvm.br"(%41, %7)[^bb3] : (i64, !llvm.ptr) -> ()
  ^bb8:  // pred: ^bb3
    %42 = "llvm.add"(%3, %1) <{overflowFlags = 0 : i32}> : (i64, i64) -> i64
    "llvm.br"(%42, %7)[^bb1] : (i64, !llvm.ptr) -> ()
  ^bb9:  // pred: ^bb1
    "llvm.return"(%4) : (!llvm.ptr) -> ()
  }) : () -> ()
}) : () -> ()

