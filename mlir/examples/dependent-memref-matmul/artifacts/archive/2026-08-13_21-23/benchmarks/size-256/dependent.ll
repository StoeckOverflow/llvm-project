; ModuleID = 'LLVMDialectModule'
source_filename = "LLVMDialectModule"

define ptr @dependent_matmul_kernel(i64 %0, i64 %1, i64 %2, ptr %3, ptr %4, ptr %5) {
  br label %7

7:                                                ; preds = %47, %6
  %8 = phi i64 [ %48, %47 ], [ 0, %6 ]
  %9 = phi ptr [ %14, %47 ], [ %5, %6 ]
  %10 = icmp slt i64 %8, %0
  br i1 %10, label %11, label %49

11:                                               ; preds = %7
  br label %12

12:                                               ; preds = %39, %11
  %13 = phi i64 [ %46, %39 ], [ 0, %11 ]
  %14 = phi ptr [ %14, %39 ], [ %9, %11 ]
  %15 = icmp slt i64 %13, %2
  br i1 %15, label %16, label %47

16:                                               ; preds = %12
  br label %17

17:                                               ; preds = %21, %16
  %18 = phi i64 [ %38, %21 ], [ 0, %16 ]
  %19 = phi float [ %37, %21 ], [ 0.000000e+00, %16 ]
  %20 = icmp slt i64 %18, %1
  br i1 %20, label %21, label %39

21:                                               ; preds = %17
  %22 = mul i64 %1, 1
  %23 = mul i64 %8, %22
  %24 = add i64 0, %23
  %25 = mul i64 %18, 1
  %26 = add i64 %24, %25
  %27 = getelementptr float, ptr %3, i64 %26
  %28 = load float, ptr %27, align 4
  %29 = mul i64 %2, 1
  %30 = mul i64 %18, %29
  %31 = add i64 0, %30
  %32 = mul i64 %13, 1
  %33 = add i64 %31, %32
  %34 = getelementptr float, ptr %4, i64 %33
  %35 = load float, ptr %34, align 4
  %36 = fmul float %28, %35
  %37 = fadd float %19, %36
  %38 = add i64 %18, 1
  br label %17

39:                                               ; preds = %17
  %40 = mul i64 %2, 1
  %41 = mul i64 %8, %40
  %42 = add i64 0, %41
  %43 = mul i64 %13, 1
  %44 = add i64 %42, %43
  %45 = getelementptr float, ptr %14, i64 %44
  store float %19, ptr %45, align 4
  %46 = add i64 %13, 1
  br label %12

47:                                               ; preds = %12
  %48 = add i64 %8, 1
  br label %7

49:                                               ; preds = %7
  ret ptr %9
}

!llvm.module.flags = !{!0}

!0 = !{i32 2, !"Debug Info Version", i32 3}
