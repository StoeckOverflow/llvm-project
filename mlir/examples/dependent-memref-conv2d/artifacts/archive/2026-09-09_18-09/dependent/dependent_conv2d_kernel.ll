; ModuleID = 'LLVMDialectModule'
source_filename = "LLVMDialectModule"

define ptr @dependent_conv2d_kernel(i64 %0, i64 %1, i64 %2, i64 %3, i64 %4, i64 %5, i64 %6, i64 %7, i64 %8, ptr %9, ptr %10, ptr %11) {
  br label %13

13:                                               ; preds = %96, %12
  %14 = phi i64 [ %97, %96 ], [ 0, %12 ]
  %15 = phi ptr [ %20, %96 ], [ %11, %12 ]
  %16 = icmp slt i64 %14, %0
  br i1 %16, label %17, label %98

17:                                               ; preds = %13
  br label %18

18:                                               ; preds = %94, %17
  %19 = phi i64 [ %95, %94 ], [ 0, %17 ]
  %20 = phi ptr [ %25, %94 ], [ %15, %17 ]
  %21 = icmp slt i64 %19, %4
  br i1 %21, label %22, label %96

22:                                               ; preds = %18
  br label %23

23:                                               ; preds = %92, %22
  %24 = phi i64 [ %93, %92 ], [ 0, %22 ]
  %25 = phi ptr [ %30, %92 ], [ %20, %22 ]
  %26 = icmp slt i64 %24, %7
  br i1 %26, label %27, label %94

27:                                               ; preds = %23
  br label %28

28:                                               ; preds = %81, %27
  %29 = phi i64 [ %91, %81 ], [ 0, %27 ]
  %30 = phi ptr [ %30, %81 ], [ %25, %27 ]
  %31 = icmp slt i64 %29, %8
  br i1 %31, label %32, label %92

32:                                               ; preds = %28
  br label %33

33:                                               ; preds = %79, %32
  %34 = phi i64 [ %80, %79 ], [ 0, %32 ]
  %35 = phi float [ %40, %79 ], [ 0.000000e+00, %32 ]
  %36 = icmp slt i64 %34, %1
  br i1 %36, label %37, label %81

37:                                               ; preds = %33
  br label %38

38:                                               ; preds = %77, %37
  %39 = phi i64 [ %78, %77 ], [ 0, %37 ]
  %40 = phi float [ %45, %77 ], [ %35, %37 ]
  %41 = icmp slt i64 %39, %5
  br i1 %41, label %42, label %79

42:                                               ; preds = %38
  br label %43

43:                                               ; preds = %47, %42
  %44 = phi i64 [ %76, %47 ], [ 0, %42 ]
  %45 = phi float [ %75, %47 ], [ %40, %42 ]
  %46 = icmp slt i64 %44, %6
  br i1 %46, label %47, label %77

47:                                               ; preds = %43
  %48 = mul i64 %5, %6
  %49 = mul i64 %8, %48
  %50 = mul i64 %7, %49
  %51 = mul i64 %1, %50
  %52 = mul i64 %14, %51
  %53 = mul i64 %34, %50
  %54 = add i64 %52, %53
  %55 = mul i64 %24, %49
  %56 = add i64 %54, %55
  %57 = mul i64 %29, %48
  %58 = add i64 %56, %57
  %59 = mul i64 %39, %6
  %60 = add i64 %58, %59
  %61 = add i64 %60, %44
  %62 = getelementptr float, ptr %9, i64 %61
  %63 = load float, ptr %62, align 4
  %64 = mul i64 %5, %6
  %65 = mul i64 %1, %64
  %66 = mul i64 %19, %65
  %67 = mul i64 %34, %64
  %68 = add i64 %66, %67
  %69 = mul i64 %39, %6
  %70 = add i64 %68, %69
  %71 = add i64 %70, %44
  %72 = getelementptr float, ptr %10, i64 %71
  %73 = load float, ptr %72, align 4
  %74 = fmul float %63, %73
  %75 = fadd float %45, %74
  %76 = add i64 %44, 1
  br label %43

77:                                               ; preds = %43
  %78 = add i64 %39, 1
  br label %38

79:                                               ; preds = %38
  %80 = add i64 %34, 1
  br label %33

81:                                               ; preds = %33
  %82 = mul i64 %7, %8
  %83 = mul i64 %4, %82
  %84 = mul i64 %14, %83
  %85 = mul i64 %19, %82
  %86 = add i64 %84, %85
  %87 = mul i64 %24, %8
  %88 = add i64 %86, %87
  %89 = add i64 %88, %29
  %90 = getelementptr float, ptr %30, i64 %89
  store float %35, ptr %90, align 4
  %91 = add i64 %29, 1
  br label %28

92:                                               ; preds = %28
  %93 = add i64 %24, 1
  br label %23

94:                                               ; preds = %23
  %95 = add i64 %19, 1
  br label %18

96:                                               ; preds = %18
  %97 = add i64 %14, 1
  br label %13

98:                                               ; preds = %13
  ret ptr %15
}

!llvm.module.flags = !{!0}

!0 = !{i32 2, !"Debug Info Version", i32 3}
