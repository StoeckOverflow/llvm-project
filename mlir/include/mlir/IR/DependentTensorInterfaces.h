//===- DependentTensorInterfaces.h - Dependent tensor owner interfaces ----===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef MLIR_IR_DEPENDENTTENSORINTERFACES_H_
#define MLIR_IR_DEPENDENTTENSORINTERFACES_H_

#include "mlir/IR/BuiltinAttributes.h"
#include "mlir/IR/OpDefinition.h"
#include "mlir/IR/PropertySSAUseInterfaces.h"
#include "mlir/IR/Value.h"
#include "llvm/ADT/Hashing.h"
#include "llvm/ADT/SmallVector.h"
#include <cstdint>

namespace mlir {
struct DependentTensorValueSemantics {
  uint32_t valueIndex = 0;
  int64_t rank = 0;
  SmallVector<Value, 4> dimValues;

  bool operator==(const DependentTensorValueSemantics &other) const {
    return valueIndex == other.valueIndex && rank == other.rank &&
           dimValues == other.dimValues;
  }
};

llvm::hash_code hash_value(const DependentTensorValueSemantics &semantics);
} // namespace mlir

#include "mlir/IR/DependentTensorInterfaces.h.inc"

#endif // MLIR_IR_DEPENDENTTENSORINTERFACES_H_
