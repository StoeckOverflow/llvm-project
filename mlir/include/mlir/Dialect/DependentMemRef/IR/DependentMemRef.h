//===- DependentMemRef.h - DependentMemRef dialect --------------*- C++ -*-===//

#ifndef MLIR_DIALECT_DEPENDENTMEMREF_IR_DEPENDENTMEMREF_H
#define MLIR_DIALECT_DEPENDENTMEMREF_IR_DEPENDENTMEMREF_H

#include "mlir/Dialect/MemRef/IR/MemRef.h"
#include "mlir/IR/BuiltinTypes.h"
#include "mlir/IR/DependentTensorSupport.h"
#include "mlir/IR/Dialect.h"
#include "mlir/IR/OpImplementation.h"
#include "mlir/Interfaces/FunctionInterfaces.h"

namespace mlir {
namespace dependent_memref {

struct MemRefValueRefinement {
  MemRefType type;
  SmallVector<Value, 4> dimValues;
  int64_t offset = 0;
  SmallVector<Value, 4> strideValues;
  bool hasExplicitLayout = false;
};

DependentMemRefValueRefinement
buildStoredRefinement(unsigned valueIndex, MemRefType type,
                      ValueRange dimValues, int64_t offset = 0,
                      ValueRange strideValues = {});
FailureOr<MemRefValueRefinement>
decodeStoredRefinement(Value value,
                       const DependentMemRefValueRefinement &stored);
LogicalResult
verifyStoredRefinement(Operation *op, Value value,
                       const DependentMemRefValueRefinement &stored);
void printMemRefSpec(OpAsmPrinter &printer,
                     const DependentMemRefValueRefinement &refinement,
                     Type elementType);

} // namespace dependent_memref
} // namespace mlir

#include "mlir/Dialect/DependentMemRef/IR/DependentMemRefOpsDialect.h.inc"

#define GET_OP_CLASSES
#include "mlir/Dialect/DependentMemRef/IR/DependentMemRefOps.h.inc"

#endif // MLIR_DIALECT_DEPENDENTMEMREF_IR_DEPENDENTMEMREF_H
