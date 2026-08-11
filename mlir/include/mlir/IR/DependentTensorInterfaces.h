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
#include "llvm/ADT/ArrayRef.h"
#include "llvm/ADT/Hashing.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/ADT/SmallVector.h"
#include <cstdint>

namespace mlir {
inline bool areEqualDependentTensorDimValues(ArrayRef<PropertyOperand> lhs,
                                             ArrayRef<PropertyOperand> rhs) {
  if (lhs.size() != rhs.size())
    return false;
  for (auto [lhsOperand, rhsOperand] : llvm::zip_equal(lhs, rhs))
    if (lhsOperand.get() != rhsOperand.get())
      return false;
  return true;
}

struct DependentTensorTypeRef {
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

  bool operator==(const DependentTensorTypeRef &other) const {
    return rank == other.rank &&
           areEqualDependentTensorDimValues(dimValues, other.dimValues);
  }
};

struct DependentTensorValueRefinement {
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

  bool operator==(const DependentTensorValueRefinement &other) const {
    return valueIndex == other.valueIndex && rank == other.rank &&
           areEqualDependentTensorDimValues(dimValues, other.dimValues);
  }
};

struct DependentTensorLoopTypeRef {
  uint32_t valueIndex = 0;
  DependentTensorTypeRef operandTypeRef;
  DependentTensorTypeRef resultTypeRef;

  bool operator==(const DependentTensorLoopTypeRef &other) const {
    return valueIndex == other.valueIndex &&
           operandTypeRef == other.operandTypeRef &&
           resultTypeRef == other.resultTypeRef;
  }
};

struct DependentTensorLoopRegionTypeRef {
  uint32_t argumentIndex = 0;
  uint32_t yieldedIndex = 0;
  DependentTensorTypeRef argumentTypeRef;
  DependentTensorTypeRef yieldedTypeRef;

  bool operator==(const DependentTensorLoopRegionTypeRef &other) const {
    return argumentIndex == other.argumentIndex &&
           yieldedIndex == other.yieldedIndex &&
           argumentTypeRef == other.argumentTypeRef &&
           yieldedTypeRef == other.yieldedTypeRef;
  }
};

struct DependentTensorDimValueRefinement {
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

  bool operator==(const DependentTensorDimValueRefinement &other) const {
    return areEqualDependentTensorDimValues(dimValues, other.dimValues);
  }
};

struct DependentMemRefValueRefinement {
  uint32_t valueIndex = 0;
  int64_t rank = 0;
  int64_t offset = 0;
  bool hasExplicitLayout = false;
  SmallVector<PropertyOperand, 4> dimValues;
  SmallVector<PropertyOperand, 4> strideValues;

  SmallVector<Value, 4> getDimValues() const {
    SmallVector<Value, 4> values;
    values.reserve(dimValues.size());
    for (const PropertyOperand &operand : dimValues)
      values.push_back(operand.get());
    return values;
  }
  void assignDimValues(ValueRange values) {
    dimValues.clear();
    dimValues.reserve(values.size());
    for (Value value : values)
      dimValues.emplace_back(value);
  }

  SmallVector<Value, 4> getStrideValues() const {
    SmallVector<Value, 4> values;
    values.reserve(strideValues.size());
    for (const PropertyOperand &operand : strideValues)
      values.push_back(operand.get());
    return values;
  }
  void assignStrideValues(ValueRange values) {
    strideValues.clear();
    strideValues.reserve(values.size());
    for (Value value : values)
      strideValues.emplace_back(value);
  }

  bool operator==(const DependentMemRefValueRefinement &other) const {
    return valueIndex == other.valueIndex && rank == other.rank &&
           offset == other.offset &&
           hasExplicitLayout == other.hasExplicitLayout &&
           areEqualDependentTensorDimValues(dimValues, other.dimValues) &&
           areEqualDependentTensorDimValues(strideValues, other.strideValues);
  }
};

llvm::hash_code hash_value(const DependentTensorTypeRef &refinement);
llvm::hash_code hash_value(const DependentTensorValueRefinement &refinement);
llvm::hash_code hash_value(const DependentTensorLoopTypeRef &refinement);
llvm::hash_code hash_value(const DependentTensorLoopRegionTypeRef &refinement);
llvm::hash_code hash_value(const DependentTensorDimValueRefinement &refinement);
llvm::hash_code hash_value(const DependentMemRefValueRefinement &refinement);
} // namespace mlir

#include "mlir/IR/DependentTensorInterfaces.h.inc"

#endif // MLIR_IR_DEPENDENTTENSORINTERFACES_H_
