#include "mlir/IR/PropertySSAUseSupport.h"

#include "mlir/IR/Operation.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/ADT/SmallPtrSet.h"

using namespace mlir;

static Operation *getPropertySSAUseSearchRoot(Value value) {
  Operation *op = value.getDefiningOp();
  if (!op) {
    auto arg = dyn_cast<BlockArgument>(value);
    op = arg && arg.getOwner() ? arg.getOwner()->getParentOp() : nullptr;
  }
  if (!op)
    return nullptr;
  if (!op->hasTrait<OpTrait::IsIsolatedFromAbove>()) {
    while (Operation *parent = op->getParentOp()) {
      op = parent;
      if (op->hasTrait<OpTrait::IsIsolatedFromAbove>())
        break;
    }
  }
  return op;
}

static Operation *getPropertySSAUseSearchRoot(Operation *op) {
  if (!op)
    return nullptr;
  while (!op->hasTrait<OpTrait::IsIsolatedFromAbove>()) {
    Operation *parent = op->getParentOp();
    if (!parent)
      break;
    op = parent;
  }
  return op;
}

void mlir::walkPropertySSAValues(Operation *op,
                                 function_ref<void(Value &)> callback) {
  if (!op)
    return;
  auto skipNullCallback = [&](Value &value) {
    if (value)
      callback(value);
  };
  if (std::optional<RegisteredOperationName> registeredInfo =
          op->getName().getRegisteredInfo()) {
    // Property SSA refs live in concrete op properties, so only ops that
    // explicitly register the interface can expose mutable Value slots. Avoid
    // dialect fallback interfaces here: this helper is also used from teardown
    // assertions, where a dialect may be destroying cached unrelated IR.
    if (auto *iface = registeredInfo->getInterface<PropertySSAUseOpInterface>())
      iface->walkPropertySSAValues(iface, op, skipNullCallback);
    return;
  }
  auto iface = dyn_cast<PropertySSAUseOpInterface>(op);
  if (!iface)
    return;
  iface.walkPropertySSAValues(skipNullCallback);
}

void mlir::remapPropertySSAValues(Operation *op, IRMapping &mapping) {
  walkPropertySSAValues(op, [&](Value &value) {
    if (Value mapped = mapping.lookupOrNull(value))
      value = mapped;
  });
}

void mlir::replacePropertySSAValue(Operation *root, Value from, Value to) {
  replacePropertySSAValueIf(root, from, to, [](Operation *) { return true; });
}

void mlir::replacePropertySSAValueIf(
    Operation *root, Value from, Value to,
    function_ref<bool(Operation *)> shouldReplaceOwner) {
  if (!root || !from || !to)
    return;
  root->walk([&](Operation *op) {
    if (!shouldReplaceOwner(op))
      return;
    walkPropertySSAValues(op, [&](Value &value) {
      if (value == from)
        value = to;
    });
  });
}

bool mlir::hasPropertySSAUses(Value value, Operation *root) {
  if (!value)
    return false;
  if (!root)
    root = getPropertySSAUseSearchRoot(value);
  if (!root)
    return false;
  bool found = false;
  root->walk([&](Operation *op) {
    walkPropertySSAValues(
        op, [&](Value &propertyValue) { found |= propertyValue == value; });
  });
  return found;
}

bool mlir::propertySSAUseEmpty(Value value, Operation *root) {
  return !hasPropertySSAUses(value, root);
}

SmallVector<Operation *> mlir::getPropertySSAUsers(Value value,
                                                   Operation *root) {
  SmallVector<Operation *> users;
  if (!value)
    return users;
  if (!root)
    root = getPropertySSAUseSearchRoot(value);
  if (!root)
    return users;
  llvm::SmallPtrSet<Operation *, 8> seen;
  root->walk([&](Operation *op) {
    walkPropertySSAValues(op, [&](Value &propertyValue) {
      if (propertyValue == value && seen.insert(op).second)
        users.push_back(op);
    });
  });
  return users;
}

bool mlir::hasPropertySSAResultUses(Operation *op, Operation *root) {
  if (!op)
    return false;
  if (!root)
    root = getPropertySSAUseSearchRoot(op);
  if (!root)
    return false;
  return llvm::any_of(op->getResults(), [&](Value result) {
    return hasPropertySSAUses(result, root);
  });
}

bool mlir::allUseEmpty(Value value, Operation *root) {
  if (!value)
    return true;
  if (!value.use_empty())
    return false;
  return propertySSAUseEmpty(value,
                             root ? root : getPropertySSAUseSearchRoot(value));
}

SmallVector<Operation *> mlir::getAllUsers(Value value, Operation *root) {
  SmallVector<Operation *> users;
  if (!value)
    return users;
  llvm::SmallPtrSet<Operation *, 8> seen;
  for (Operation *user : value.getUsers())
    if (seen.insert(user).second)
      users.push_back(user);
  for (Operation *user : getPropertySSAUsers(
           value, root ? root : getPropertySSAUseSearchRoot(value)))
    if (seen.insert(user).second)
      users.push_back(user);
  return users;
}

bool mlir::allResultsUseEmpty(Operation *op, Operation *root) {
  if (!op)
    return true;
  Operation *searchRoot = root ? root : getPropertySSAUseSearchRoot(op);
  return llvm::all_of(op->getResults(), [&](Value result) {
    return allUseEmpty(result, searchRoot);
  });
}

LogicalResult mlir::verifyNoPropertySSAUses(Value value, Operation *root,
                                            Location loc) {
  if (hasPropertySSAUses(value, root))
    return emitError(loc) << "value is referenced from property SSA uses";
  return success();
}

void mlir::replaceUsesOfWithIncludingPropertySSAUses(Operation *op, Value from,
                                                     Value to) {
  if (!op || from == to)
    return;
  op->replaceUsesOfWith(from, to);
  walkPropertySSAValues(op, [&](Value &propertyValue) {
    if (propertyValue == from)
      propertyValue = to;
  });
}
