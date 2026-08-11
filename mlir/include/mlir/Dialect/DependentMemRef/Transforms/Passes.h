//===- Passes.h - DependentMemRef pass entrypoints -------------*- C++ -*-===//

#ifndef MLIR_DIALECT_DEPENDENTMEMREF_TRANSFORMS_PASSES_H
#define MLIR_DIALECT_DEPENDENTMEMREF_TRANSFORMS_PASSES_H

#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Dialect/ControlFlow/IR/ControlFlowOps.h"
#include "mlir/Dialect/DependentMemRef/IR/DependentMemRef.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Dialect/LLVMIR/LLVMDialect.h"
#include "mlir/Dialect/MemRef/IR/MemRef.h"
#include "mlir/Dialect/SCF/IR/SCF.h"
#include "mlir/Pass/Pass.h"

namespace mlir {
namespace dependent_memref {
#define GEN_PASS_DECL
#include "mlir/Dialect/DependentMemRef/Transforms/Passes.h.inc"

#define GEN_PASS_REGISTRATION
#include "mlir/Dialect/DependentMemRef/Transforms/Passes.h.inc"
} // namespace dependent_memref
} // namespace mlir

#endif // MLIR_DIALECT_DEPENDENTMEMREF_TRANSFORMS_PASSES_H
