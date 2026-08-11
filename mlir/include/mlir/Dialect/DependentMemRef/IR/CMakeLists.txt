set(LLVM_TARGET_DEFINITIONS DependentMemRefOps.td)
add_mlir_dialect(DependentMemRefOps dependent_memref)
add_mlir_doc(DependentMemRefOps DependentMemRefOps Dialects/ -gen-dialect-doc)
