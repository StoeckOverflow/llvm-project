; ModuleID = 'artifacts/archive/2026-09-09_18-09/baseline-strided/baseline_conv2d_strided.ll'
source_filename = "LLVMDialectModule"

; Function Attrs: nofree norecurse nosync nounwind memory(argmem: readwrite)
define void @baseline_conv2d_strided(i64 %0, i64 %1, i64 %2, i64 %3, i64 %4, i64 %5, i64 %6, i64 %7, i64 %8, ptr readnone captures(none) %9, ptr readonly captures(none) %10, i64 %11, i64 %12, i64 %13, ptr readnone captures(none) %14, ptr readonly captures(none) %15, i64 %16, i64 %17, i64 %18, ptr readnone captures(none) %19, ptr writeonly captures(none) %20, i64 %21, i64 %22, i64 %23) local_unnamed_addr #0 {
  %25 = mul i64 %3, %2
  %26 = mul i64 %25, %1
  %27 = mul i64 %6, %5
  %28 = mul i64 %27, %1
  %29 = mul i64 %8, %7
  %30 = mul i64 %29, %4
  %31 = icmp sgt i64 %0, 0
  br i1 %31, label %.preheader6.lr.ph, label %._crit_edge

.preheader6.lr.ph:                                ; preds = %24
  %32 = icmp slt i64 %4, 1
  %33 = icmp slt i64 %8, 1
  %34 = icmp slt i64 %7, 1
  %or.cond.not91 = select i1 %32, i1 true, i1 %34
  %brmerge = select i1 %or.cond.not91, i1 true, i1 %33
  br i1 %brmerge, label %._crit_edge, label %.preheader6.lr.ph.split.us.split.us.split.us

.preheader6.lr.ph.split.us.split.us.split.us:     ; preds = %.preheader6.lr.ph
  %35 = icmp slt i64 %6, 1
  %36 = icmp slt i64 %5, 1
  %37 = icmp slt i64 %1, 1
  %brmerge86 = select i1 %37, i1 true, i1 %36
  %brmerge88 = select i1 %brmerge86, i1 true, i1 %35
  br i1 %brmerge88, label %._crit_edge.sink.split, label %.preheader6.us.us.us.us.us.us

.preheader6.us.us.us.us.us.us:                    ; preds = %.preheader6.lr.ph.split.us.split.us.split.us, %._crit_edge34.split.us.split.us.split.us.split.us.split.us.us.us.us.us.us.us
  %38 = phi i64 [ %86, %._crit_edge34.split.us.split.us.split.us.split.us.split.us.us.us.us.us.us.us ], [ 0, %.preheader6.lr.ph.split.us.split.us.split.us ]
  %39 = mul nuw nsw i64 %26, %38
  %40 = getelementptr inbounds nuw [4 x i8], ptr %10, i64 %39
  %41 = mul nuw nsw i64 %30, %38
  %42 = getelementptr inbounds nuw [4 x i8], ptr %20, i64 %41
  br label %.preheader5.us.us.us.us.us.us.us.us.us.us.us

.preheader5.us.us.us.us.us.us.us.us.us.us.us:     ; preds = %._crit_edge.split.us.split.us.split.us.split.us.us.us.us.us.us.us.us.us.us.us.us, %.preheader6.us.us.us.us.us.us
  %43 = phi i64 [ 0, %.preheader6.us.us.us.us.us.us ], [ %84, %._crit_edge.split.us.split.us.split.us.split.us.us.us.us.us.us.us.us.us.us.us.us ]
  %44 = mul nuw nsw i64 %28, %43
  %45 = getelementptr inbounds nuw [4 x i8], ptr %15, i64 %44
  %46 = mul nuw nsw i64 %43, %29
  %47 = getelementptr inbounds nuw [4 x i8], ptr %42, i64 %46
  br label %.preheader4.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us

.preheader4.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us: ; preds = %._crit_edge18.split.us.split.us.split.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us, %.preheader5.us.us.us.us.us.us.us.us.us.us.us
  %48 = phi i64 [ 0, %.preheader5.us.us.us.us.us.us.us.us.us.us.us ], [ %82, %._crit_edge18.split.us.split.us.split.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us ]
  %49 = mul nuw nsw i64 %48, %3
  %invariant.gep.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us = getelementptr [4 x i8], ptr %40, i64 %49
  %50 = mul nuw nsw i64 %48, %8
  %51 = getelementptr inbounds nuw [4 x i8], ptr %47, i64 %50
  br label %.preheader3.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us

.preheader3.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us: ; preds = %._crit_edge.split.us.split.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us, %.preheader4.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us
  %52 = phi i64 [ 0, %.preheader4.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us ], [ %80, %._crit_edge.split.us.split.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us ]
  %invariant.gep11.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us = getelementptr [4 x i8], ptr %invariant.gep.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us, i64 %52
  br label %.preheader2.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us

.preheader2.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us: ; preds = %._crit_edge9.split.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us, %.preheader3.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us
  %53 = phi float [ 0.000000e+00, %.preheader3.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us ], [ %72, %._crit_edge9.split.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us ]
  %54 = phi i64 [ 0, %.preheader3.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us ], [ %77, %._crit_edge9.split.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us ]
  %55 = mul nuw nsw i64 %54, %25
  %gep12.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us = getelementptr [4 x i8], ptr %invariant.gep11.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us, i64 %55
  %56 = mul nuw nsw i64 %54, %27
  %57 = getelementptr inbounds nuw [4 x i8], ptr %45, i64 %56
  br label %.preheader.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us

.preheader.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us: ; preds = %._crit_edge.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us, %.preheader2.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us
  %58 = phi float [ %53, %.preheader2.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us ], [ %72, %._crit_edge.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us ]
  %59 = phi i64 [ 0, %.preheader2.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us ], [ %75, %._crit_edge.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us ]
  %60 = mul nuw nsw i64 %59, %3
  %61 = getelementptr inbounds nuw [4 x i8], ptr %gep12.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us, i64 %60
  %62 = mul nuw nsw i64 %59, %6
  %63 = getelementptr inbounds nuw [4 x i8], ptr %57, i64 %62
  br label %64

64:                                               ; preds = %64, %.preheader.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us
  %65 = phi float [ %58, %.preheader.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us ], [ %72, %64 ]
  %66 = phi i64 [ 0, %.preheader.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us ], [ %73, %64 ]
  %67 = getelementptr inbounds nuw [4 x i8], ptr %61, i64 %66
  %68 = load float, ptr %67, align 4
  %69 = getelementptr inbounds nuw [4 x i8], ptr %63, i64 %66
  %70 = load float, ptr %69, align 4
  %71 = fmul float %68, %70
  %72 = fadd float %65, %71
  %73 = add nuw nsw i64 %66, 1
  %74 = icmp slt i64 %73, %6
  br i1 %74, label %64, label %._crit_edge.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us

._crit_edge.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us: ; preds = %64
  %75 = add nuw nsw i64 %59, 1
  %76 = icmp slt i64 %75, %5
  br i1 %76, label %.preheader.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us, label %._crit_edge9.split.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us

._crit_edge9.split.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us: ; preds = %._crit_edge.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us
  %77 = add nuw nsw i64 %54, 1
  %78 = icmp slt i64 %77, %1
  br i1 %78, label %.preheader2.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us, label %._crit_edge.split.us.split.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us

._crit_edge.split.us.split.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us: ; preds = %._crit_edge9.split.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us
  %79 = getelementptr inbounds nuw [4 x i8], ptr %51, i64 %52
  store float %72, ptr %79, align 4
  %80 = add nuw nsw i64 %52, 1
  %81 = icmp slt i64 %80, %8
  br i1 %81, label %.preheader3.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us, label %._crit_edge18.split.us.split.us.split.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us

._crit_edge18.split.us.split.us.split.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us: ; preds = %._crit_edge.split.us.split.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us
  %82 = add nuw nsw i64 %48, 1
  %83 = icmp slt i64 %82, %7
  br i1 %83, label %.preheader4.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us, label %._crit_edge.split.us.split.us.split.us.split.us.us.us.us.us.us.us.us.us.us.us.us

._crit_edge.split.us.split.us.split.us.split.us.us.us.us.us.us.us.us.us.us.us.us: ; preds = %._crit_edge18.split.us.split.us.split.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us
  %84 = add nuw nsw i64 %43, 1
  %85 = icmp slt i64 %84, %4
  br i1 %85, label %.preheader5.us.us.us.us.us.us.us.us.us.us.us, label %._crit_edge34.split.us.split.us.split.us.split.us.split.us.us.us.us.us.us.us

._crit_edge34.split.us.split.us.split.us.split.us.split.us.us.us.us.us.us.us: ; preds = %._crit_edge.split.us.split.us.split.us.split.us.us.us.us.us.us.us.us.us.us.us.us
  %86 = add nuw nsw i64 %38, 1
  %87 = icmp slt i64 %86, %0
  br i1 %87, label %.preheader6.us.us.us.us.us.us, label %._crit_edge

._crit_edge.sink.split:                           ; preds = %.preheader6.lr.ph.split.us.split.us.split.us
  %88 = mul i64 %30, %0
  %89 = shl i64 %88, 2
  tail call void @llvm.memset.p0.i64(ptr align 4 %20, i8 0, i64 %89, i1 false)
  br label %._crit_edge

._crit_edge:                                      ; preds = %._crit_edge34.split.us.split.us.split.us.split.us.split.us.us.us.us.us.us.us, %._crit_edge.sink.split, %.preheader6.lr.ph, %24
  ret void
}

; Function Attrs: nocallback nofree nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i64(ptr writeonly captures(none), i8, i64, i1 immarg) #1

attributes #0 = { nofree norecurse nosync nounwind memory(argmem: readwrite) }
attributes #1 = { nocallback nofree nounwind willreturn memory(argmem: write) }

!llvm.module.flags = !{!0}

!0 = !{i32 2, !"Debug Info Version", i32 3}
