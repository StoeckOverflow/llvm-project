; ModuleID = 'LLVMDialectModule'
source_filename = "LLVMDialectModule"

define { ptr, ptr, i64, [4 x i64], [4 x i64] } @baseline_conv2d_kernel(i64 %0, i64 %1, i64 %2, i64 %3, i64 %4, i64 %5, i64 %6, i64 %7, i64 %8, ptr %9, ptr %10, i64 %11, i64 %12, i64 %13, i64 %14, i64 %15, i64 %16, i64 %17, i64 %18, i64 %19, i64 %20, i64 %21, i64 %22, i64 %23, ptr %24, ptr %25, i64 %26, i64 %27, i64 %28, i64 %29, i64 %30, i64 %31, i64 %32, i64 %33, i64 %34, ptr %35, ptr %36, i64 %37, i64 %38, i64 %39, i64 %40, i64 %41, i64 %42, i64 %43, i64 %44, i64 %45) {
  %47 = insertvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } poison, ptr %35, 0
  %48 = insertvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %47, ptr %36, 1
  %49 = insertvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %48, i64 %37, 2
  %50 = insertvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %49, i64 %38, 3, 0
  %51 = insertvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %50, i64 %42, 4, 0
  %52 = insertvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %51, i64 %39, 3, 1
  %53 = insertvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %52, i64 %43, 4, 1
  %54 = insertvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %53, i64 %40, 3, 2
  %55 = insertvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %54, i64 %44, 4, 2
  %56 = insertvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %55, i64 %41, 3, 3
  %57 = insertvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %56, i64 %45, 4, 3
  %58 = insertvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } poison, ptr %24, 0
  %59 = insertvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %58, ptr %25, 1
  %60 = insertvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %59, i64 %26, 2
  %61 = insertvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %60, i64 %27, 3, 0
  %62 = insertvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %61, i64 %31, 4, 0
  %63 = insertvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %62, i64 %28, 3, 1
  %64 = insertvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %63, i64 %32, 4, 1
  %65 = insertvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %64, i64 %29, 3, 2
  %66 = insertvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %65, i64 %33, 4, 2
  %67 = insertvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %66, i64 %30, 3, 3
  %68 = insertvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %67, i64 %34, 4, 3
  %69 = insertvalue { ptr, ptr, i64, [6 x i64], [6 x i64] } poison, ptr %9, 0
  %70 = insertvalue { ptr, ptr, i64, [6 x i64], [6 x i64] } %69, ptr %10, 1
  %71 = insertvalue { ptr, ptr, i64, [6 x i64], [6 x i64] } %70, i64 %11, 2
  %72 = insertvalue { ptr, ptr, i64, [6 x i64], [6 x i64] } %71, i64 %12, 3, 0
  %73 = insertvalue { ptr, ptr, i64, [6 x i64], [6 x i64] } %72, i64 %18, 4, 0
  %74 = insertvalue { ptr, ptr, i64, [6 x i64], [6 x i64] } %73, i64 %13, 3, 1
  %75 = insertvalue { ptr, ptr, i64, [6 x i64], [6 x i64] } %74, i64 %19, 4, 1
  %76 = insertvalue { ptr, ptr, i64, [6 x i64], [6 x i64] } %75, i64 %14, 3, 2
  %77 = insertvalue { ptr, ptr, i64, [6 x i64], [6 x i64] } %76, i64 %20, 4, 2
  %78 = insertvalue { ptr, ptr, i64, [6 x i64], [6 x i64] } %77, i64 %15, 3, 3
  %79 = insertvalue { ptr, ptr, i64, [6 x i64], [6 x i64] } %78, i64 %21, 4, 3
  %80 = insertvalue { ptr, ptr, i64, [6 x i64], [6 x i64] } %79, i64 %16, 3, 4
  %81 = insertvalue { ptr, ptr, i64, [6 x i64], [6 x i64] } %80, i64 %22, 4, 4
  %82 = insertvalue { ptr, ptr, i64, [6 x i64], [6 x i64] } %81, i64 %17, 3, 5
  %83 = insertvalue { ptr, ptr, i64, [6 x i64], [6 x i64] } %82, i64 %23, 4, 5
  br label %84

84:                                               ; preds = %185, %46
  %85 = phi i64 [ %186, %185 ], [ 0, %46 ]
  %86 = phi { ptr, ptr, i64, [4 x i64], [4 x i64] } [ %91, %185 ], [ %57, %46 ]
  %87 = icmp slt i64 %85, %0
  br i1 %87, label %88, label %187

88:                                               ; preds = %84
  br label %89

89:                                               ; preds = %183, %88
  %90 = phi i64 [ %184, %183 ], [ 0, %88 ]
  %91 = phi { ptr, ptr, i64, [4 x i64], [4 x i64] } [ %96, %183 ], [ %86, %88 ]
  %92 = icmp slt i64 %90, %4
  br i1 %92, label %93, label %185

93:                                               ; preds = %89
  br label %94

94:                                               ; preds = %181, %93
  %95 = phi i64 [ %182, %181 ], [ 0, %93 ]
  %96 = phi { ptr, ptr, i64, [4 x i64], [4 x i64] } [ %101, %181 ], [ %91, %93 ]
  %97 = icmp slt i64 %95, %7
  br i1 %97, label %98, label %183

98:                                               ; preds = %94
  br label %99

99:                                               ; preds = %164, %98
  %100 = phi i64 [ %180, %164 ], [ 0, %98 ]
  %101 = phi { ptr, ptr, i64, [4 x i64], [4 x i64] } [ %101, %164 ], [ %96, %98 ]
  %102 = icmp slt i64 %100, %8
  br i1 %102, label %103, label %181

103:                                              ; preds = %99
  br label %104

104:                                              ; preds = %162, %103
  %105 = phi i64 [ %163, %162 ], [ 0, %103 ]
  %106 = phi float [ %111, %162 ], [ 0.000000e+00, %103 ]
  %107 = icmp slt i64 %105, %1
  br i1 %107, label %108, label %164

108:                                              ; preds = %104
  br label %109

109:                                              ; preds = %160, %108
  %110 = phi i64 [ %161, %160 ], [ 0, %108 ]
  %111 = phi float [ %116, %160 ], [ %106, %108 ]
  %112 = icmp slt i64 %110, %5
  br i1 %112, label %113, label %162

113:                                              ; preds = %109
  br label %114

114:                                              ; preds = %118, %113
  %115 = phi i64 [ %159, %118 ], [ 0, %113 ]
  %116 = phi float [ %158, %118 ], [ %111, %113 ]
  %117 = icmp slt i64 %115, %6
  br i1 %117, label %118, label %160

118:                                              ; preds = %114
  %119 = extractvalue { ptr, ptr, i64, [6 x i64], [6 x i64] } %83, 1
  %120 = extractvalue { ptr, ptr, i64, [6 x i64], [6 x i64] } %83, 2
  %121 = getelementptr float, ptr %119, i64 %120
  %122 = extractvalue { ptr, ptr, i64, [6 x i64], [6 x i64] } %83, 4, 0
  %123 = mul nuw nsw i64 %85, %122
  %124 = extractvalue { ptr, ptr, i64, [6 x i64], [6 x i64] } %83, 4, 1
  %125 = mul nuw nsw i64 %105, %124
  %126 = add nuw nsw i64 %123, %125
  %127 = extractvalue { ptr, ptr, i64, [6 x i64], [6 x i64] } %83, 4, 2
  %128 = mul nuw nsw i64 %95, %127
  %129 = add nuw nsw i64 %126, %128
  %130 = extractvalue { ptr, ptr, i64, [6 x i64], [6 x i64] } %83, 4, 3
  %131 = mul nuw nsw i64 %100, %130
  %132 = add nuw nsw i64 %129, %131
  %133 = extractvalue { ptr, ptr, i64, [6 x i64], [6 x i64] } %83, 4, 4
  %134 = mul nuw nsw i64 %110, %133
  %135 = add nuw nsw i64 %132, %134
  %136 = extractvalue { ptr, ptr, i64, [6 x i64], [6 x i64] } %83, 4, 5
  %137 = mul nuw nsw i64 %115, %136
  %138 = add nuw nsw i64 %135, %137
  %139 = getelementptr inbounds nuw float, ptr %121, i64 %138
  %140 = load float, ptr %139, align 4
  %141 = extractvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %68, 1
  %142 = extractvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %68, 2
  %143 = getelementptr float, ptr %141, i64 %142
  %144 = extractvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %68, 4, 0
  %145 = mul nuw nsw i64 %90, %144
  %146 = extractvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %68, 4, 1
  %147 = mul nuw nsw i64 %105, %146
  %148 = add nuw nsw i64 %145, %147
  %149 = extractvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %68, 4, 2
  %150 = mul nuw nsw i64 %110, %149
  %151 = add nuw nsw i64 %148, %150
  %152 = extractvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %68, 4, 3
  %153 = mul nuw nsw i64 %115, %152
  %154 = add nuw nsw i64 %151, %153
  %155 = getelementptr inbounds nuw float, ptr %143, i64 %154
  %156 = load float, ptr %155, align 4
  %157 = fmul float %140, %156
  %158 = fadd float %116, %157
  %159 = add i64 %115, 1
  br label %114

160:                                              ; preds = %114
  %161 = add i64 %110, 1
  br label %109

162:                                              ; preds = %109
  %163 = add i64 %105, 1
  br label %104

164:                                              ; preds = %104
  %165 = extractvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %101, 1
  %166 = extractvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %101, 2
  %167 = getelementptr float, ptr %165, i64 %166
  %168 = extractvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %101, 4, 0
  %169 = mul nuw nsw i64 %85, %168
  %170 = extractvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %101, 4, 1
  %171 = mul nuw nsw i64 %90, %170
  %172 = add nuw nsw i64 %169, %171
  %173 = extractvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %101, 4, 2
  %174 = mul nuw nsw i64 %95, %173
  %175 = add nuw nsw i64 %172, %174
  %176 = extractvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %101, 4, 3
  %177 = mul nuw nsw i64 %100, %176
  %178 = add nuw nsw i64 %175, %177
  %179 = getelementptr inbounds nuw float, ptr %167, i64 %178
  store float %106, ptr %179, align 4
  %180 = add i64 %100, 1
  br label %99

181:                                              ; preds = %99
  %182 = add i64 %95, 1
  br label %94

183:                                              ; preds = %94
  %184 = add i64 %90, 1
  br label %89

185:                                              ; preds = %89
  %186 = add i64 %85, 1
  br label %84

187:                                              ; preds = %84
  ret { ptr, ptr, i64, [4 x i64], [4 x i64] } %86
}

!llvm.module.flags = !{!0}

!0 = !{i32 2, !"Debug Info Version", i32 3}
