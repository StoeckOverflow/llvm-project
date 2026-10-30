//===- DependentTensorDialect.cpp - DependentTensor dialect ---------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/DependentTensor/IR/DependentTensor.h"

#include "mlir/Transforms/InliningUtils.h"

using namespace mlir;
using namespace mlir::dependent_tensor;

namespace {
struct DependentInlinerInterface : DialectInlinerInterface {
  using DialectInlinerInterface::DialectInlinerInterface;
  bool isLegalToInline(Operation *, Region *, bool, IRMapping &) const final {
    return true;
  }
};
} // namespace

void DependentTensorDialect::initialize() {
  addInterfaces<DependentInlinerInterface>();
  addOperations<
#define GET_OP_LIST
#include "mlir/Dialect/DependentTensor/IR/DependentTensorOps.cpp.inc"
      >();
}

#include "mlir/Dialect/DependentTensor/IR/DependentTensorOpsDialect.cpp.inc"
