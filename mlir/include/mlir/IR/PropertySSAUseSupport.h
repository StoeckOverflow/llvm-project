//===- PropertySSAUseSupport.h - Property SSA reference helpers -*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef MLIR_IR_PROPERTYSSAUSESUPPORT_H
#define MLIR_IR_PROPERTYSSAUSESUPPORT_H

#include "mlir/IR/Diagnostics.h"
#include "mlir/IR/IRMapping.h"
#include "mlir/IR/PropertySSAUseInterfaces.h"
#include "mlir/IR/Value.h"

namespace mlir {
class Operation;

/// Properties may contain SSA `Value` references. These references are
/// second-class SSA edges: they are not MLIR operands and are not visible
/// through native `Value::getUses()`, `Value::getUsers()`, or `use_empty()`.
///
/// Operations that store such references expose their mutable slots with
/// `PropertySSAUseOpInterface::walkPropertySSAValues`.
void walkPropertySSAValues(Operation *op, function_ref<void(Value &)> callback);
void remapPropertySSAValues(Operation *op, IRMapping &mapping);
void replacePropertySSAValue(Operation *root, Value from, Value to);
void replacePropertySSAValueIf(
    Operation *root, Value from, Value to,
    function_ref<bool(Operation *)> shouldReplaceOwner);
bool hasPropertySSAUses(Value value, Operation *root = nullptr);
bool propertySSAUseEmpty(Value value, Operation *root = nullptr);
SmallVector<Operation *> getPropertySSAUsers(Value value,
                                             Operation *root = nullptr);
bool hasPropertySSAResultUses(Operation *op, Operation *root = nullptr);
bool allUseEmpty(Value value, Operation *root = nullptr);
SmallVector<Operation *> getAllUsers(Value value, Operation *root = nullptr);
bool allResultsUseEmpty(Operation *op, Operation *root = nullptr);
LogicalResult verifyNoPropertySSAUses(Value value, Operation *root,
                                      Location loc);
void replaceUsesOfWithIncludingPropertySSAUses(Operation *op, Value from,
                                               Value to);

// TODO: Replace the scan-based property-use queries with an intrusive
// PropertySSAUse list hanging off ValueImpl. That secondary list should remain
// distinct from the native OpOperand use-list, but make all-use queries cheap
// and improve release-mode erasure checks in generic transforms.

} // namespace mlir

#endif // MLIR_IR_PROPERTYSSAUSESUPPORT_H
