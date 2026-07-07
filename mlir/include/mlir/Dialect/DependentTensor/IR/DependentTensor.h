//===- DependentTensor.h - DependentTensor dialect --------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef MLIR_DIALECT_DEPENDENTTENSOR_IR_DEPENDENTTENSOR_H
#define MLIR_DIALECT_DEPENDENTTENSOR_IR_DEPENDENTTENSOR_H

#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/IR/BuiltinAttributes.h"
#include "mlir/IR/BuiltinTypes.h"
#include "mlir/IR/DependentTensorSupport.h"
#include "mlir/IR/Dialect.h"
#include "mlir/IR/OpImplementation.h"
#include "mlir/Interfaces/FunctionInterfaces.h"

namespace mlir {
namespace dependent_tensor {

struct TensorValueRefinement {
  RankedTensorType type;
  SmallVector<Value, 4> dimValues;
};

FailureOr<TensorValueRefinement> getValueRefinement(Value value);
FailureOr<bool> haveEqualRefinements(Value lhs, Value rhs);
bool haveEqualRefinements(const TensorValueRefinement &lhs,
                          const TensorValueRefinement &rhs);
FailureOr<bool> haveEqualDimRefinements(Value lhs, unsigned lhsDim, Value rhs,
                                        unsigned rhsDim);
DependentTensorValueRefinement buildStoredRefinement(unsigned valueIndex,
                                                     RankedTensorType type,
                                                     ArrayRef<Value> dimValues);
FailureOr<TensorValueRefinement>
decodeStoredRefinement(Value value,
                       const DependentTensorValueRefinement &stored);
LogicalResult refreshDependentTensorForwardingRefinement(Operation *op);

} // namespace dependent_tensor
} // namespace mlir

#include "mlir/Dialect/DependentTensor/IR/DependentTensorOpsDialect.h.inc"

#define GET_OP_CLASSES
#include "mlir/Dialect/DependentTensor/IR/DependentTensorOps.h.inc"

#endif // MLIR_DIALECT_DEPENDENTTENSOR_IR_DEPENDENTTENSOR_H
