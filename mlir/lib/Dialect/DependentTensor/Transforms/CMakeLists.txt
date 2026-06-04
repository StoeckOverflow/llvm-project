add_mlir_dialect_library(MLIRDependentTensorTransforms
  DependentTensorPasses.cpp

  ADDITIONAL_HEADER_DIRS
  ${MLIR_MAIN_INCLUDE_DIR}/mlir/Dialect/DependentTensor/Transforms

  DEPENDS
  MLIRDependentTensorTransformsIncGen

  LINK_LIBS PUBLIC
  MLIRAffineDialect
  MLIRDependentTensorDialect
  MLIRFuncDialect
  MLIRFunctionInterfaces
  MLIRPass
  MLIRSCFDialect
  )
