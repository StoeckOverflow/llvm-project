; ModuleID = 'LLVMDialectModule'
source_filename = "LLVMDialectModule"

define void @dependent_conv2d_strided(i64 %0, i64 %1, i64 %2, i64 %3, i64 %4, i64 %5, i64 %6, i64 %7, i64 %8, i64 %9, i64 %10, i64 %11, i64 %12, i64 %13, i64 %14, i64 %15, i64 %16, i64 %17, i64 %18, ptr %19, ptr %20, ptr %21) {
  br label %23

23:                                               ; preds = %97, %22
  %24 = phi i64 [ %98, %97 ], [ 0, %22 ]
  %25 = icmp slt i64 %24, %0
  br i1 %25, label %26, label %99

26:                                               ; preds = %23
  br label %27

27:                                               ; preds = %95, %26
  %28 = phi i64 [ %96, %95 ], [ 0, %26 ]
  %29 = icmp slt i64 %28, %4
  br i1 %29, label %30, label %97

30:                                               ; preds = %27
  br label %31

31:                                               ; preds = %93, %30
  %32 = phi i64 [ %94, %93 ], [ 0, %30 ]
  %33 = icmp slt i64 %32, %7
  br i1 %33, label %34, label %95

34:                                               ; preds = %31
  br label %35

35:                                               ; preds = %83, %34
  %36 = phi i64 [ %92, %83 ], [ 0, %34 ]
  %37 = icmp slt i64 %36, %8
  br i1 %37, label %38, label %93

38:                                               ; preds = %35
  br label %39

39:                                               ; preds = %81, %38
  %40 = phi i64 [ %82, %81 ], [ 0, %38 ]
  %41 = phi float [ %46, %81 ], [ 0.000000e+00, %38 ]
  %42 = icmp slt i64 %40, %1
  br i1 %42, label %43, label %83

43:                                               ; preds = %39
  br label %44

44:                                               ; preds = %79, %43
  %45 = phi i64 [ %80, %79 ], [ 0, %43 ]
  %46 = phi float [ %51, %79 ], [ %41, %43 ]
  %47 = icmp slt i64 %45, %5
  br i1 %47, label %48, label %81

48:                                               ; preds = %44
  br label %49

49:                                               ; preds = %53, %48
  %50 = phi i64 [ %78, %53 ], [ 0, %48 ]
  %51 = phi float [ %77, %53 ], [ %46, %48 ]
  %52 = icmp slt i64 %50, %6
  br i1 %52, label %53, label %79

53:                                               ; preds = %49
  %54 = mul i64 %24, %9
  %55 = mul i64 %40, %10
  %56 = add i64 %54, %55
  %57 = mul i64 %32, %11
  %58 = add i64 %56, %57
  %59 = mul i64 %36, %12
  %60 = add i64 %58, %59
  %61 = mul i64 %45, %11
  %62 = add i64 %60, %61
  %63 = mul i64 %50, %12
  %64 = add i64 %62, %63
  %65 = getelementptr float, ptr %19, i64 %64
  %66 = load float, ptr %65, align 4
  %67 = mul i64 %28, %13
  %68 = mul i64 %40, %14
  %69 = add i64 %67, %68
  %70 = mul i64 %45, %15
  %71 = add i64 %69, %70
  %72 = mul i64 %50, %12
  %73 = add i64 %71, %72
  %74 = getelementptr float, ptr %20, i64 %73
  %75 = load float, ptr %74, align 4
  %76 = fmul float %66, %75
  %77 = fadd float %51, %76
  %78 = add i64 %50, 1
  br label %49

79:                                               ; preds = %49
  %80 = add i64 %45, 1
  br label %44

81:                                               ; preds = %44
  %82 = add i64 %40, 1
  br label %39

83:                                               ; preds = %39
  %84 = mul i64 %24, %16
  %85 = mul i64 %28, %17
  %86 = add i64 %84, %85
  %87 = mul i64 %32, %18
  %88 = add i64 %86, %87
  %89 = mul i64 %36, %12
  %90 = add i64 %88, %89
  %91 = getelementptr float, ptr %21, i64 %90
  store float %41, ptr %91, align 4
  %92 = add i64 %36, 1
  br label %35

93:                                               ; preds = %35
  %94 = add i64 %32, 1
  br label %31

95:                                               ; preds = %31
  %96 = add i64 %28, 1
  br label %27

97:                                               ; preds = %27
  %98 = add i64 %24, 1
  br label %23

99:                                               ; preds = %23
  ret void
}

!llvm.module.flags = !{!0}

!0 = !{i32 2, !"Debug Info Version", i32 3}
