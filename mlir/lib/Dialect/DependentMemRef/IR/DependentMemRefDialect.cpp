//===- DependentMemRefDialect.cpp - DependentMemRef dialect ---------------===//

#include "mlir/Dialect/DependentMemRef/IR/DependentMemRef.h"

using namespace mlir;
using namespace mlir::dependent_memref;

void DependentMemRefDialect::initialize() {
  addOperations<
#define GET_OP_LIST
#include "mlir/Dialect/DependentMemRef/IR/DependentMemRefOps.cpp.inc"
      >();
}

#include "mlir/Dialect/DependentMemRef/IR/DependentMemRefOpsDialect.cpp.inc"
