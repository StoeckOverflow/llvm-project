; ModuleID = 'artifacts/archive/2026-09-09_18-09/direct-strided/dependent_conv2d_strided.ll'
source_filename = "LLVMDialectModule"

; Function Attrs: nofree norecurse nosync nounwind memory(argmem: readwrite)
define void @dependent_conv2d_strided(i64 %0, i64 %1, i64 %2, i64 %3, i64 %4, i64 %5, i64 %6, i64 %7, i64 %8, i64 %9, i64 %10, i64 %11, i64 %12, i64 %13, i64 %14, i64 %15, i64 %16, i64 %17, i64 %18, ptr readonly captures(none) %19, ptr readonly captures(none) %20, ptr writeonly captures(none) %21) local_unnamed_addr #0 {
  %23 = icmp sgt i64 %0, 0
  br i1 %23, label %.preheader5.lr.ph, label %._crit_edge

.preheader5.lr.ph:                                ; preds = %22
  %24 = icmp slt i64 %4, 1
  %25 = icmp slt i64 %8, 1
  %26 = icmp sgt i64 %5, 0
  %27 = icmp sgt i64 %6, 0
  %28 = icmp slt i64 %7, 1
  %or.cond.not93 = select i1 %24, i1 true, i1 %28
  %brmerge = select i1 %or.cond.not93, i1 true, i1 %25
  br i1 %brmerge, label %._crit_edge, label %.preheader5.lr.ph.split.us.split.us.split.us

.preheader5.lr.ph.split.us.split.us.split.us:     ; preds = %.preheader5.lr.ph
  %29 = icmp sgt i64 %1, 0
  br i1 %29, label %.preheader5.lr.ph.split.us.split.us.split.us.split.us, label %.preheader5.us.us.us

.preheader5.lr.ph.split.us.split.us.split.us.split.us: ; preds = %.preheader5.lr.ph.split.us.split.us.split.us
  br i1 %26, label %.preheader5.lr.ph.split.us.split.us.split.us.split.us.split.us, label %.preheader5.us.us.us.us

.preheader5.lr.ph.split.us.split.us.split.us.split.us.split.us: ; preds = %.preheader5.lr.ph.split.us.split.us.split.us.split.us
  br i1 %27, label %.preheader5.us.us.us.us.us.us, label %.preheader5.us.us.us.us.us

.preheader5.us.us.us.us.us.us:                    ; preds = %.preheader5.lr.ph.split.us.split.us.split.us.split.us.split.us, %._crit_edge33.split.us.split.us.split.us.split.us.split.us.us.us.us.us.us.us
  %30 = phi i64 [ %80, %._crit_edge33.split.us.split.us.split.us.split.us.split.us.us.us.us.us.us.us ], [ 0, %.preheader5.lr.ph.split.us.split.us.split.us.split.us.split.us ]
  %31 = mul i64 %30, %9
  %32 = getelementptr [4 x i8], ptr %19, i64 %31
  %33 = mul i64 %30, %16
  %34 = getelementptr [4 x i8], ptr %21, i64 %33
  br label %.preheader4.us.us.us.us.us.us.us.us.us.us.us

.preheader4.us.us.us.us.us.us.us.us.us.us.us:     ; preds = %._crit_edge.split.us.split.us.split.us.split.us.us.us.us.us.us.us.us.us.us.us.us, %.preheader5.us.us.us.us.us.us
  %35 = phi i64 [ 0, %.preheader5.us.us.us.us.us.us ], [ %78, %._crit_edge.split.us.split.us.split.us.split.us.us.us.us.us.us.us.us.us.us.us.us ]
  %36 = mul i64 %35, %13
  %37 = getelementptr [4 x i8], ptr %20, i64 %36
  %38 = mul i64 %35, %17
  %39 = getelementptr [4 x i8], ptr %34, i64 %38
  br label %.preheader3.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us

.preheader3.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us: ; preds = %._crit_edge17.split.us.split.us.split.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us, %.preheader4.us.us.us.us.us.us.us.us.us.us.us
  %40 = phi i64 [ 0, %.preheader4.us.us.us.us.us.us.us.us.us.us.us ], [ %76, %._crit_edge17.split.us.split.us.split.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us ]
  %41 = mul i64 %40, %11
  %invariant.gep.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us = getelementptr [4 x i8], ptr %32, i64 %41
  %42 = mul i64 %40, %18
  %43 = getelementptr [4 x i8], ptr %39, i64 %42
  br label %.preheader2.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us

.preheader2.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us: ; preds = %._crit_edge.split.us.split.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us, %.preheader3.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us
  %44 = phi i64 [ 0, %.preheader3.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us ], [ %74, %._crit_edge.split.us.split.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us ]
  %45 = mul i64 %44, %12
  %invariant.gep10.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us = getelementptr [4 x i8], ptr %invariant.gep.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us, i64 %45
  br label %.preheader1.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us

.preheader1.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us: ; preds = %._crit_edge8.split.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us, %.preheader2.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us
  %46 = phi float [ 0.000000e+00, %.preheader2.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us ], [ %66, %._crit_edge8.split.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us ]
  %47 = phi i64 [ 0, %.preheader2.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us ], [ %71, %._crit_edge8.split.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us ]
  %48 = mul i64 %47, %10
  %gep11.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us = getelementptr [4 x i8], ptr %invariant.gep10.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us, i64 %48
  %49 = mul i64 %47, %14
  %50 = getelementptr [4 x i8], ptr %37, i64 %49
  br label %.preheader.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us

.preheader.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us: ; preds = %._crit_edge.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us, %.preheader1.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us
  %51 = phi float [ %46, %.preheader1.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us ], [ %66, %._crit_edge.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us ]
  %52 = phi i64 [ 0, %.preheader1.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us ], [ %69, %._crit_edge.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us ]
  %53 = mul i64 %52, %11
  %54 = getelementptr [4 x i8], ptr %gep11.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us, i64 %53
  %55 = mul i64 %52, %15
  %56 = getelementptr [4 x i8], ptr %50, i64 %55
  br label %57

57:                                               ; preds = %57, %.preheader.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us
  %58 = phi float [ %51, %.preheader.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us ], [ %66, %57 ]
  %59 = phi i64 [ 0, %.preheader.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us ], [ %67, %57 ]
  %60 = mul i64 %59, %12
  %61 = getelementptr [4 x i8], ptr %54, i64 %60
  %62 = load float, ptr %61, align 4
  %63 = getelementptr [4 x i8], ptr %56, i64 %60
  %64 = load float, ptr %63, align 4
  %65 = fmul float %62, %64
  %66 = fadd float %58, %65
  %67 = add nuw nsw i64 %59, 1
  %68 = icmp slt i64 %67, %6
  br i1 %68, label %57, label %._crit_edge.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us

._crit_edge.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us: ; preds = %57
  %69 = add nuw nsw i64 %52, 1
  %70 = icmp slt i64 %69, %5
  br i1 %70, label %.preheader.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us, label %._crit_edge8.split.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us

._crit_edge8.split.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us: ; preds = %._crit_edge.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us
  %71 = add nuw nsw i64 %47, 1
  %72 = icmp slt i64 %71, %1
  br i1 %72, label %.preheader1.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us, label %._crit_edge.split.us.split.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us

._crit_edge.split.us.split.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us: ; preds = %._crit_edge8.split.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us
  %73 = getelementptr [4 x i8], ptr %43, i64 %45
  store float %66, ptr %73, align 4
  %74 = add nuw nsw i64 %44, 1
  %75 = icmp slt i64 %74, %8
  br i1 %75, label %.preheader2.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us, label %._crit_edge17.split.us.split.us.split.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us

._crit_edge17.split.us.split.us.split.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us: ; preds = %._crit_edge.split.us.split.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us
  %76 = add nuw nsw i64 %40, 1
  %77 = icmp slt i64 %76, %7
  br i1 %77, label %.preheader3.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us, label %._crit_edge.split.us.split.us.split.us.split.us.us.us.us.us.us.us.us.us.us.us.us

._crit_edge.split.us.split.us.split.us.split.us.us.us.us.us.us.us.us.us.us.us.us: ; preds = %._crit_edge17.split.us.split.us.split.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us
  %78 = add nuw nsw i64 %35, 1
  %79 = icmp slt i64 %78, %4
  br i1 %79, label %.preheader4.us.us.us.us.us.us.us.us.us.us.us, label %._crit_edge33.split.us.split.us.split.us.split.us.split.us.us.us.us.us.us.us

._crit_edge33.split.us.split.us.split.us.split.us.split.us.us.us.us.us.us.us: ; preds = %._crit_edge.split.us.split.us.split.us.split.us.us.us.us.us.us.us.us.us.us.us.us
  %80 = add nuw nsw i64 %30, 1
  %81 = icmp slt i64 %80, %0
  br i1 %81, label %.preheader5.us.us.us.us.us.us, label %._crit_edge

.preheader5.us.us.us.us.us:                       ; preds = %.preheader5.lr.ph.split.us.split.us.split.us.split.us.split.us, %._crit_edge33.split.us.split.us.split.us.split.us.split.us59.us.us.us.us
  %82 = phi i64 [ %100, %._crit_edge33.split.us.split.us.split.us.split.us.split.us59.us.us.us.us ], [ 0, %.preheader5.lr.ph.split.us.split.us.split.us.split.us.split.us ]
  %83 = mul i64 %82, %16
  %84 = getelementptr [4 x i8], ptr %21, i64 %83
  br label %.preheader4.us.us.us.us.us58.us.us.us.us

.preheader4.us.us.us.us.us58.us.us.us.us:         ; preds = %.preheader5.us.us.us.us.us, %._crit_edge.split.us.split.us.split.us.split.us44.us.us.us.us.us.us.us.us
  %85 = phi i64 [ 0, %.preheader5.us.us.us.us.us ], [ %98, %._crit_edge.split.us.split.us.split.us.split.us44.us.us.us.us.us.us.us.us ]
  %86 = mul i64 %85, %17
  %87 = getelementptr [4 x i8], ptr %84, i64 %86
  br label %.preheader3.us.us.us.us43.us.us.us.us.us.us.us.us

.preheader3.us.us.us.us43.us.us.us.us.us.us.us.us: ; preds = %._crit_edge17.split.us.split.us.split.us31.us.us.us.us.us.us.us.us.us.us.us, %.preheader4.us.us.us.us.us58.us.us.us.us
  %88 = phi i64 [ 0, %.preheader4.us.us.us.us.us58.us.us.us.us ], [ %96, %._crit_edge17.split.us.split.us.split.us31.us.us.us.us.us.us.us.us.us.us.us ]
  %89 = mul i64 %88, %18
  %90 = getelementptr [4 x i8], ptr %87, i64 %89
  br label %.preheader2.us.us.us30.us.us.us.us.us.us.us.us.us.us.us

.preheader2.us.us.us30.us.us.us.us.us.us.us.us.us.us.us: ; preds = %.preheader2.us.us.us30.us.us.us.us.us.us.us.us.us.us.us, %.preheader3.us.us.us.us43.us.us.us.us.us.us.us.us
  %91 = phi i64 [ 0, %.preheader3.us.us.us.us43.us.us.us.us.us.us.us.us ], [ %94, %.preheader2.us.us.us30.us.us.us.us.us.us.us.us.us.us.us ]
  %92 = mul i64 %91, %12
  %93 = getelementptr [4 x i8], ptr %90, i64 %92
  store float 0.000000e+00, ptr %93, align 4
  %94 = add nuw nsw i64 %91, 1
  %95 = icmp slt i64 %94, %8
  br i1 %95, label %.preheader2.us.us.us30.us.us.us.us.us.us.us.us.us.us.us, label %._crit_edge17.split.us.split.us.split.us31.us.us.us.us.us.us.us.us.us.us.us

._crit_edge17.split.us.split.us.split.us31.us.us.us.us.us.us.us.us.us.us.us: ; preds = %.preheader2.us.us.us30.us.us.us.us.us.us.us.us.us.us.us
  %96 = add nuw nsw i64 %88, 1
  %97 = icmp slt i64 %96, %7
  br i1 %97, label %.preheader3.us.us.us.us43.us.us.us.us.us.us.us.us, label %._crit_edge.split.us.split.us.split.us.split.us44.us.us.us.us.us.us.us.us

._crit_edge.split.us.split.us.split.us.split.us44.us.us.us.us.us.us.us.us: ; preds = %._crit_edge17.split.us.split.us.split.us31.us.us.us.us.us.us.us.us.us.us.us
  %98 = add nuw nsw i64 %85, 1
  %99 = icmp slt i64 %98, %4
  br i1 %99, label %.preheader4.us.us.us.us.us58.us.us.us.us, label %._crit_edge33.split.us.split.us.split.us.split.us.split.us59.us.us.us.us

._crit_edge33.split.us.split.us.split.us.split.us.split.us59.us.us.us.us: ; preds = %._crit_edge.split.us.split.us.split.us.split.us44.us.us.us.us.us.us.us.us
  %100 = add nuw nsw i64 %82, 1
  %101 = icmp slt i64 %100, %0
  br i1 %101, label %.preheader5.us.us.us.us.us, label %._crit_edge

.preheader5.us.us.us.us:                          ; preds = %.preheader5.lr.ph.split.us.split.us.split.us.split.us, %._crit_edge33.split.us.split.us.split.us.split.us56.us.us.us
  %102 = phi i64 [ %120, %._crit_edge33.split.us.split.us.split.us.split.us56.us.us.us ], [ 0, %.preheader5.lr.ph.split.us.split.us.split.us.split.us ]
  %103 = mul i64 %102, %16
  %104 = getelementptr [4 x i8], ptr %21, i64 %103
  br label %.preheader4.us.us.us.us55.us.us.us

.preheader4.us.us.us.us55.us.us.us:               ; preds = %.preheader5.us.us.us.us, %._crit_edge.split.us.split.us.split.us41.us.us.us.us.us.us
  %105 = phi i64 [ 0, %.preheader5.us.us.us.us ], [ %118, %._crit_edge.split.us.split.us.split.us41.us.us.us.us.us.us ]
  %106 = mul i64 %105, %17
  %107 = getelementptr [4 x i8], ptr %104, i64 %106
  br label %.preheader3.us.us.us40.us.us.us.us.us.us

.preheader3.us.us.us40.us.us.us.us.us.us:         ; preds = %._crit_edge17.split.us.split.us28.us.us.us.us.us.us.us.us, %.preheader4.us.us.us.us55.us.us.us
  %108 = phi i64 [ 0, %.preheader4.us.us.us.us55.us.us.us ], [ %116, %._crit_edge17.split.us.split.us28.us.us.us.us.us.us.us.us ]
  %109 = mul i64 %108, %18
  %110 = getelementptr [4 x i8], ptr %107, i64 %109
  br label %.preheader2.us.us27.us.us.us.us.us.us.us.us

.preheader2.us.us27.us.us.us.us.us.us.us.us:      ; preds = %.preheader2.us.us27.us.us.us.us.us.us.us.us, %.preheader3.us.us.us40.us.us.us.us.us.us
  %111 = phi i64 [ 0, %.preheader3.us.us.us40.us.us.us.us.us.us ], [ %114, %.preheader2.us.us27.us.us.us.us.us.us.us.us ]
  %112 = mul i64 %111, %12
  %113 = getelementptr [4 x i8], ptr %110, i64 %112
  store float 0.000000e+00, ptr %113, align 4
  %114 = add nuw nsw i64 %111, 1
  %115 = icmp slt i64 %114, %8
  br i1 %115, label %.preheader2.us.us27.us.us.us.us.us.us.us.us, label %._crit_edge17.split.us.split.us28.us.us.us.us.us.us.us.us

._crit_edge17.split.us.split.us28.us.us.us.us.us.us.us.us: ; preds = %.preheader2.us.us27.us.us.us.us.us.us.us.us
  %116 = add nuw nsw i64 %108, 1
  %117 = icmp slt i64 %116, %7
  br i1 %117, label %.preheader3.us.us.us40.us.us.us.us.us.us, label %._crit_edge.split.us.split.us.split.us41.us.us.us.us.us.us

._crit_edge.split.us.split.us.split.us41.us.us.us.us.us.us: ; preds = %._crit_edge17.split.us.split.us28.us.us.us.us.us.us.us.us
  %118 = add nuw nsw i64 %105, 1
  %119 = icmp slt i64 %118, %4
  br i1 %119, label %.preheader4.us.us.us.us55.us.us.us, label %._crit_edge33.split.us.split.us.split.us.split.us56.us.us.us

._crit_edge33.split.us.split.us.split.us.split.us56.us.us.us: ; preds = %._crit_edge.split.us.split.us.split.us41.us.us.us.us.us.us
  %120 = add nuw nsw i64 %102, 1
  %121 = icmp slt i64 %120, %0
  br i1 %121, label %.preheader5.us.us.us.us, label %._crit_edge

.preheader5.us.us.us:                             ; preds = %.preheader5.lr.ph.split.us.split.us.split.us, %._crit_edge33.split.us.split.us.split.us53.us.us
  %122 = phi i64 [ %140, %._crit_edge33.split.us.split.us.split.us53.us.us ], [ 0, %.preheader5.lr.ph.split.us.split.us.split.us ]
  %123 = mul i64 %122, %16
  %124 = getelementptr [4 x i8], ptr %21, i64 %123
  br label %.preheader4.us.us.us52.us.us

.preheader4.us.us.us52.us.us:                     ; preds = %.preheader5.us.us.us, %._crit_edge.split.us.split.us38.us.us.us.us
  %125 = phi i64 [ 0, %.preheader5.us.us.us ], [ %138, %._crit_edge.split.us.split.us38.us.us.us.us ]
  %126 = mul i64 %125, %17
  %127 = getelementptr [4 x i8], ptr %124, i64 %126
  br label %.preheader3.us.us37.us.us.us.us

.preheader3.us.us37.us.us.us.us:                  ; preds = %._crit_edge17.split.us25.us.us.us.us.us, %.preheader4.us.us.us52.us.us
  %128 = phi i64 [ 0, %.preheader4.us.us.us52.us.us ], [ %136, %._crit_edge17.split.us25.us.us.us.us.us ]
  %129 = mul i64 %128, %18
  %130 = getelementptr [4 x i8], ptr %127, i64 %129
  br label %.preheader2.us24.us.us.us.us.us

.preheader2.us24.us.us.us.us.us:                  ; preds = %.preheader2.us24.us.us.us.us.us, %.preheader3.us.us37.us.us.us.us
  %131 = phi i64 [ 0, %.preheader3.us.us37.us.us.us.us ], [ %134, %.preheader2.us24.us.us.us.us.us ]
  %132 = mul i64 %131, %12
  %133 = getelementptr [4 x i8], ptr %130, i64 %132
  store float 0.000000e+00, ptr %133, align 4
  %134 = add nuw nsw i64 %131, 1
  %135 = icmp slt i64 %134, %8
  br i1 %135, label %.preheader2.us24.us.us.us.us.us, label %._crit_edge17.split.us25.us.us.us.us.us

._crit_edge17.split.us25.us.us.us.us.us:          ; preds = %.preheader2.us24.us.us.us.us.us
  %136 = add nuw nsw i64 %128, 1
  %137 = icmp slt i64 %136, %7
  br i1 %137, label %.preheader3.us.us37.us.us.us.us, label %._crit_edge.split.us.split.us38.us.us.us.us

._crit_edge.split.us.split.us38.us.us.us.us:      ; preds = %._crit_edge17.split.us25.us.us.us.us.us
  %138 = add nuw nsw i64 %125, 1
  %139 = icmp slt i64 %138, %4
  br i1 %139, label %.preheader4.us.us.us52.us.us, label %._crit_edge33.split.us.split.us.split.us53.us.us

._crit_edge33.split.us.split.us.split.us53.us.us: ; preds = %._crit_edge.split.us.split.us38.us.us.us.us
  %140 = add nuw nsw i64 %122, 1
  %141 = icmp slt i64 %140, %0
  br i1 %141, label %.preheader5.us.us.us, label %._crit_edge

._crit_edge:                                      ; preds = %._crit_edge33.split.us.split.us.split.us53.us.us, %._crit_edge33.split.us.split.us.split.us.split.us56.us.us.us, %._crit_edge33.split.us.split.us.split.us.split.us.split.us59.us.us.us.us, %._crit_edge33.split.us.split.us.split.us.split.us.split.us.us.us.us.us.us.us, %.preheader5.lr.ph, %22
  ret void
}

attributes #0 = { nofree norecurse nosync nounwind memory(argmem: readwrite) }

!llvm.module.flags = !{!0}

!0 = !{i32 2, !"Debug Info Version", i32 3}
