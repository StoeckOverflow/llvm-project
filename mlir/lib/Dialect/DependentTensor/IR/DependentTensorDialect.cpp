//===- DependentTensorDialect.cpp - DependentTensor dialect ---------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/DependentTensor/IR/DependentTensor.h"

using namespace mlir;
using namespace mlir::dependent_tensor;

void DependentTensorDialect::initialize() {
  addOperations<
#define GET_OP_LIST
#include "mlir/Dialect/DependentTensor/IR/DependentTensorOps.cpp.inc"
      >();
}

#include "mlir/Dialect/DependentTensor/IR/DependentTensorOpsDialect.cpp.inc"
