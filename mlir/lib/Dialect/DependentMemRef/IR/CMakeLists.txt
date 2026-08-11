add_mlir_dialect_library(MLIRDependentMemRefDialect
  DependentMemRefDialect.cpp
  DependentMemRefOps.cpp

  ADDITIONAL_HEADER_DIRS
  ${MLIR_MAIN_INCLUDE_DIR}/mlir/Dialect/DependentMemRef/IR

  DEPENDS
  MLIRDependentMemRefOpsIncGen

  LINK_LIBS PUBLIC
  MLIRIR
  MLIRMemRefDialect
  MLIRSideEffectInterfaces
)
