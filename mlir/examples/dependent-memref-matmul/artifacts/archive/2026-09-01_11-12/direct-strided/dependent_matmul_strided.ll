; ModuleID = 'LLVMDialectModule'
source_filename = "LLVMDialectModule"

define void @dependent_matmul_strided(i64 %0, i64 %1, i64 %2, i64 %3, i64 %4, i64 %5, i64 %6, i64 %7, i64 %8, ptr %9, ptr %10, ptr %11) {
  br label %13

13:                                               ; preds = %45, %12
  %14 = phi i64 [ %46, %45 ], [ 0, %12 ]
  %15 = icmp slt i64 %14, %0
  br i1 %15, label %16, label %47

16:                                               ; preds = %13
  br label %17

17:                                               ; preds = %39, %16
  %18 = phi i64 [ %44, %39 ], [ 0, %16 ]
  %19 = icmp slt i64 %18, %1
  br i1 %19, label %20, label %45

20:                                               ; preds = %17
  br label %21

21:                                               ; preds = %25, %20
  %22 = phi i64 [ %38, %25 ], [ 0, %20 ]
  %23 = phi float [ %37, %25 ], [ 0.000000e+00, %20 ]
  %24 = icmp slt i64 %22, %2
  br i1 %24, label %25, label %39

25:                                               ; preds = %21
  %26 = mul i64 %14, %3
  %27 = mul i64 %22, %4
  %28 = add i64 %26, %27
  %29 = getelementptr float, ptr %9, i64 %28
  %30 = load float, ptr %29, align 4
  %31 = mul i64 %22, %5
  %32 = mul i64 %18, %6
  %33 = add i64 %31, %32
  %34 = getelementptr float, ptr %10, i64 %33
  %35 = load float, ptr %34, align 4
  %36 = fmul float %30, %35
  %37 = fadd float %23, %36
  %38 = add i64 %22, 1
  br label %21

39:                                               ; preds = %21
  %40 = mul i64 %14, %7
  %41 = mul i64 %18, %8
  %42 = add i64 %40, %41
  %43 = getelementptr float, ptr %11, i64 %42
  store float %23, ptr %43, align 4
  %44 = add i64 %18, 1
  br label %17

45:                                               ; preds = %17
  %46 = add i64 %14, 1
  br label %13

47:                                               ; preds = %13
  ret void
}

!llvm.module.flags = !{!0}

!0 = !{i32 2, !"Debug Info Version", i32 3}
