; ModuleID = 'mlir/examples/dependent-memref-matmul/artifacts/archive/2026-09-01_11-12/baseline-strided/baseline_matmul_strided.ll'
source_filename = "LLVMDialectModule"

; Function Attrs: nofree norecurse nosync nounwind memory(argmem: readwrite)
define void @baseline_matmul_strided(i64 %0, i64 %1, i64 %2, i64 %3, i64 %4, i64 %5, i64 %6, i64 %7, i64 %8, ptr readnone captures(none) %9, ptr readonly captures(none) %10, i64 %11, ptr readnone captures(none) %12, ptr readonly captures(none) %13, i64 %14, ptr readnone captures(none) %15, ptr writeonly captures(none) %16, i64 %17) local_unnamed_addr #0 {
  %19 = icmp sgt i64 %0, 0
  %20 = icmp sgt i64 %1, 0
  %or.cond = select i1 %19, i1 %20, i1 false
  br i1 %or.cond, label %.preheader1.lr.ph.split.us, label %._crit_edge

.preheader1.lr.ph.split.us:                       ; preds = %18
  %21 = icmp sgt i64 %2, 0
  br i1 %21, label %.preheader1.us.us, label %.preheader1.us

.preheader1.us.us:                                ; preds = %.preheader1.lr.ph.split.us, %._crit_edge2.split.us.us.us
  %22 = phi i64 [ %45, %._crit_edge2.split.us.us.us ], [ 0, %.preheader1.lr.ph.split.us ]
  %23 = mul nuw nsw i64 %22, %3
  %24 = getelementptr inbounds nuw [4 x i8], ptr %10, i64 %23
  %25 = mul nuw nsw i64 %22, %7
  %26 = getelementptr inbounds nuw [4 x i8], ptr %16, i64 %25
  br label %.preheader.us.us.us

.preheader.us.us.us:                              ; preds = %._crit_edge.us.us.us, %.preheader1.us.us
  %27 = phi i64 [ 0, %.preheader1.us.us ], [ %43, %._crit_edge.us.us.us ]
  %28 = mul nuw nsw i64 %27, %6
  %invariant.gep.us.us.us = getelementptr [4 x i8], ptr %13, i64 %28
  br label %29

29:                                               ; preds = %29, %.preheader.us.us.us
  %30 = phi float [ 0.000000e+00, %.preheader.us.us.us ], [ %38, %29 ]
  %31 = phi i64 [ 0, %.preheader.us.us.us ], [ %39, %29 ]
  %32 = mul nuw nsw i64 %31, %4
  %33 = getelementptr inbounds nuw [4 x i8], ptr %24, i64 %32
  %34 = load float, ptr %33, align 4
  %35 = mul nuw nsw i64 %31, %5
  %gep.us.us.us = getelementptr [4 x i8], ptr %invariant.gep.us.us.us, i64 %35
  %36 = load float, ptr %gep.us.us.us, align 4
  %37 = fmul float %34, %36
  %38 = fadd float %30, %37
  %39 = add nuw nsw i64 %31, 1
  %40 = icmp slt i64 %39, %2
  br i1 %40, label %29, label %._crit_edge.us.us.us

._crit_edge.us.us.us:                             ; preds = %29
  %41 = mul nuw nsw i64 %27, %8
  %42 = getelementptr inbounds nuw [4 x i8], ptr %26, i64 %41
  store float %38, ptr %42, align 4
  %43 = add nuw nsw i64 %27, 1
  %44 = icmp slt i64 %43, %1
  br i1 %44, label %.preheader.us.us.us, label %._crit_edge2.split.us.us.us

._crit_edge2.split.us.us.us:                      ; preds = %._crit_edge.us.us.us
  %45 = add nuw nsw i64 %22, 1
  %46 = icmp slt i64 %45, %0
  br i1 %46, label %.preheader1.us.us, label %._crit_edge

.preheader1.us:                                   ; preds = %.preheader1.lr.ph.split.us, %._crit_edge2.split.us4
  %47 = phi i64 [ %55, %._crit_edge2.split.us4 ], [ 0, %.preheader1.lr.ph.split.us ]
  %48 = mul nuw nsw i64 %47, %7
  %49 = getelementptr inbounds nuw [4 x i8], ptr %16, i64 %48
  br label %.preheader.us3

.preheader.us3:                                   ; preds = %.preheader1.us, %.preheader.us3
  %50 = phi i64 [ 0, %.preheader1.us ], [ %53, %.preheader.us3 ]
  %51 = mul nuw nsw i64 %50, %8
  %52 = getelementptr inbounds nuw [4 x i8], ptr %49, i64 %51
  store float 0.000000e+00, ptr %52, align 4
  %53 = add nuw nsw i64 %50, 1
  %54 = icmp slt i64 %53, %1
  br i1 %54, label %.preheader.us3, label %._crit_edge2.split.us4

._crit_edge2.split.us4:                           ; preds = %.preheader.us3
  %55 = add nuw nsw i64 %47, 1
  %56 = icmp slt i64 %55, %0
  br i1 %56, label %.preheader1.us, label %._crit_edge

._crit_edge:                                      ; preds = %._crit_edge2.split.us4, %._crit_edge2.split.us.us.us, %18
  ret void
}

attributes #0 = { nofree norecurse nosync nounwind memory(argmem: readwrite) }

!llvm.module.flags = !{!0}

!0 = !{i32 2, !"Debug Info Version", i32 3}
