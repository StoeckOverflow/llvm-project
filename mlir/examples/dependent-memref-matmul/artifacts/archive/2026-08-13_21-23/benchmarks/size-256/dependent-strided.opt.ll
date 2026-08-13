; ModuleID = '/home/stoeckoverflow/llvm-project/mlir/examples/dependent-memref-matmul/artifacts/benchmarks/size-256/dependent-strided.ll'
source_filename = "LLVMDialectModule"

; Function Attrs: nofree norecurse nosync nounwind memory(argmem: readwrite)
define void @dependent_matmul_strided(i64 %0, i64 %1, i64 %2, i64 %3, i64 %4, i64 %5, i64 %6, i64 %7, i64 %8, ptr readonly captures(none) %9, ptr readonly captures(none) %10, ptr writeonly captures(none) %11) local_unnamed_addr #0 {
  %13 = icmp sgt i64 %0, 0
  %14 = icmp sgt i64 %1, 0
  %or.cond.i = select i1 %13, i1 %14, i1 false
  br i1 %or.cond.i, label %.preheader1.lr.ph.split.us.i, label %dependent_matmul_strided_typed.exit

.preheader1.lr.ph.split.us.i:                     ; preds = %12
  %15 = icmp sgt i64 %2, 0
  br i1 %15, label %.preheader1.us.us.i, label %.preheader1.us.i

.preheader1.us.us.i:                              ; preds = %.preheader1.lr.ph.split.us.i, %._crit_edge2.split.us.us.us.i
  %16 = phi i64 [ %39, %._crit_edge2.split.us.us.us.i ], [ 0, %.preheader1.lr.ph.split.us.i ]
  %17 = mul i64 %16, %3
  %18 = getelementptr [4 x i8], ptr %9, i64 %17
  %19 = mul i64 %16, %7
  %20 = getelementptr [4 x i8], ptr %11, i64 %19
  br label %.preheader.us.us.us.i

.preheader.us.us.us.i:                            ; preds = %._crit_edge.us.us.us.i, %.preheader1.us.us.i
  %21 = phi i64 [ 0, %.preheader1.us.us.i ], [ %37, %._crit_edge.us.us.us.i ]
  %22 = mul i64 %21, %6
  %invariant.gep.us.us.us.i = getelementptr [4 x i8], ptr %10, i64 %22
  br label %23

23:                                               ; preds = %23, %.preheader.us.us.us.i
  %24 = phi float [ 0.000000e+00, %.preheader.us.us.us.i ], [ %32, %23 ]
  %25 = phi i64 [ 0, %.preheader.us.us.us.i ], [ %33, %23 ]
  %26 = mul i64 %25, %4
  %27 = getelementptr [4 x i8], ptr %18, i64 %26
  %28 = load float, ptr %27, align 4
  %29 = mul i64 %25, %5
  %gep.us.us.us.i = getelementptr [4 x i8], ptr %invariant.gep.us.us.us.i, i64 %29
  %30 = load float, ptr %gep.us.us.us.i, align 4
  %31 = fmul float %28, %30
  %32 = fadd float %24, %31
  %33 = add nuw nsw i64 %25, 1
  %34 = icmp slt i64 %33, %2
  br i1 %34, label %23, label %._crit_edge.us.us.us.i

._crit_edge.us.us.us.i:                           ; preds = %23
  %35 = mul i64 %21, %8
  %36 = getelementptr [4 x i8], ptr %20, i64 %35
  store float %32, ptr %36, align 4
  %37 = add nuw nsw i64 %21, 1
  %38 = icmp slt i64 %37, %1
  br i1 %38, label %.preheader.us.us.us.i, label %._crit_edge2.split.us.us.us.i

._crit_edge2.split.us.us.us.i:                    ; preds = %._crit_edge.us.us.us.i
  %39 = add nuw nsw i64 %16, 1
  %40 = icmp slt i64 %39, %0
  br i1 %40, label %.preheader1.us.us.i, label %dependent_matmul_strided_typed.exit

.preheader1.us.i:                                 ; preds = %.preheader1.lr.ph.split.us.i, %._crit_edge2.split.us4.i
  %41 = phi i64 [ %49, %._crit_edge2.split.us4.i ], [ 0, %.preheader1.lr.ph.split.us.i ]
  %42 = mul i64 %41, %7
  %43 = getelementptr [4 x i8], ptr %11, i64 %42
  br label %.preheader.us3.i

.preheader.us3.i:                                 ; preds = %.preheader.us3.i, %.preheader1.us.i
  %44 = phi i64 [ 0, %.preheader1.us.i ], [ %47, %.preheader.us3.i ]
  %45 = mul i64 %44, %8
  %46 = getelementptr [4 x i8], ptr %43, i64 %45
  store float 0.000000e+00, ptr %46, align 4
  %47 = add nuw nsw i64 %44, 1
  %48 = icmp slt i64 %47, %1
  br i1 %48, label %.preheader.us3.i, label %._crit_edge2.split.us4.i

._crit_edge2.split.us4.i:                         ; preds = %.preheader.us3.i
  %49 = add nuw nsw i64 %41, 1
  %50 = icmp slt i64 %49, %0
  br i1 %50, label %.preheader1.us.i, label %dependent_matmul_strided_typed.exit

dependent_matmul_strided_typed.exit:              ; preds = %._crit_edge2.split.us4.i, %._crit_edge2.split.us.us.us.i, %12
  ret void
}

; Function Attrs: nofree norecurse nosync nounwind memory(argmem: readwrite)
define void @dependent_matmul_strided_typed(i64 %0, i64 %1, i64 %2, i64 %3, i64 %4, i64 %5, i64 %6, i64 %7, i64 %8, ptr readonly captures(none) %9, ptr readonly captures(none) %10, ptr writeonly captures(none) %11) local_unnamed_addr #0 {
  %13 = icmp sgt i64 %0, 0
  %14 = icmp sgt i64 %1, 0
  %or.cond = select i1 %13, i1 %14, i1 false
  br i1 %or.cond, label %.preheader1.lr.ph.split.us, label %._crit_edge

.preheader1.lr.ph.split.us:                       ; preds = %12
  %15 = icmp sgt i64 %2, 0
  br i1 %15, label %.preheader1.us.us, label %.preheader1.us

.preheader1.us.us:                                ; preds = %.preheader1.lr.ph.split.us, %._crit_edge2.split.us.us.us
  %16 = phi i64 [ %39, %._crit_edge2.split.us.us.us ], [ 0, %.preheader1.lr.ph.split.us ]
  %17 = mul i64 %16, %3
  %18 = getelementptr [4 x i8], ptr %9, i64 %17
  %19 = mul i64 %16, %7
  %20 = getelementptr [4 x i8], ptr %11, i64 %19
  br label %.preheader.us.us.us

.preheader.us.us.us:                              ; preds = %._crit_edge.us.us.us, %.preheader1.us.us
  %21 = phi i64 [ 0, %.preheader1.us.us ], [ %37, %._crit_edge.us.us.us ]
  %22 = mul i64 %21, %6
  %invariant.gep.us.us.us = getelementptr [4 x i8], ptr %10, i64 %22
  br label %23

23:                                               ; preds = %23, %.preheader.us.us.us
  %24 = phi float [ 0.000000e+00, %.preheader.us.us.us ], [ %32, %23 ]
  %25 = phi i64 [ 0, %.preheader.us.us.us ], [ %33, %23 ]
  %26 = mul i64 %25, %4
  %27 = getelementptr [4 x i8], ptr %18, i64 %26
  %28 = load float, ptr %27, align 4
  %29 = mul i64 %25, %5
  %gep.us.us.us = getelementptr [4 x i8], ptr %invariant.gep.us.us.us, i64 %29
  %30 = load float, ptr %gep.us.us.us, align 4
  %31 = fmul float %28, %30
  %32 = fadd float %24, %31
  %33 = add nuw nsw i64 %25, 1
  %34 = icmp slt i64 %33, %2
  br i1 %34, label %23, label %._crit_edge.us.us.us

._crit_edge.us.us.us:                             ; preds = %23
  %35 = mul i64 %21, %8
  %36 = getelementptr [4 x i8], ptr %20, i64 %35
  store float %32, ptr %36, align 4
  %37 = add nuw nsw i64 %21, 1
  %38 = icmp slt i64 %37, %1
  br i1 %38, label %.preheader.us.us.us, label %._crit_edge2.split.us.us.us

._crit_edge2.split.us.us.us:                      ; preds = %._crit_edge.us.us.us
  %39 = add nuw nsw i64 %16, 1
  %40 = icmp slt i64 %39, %0
  br i1 %40, label %.preheader1.us.us, label %._crit_edge

.preheader1.us:                                   ; preds = %.preheader1.lr.ph.split.us, %._crit_edge2.split.us4
  %41 = phi i64 [ %49, %._crit_edge2.split.us4 ], [ 0, %.preheader1.lr.ph.split.us ]
  %42 = mul i64 %41, %7
  %43 = getelementptr [4 x i8], ptr %11, i64 %42
  br label %.preheader.us3

.preheader.us3:                                   ; preds = %.preheader1.us, %.preheader.us3
  %44 = phi i64 [ 0, %.preheader1.us ], [ %47, %.preheader.us3 ]
  %45 = mul i64 %44, %8
  %46 = getelementptr [4 x i8], ptr %43, i64 %45
  store float 0.000000e+00, ptr %46, align 4
  %47 = add nuw nsw i64 %44, 1
  %48 = icmp slt i64 %47, %1
  br i1 %48, label %.preheader.us3, label %._crit_edge2.split.us4

._crit_edge2.split.us4:                           ; preds = %.preheader.us3
  %49 = add nuw nsw i64 %41, 1
  %50 = icmp slt i64 %49, %0
  br i1 %50, label %.preheader1.us, label %._crit_edge

._crit_edge:                                      ; preds = %._crit_edge2.split.us4, %._crit_edge2.split.us.us.us, %12
  ret void
}

attributes #0 = { nofree norecurse nosync nounwind memory(argmem: readwrite) }

!llvm.module.flags = !{!0}

!0 = !{i32 2, !"Debug Info Version", i32 3}
