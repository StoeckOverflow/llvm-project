; ModuleID = 'artifacts/archive/2026-09-09_18-09/baseline/baseline_conv2d_kernel.ll'
source_filename = "LLVMDialectModule"

; Function Attrs: nofree norecurse nosync nounwind memory(argmem: readwrite)
define { ptr, ptr, i64, [4 x i64], [4 x i64] } @baseline_conv2d_kernel(i64 %0, i64 %1, i64 %2, i64 %3, i64 %4, i64 %5, i64 %6, i64 %7, i64 %8, ptr readnone captures(none) %9, ptr readonly captures(none) %10, i64 %11, i64 %12, i64 %13, i64 %14, i64 %15, i64 %16, i64 %17, i64 %18, i64 %19, i64 %20, i64 %21, i64 %22, i64 %23, ptr readnone captures(none) %24, ptr readonly captures(none) %25, i64 %26, i64 %27, i64 %28, i64 %29, i64 %30, i64 %31, i64 %32, i64 %33, i64 %34, ptr %35, ptr %36, i64 %37, i64 %38, i64 %39, i64 %40, i64 %41, i64 %42, i64 %43, i64 %44, i64 %45) local_unnamed_addr #0 {
  %47 = icmp sgt i64 %0, 0
  br i1 %47, label %.preheader5.lr.ph, label %._crit_edge

.preheader5.lr.ph:                                ; preds = %46
  %48 = icmp slt i64 %4, 1
  %49 = icmp slt i64 %8, 1
  %50 = icmp sgt i64 %5, 0
  %51 = icmp sgt i64 %6, 0
  %52 = getelementptr [4 x i8], ptr %10, i64 %11
  %53 = getelementptr [4 x i8], ptr %25, i64 %26
  %54 = getelementptr [4 x i8], ptr %36, i64 %37
  %55 = icmp slt i64 %7, 1
  %or.cond.not93 = select i1 %48, i1 true, i1 %55
  %brmerge = select i1 %or.cond.not93, i1 true, i1 %49
  br i1 %brmerge, label %._crit_edge, label %.preheader5.lr.ph.split.us.split.us.split.us

.preheader5.lr.ph.split.us.split.us.split.us:     ; preds = %.preheader5.lr.ph
  %56 = icmp sgt i64 %1, 0
  br i1 %56, label %.preheader5.lr.ph.split.us.split.us.split.us.split.us, label %.preheader5.us.us.us

.preheader5.lr.ph.split.us.split.us.split.us.split.us: ; preds = %.preheader5.lr.ph.split.us.split.us.split.us
  br i1 %50, label %.preheader5.lr.ph.split.us.split.us.split.us.split.us.split.us, label %.preheader5.us.us.us.us

.preheader5.lr.ph.split.us.split.us.split.us.split.us.split.us: ; preds = %.preheader5.lr.ph.split.us.split.us.split.us.split.us
  br i1 %51, label %.preheader5.us.us.us.us.us.us, label %.preheader5.us.us.us.us.us

.preheader5.us.us.us.us.us.us:                    ; preds = %.preheader5.lr.ph.split.us.split.us.split.us.split.us.split.us, %._crit_edge33.split.us.split.us.split.us.split.us.split.us.us.us.us.us.us.us
  %57 = phi i64 [ %109, %._crit_edge33.split.us.split.us.split.us.split.us.split.us.us.us.us.us.us.us ], [ 0, %.preheader5.lr.ph.split.us.split.us.split.us.split.us.split.us ]
  %58 = mul nuw nsw i64 %57, %18
  %59 = getelementptr inbounds nuw [4 x i8], ptr %52, i64 %58
  %60 = mul nuw nsw i64 %57, %42
  %61 = getelementptr inbounds nuw [4 x i8], ptr %54, i64 %60
  br label %.preheader4.us.us.us.us.us.us.us.us.us.us.us

.preheader4.us.us.us.us.us.us.us.us.us.us.us:     ; preds = %._crit_edge.split.us.split.us.split.us.split.us.us.us.us.us.us.us.us.us.us.us.us, %.preheader5.us.us.us.us.us.us
  %62 = phi i64 [ 0, %.preheader5.us.us.us.us.us.us ], [ %107, %._crit_edge.split.us.split.us.split.us.split.us.us.us.us.us.us.us.us.us.us.us.us ]
  %63 = mul nuw nsw i64 %62, %31
  %64 = getelementptr inbounds nuw [4 x i8], ptr %53, i64 %63
  %65 = mul nuw nsw i64 %62, %43
  %66 = getelementptr inbounds nuw [4 x i8], ptr %61, i64 %65
  br label %.preheader3.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us

.preheader3.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us: ; preds = %._crit_edge17.split.us.split.us.split.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us, %.preheader4.us.us.us.us.us.us.us.us.us.us.us
  %67 = phi i64 [ 0, %.preheader4.us.us.us.us.us.us.us.us.us.us.us ], [ %105, %._crit_edge17.split.us.split.us.split.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us ]
  %68 = mul nuw nsw i64 %67, %20
  %invariant.gep.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us = getelementptr [4 x i8], ptr %59, i64 %68
  %69 = mul nuw nsw i64 %67, %44
  %70 = getelementptr inbounds nuw [4 x i8], ptr %66, i64 %69
  br label %.preheader2.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us

.preheader2.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us: ; preds = %._crit_edge.split.us.split.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us, %.preheader3.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us
  %71 = phi i64 [ 0, %.preheader3.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us ], [ %103, %._crit_edge.split.us.split.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us ]
  %72 = mul nuw nsw i64 %71, %21
  %invariant.gep10.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us = getelementptr [4 x i8], ptr %invariant.gep.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us, i64 %72
  br label %.preheader1.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us

.preheader1.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us: ; preds = %._crit_edge8.split.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us, %.preheader2.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us
  %73 = phi float [ 0.000000e+00, %.preheader2.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us ], [ %94, %._crit_edge8.split.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us ]
  %74 = phi i64 [ 0, %.preheader2.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us ], [ %99, %._crit_edge8.split.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us ]
  %75 = mul nuw nsw i64 %74, %19
  %gep11.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us = getelementptr [4 x i8], ptr %invariant.gep10.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us, i64 %75
  %76 = mul nuw nsw i64 %74, %32
  %77 = getelementptr inbounds nuw [4 x i8], ptr %64, i64 %76
  br label %.preheader.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us

.preheader.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us: ; preds = %._crit_edge.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us, %.preheader1.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us
  %78 = phi float [ %73, %.preheader1.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us ], [ %94, %._crit_edge.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us ]
  %79 = phi i64 [ 0, %.preheader1.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us ], [ %97, %._crit_edge.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us ]
  %80 = mul nuw nsw i64 %79, %22
  %81 = getelementptr inbounds nuw [4 x i8], ptr %gep11.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us, i64 %80
  %82 = mul nuw nsw i64 %79, %33
  %83 = getelementptr inbounds nuw [4 x i8], ptr %77, i64 %82
  br label %84

84:                                               ; preds = %84, %.preheader.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us
  %85 = phi float [ %78, %.preheader.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us ], [ %94, %84 ]
  %86 = phi i64 [ 0, %.preheader.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us ], [ %95, %84 ]
  %87 = mul nuw nsw i64 %86, %23
  %88 = getelementptr inbounds nuw [4 x i8], ptr %81, i64 %87
  %89 = load float, ptr %88, align 4
  %90 = mul nuw nsw i64 %86, %34
  %91 = getelementptr inbounds nuw [4 x i8], ptr %83, i64 %90
  %92 = load float, ptr %91, align 4
  %93 = fmul float %89, %92
  %94 = fadd float %85, %93
  %95 = add nuw nsw i64 %86, 1
  %96 = icmp slt i64 %95, %6
  br i1 %96, label %84, label %._crit_edge.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us

._crit_edge.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us: ; preds = %84
  %97 = add nuw nsw i64 %79, 1
  %98 = icmp slt i64 %97, %5
  br i1 %98, label %.preheader.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us, label %._crit_edge8.split.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us

._crit_edge8.split.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us: ; preds = %._crit_edge.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us
  %99 = add nuw nsw i64 %74, 1
  %100 = icmp slt i64 %99, %1
  br i1 %100, label %.preheader1.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us, label %._crit_edge.split.us.split.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us

._crit_edge.split.us.split.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us: ; preds = %._crit_edge8.split.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us
  %101 = mul nuw nsw i64 %71, %45
  %102 = getelementptr inbounds nuw [4 x i8], ptr %70, i64 %101
  store float %94, ptr %102, align 4
  %103 = add nuw nsw i64 %71, 1
  %104 = icmp slt i64 %103, %8
  br i1 %104, label %.preheader2.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us, label %._crit_edge17.split.us.split.us.split.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us

._crit_edge17.split.us.split.us.split.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us: ; preds = %._crit_edge.split.us.split.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us
  %105 = add nuw nsw i64 %67, 1
  %106 = icmp slt i64 %105, %7
  br i1 %106, label %.preheader3.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us, label %._crit_edge.split.us.split.us.split.us.split.us.us.us.us.us.us.us.us.us.us.us.us

._crit_edge.split.us.split.us.split.us.split.us.us.us.us.us.us.us.us.us.us.us.us: ; preds = %._crit_edge17.split.us.split.us.split.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us
  %107 = add nuw nsw i64 %62, 1
  %108 = icmp slt i64 %107, %4
  br i1 %108, label %.preheader4.us.us.us.us.us.us.us.us.us.us.us, label %._crit_edge33.split.us.split.us.split.us.split.us.split.us.us.us.us.us.us.us

._crit_edge33.split.us.split.us.split.us.split.us.split.us.us.us.us.us.us.us: ; preds = %._crit_edge.split.us.split.us.split.us.split.us.us.us.us.us.us.us.us.us.us.us.us
  %109 = add nuw nsw i64 %57, 1
  %110 = icmp slt i64 %109, %0
  br i1 %110, label %.preheader5.us.us.us.us.us.us, label %._crit_edge

.preheader5.us.us.us.us.us:                       ; preds = %.preheader5.lr.ph.split.us.split.us.split.us.split.us.split.us, %._crit_edge33.split.us.split.us.split.us.split.us.split.us59.us.us.us.us
  %111 = phi i64 [ %129, %._crit_edge33.split.us.split.us.split.us.split.us.split.us59.us.us.us.us ], [ 0, %.preheader5.lr.ph.split.us.split.us.split.us.split.us.split.us ]
  %112 = mul nuw nsw i64 %111, %42
  %113 = getelementptr inbounds nuw [4 x i8], ptr %54, i64 %112
  br label %.preheader4.us.us.us.us.us58.us.us.us.us

.preheader4.us.us.us.us.us58.us.us.us.us:         ; preds = %.preheader5.us.us.us.us.us, %._crit_edge.split.us.split.us.split.us.split.us44.us.us.us.us.us.us.us.us
  %114 = phi i64 [ 0, %.preheader5.us.us.us.us.us ], [ %127, %._crit_edge.split.us.split.us.split.us.split.us44.us.us.us.us.us.us.us.us ]
  %115 = mul nuw nsw i64 %114, %43
  %116 = getelementptr inbounds nuw [4 x i8], ptr %113, i64 %115
  br label %.preheader3.us.us.us.us43.us.us.us.us.us.us.us.us

.preheader3.us.us.us.us43.us.us.us.us.us.us.us.us: ; preds = %._crit_edge17.split.us.split.us.split.us31.us.us.us.us.us.us.us.us.us.us.us, %.preheader4.us.us.us.us.us58.us.us.us.us
  %117 = phi i64 [ 0, %.preheader4.us.us.us.us.us58.us.us.us.us ], [ %125, %._crit_edge17.split.us.split.us.split.us31.us.us.us.us.us.us.us.us.us.us.us ]
  %118 = mul nuw nsw i64 %117, %44
  %119 = getelementptr inbounds nuw [4 x i8], ptr %116, i64 %118
  br label %.preheader2.us.us.us30.us.us.us.us.us.us.us.us.us.us.us

.preheader2.us.us.us30.us.us.us.us.us.us.us.us.us.us.us: ; preds = %.preheader2.us.us.us30.us.us.us.us.us.us.us.us.us.us.us, %.preheader3.us.us.us.us43.us.us.us.us.us.us.us.us
  %120 = phi i64 [ 0, %.preheader3.us.us.us.us43.us.us.us.us.us.us.us.us ], [ %123, %.preheader2.us.us.us30.us.us.us.us.us.us.us.us.us.us.us ]
  %121 = mul nuw nsw i64 %120, %45
  %122 = getelementptr inbounds nuw [4 x i8], ptr %119, i64 %121
  store float 0.000000e+00, ptr %122, align 4
  %123 = add nuw nsw i64 %120, 1
  %124 = icmp slt i64 %123, %8
  br i1 %124, label %.preheader2.us.us.us30.us.us.us.us.us.us.us.us.us.us.us, label %._crit_edge17.split.us.split.us.split.us31.us.us.us.us.us.us.us.us.us.us.us

._crit_edge17.split.us.split.us.split.us31.us.us.us.us.us.us.us.us.us.us.us: ; preds = %.preheader2.us.us.us30.us.us.us.us.us.us.us.us.us.us.us
  %125 = add nuw nsw i64 %117, 1
  %126 = icmp slt i64 %125, %7
  br i1 %126, label %.preheader3.us.us.us.us43.us.us.us.us.us.us.us.us, label %._crit_edge.split.us.split.us.split.us.split.us44.us.us.us.us.us.us.us.us

._crit_edge.split.us.split.us.split.us.split.us44.us.us.us.us.us.us.us.us: ; preds = %._crit_edge17.split.us.split.us.split.us31.us.us.us.us.us.us.us.us.us.us.us
  %127 = add nuw nsw i64 %114, 1
  %128 = icmp slt i64 %127, %4
  br i1 %128, label %.preheader4.us.us.us.us.us58.us.us.us.us, label %._crit_edge33.split.us.split.us.split.us.split.us.split.us59.us.us.us.us

._crit_edge33.split.us.split.us.split.us.split.us.split.us59.us.us.us.us: ; preds = %._crit_edge.split.us.split.us.split.us.split.us44.us.us.us.us.us.us.us.us
  %129 = add nuw nsw i64 %111, 1
  %130 = icmp slt i64 %129, %0
  br i1 %130, label %.preheader5.us.us.us.us.us, label %._crit_edge

.preheader5.us.us.us.us:                          ; preds = %.preheader5.lr.ph.split.us.split.us.split.us.split.us, %._crit_edge33.split.us.split.us.split.us.split.us56.us.us.us
  %131 = phi i64 [ %149, %._crit_edge33.split.us.split.us.split.us.split.us56.us.us.us ], [ 0, %.preheader5.lr.ph.split.us.split.us.split.us.split.us ]
  %132 = mul nuw nsw i64 %131, %42
  %133 = getelementptr inbounds nuw [4 x i8], ptr %54, i64 %132
  br label %.preheader4.us.us.us.us55.us.us.us

.preheader4.us.us.us.us55.us.us.us:               ; preds = %.preheader5.us.us.us.us, %._crit_edge.split.us.split.us.split.us41.us.us.us.us.us.us
  %134 = phi i64 [ 0, %.preheader5.us.us.us.us ], [ %147, %._crit_edge.split.us.split.us.split.us41.us.us.us.us.us.us ]
  %135 = mul nuw nsw i64 %134, %43
  %136 = getelementptr inbounds nuw [4 x i8], ptr %133, i64 %135
  br label %.preheader3.us.us.us40.us.us.us.us.us.us

.preheader3.us.us.us40.us.us.us.us.us.us:         ; preds = %._crit_edge17.split.us.split.us28.us.us.us.us.us.us.us.us, %.preheader4.us.us.us.us55.us.us.us
  %137 = phi i64 [ 0, %.preheader4.us.us.us.us55.us.us.us ], [ %145, %._crit_edge17.split.us.split.us28.us.us.us.us.us.us.us.us ]
  %138 = mul nuw nsw i64 %137, %44
  %139 = getelementptr inbounds nuw [4 x i8], ptr %136, i64 %138
  br label %.preheader2.us.us27.us.us.us.us.us.us.us.us

.preheader2.us.us27.us.us.us.us.us.us.us.us:      ; preds = %.preheader2.us.us27.us.us.us.us.us.us.us.us, %.preheader3.us.us.us40.us.us.us.us.us.us
  %140 = phi i64 [ 0, %.preheader3.us.us.us40.us.us.us.us.us.us ], [ %143, %.preheader2.us.us27.us.us.us.us.us.us.us.us ]
  %141 = mul nuw nsw i64 %140, %45
  %142 = getelementptr inbounds nuw [4 x i8], ptr %139, i64 %141
  store float 0.000000e+00, ptr %142, align 4
  %143 = add nuw nsw i64 %140, 1
  %144 = icmp slt i64 %143, %8
  br i1 %144, label %.preheader2.us.us27.us.us.us.us.us.us.us.us, label %._crit_edge17.split.us.split.us28.us.us.us.us.us.us.us.us

._crit_edge17.split.us.split.us28.us.us.us.us.us.us.us.us: ; preds = %.preheader2.us.us27.us.us.us.us.us.us.us.us
  %145 = add nuw nsw i64 %137, 1
  %146 = icmp slt i64 %145, %7
  br i1 %146, label %.preheader3.us.us.us40.us.us.us.us.us.us, label %._crit_edge.split.us.split.us.split.us41.us.us.us.us.us.us

._crit_edge.split.us.split.us.split.us41.us.us.us.us.us.us: ; preds = %._crit_edge17.split.us.split.us28.us.us.us.us.us.us.us.us
  %147 = add nuw nsw i64 %134, 1
  %148 = icmp slt i64 %147, %4
  br i1 %148, label %.preheader4.us.us.us.us55.us.us.us, label %._crit_edge33.split.us.split.us.split.us.split.us56.us.us.us

._crit_edge33.split.us.split.us.split.us.split.us56.us.us.us: ; preds = %._crit_edge.split.us.split.us.split.us41.us.us.us.us.us.us
  %149 = add nuw nsw i64 %131, 1
  %150 = icmp slt i64 %149, %0
  br i1 %150, label %.preheader5.us.us.us.us, label %._crit_edge

.preheader5.us.us.us:                             ; preds = %.preheader5.lr.ph.split.us.split.us.split.us, %._crit_edge33.split.us.split.us.split.us53.us.us
  %151 = phi i64 [ %169, %._crit_edge33.split.us.split.us.split.us53.us.us ], [ 0, %.preheader5.lr.ph.split.us.split.us.split.us ]
  %152 = mul nuw nsw i64 %151, %42
  %153 = getelementptr inbounds nuw [4 x i8], ptr %54, i64 %152
  br label %.preheader4.us.us.us52.us.us

.preheader4.us.us.us52.us.us:                     ; preds = %.preheader5.us.us.us, %._crit_edge.split.us.split.us38.us.us.us.us
  %154 = phi i64 [ 0, %.preheader5.us.us.us ], [ %167, %._crit_edge.split.us.split.us38.us.us.us.us ]
  %155 = mul nuw nsw i64 %154, %43
  %156 = getelementptr inbounds nuw [4 x i8], ptr %153, i64 %155
  br label %.preheader3.us.us37.us.us.us.us

.preheader3.us.us37.us.us.us.us:                  ; preds = %._crit_edge17.split.us25.us.us.us.us.us, %.preheader4.us.us.us52.us.us
  %157 = phi i64 [ 0, %.preheader4.us.us.us52.us.us ], [ %165, %._crit_edge17.split.us25.us.us.us.us.us ]
  %158 = mul nuw nsw i64 %157, %44
  %159 = getelementptr inbounds nuw [4 x i8], ptr %156, i64 %158
  br label %.preheader2.us24.us.us.us.us.us

.preheader2.us24.us.us.us.us.us:                  ; preds = %.preheader2.us24.us.us.us.us.us, %.preheader3.us.us37.us.us.us.us
  %160 = phi i64 [ 0, %.preheader3.us.us37.us.us.us.us ], [ %163, %.preheader2.us24.us.us.us.us.us ]
  %161 = mul nuw nsw i64 %160, %45
  %162 = getelementptr inbounds nuw [4 x i8], ptr %159, i64 %161
  store float 0.000000e+00, ptr %162, align 4
  %163 = add nuw nsw i64 %160, 1
  %164 = icmp slt i64 %163, %8
  br i1 %164, label %.preheader2.us24.us.us.us.us.us, label %._crit_edge17.split.us25.us.us.us.us.us

._crit_edge17.split.us25.us.us.us.us.us:          ; preds = %.preheader2.us24.us.us.us.us.us
  %165 = add nuw nsw i64 %157, 1
  %166 = icmp slt i64 %165, %7
  br i1 %166, label %.preheader3.us.us37.us.us.us.us, label %._crit_edge.split.us.split.us38.us.us.us.us

._crit_edge.split.us.split.us38.us.us.us.us:      ; preds = %._crit_edge17.split.us25.us.us.us.us.us
  %167 = add nuw nsw i64 %154, 1
  %168 = icmp slt i64 %167, %4
  br i1 %168, label %.preheader4.us.us.us52.us.us, label %._crit_edge33.split.us.split.us.split.us53.us.us

._crit_edge33.split.us.split.us.split.us53.us.us: ; preds = %._crit_edge.split.us.split.us38.us.us.us.us
  %169 = add nuw nsw i64 %151, 1
  %170 = icmp slt i64 %169, %0
  br i1 %170, label %.preheader5.us.us.us, label %._crit_edge

._crit_edge:                                      ; preds = %._crit_edge33.split.us.split.us.split.us53.us.us, %._crit_edge33.split.us.split.us.split.us.split.us56.us.us.us, %._crit_edge33.split.us.split.us.split.us.split.us.split.us59.us.us.us.us, %._crit_edge33.split.us.split.us.split.us.split.us.split.us.us.us.us.us.us.us, %.preheader5.lr.ph, %46
  %171 = insertvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } poison, ptr %35, 0
  %172 = insertvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %171, ptr %36, 1
  %173 = insertvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %172, i64 %37, 2
  %174 = insertvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %173, i64 %38, 3, 0
  %175 = insertvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %174, i64 %42, 4, 0
  %176 = insertvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %175, i64 %39, 3, 1
  %177 = insertvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %176, i64 %43, 4, 1
  %178 = insertvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %177, i64 %40, 3, 2
  %179 = insertvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %178, i64 %44, 4, 2
  %180 = insertvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %179, i64 %41, 3, 3
  %181 = insertvalue { ptr, ptr, i64, [4 x i64], [4 x i64] } %180, i64 %45, 4, 3
  ret { ptr, ptr, i64, [4 x i64], [4 x i64] } %181
}

attributes #0 = { nofree norecurse nosync nounwind memory(argmem: readwrite) }

!llvm.module.flags = !{!0}

!0 = !{i32 2, !"Debug Info Version", i32 3}
