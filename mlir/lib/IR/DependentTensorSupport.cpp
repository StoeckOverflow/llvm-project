#include "mlir/IR/DependentTensorSupport.h"
#include "mlir/IR/Operation.h"
#include "llvm/ADT/STLExtras.h"

using namespace mlir;

llvm::hash_code
mlir::hash_value(const DependentTensorValueSemantics &semantics) {
  SmallVector<Value, 4> dimValues = semantics.getDimValues();
  return llvm::hash_combine(
      semantics.valueIndex, semantics.rank,
      llvm::hash_combine_range(dimValues.begin(), dimValues.end()));
}

llvm::hash_code
mlir::hash_value(const DependentTensorDimValueSemantics &semantics) {
  SmallVector<Value, 1> dimValues = semantics.getDimValues();
  return llvm::hash_combine_range(dimValues.begin(), dimValues.end());
}

void mlir::walkDependentTensorPropertyUses(
    Operation *op, function_ref<void(PropertyOperand &)> callback) {
  walkPropertyOperands(op, callback);
}

void mlir::remapDependentTensorPropertyValues(Operation *op,
                                              IRMapping &mapping) {
  remapPropertySSAValues(op, mapping);
}

void mlir::replaceDependentTensorPropertyValue(Operation *root, Value from,
                                               Value to) {
  replacePropertySSAValue(root, from, to);
}

void mlir::replaceDependentTensorPropertyValueIf(
    Operation *root, Value from, Value to,
    function_ref<bool(Operation *)> shouldReplaceOwner) {
  replacePropertySSAValueIf(root, from, to, shouldReplaceOwner);
}

bool mlir::hasDependentTensorPropertyUses(Value value, Operation *root) {
  return hasPropertySSAUses(value, root);
}

bool mlir::dependentTensorUseEmpty(Value value, Operation *root) {
  return propertySSAUseEmpty(value, root);
}

SmallVector<Operation *>
mlir::getDependentTensorPropertyUsers(Value value, Operation *root) {
  return getPropertySSAUsers(value, root);
}

bool mlir::hasDependentTensorResultUses(Operation *op, Operation *root) {
  return hasPropertySSAResultUses(op, root);
}

LogicalResult mlir::verifyNoDependentTensorPropertyUses(Value value,
                                                        Operation *root,
                                                        Location loc) {
  return verifyNoPropertySSAUses(value, root, loc);
}

void mlir::replaceUsesOfWithIncludingDependentTensorProperties(Operation *op,
                                                               Value from,
                                                               Value to) {
  replaceUsesOfWithIncludingPropertySSAUses(op, from, to);
}

ParseResult mlir::dependent_tensor::parseTensorSpecBody(
    OpAsmParser &parser, SmallVectorImpl<OpAsmParser::UnresolvedOperand> &dims,
    Type &elementType) {
  if (parser.parseLess())
    return failure();
  if (parser.parseCommaSeparatedList(OpAsmParser::Delimiter::Square,
                                     [&]() -> ParseResult {
                                       OpAsmParser::UnresolvedOperand dim;
                                       if (parser.parseOperand(dim))
                                         return failure();
                                       dims.push_back(dim);
                                       return success();
                                     }))
    return failure();
  if (parser.parseComma() || parser.parseType(elementType) ||
      parser.parseGreater())
    return failure();
  return success();
}

ParseResult mlir::dependent_tensor::parseTensorSpec(
    OpAsmParser &parser, SmallVectorImpl<OpAsmParser::UnresolvedOperand> &dims,
    Type &elementType) {
  if (parser.parseHashKeyword("tensor"))
    return failure();
  return parseTensorSpecBody(parser, dims, elementType);
}

ParseResult mlir::dependent_tensor::parseTensorSpec(
    OpAsmParser &parser, RankedTensorType valueType,
    SmallVectorImpl<OpAsmParser::UnresolvedOperand> &dims) {
  SMLoc specLoc = parser.getCurrentLocation();
  Type elementType;
  if (parseTensorSpec(parser, dims, elementType))
    return failure();
  if (static_cast<int64_t>(dims.size()) != valueType.getRank())
    return parser.emitError(specLoc, "dependent tensor rank mismatch");
  if (elementType != valueType.getElementType())
    return parser.emitError(
        specLoc, "dependent tensor element type must match value type");
  return success();
}

void mlir::dependent_tensor::printTensorSpec(OpAsmPrinter &printer,
                                             ValueRange dims,
                                             Type elementType) {
  printer << "#tensor<[";
  llvm::interleaveComma(dims, printer,
                        [&](Value value) { printer.printOperand(value); });
  printer << "], ";
  printer.printType(elementType);
  printer << ">";
}
