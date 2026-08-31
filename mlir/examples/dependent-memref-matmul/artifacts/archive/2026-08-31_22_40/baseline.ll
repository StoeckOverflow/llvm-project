; ModuleID = 'LLVMDialectModule'
source_filename = "LLVMDialectModule"

define { ptr, ptr, i64, [2 x i64], [2 x i64] } @baseline_matmul_kernel(i64 %0, i64 %1, i64 %2, ptr %3, ptr %4, i64 %5, i64 %6, i64 %7, i64 %8, i64 %9, ptr %10, ptr %11, i64 %12, i64 %13, i64 %14, i64 %15, i64 %16, ptr %17, ptr %18, i64 %19, i64 %20, i64 %21, i64 %22, i64 %23) {
  %25 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %17, 0
  %26 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, ptr %18, 1
  %27 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %26, i64 %19, 2
  %28 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %27, i64 %20, 3, 0
  %29 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %28, i64 %22, 4, 0
  %30 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %29, i64 %21, 3, 1
  %31 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %30, i64 %23, 4, 1
  %32 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %10, 0
  %33 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, ptr %11, 1
  %34 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %33, i64 %12, 2
  %35 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %34, i64 %13, 3, 0
  %36 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %35, i64 %15, 4, 0
  %37 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %36, i64 %14, 3, 1
  %38 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %37, i64 %16, 4, 1
  %39 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %3, 0
  %40 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %39, ptr %4, 1
  %41 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %40, i64 %5, 2
  %42 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %41, i64 %6, 3, 0
  %43 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %42, i64 %8, 4, 0
  %44 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %43, i64 %7, 3, 1
  %45 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %44, i64 %9, 4, 1
  br label %46

46:                                               ; preds = %95, %24
  %47 = phi i64 [ %96, %95 ], [ 0, %24 ]
  %48 = phi { ptr, ptr, i64, [2 x i64], [2 x i64] } [ %53, %95 ], [ %31, %24 ]
  %49 = icmp slt i64 %47, %0
  br i1 %49, label %50, label %97

50:                                               ; preds = %46
  br label %51

51:                                               ; preds = %84, %50
  %52 = phi i64 [ %94, %84 ], [ 0, %50 ]
  %53 = phi { ptr, ptr, i64, [2 x i64], [2 x i64] } [ %53, %84 ], [ %48, %50 ]
  %54 = icmp slt i64 %52, %2
  br i1 %54, label %55, label %95

55:                                               ; preds = %51
  br label %56

56:                                               ; preds = %60, %55
  %57 = phi i64 [ %83, %60 ], [ 0, %55 ]
  %58 = phi float [ %82, %60 ], [ 0.000000e+00, %55 ]
  %59 = icmp slt i64 %57, %1
  br i1 %59, label %60, label %84

60:                                               ; preds = %56
  %61 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %45, 1
  %62 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %45, 2
  %63 = getelementptr float, ptr %61, i64 %62
  %64 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %45, 4, 0
  %65 = mul nuw nsw i64 %47, %64
  %66 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %45, 4, 1
  %67 = mul nuw nsw i64 %57, %66
  %68 = add nuw nsw i64 %65, %67
  %69 = getelementptr inbounds nuw float, ptr %63, i64 %68
  %70 = load float, ptr %69, align 4
  %71 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 1
  %72 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 2
  %73 = getelementptr float, ptr %71, i64 %72
  %74 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 4, 0
  %75 = mul nuw nsw i64 %57, %74
  %76 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, 4, 1
  %77 = mul nuw nsw i64 %52, %76
  %78 = add nuw nsw i64 %75, %77
  %79 = getelementptr inbounds nuw float, ptr %73, i64 %78
  %80 = load float, ptr %79, align 4
  %81 = fmul float %70, %80
  %82 = fadd float %58, %81
  %83 = add i64 %57, 1
  br label %56

84:                                               ; preds = %56
  %85 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %53, 1
  %86 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %53, 2
  %87 = getelementptr float, ptr %85, i64 %86
  %88 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %53, 4, 0
  %89 = mul nuw nsw i64 %47, %88
  %90 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %53, 4, 1
  %91 = mul nuw nsw i64 %52, %90
  %92 = add nuw nsw i64 %89, %91
  %93 = getelementptr inbounds nuw float, ptr %87, i64 %92
  store float %58, ptr %93, align 4
  %94 = add i64 %52, 1
  br label %51

95:                                               ; preds = %51
  %96 = add i64 %47, 1
  br label %46

97:                                               ; preds = %46
  ret { ptr, ptr, i64, [2 x i64], [2 x i64] } %48
}

!llvm.module.flags = !{!0}

!0 = !{i32 2, !"Debug Info Version", i32 3}
