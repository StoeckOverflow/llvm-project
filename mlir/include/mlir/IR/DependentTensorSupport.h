#ifndef MLIR_IR_DEPENDENTTENSORSUPPORT_H
#define MLIR_IR_DEPENDENTTENSORSUPPORT_H

#include "mlir/IR/DependentTensorInterfaces.h"
#include "mlir/IR/BuiltinTypes.h"
#include "mlir/IR/Diagnostics.h"
#include "mlir/IR/IRMapping.h"
#include "mlir/IR/OpImplementation.h"
#include "mlir/IR/Value.h"

namespace mlir {
class Operation;

/// Dependent tensor properties may contain SSA `Value` references. These
/// references are semantic SSA edges, but they are not MLIR operands and are
/// not visible through `Value::getUses()`.
///
/// Code that needs to inspect, update, remap, verify, or query these
/// second-class uses must go through the helpers in this file. Operations that
/// store such references expose their mutable slots with
/// `DependentTensorPropertyOpInterface::walkDependentTensorPropertyValues`.
void walkDependentTensorPropertyValues(
    Operation *op, function_ref<void(Value &)> callback);
void remapDependentTensorPropertyValues(Operation *op, IRMapping &mapping);
void replaceDependentTensorPropertyValue(Operation *root, Value from, Value to);
void replaceDependentTensorPropertyValueIf(
    Operation *root, Value from, Value to,
    function_ref<bool(Operation *)> shouldReplaceOwner);
bool hasDependentTensorPropertyUses(Value value, Operation *root);
bool dependentTensorUseEmpty(Value value, Operation *root);
SmallVector<Operation *> getDependentTensorPropertyUsers(Value value,
                                                         Operation *root);
bool hasDependentTensorResultUses(Operation *op, Operation *root);
LogicalResult verifyNoDependentTensorPropertyUses(Value value, Operation *root,
                                                  Location loc);
void replaceUsesOfWithIncludingDependentTensorProperties(Operation *op,
                                                         Value from, Value to);

namespace dependent_tensor {
ParseResult
parseTensorSpec(OpAsmParser &parser,
                SmallVectorImpl<OpAsmParser::UnresolvedOperand> &dims,
                Type &elementType);
ParseResult
parseTensorSpec(OpAsmParser &parser, RankedTensorType valueType,
                SmallVectorImpl<OpAsmParser::UnresolvedOperand> &dims);
void printTensorSpec(OpAsmPrinter &printer, ValueRange dims, Type elementType);
} // namespace dependent_tensor

} // namespace mlir

#endif // MLIR_IR_DEPENDENTTENSORSUPPORT_H
