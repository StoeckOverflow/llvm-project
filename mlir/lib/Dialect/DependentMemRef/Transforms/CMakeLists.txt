add_mlir_dialect_library(MLIRDependentMemRefTransforms
  DependentTensorToDependentMemRef.cpp
  DependentMemRefToLLVM.cpp

  ADDITIONAL_HEADER_DIRS
  ${MLIR_MAIN_INCLUDE_DIR}/mlir/Dialect/DependentMemRef/Transforms

  DEPENDS
  MLIRDependentMemRefTransformsIncGen

  LINK_LIBS PUBLIC
  MLIRArithToLLVM
  MLIRControlFlowToLLVM
  MLIRDependentMemRefDialect
  MLIRDependentTensorDialect
  MLIRFuncToLLVM
  MLIRIR
  MLIRIndexToLLVM
  MLIRLLVMDialect
  MLIRPass
  MLIRSCFToControlFlow
  MLIRTransforms
)
