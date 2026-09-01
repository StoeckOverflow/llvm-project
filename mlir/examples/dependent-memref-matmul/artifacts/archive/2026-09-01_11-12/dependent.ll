; ModuleID = 'LLVMDialectModule'
source_filename = "LLVMDialectModule"

define ptr @dependent_matmul_kernel(i64 %0, i64 %1, i64 %2, ptr %3, ptr %4, ptr %5) {
  br label %7

7:                                                ; preds = %38, %6
  %8 = phi i64 [ %39, %38 ], [ 0, %6 ]
  %9 = phi ptr [ %14, %38 ], [ %5, %6 ]
  %10 = icmp slt i64 %8, %0
  br i1 %10, label %11, label %40

11:                                               ; preds = %7
  br label %12

12:                                               ; preds = %33, %11
  %13 = phi i64 [ %37, %33 ], [ 0, %11 ]
  %14 = phi ptr [ %14, %33 ], [ %9, %11 ]
  %15 = icmp slt i64 %13, %2
  br i1 %15, label %16, label %38

16:                                               ; preds = %12
  br label %17

17:                                               ; preds = %21, %16
  %18 = phi i64 [ %32, %21 ], [ 0, %16 ]
  %19 = phi float [ %31, %21 ], [ 0.000000e+00, %16 ]
  %20 = icmp slt i64 %18, %1
  br i1 %20, label %21, label %33

21:                                               ; preds = %17
  %22 = mul i64 %8, %1
  %23 = add i64 %22, %18
  %24 = getelementptr float, ptr %3, i64 %23
  %25 = load float, ptr %24, align 4
  %26 = mul i64 %18, %2
  %27 = add i64 %26, %13
  %28 = getelementptr float, ptr %4, i64 %27
  %29 = load float, ptr %28, align 4
  %30 = fmul float %25, %29
  %31 = fadd float %19, %30
  %32 = add i64 %18, 1
  br label %17

33:                                               ; preds = %17
  %34 = mul i64 %8, %2
  %35 = add i64 %34, %13
  %36 = getelementptr float, ptr %14, i64 %35
  store float %19, ptr %36, align 4
  %37 = add i64 %13, 1
  br label %12

38:                                               ; preds = %12
  %39 = add i64 %8, 1
  br label %7

40:                                               ; preds = %7
  ret ptr %9
}

!llvm.module.flags = !{!0}

!0 = !{i32 2, !"Debug Info Version", i32 3}
