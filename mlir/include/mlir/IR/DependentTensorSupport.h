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

void walkDependentTensorPropertyValues(
    Operation *op, function_ref<void(Value &)> callback);
void remapDependentTensorPropertyValues(Operation *op, IRMapping &mapping);
void replaceDependentTensorPropertyValue(Operation *root, Value from, Value to);
void replaceDependentTensorPropertyValueIf(
    Operation *root, Value from, Value to,
    function_ref<bool(Operation *)> shouldReplaceOwner);

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
