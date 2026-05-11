# Exclude tests from libMLIR.so
add_mlir_library(MLIRDependentTensorTestPasses
  TestDependentTensorTransforms.cpp

  EXCLUDE_FROM_LIBMLIR
  )
mlir_target_link_libraries(MLIRDependentTensorTestPasses PUBLIC
  MLIRArithDialect
  MLIRDependentTensorDialect
  MLIRDependentTensorTransforms
  MLIRFuncDialect
  MLIRIR
  MLIRPass
  MLIRSCFDialect
  MLIRTransforms
  )
