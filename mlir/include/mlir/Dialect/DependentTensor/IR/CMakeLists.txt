set(LLVM_TARGET_DEFINITIONS DependentTensorOps.td)
add_mlir_dialect(DependentTensorOps dependent_tensor)
add_mlir_doc(DependentTensorOps DependentTensorOps Dialects/ -gen-dialect-doc)
