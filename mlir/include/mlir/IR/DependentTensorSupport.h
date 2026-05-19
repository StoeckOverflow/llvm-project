#ifndef MLIR_IR_DEPENDENTTENSORSUPPORT_H
#define MLIR_IR_DEPENDENTTENSORSUPPORT_H

#include "mlir/IR/BuiltinTypes.h"
#include "mlir/IR/DependentTensorInterfaces.h"
#include "mlir/IR/Diagnostics.h"
#include "mlir/IR/IRMapping.h"
#include "mlir/IR/OpImplementation.h"
#include "mlir/IR/PropertySSAUseSupport.h"
#include "mlir/IR/Value.h"

namespace mlir {
class Operation;

/// Compatibility wrappers for the generic property SSA use layer. New generic
/// IR code should use PropertySSAUseSupport directly; dependent_tensor-specific
/// code may use these names when that reads more clearly.
void walkDependentTensorPropertyUses(
    Operation *op, function_ref<void(PropertyOperand &)> callback);
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
ParseResult
parseTensorSpecBody(OpAsmParser &parser,
                    SmallVectorImpl<OpAsmParser::UnresolvedOperand> &dims,
                    Type &elementType);
void printTensorSpec(OpAsmPrinter &printer, ValueRange dims, Type elementType);
} // namespace dependent_tensor

} // namespace mlir

#endif // MLIR_IR_DEPENDENTTENSORSUPPORT_H
