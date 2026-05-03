//===- Passes.h - DependentTensor pass entrypoints -------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef MLIR_DIALECT_DEPENDENTTENSOR_TRANSFORMS_PASSES_H
#define MLIR_DIALECT_DEPENDENTTENSOR_TRANSFORMS_PASSES_H

#include "mlir/Pass/Pass.h"

namespace mlir {
namespace func {
class FuncOp;
} // namespace func
namespace dependent_tensor {

#define GEN_PASS_DECL
#include "mlir/Dialect/DependentTensor/Transforms/Passes.h.inc"

#define GEN_PASS_REGISTRATION
#include "mlir/Dialect/DependentTensor/Transforms/Passes.h.inc"

} // namespace dependent_tensor
} // namespace mlir

#endif // MLIR_DIALECT_DEPENDENTTENSOR_TRANSFORMS_PASSES_H
