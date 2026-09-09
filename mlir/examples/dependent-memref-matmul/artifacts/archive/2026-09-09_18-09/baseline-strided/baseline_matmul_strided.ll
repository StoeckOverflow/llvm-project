; ModuleID = 'LLVMDialectModule'
source_filename = "LLVMDialectModule"

define void @baseline_matmul_strided(i64 %0, i64 %1, i64 %2, i64 %3, i64 %4, i64 %5, i64 %6, i64 %7, i64 %8, ptr %9, ptr %10, i64 %11, ptr %12, ptr %13, i64 %14, ptr %15, ptr %16, i64 %17) {
  %19 = insertvalue { ptr, ptr, i64 } poison, ptr %15, 0
  %20 = insertvalue { ptr, ptr, i64 } %19, ptr %16, 1
  %21 = insertvalue { ptr, ptr, i64 } %20, i64 %17, 2
  %22 = insertvalue { ptr, ptr, i64 } poison, ptr %12, 0
  %23 = insertvalue { ptr, ptr, i64 } %22, ptr %13, 1
  %24 = insertvalue { ptr, ptr, i64 } %23, i64 %14, 2
  %25 = insertvalue { ptr, ptr, i64 } poison, ptr %9, 0
  %26 = insertvalue { ptr, ptr, i64 } %25, ptr %10, 1
  %27 = insertvalue { ptr, ptr, i64 } %26, i64 %11, 2
  %28 = extractvalue { ptr, ptr, i64 } %27, 0
  %29 = extractvalue { ptr, ptr, i64 } %27, 1
  %30 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %28, 0
  %31 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %30, ptr %29, 1
  %32 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, i64 0, 2
  %33 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, i64 %0, 3, 0
  %34 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %33, i64 %3, 4, 0
  %35 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %34, i64 %2, 3, 1
  %36 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %35, i64 %4, 4, 1
  %37 = extractvalue { ptr, ptr, i64 } %24, 0
  %38 = extractvalue { ptr, ptr, i64 } %24, 1
  %39 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %37, 0
  %40 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %39, ptr %38, 1
  %41 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %40, i64 0, 2
  %42 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %41, i64 %2, 3, 0
  %43 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %42, i64 %5, 4, 0
  %44 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %43, i64 %1, 3, 1
  %45 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %44, i64 %6, 4, 1
  %46 = extractvalue { ptr, ptr, i64 } %21, 0
  %47 = extractvalue { ptr, ptr, i64 } %21, 1
  %48 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %46, 0
  %49 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %48, ptr %47, 1
  %50 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %49, i64 0, 2
  %51 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %50, i64 %0, 3, 0
  %52 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %51, i64 %7, 4, 0
  %53 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %52, i64 %1, 3, 1
  %54 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %53, i64 %8, 4, 1
  br label %55

55:                                               ; preds = %96, %18
  %56 = phi i64 [ %97, %96 ], [ 0, %18 ]
  %57 = icmp slt i64 %56, %0
  br i1 %57, label %58, label %98

58:                                               ; preds = %55
  br label %59

59:                                               ; preds = %87, %58
  %60 = phi i64 [ %95, %87 ], [ 0, %58 ]
  %61 = icmp slt i64 %60, %1
  br i1 %61, label %62, label %96

62:                                               ; preds = %59
  br label %63

63:                                               ; preds = %67, %62
  %64 = phi i64 [ %86, %67 ], [ 0, %62 ]
  %65 = phi float [ %85, %67 ], [ 0.000000e+00, %62 ]
  %66 = icmp slt i64 %64, %2
  br i1 %66, label %67, label %87

67:                                               ; preds = %63
  %68 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %36, 1
  %69 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %36, 4, 0
  %70 = mul nuw nsw i64 %56, %69
  %71 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %36, 4, 1
  %72 = mul nuw nsw i64 %64, %71
  %73 = add nuw nsw i64 %70, %72
  %74 = getelementptr inbounds nuw float, ptr %68, i64 %73
  %75 = load float, ptr %74, align 4
  %76 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %45, 1
  %77 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %45, 4, 0
  %78 = mul nuw nsw i64 %64, %77
  %79 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %45, 4, 1
  %80 = mul nuw nsw i64 %60, %79
  %81 = add nuw nsw i64 %78, %80
  %82 = getelementptr inbounds nuw float, ptr %76, i64 %81
  %83 = load float, ptr %82, align 4
  %84 = fmul float %75, %83
  %85 = fadd float %65, %84
  %86 = add i64 %64, 1
  br label %63

87:                                               ; preds = %63
  %88 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %54, 1
  %89 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %54, 4, 0
  %90 = mul nuw nsw i64 %56, %89
  %91 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %54, 4, 1
  %92 = mul nuw nsw i64 %60, %91
  %93 = add nuw nsw i64 %90, %92
  %94 = getelementptr inbounds nuw float, ptr %88, i64 %93
  store float %65, ptr %94, align 4
  %95 = add i64 %60, 1
  br label %59

96:                                               ; preds = %59
  %97 = add i64 %56, 1
  br label %55

98:                                               ; preds = %55
  ret void
}

!llvm.module.flags = !{!0}

!0 = !{i32 2, !"Debug Info Version", i32 3}
