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
  SmallVector<PropertyOperand, 4> dimValues;

  void appendDimValuesTo(SmallVectorImpl<Value> &values) const {
    for (const PropertyOperand &operand : dimValues)
      values.push_back(operand.get());
  }
  SmallVector<Value, 4> getDimValues() const {
    SmallVector<Value, 4> values;
    values.reserve(dimValues.size());
    appendDimValuesTo(values);
    return values;
  }
  void assignDimValues(ValueRange values) {
    dimValues.clear();
    dimValues.reserve(values.size());
    for (Value value : values)
      dimValues.emplace_back(value);
  }

  bool operator==(const DependentTensorValueSemantics &other) const {
    return valueIndex == other.valueIndex && rank == other.rank &&
           getDimValues() == other.getDimValues();
  }
};

struct DependentTensorDimValueSemantics {
  SmallVector<PropertyOperand, 1> dimValues;

  void appendDimValuesTo(SmallVectorImpl<Value> &values) const {
    for (const PropertyOperand &operand : dimValues)
      values.push_back(operand.get());
  }
  SmallVector<Value, 1> getDimValues() const {
    SmallVector<Value, 1> values;
    values.reserve(dimValues.size());
    appendDimValuesTo(values);
    return values;
  }
  void assignDimValues(ValueRange values) {
    dimValues.clear();
    dimValues.reserve(values.size());
    for (Value value : values)
      dimValues.emplace_back(value);
  }

  bool operator==(const DependentTensorDimValueSemantics &other) const {
    return getDimValues() == other.getDimValues();
  }
};

llvm::hash_code hash_value(const DependentTensorValueSemantics &semantics);
llvm::hash_code hash_value(const DependentTensorDimValueSemantics &semantics);
} // namespace mlir

#include "mlir/IR/DependentTensorInterfaces.h.inc"

#endif // MLIR_IR_DEPENDENTTENSORINTERFACES_H_
