#include "mlir/IR/DependentTensorSupport.h"
#include "mlir/IR/Operation.h"
#include "llvm/ADT/STLExtras.h"

using namespace mlir;

llvm::hash_code
mlir::hash_value(const DependentTensorValueSemantics &semantics) {
  return llvm::hash_combine(
      semantics.valueIndex, semantics.rank,
      llvm::hash_combine_range(semantics.dimValues.begin(),
                               semantics.dimValues.end()));
}

void mlir::walkDependentTensorPropertyValues(
    Operation *op, function_ref<void(Value &)> callback) {
  if (!op)
    return;
  auto skipNullCallback = [&](Value &value) {
    if (value)
      callback(value);
  };
  if (std::optional<RegisteredOperationName> registeredInfo =
          op->getName().getRegisteredInfo()) {
    // Dependent tensor properties live in concrete op properties, so only ops
    // that explicitly register the interface can expose mutable Value slots.
    // Avoid consulting dialect fallback interfaces here: this helper is also
    // used from teardown assertions, where a dialect may be destroying cached
    // IR containing unrelated operations.
    if (auto *iface =
            registeredInfo->getInterface<DependentTensorPropertyOpInterface>())
      iface->walkDependentTensorPropertyValues(iface, op, skipNullCallback);
    return;
  }
  auto iface = dyn_cast<DependentTensorPropertyOpInterface>(op);
  if (!iface)
    return;
  iface.walkDependentTensorPropertyValues(skipNullCallback);
}

void mlir::remapDependentTensorPropertyValues(Operation *op,
                                              IRMapping &mapping) {
  walkDependentTensorPropertyValues(op, [&](Value &value) {
    if (Value mapped = mapping.lookupOrNull(value))
      value = mapped;
  });
}

void mlir::replaceDependentTensorPropertyValue(Operation *root, Value from,
                                               Value to) {
  replaceDependentTensorPropertyValueIf(root, from, to,
                                        [](Operation *) { return true; });
}

void mlir::replaceDependentTensorPropertyValueIf(
    Operation *root, Value from, Value to,
    function_ref<bool(Operation *)> shouldReplaceOwner) {
  if (!root || !from || !to)
    return;
  root->walk([&](Operation *op) {
    if (!shouldReplaceOwner(op))
      return;
    walkDependentTensorPropertyValues(op, [&](Value &value) {
      if (value == from)
        value = to;
    });
  });
}

ParseResult mlir::dependent_tensor::parseTensorSpec(
    OpAsmParser &parser, SmallVectorImpl<OpAsmParser::UnresolvedOperand> &dims,
    Type &elementType) {
  if (parser.parseHashKeyword("tensor") || parser.parseLess())
    return failure();
  if (parser.parseCommaSeparatedList(
          OpAsmParser::Delimiter::Square, [&]() -> ParseResult {
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
    OpAsmParser &parser, RankedTensorType valueType,
    SmallVectorImpl<OpAsmParser::UnresolvedOperand> &dims) {
  SMLoc specLoc = parser.getCurrentLocation();
  Type elementType;
  if (parseTensorSpec(parser, dims, elementType))
    return failure();
  if (static_cast<int64_t>(dims.size()) != valueType.getRank())
    return parser.emitError(specLoc, "dependent tensor rank mismatch");
  if (elementType != valueType.getElementType())
    return parser.emitError(specLoc,
                            "dependent tensor element type must match value type");
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
