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
#include "mlir/IR/Dialect.h"
#include "mlir/IR/DependentTensorSupport.h"
#include "mlir/IR/OpImplementation.h"
#include "mlir/Interfaces/FunctionInterfaces.h"

namespace mlir {
namespace dependent_tensor {

struct TensorValueSemantics {
  RankedTensorType type;
  SmallVector<Value, 4> dimValues;
  SmallVector<std::string, 4> dimNames;
};

FailureOr<TensorValueSemantics> getValueSemantics(Value value);
FailureOr<bool> haveEqualSemantics(Value lhs, Value rhs);
bool haveEqualSemantics(const TensorValueSemantics &lhs,
                        const TensorValueSemantics &rhs);
FailureOr<bool> haveEqualDimSemantics(Value lhs, unsigned lhsDim, Value rhs,
                                      unsigned rhsDim);
DependentTensorValueSemantics
buildStoredSemantics(unsigned valueIndex, RankedTensorType type,
                     ArrayRef<Value> dimValues,
                     ArrayRef<std::string> dimNames = {});
FailureOr<TensorValueSemantics>
decodeStoredSemantics(Value value,
                      const DependentTensorValueSemantics &stored);

} // namespace dependent_tensor
} // namespace mlir

#include "mlir/Dialect/DependentTensor/IR/DependentTensorOpsDialect.h.inc"

#define GET_OP_CLASSES
#include "mlir/Dialect/DependentTensor/IR/DependentTensorOps.h.inc"

#endif // MLIR_DIALECT_DEPENDENTTENSOR_IR_DEPENDENTTENSOR_H
