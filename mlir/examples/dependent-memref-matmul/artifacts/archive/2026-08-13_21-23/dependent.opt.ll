; ModuleID = '/home/stoeckoverflow/llvm-project/mlir/examples/dependent-memref-matmul/artifacts/dependent.ll'
source_filename = "LLVMDialectModule"

; Function Attrs: nofree norecurse nosync nounwind memory(argmem: readwrite)
define ptr @dependent_matmul_kernel(i64 %0, i64 %1, i64 %2, ptr readonly captures(none) %3, ptr readonly captures(none) %4, ptr returned writeonly captures(ret: address, provenance) %5) local_unnamed_addr #0 {
  %7 = icmp sgt i64 %0, 0
  %8 = icmp sgt i64 %2, 0
  %or.cond = select i1 %7, i1 %8, i1 false
  br i1 %or.cond, label %.preheader2.lr.ph.split.us, label %._crit_edge

.preheader2.lr.ph.split.us:                       ; preds = %6
  %9 = icmp sgt i64 %1, 0
  br i1 %9, label %.preheader2.us.us, label %.preheader2.us.preheader

.preheader2.us.preheader:                         ; preds = %.preheader2.lr.ph.split.us
  %10 = mul i64 %2, %0
  %11 = shl i64 %10, 2
  tail call void @llvm.memset.p0.i64(ptr align 4 %5, i8 0, i64 %11, i1 false)
  br label %._crit_edge

.preheader2.us.us:                                ; preds = %.preheader2.lr.ph.split.us, %._crit_edge3.split.us.us.us
  %12 = phi i64 [ %32, %._crit_edge3.split.us.us.us ], [ 0, %.preheader2.lr.ph.split.us ]
  %13 = mul i64 %12, %1
  %14 = getelementptr [4 x i8], ptr %3, i64 %13
  %15 = mul i64 %12, %2
  %16 = getelementptr [4 x i8], ptr %5, i64 %15
  br label %.preheader.us.us.us

.preheader.us.us.us:                              ; preds = %._crit_edge.us.us.us, %.preheader2.us.us
  %17 = phi i64 [ 0, %.preheader2.us.us ], [ %30, %._crit_edge.us.us.us ]
  %invariant.gep.us.us.us = getelementptr [4 x i8], ptr %4, i64 %17
  br label %18

18:                                               ; preds = %18, %.preheader.us.us.us
  %19 = phi float [ 0.000000e+00, %.preheader.us.us.us ], [ %26, %18 ]
  %20 = phi i64 [ 0, %.preheader.us.us.us ], [ %27, %18 ]
  %21 = getelementptr [4 x i8], ptr %14, i64 %20
  %22 = load float, ptr %21, align 4
  %23 = mul i64 %20, %2
  %gep.us.us.us = getelementptr [4 x i8], ptr %invariant.gep.us.us.us, i64 %23
  %24 = load float, ptr %gep.us.us.us, align 4
  %25 = fmul float %22, %24
  %26 = fadd float %19, %25
  %27 = add nuw nsw i64 %20, 1
  %28 = icmp slt i64 %27, %1
  br i1 %28, label %18, label %._crit_edge.us.us.us

._crit_edge.us.us.us:                             ; preds = %18
  %29 = getelementptr [4 x i8], ptr %16, i64 %17
  store float %26, ptr %29, align 4
  %30 = add nuw nsw i64 %17, 1
  %31 = icmp slt i64 %30, %2
  br i1 %31, label %.preheader.us.us.us, label %._crit_edge3.split.us.us.us

._crit_edge3.split.us.us.us:                      ; preds = %._crit_edge.us.us.us
  %32 = add nuw nsw i64 %12, 1
  %33 = icmp slt i64 %32, %0
  br i1 %33, label %.preheader2.us.us, label %._crit_edge

._crit_edge:                                      ; preds = %._crit_edge3.split.us.us.us, %.preheader2.us.preheader, %6
  ret ptr %5
}

; Function Attrs: nocallback nofree nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i64(ptr writeonly captures(none), i8, i64, i1 immarg) #1

attributes #0 = { nofree norecurse nosync nounwind memory(argmem: readwrite) }
attributes #1 = { nocallback nofree nounwind willreturn memory(argmem: write) }

!llvm.module.flags = !{!0}

!0 = !{i32 2, !"Debug Info Version", i32 3}
