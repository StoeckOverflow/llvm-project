//===- DependentMemRefDialect.cpp - DependentMemRef dialect ---------------===//

#include "mlir/Dialect/DependentMemRef/IR/DependentMemRef.h"

#include "mlir/Transforms/InliningUtils.h"

using namespace mlir;
using namespace mlir::dependent_memref;

namespace {
struct DependentInlinerInterface : DialectInlinerInterface {
  using DialectInlinerInterface::DialectInlinerInterface;
  bool isLegalToInline(Operation *, Region *, bool, IRMapping &) const final {
    return true;
  }
};
} // namespace

void DependentMemRefDialect::initialize() {
  addInterfaces<DependentInlinerInterface>();
  addOperations<
#define GET_OP_LIST
#include "mlir/Dialect/DependentMemRef/IR/DependentMemRefOps.cpp.inc"
      >();
}

#include "mlir/Dialect/DependentMemRef/IR/DependentMemRefOpsDialect.cpp.inc"
