#include "mlir/IR/DependentTensorSupport.h"
#include "mlir/IR/Operation.h"

using namespace mlir;

llvm::hash_code
mlir::hash_value(const DependentTensorValueSemantics &semantics) {
  return llvm::hash_combine(
      semantics.valueIndex, semantics.rank,
      llvm::hash_combine_range(semantics.dimNames.begin(),
                               semantics.dimNames.end()),
      llvm::hash_combine_range(semantics.dimValues.begin(),
                               semantics.dimValues.end()));
}

void mlir::walkDependentTensorPropertyValues(
    Operation *op, function_ref<void(Value &)> callback) {
  if (!op)
    return;
  auto iface = dyn_cast<DependentTensorPropertyOpInterface>(op);
  if (!iface)
    return;
  iface.walkDependentTensorPropertyValues(callback);
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
