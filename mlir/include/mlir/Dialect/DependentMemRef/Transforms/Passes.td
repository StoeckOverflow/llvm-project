//===- Passes.td - DependentMemRef pass definitions -----------*- tablegen -*-===//

#ifndef MLIR_DIALECT_DEPENDENTMEMREF_TRANSFORMS_PASSES_TD
#define MLIR_DIALECT_DEPENDENTMEMREF_TRANSFORMS_PASSES_TD

include "mlir/Pass/PassBase.td"

def ConvertDependentTensorToDependentMemRefPass
    : Pass<"convert-dependent-tensor-to-dependent-memref", "ModuleOp"> {
  let summary = "Lower the executable dependent_tensor subset to dependent_memref";
  let dependentDialects = ["::mlir::dependent_memref::DependentMemRefDialect",
                           "::mlir::func::FuncDialect",
                           "::mlir::memref::MemRefDialect",
                           "::mlir::scf::SCFDialect"];
}

#endif // MLIR_DIALECT_DEPENDENTMEMREF_TRANSFORMS_PASSES_TD
