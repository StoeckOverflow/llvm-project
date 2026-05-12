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
class DominanceInfo;
class Operation;

/// Properties may contain SSA `Value` references. These references are
/// second-class SSA edges: they are not MLIR operands and are not visible
/// through native `Value::getUses()`, `Value::getUsers()`, or `use_empty()`.
///
/// Operations that store such references expose their mutable slots with
/// `PropertySSAUseOpInterface::walkPropertySSAValues`.
void walkPropertySSAValues(Operation *op, function_ref<void(Value &)> callback);
void registerPropertySSAUses(Operation *op);
void refreshPropertySSAUses(Operation *op);
void dropPropertySSAUses(Operation *op);
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
void reportFatalPropertySSAUseError(Value value, StringRef action);

/// Return true when `value` models an ordinary property SSA use at `owner`'s
/// operation location. Some operation properties describe boundary metadata for
/// values defined in regions nested under the owner itself; those references
/// have dialect-specific semantics and are not ordinary owner-site uses.
bool isOwnerSitePropertySSAUse(Operation *owner, Value value);

/// Return true if `value` would be an illegal property capture by `owner`
/// across the nearest IsolatedFromAbove boundary containing `owner`.
bool crossesPropertySSAUseIsolatedFromAboveBoundary(Operation *owner,
                                                    Value value);

/// Verify generic SSA dominance/isolation for an owner-site property SSA use.
/// Dialects are still responsible for stronger semantic rules attached to
/// their property metadata.
LogicalResult verifyPropertySSAUseDominance(Operation *owner, Value value,
                                            DominanceInfo &dominance);
LogicalResult verifyPropertySSAUseDominance(Operation *owner,
                                            DominanceInfo &dominance);

// Future direction: if property SSA references become common beyond
// value-dependent type metadata, consider moving operation-owned
// PropertySSAUse nodes into trailing storage instead of the current op-local
// vector. Keep the list separate from native OpOperand uses unless MLIR
// intentionally grows an opt-in merged use iterator.

} // namespace mlir

#endif // MLIR_IR_PROPERTYSSAUSESUPPORT_H
