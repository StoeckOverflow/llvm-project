; ModuleID = '/home/stoeckoverflow/llvm-project/mlir/examples/dependent-memref-matmul/artifacts/benchmarks/size-256/baseline.ll'
source_filename = "LLVMDialectModule"

; Function Attrs: nofree norecurse nosync nounwind memory(argmem: readwrite)
define { ptr, ptr, i64, [2 x i64], [2 x i64] } @baseline_matmul_kernel(i64 %0, i64 %1, i64 %2, ptr readnone captures(none) %3, ptr readonly captures(none) %4, i64 %5, i64 %6, i64 %7, i64 %8, i64 %9, ptr readnone captures(none) %10, ptr readonly captures(none) %11, i64 %12, i64 %13, i64 %14, i64 %15, i64 %16, ptr %17, ptr %18, i64 %19, i64 %20, i64 %21, i64 %22, i64 %23) local_unnamed_addr #0 {
  %25 = icmp sgt i64 %0, 0
  br i1 %25, label %.preheader1.lr.ph, label %._crit_edge

.preheader1.lr.ph:                                ; preds = %24
  %26 = icmp sgt i64 %2, 0
  %27 = getelementptr [4 x i8], ptr %4, i64 %5
  %28 = getelementptr [4 x i8], ptr %11, i64 %12
  %29 = getelementptr [4 x i8], ptr %18, i64 %19
  br i1 %26, label %.preheader1.lr.ph.split.us, label %._crit_edge

.preheader1.lr.ph.split.us:                       ; preds = %.preheader1.lr.ph
  %30 = icmp sgt i64 %1, 0
  br i1 %30, label %.preheader1.us.us, label %.preheader1.us

.preheader1.us.us:                                ; preds = %.preheader1.lr.ph.split.us, %._crit_edge2.split.us.us.us
  %31 = phi i64 [ %54, %._crit_edge2.split.us.us.us ], [ 0, %.preheader1.lr.ph.split.us ]
  %32 = mul nuw nsw i64 %31, %8
  %33 = getelementptr inbounds nuw [4 x i8], ptr %27, i64 %32
  %34 = mul nuw nsw i64 %31, %22
  %35 = getelementptr inbounds nuw [4 x i8], ptr %29, i64 %34
  br label %.preheader.us.us.us

.preheader.us.us.us:                              ; preds = %._crit_edge.us.us.us, %.preheader1.us.us
  %36 = phi i64 [ 0, %.preheader1.us.us ], [ %52, %._crit_edge.us.us.us ]
  %37 = mul nuw nsw i64 %36, %16
  %invariant.gep.us.us.us = getelementptr [4 x i8], ptr %28, i64 %37
  br label %38

38:                                               ; preds = %38, %.preheader.us.us.us
  %39 = phi float [ 0.000000e+00, %.preheader.us.us.us ], [ %47, %38 ]
  %40 = phi i64 [ 0, %.preheader.us.us.us ], [ %48, %38 ]
  %41 = mul nuw nsw i64 %40, %9
  %42 = getelementptr inbounds nuw [4 x i8], ptr %33, i64 %41
  %43 = load float, ptr %42, align 4
  %44 = mul nuw nsw i64 %40, %15
  %gep.us.us.us = getelementptr [4 x i8], ptr %invariant.gep.us.us.us, i64 %44
  %45 = load float, ptr %gep.us.us.us, align 4
  %46 = fmul float %43, %45
  %47 = fadd float %39, %46
  %48 = add nuw nsw i64 %40, 1
  %49 = icmp slt i64 %48, %1
  br i1 %49, label %38, label %._crit_edge.us.us.us

._crit_edge.us.us.us:                             ; preds = %38
  %50 = mul nuw nsw i64 %36, %23
  %51 = getelementptr inbounds nuw [4 x i8], ptr %35, i64 %50
  store float %47, ptr %51, align 4
  %52 = add nuw nsw i64 %36, 1
  %53 = icmp slt i64 %52, %2
  br i1 %53, label %.preheader.us.us.us, label %._crit_edge2.split.us.us.us

._crit_edge2.split.us.us.us:                      ; preds = %._crit_edge.us.us.us
  %54 = add nuw nsw i64 %31, 1
  %55 = icmp slt i64 %54, %0
  br i1 %55, label %.preheader1.us.us, label %._crit_edge

.preheader1.us:                                   ; preds = %.preheader1.lr.ph.split.us, %._crit_edge2.split.us4
  %56 = phi i64 [ %64, %._crit_edge2.split.us4 ], [ 0, %.preheader1.lr.ph.split.us ]
  %57 = mul nuw nsw i64 %56, %22
  %58 = getelementptr inbounds nuw [4 x i8], ptr %29, i64 %57
  br label %.preheader.us3

.preheader.us3:                                   ; preds = %.preheader1.us, %.preheader.us3
  %59 = phi i64 [ 0, %.preheader1.us ], [ %62, %.preheader.us3 ]
  %60 = mul nuw nsw i64 %59, %23
  %61 = getelementptr inbounds nuw [4 x i8], ptr %58, i64 %60
  store float 0.000000e+00, ptr %61, align 4
  %62 = add nuw nsw i64 %59, 1
  %63 = icmp slt i64 %62, %2
  br i1 %63, label %.preheader.us3, label %._crit_edge2.split.us4

._crit_edge2.split.us4:                           ; preds = %.preheader.us3
  %64 = add nuw nsw i64 %56, 1
  %65 = icmp slt i64 %64, %0
  br i1 %65, label %.preheader1.us, label %._crit_edge

._crit_edge:                                      ; preds = %._crit_edge2.split.us4, %._crit_edge2.split.us.us.us, %.preheader1.lr.ph, %24
  %66 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %17, 0
  %67 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %66, ptr %18, 1
  %68 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %67, i64 %19, 2
  %69 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %68, i64 %20, 3, 0
  %70 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %69, i64 %22, 4, 0
  %71 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %70, i64 %21, 3, 1
  %72 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %71, i64 %23, 4, 1
  ret { ptr, ptr, i64, [2 x i64], [2 x i64] } %72
}

attributes #0 = { nofree norecurse nosync nounwind memory(argmem: readwrite) }

!llvm.module.flags = !{!0}

!0 = !{i32 2, !"Debug Info Version", i32 3}
