; ModuleID = 'LLVMDialectModule'
source_filename = "LLVMDialectModule"

define void @dependent_matmul_strided(i64 %0, i64 %1, i64 %2, i64 %3, i64 %4, i64 %5, i64 %6, i64 %7, i64 %8, ptr %9, ptr %10, ptr %11) {
  call void @dependent_matmul_strided_typed(i64 %0, i64 %1, i64 %2, i64 %3, i64 %4, i64 %5, i64 %6, i64 %7, i64 %8, ptr %9, ptr %10, ptr %11)
  ret void
}

define void @dependent_matmul_strided_typed(i64 %0, i64 %1, i64 %2, i64 %3, i64 %4, i64 %5, i64 %6, i64 %7, i64 %8, ptr %9, ptr %10, ptr %11) {
  br label %13

13:                                               ; preds = %48, %12
  %14 = phi i64 [ %49, %48 ], [ 0, %12 ]
  %15 = icmp slt i64 %14, %0
  br i1 %15, label %16, label %50

16:                                               ; preds = %13
  br label %17

17:                                               ; preds = %41, %16
  %18 = phi i64 [ %47, %41 ], [ 0, %16 ]
  %19 = icmp slt i64 %18, %1
  br i1 %19, label %20, label %48

20:                                               ; preds = %17
  br label %21

21:                                               ; preds = %25, %20
  %22 = phi i64 [ %40, %25 ], [ 0, %20 ]
  %23 = phi float [ %39, %25 ], [ 0.000000e+00, %20 ]
  %24 = icmp slt i64 %22, %2
  br i1 %24, label %25, label %41

25:                                               ; preds = %21
  %26 = mul i64 %14, %3
  %27 = add i64 0, %26
  %28 = mul i64 %22, %4
  %29 = add i64 %27, %28
  %30 = getelementptr float, ptr %9, i64 %29
  %31 = load float, ptr %30, align 4
  %32 = mul i64 %22, %5
  %33 = add i64 0, %32
  %34 = mul i64 %18, %6
  %35 = add i64 %33, %34
  %36 = getelementptr float, ptr %10, i64 %35
  %37 = load float, ptr %36, align 4
  %38 = fmul float %31, %37
  %39 = fadd float %23, %38
  %40 = add i64 %22, 1
  br label %21

41:                                               ; preds = %21
  %42 = mul i64 %14, %7
  %43 = add i64 0, %42
  %44 = mul i64 %18, %8
  %45 = add i64 %43, %44
  %46 = getelementptr float, ptr %11, i64 %45
  store float %23, ptr %46, align 4
  %47 = add i64 %18, 1
  br label %17

48:                                               ; preds = %17
  %49 = add i64 %14, 1
  br label %13

50:                                               ; preds = %13
  ret void
}

!llvm.module.flags = !{!0}

!0 = !{i32 2, !"Debug Info Version", i32 3}
