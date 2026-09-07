; ModuleID = 'mlir/examples/dependent-memref-conv2d/artifacts/archive/2026-09-07_14-39/dependent/dependent_conv2d_kernel.ll'
source_filename = "LLVMDialectModule"

; Function Attrs: nofree norecurse nosync nounwind memory(argmem: readwrite)
define ptr @dependent_conv2d_kernel(i64 %0, i64 %1, i64 %2, i64 %3, i64 %4, i64 %5, i64 %6, i64 %7, i64 %8, ptr readonly captures(none) %9, ptr readonly captures(none) %10, ptr returned writeonly captures(ret: address, provenance) %11) local_unnamed_addr #0 {
  %13 = icmp sgt i64 %0, 0
  br i1 %13, label %.preheader6.lr.ph, label %._crit_edge

.preheader6.lr.ph:                                ; preds = %12
  %14 = icmp slt i64 %4, 1
  %15 = icmp slt i64 %8, 1
  %16 = mul i64 %6, %5
  %17 = mul i64 %8, %16
  %18 = mul i64 %17, %7
  %factor.op.mul52 = mul i64 %1, %18
  %factor.op.mul39 = mul i64 %1, %16
  %19 = mul i64 %8, %7
  %factor.op.mul = mul i64 %4, %19
  %20 = icmp slt i64 %7, 1
  %or.cond.not97 = select i1 %14, i1 true, i1 %20
  %brmerge = select i1 %or.cond.not97, i1 true, i1 %15
  br i1 %brmerge, label %._crit_edge, label %.preheader6.lr.ph.split.us.split.us.split.us

.preheader6.lr.ph.split.us.split.us.split.us:     ; preds = %.preheader6.lr.ph
  %21 = icmp slt i64 %6, 1
  %22 = icmp slt i64 %5, 1
  %23 = icmp slt i64 %1, 1
  %brmerge92 = select i1 %23, i1 true, i1 %22
  %brmerge94 = select i1 %brmerge92, i1 true, i1 %21
  br i1 %brmerge94, label %._crit_edge.sink.split, label %.preheader6.us.us.us.us.us.us

.preheader6.us.us.us.us.us.us:                    ; preds = %.preheader6.lr.ph.split.us.split.us.split.us, %._crit_edge38.split.us.split.us.split.us.split.us.split.us.us.us.us.us.us.us
  %24 = phi i64 [ %69, %._crit_edge38.split.us.split.us.split.us.split.us.split.us.us.us.us.us.us.us ], [ 0, %.preheader6.lr.ph.split.us.split.us.split.us ]
  %factor.op.mul20.reass.us.us.us.us.us.us = mul i64 %factor.op.mul, %24
  %factor.op.mul.reass.us.us.us.us.us.us = mul i64 %factor.op.mul52, %24
  %25 = getelementptr [4 x i8], ptr %9, i64 %factor.op.mul.reass.us.us.us.us.us.us
  %26 = getelementptr [4 x i8], ptr %11, i64 %factor.op.mul20.reass.us.us.us.us.us.us
  br label %.preheader5.us.us.us.us.us.us.us.us.us.us.us

.preheader5.us.us.us.us.us.us.us.us.us.us.us:     ; preds = %._crit_edge.split.us.split.us.split.us.split.us.us.us.us.us.us.us.us.us.us.us.us, %.preheader6.us.us.us.us.us.us
  %27 = phi i64 [ 0, %.preheader6.us.us.us.us.us.us ], [ %67, %._crit_edge.split.us.split.us.split.us.split.us.us.us.us.us.us.us.us.us.us.us.us ]
  %factor.op.mul9.reass.us.us.us.us.us.us.us.us.us.us.us = mul i64 %factor.op.mul39, %27
  %28 = getelementptr [4 x i8], ptr %10, i64 %factor.op.mul9.reass.us.us.us.us.us.us.us.us.us.us.us
  %29 = mul i64 %27, %19
  %30 = getelementptr [4 x i8], ptr %26, i64 %29
  br label %.preheader4.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us

.preheader4.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us: ; preds = %._crit_edge22.split.us.split.us.split.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us, %.preheader5.us.us.us.us.us.us.us.us.us.us.us
  %31 = phi i64 [ 0, %.preheader5.us.us.us.us.us.us.us.us.us.us.us ], [ %65, %._crit_edge22.split.us.split.us.split.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us ]
  %32 = mul i64 %31, %17
  %invariant.gep.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us = getelementptr [4 x i8], ptr %25, i64 %32
  %33 = mul i64 %31, %8
  %34 = getelementptr [4 x i8], ptr %30, i64 %33
  br label %.preheader3.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us

.preheader3.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us: ; preds = %._crit_edge.split.us.split.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us, %.preheader4.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us
  %35 = phi i64 [ 0, %.preheader4.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us ], [ %63, %._crit_edge.split.us.split.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us ]
  %36 = mul i64 %35, %16
  %invariant.gep13.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us = getelementptr [4 x i8], ptr %invariant.gep.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us, i64 %36
  br label %.preheader2.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us

.preheader2.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us: ; preds = %._crit_edge11.split.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us, %.preheader3.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us
  %37 = phi float [ 0.000000e+00, %.preheader3.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us ], [ %55, %._crit_edge11.split.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us ]
  %38 = phi i64 [ 0, %.preheader3.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us ], [ %60, %._crit_edge11.split.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us ]
  %39 = mul i64 %38, %18
  %gep14.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us = getelementptr [4 x i8], ptr %invariant.gep13.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us, i64 %39
  %40 = mul i64 %38, %16
  %41 = getelementptr [4 x i8], ptr %28, i64 %40
  br label %.preheader.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us

.preheader.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us: ; preds = %._crit_edge.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us, %.preheader2.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us
  %42 = phi float [ %37, %.preheader2.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us ], [ %55, %._crit_edge.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us ]
  %43 = phi i64 [ 0, %.preheader2.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us ], [ %58, %._crit_edge.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us ]
  %44 = mul i64 %43, %6
  %45 = getelementptr [4 x i8], ptr %gep14.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us, i64 %44
  %46 = getelementptr [4 x i8], ptr %41, i64 %44
  br label %47

47:                                               ; preds = %47, %.preheader.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us
  %48 = phi float [ %42, %.preheader.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us ], [ %55, %47 ]
  %49 = phi i64 [ 0, %.preheader.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us ], [ %56, %47 ]
  %50 = getelementptr [4 x i8], ptr %45, i64 %49
  %51 = load float, ptr %50, align 4
  %52 = getelementptr [4 x i8], ptr %46, i64 %49
  %53 = load float, ptr %52, align 4
  %54 = fmul float %51, %53
  %55 = fadd float %48, %54
  %56 = add nuw nsw i64 %49, 1
  %57 = icmp slt i64 %56, %6
  br i1 %57, label %47, label %._crit_edge.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us

._crit_edge.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us: ; preds = %47
  %58 = add nuw nsw i64 %43, 1
  %59 = icmp slt i64 %58, %5
  br i1 %59, label %.preheader.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us, label %._crit_edge11.split.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us

._crit_edge11.split.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us: ; preds = %._crit_edge.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us
  %60 = add nuw nsw i64 %38, 1
  %61 = icmp slt i64 %60, %1
  br i1 %61, label %.preheader2.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us, label %._crit_edge.split.us.split.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us

._crit_edge.split.us.split.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us: ; preds = %._crit_edge11.split.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us
  %62 = getelementptr [4 x i8], ptr %34, i64 %35
  store float %55, ptr %62, align 4
  %63 = add nuw nsw i64 %35, 1
  %64 = icmp slt i64 %63, %8
  br i1 %64, label %.preheader3.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us, label %._crit_edge22.split.us.split.us.split.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us

._crit_edge22.split.us.split.us.split.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us: ; preds = %._crit_edge.split.us.split.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us
  %65 = add nuw nsw i64 %31, 1
  %66 = icmp slt i64 %65, %7
  br i1 %66, label %.preheader4.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us, label %._crit_edge.split.us.split.us.split.us.split.us.us.us.us.us.us.us.us.us.us.us.us

._crit_edge.split.us.split.us.split.us.split.us.us.us.us.us.us.us.us.us.us.us.us: ; preds = %._crit_edge22.split.us.split.us.split.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us.us
  %67 = add nuw nsw i64 %27, 1
  %68 = icmp slt i64 %67, %4
  br i1 %68, label %.preheader5.us.us.us.us.us.us.us.us.us.us.us, label %._crit_edge38.split.us.split.us.split.us.split.us.split.us.us.us.us.us.us.us

._crit_edge38.split.us.split.us.split.us.split.us.split.us.us.us.us.us.us.us: ; preds = %._crit_edge.split.us.split.us.split.us.split.us.us.us.us.us.us.us.us.us.us.us.us
  %69 = add nuw nsw i64 %24, 1
  %70 = icmp slt i64 %69, %0
  br i1 %70, label %.preheader6.us.us.us.us.us.us, label %._crit_edge

._crit_edge.sink.split:                           ; preds = %.preheader6.lr.ph.split.us.split.us.split.us
  %71 = mul i64 %factor.op.mul, %0
  %72 = shl i64 %71, 2
  tail call void @llvm.memset.p0.i64(ptr align 4 %11, i8 0, i64 %72, i1 false)
  br label %._crit_edge

._crit_edge:                                      ; preds = %._crit_edge38.split.us.split.us.split.us.split.us.split.us.us.us.us.us.us.us, %._crit_edge.sink.split, %.preheader6.lr.ph, %12
  ret ptr %11
}

; Function Attrs: nocallback nofree nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i64(ptr writeonly captures(none), i8, i64, i1 immarg) #1

attributes #0 = { nofree norecurse nosync nounwind memory(argmem: readwrite) }
attributes #1 = { nocallback nofree nounwind willreturn memory(argmem: write) }

!llvm.module.flags = !{!0}

!0 = !{i32 2, !"Debug Info Version", i32 3}
