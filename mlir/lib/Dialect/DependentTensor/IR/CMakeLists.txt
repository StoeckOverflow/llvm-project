add_mlir_dialect_library(MLIRDependentTensorDialect
  DependentTensorDialect.cpp
  DependentTensorOps.cpp

  ADDITIONAL_HEADER_DIRS
  ${MLIR_MAIN_INCLUDE_DIR}/mlir/Dialect/DependentTensor/IR

  DEPENDS
  MLIRDependentTensorOpsIncGen

  LINK_LIBS PUBLIC
  MLIRDialect
  MLIRFuncDialect
  MLIRFunctionInterfaces
  MLIRIR
  MLIRSideEffectInterfaces
  )
