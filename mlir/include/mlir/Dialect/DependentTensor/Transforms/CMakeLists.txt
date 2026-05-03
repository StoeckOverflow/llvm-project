set(LLVM_TARGET_DEFINITIONS Passes.td)
mlir_tablegen(Passes.h.inc -gen-pass-decls -name DependentTensor)
add_mlir_dialect_tablegen_target(MLIRDependentTensorTransformsIncGen)

add_mlir_doc(Passes DependentTensorPasses ./ -gen-pass-doc)
