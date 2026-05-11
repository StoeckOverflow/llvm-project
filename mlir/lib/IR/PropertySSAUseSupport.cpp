#include "mlir/IR/PropertySSAUseSupport.h"

#include "mlir/IR/Dominance.h"
#include "mlir/IR/Operation.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/ADT/SmallPtrSet.h"
#include <memory>

using namespace mlir;

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

static bool isInPropertySSAUseScope(Operation *root, Operation *owner) {
  return !root || (owner && root->isAncestor(owner));
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

void mlir::dropPropertySSAUses(Operation *op) {
  if (!op)
    return;
  for (std::unique_ptr<PropertySSAUse> &use : op->propertySSAUses)
    use->unlink();
  op->propertySSAUses.clear();
}

void mlir::registerPropertySSAUses(Operation *op) {
  if (!op)
    return;
  walkPropertySSAValues(op, [&](Value &value) {
    if (value)
      op->propertySSAUses.push_back(
          std::make_unique<PropertySSAUse>(op, &value));
  });
}

void mlir::refreshPropertySSAUses(Operation *op) {
  dropPropertySSAUses(op);
  registerPropertySSAUses(op);
}

void mlir::remapPropertySSAValues(Operation *op, IRMapping &mapping) {
  for (std::unique_ptr<PropertySSAUse> &use : op->propertySSAUses)
    if (Value mapped = mapping.lookupOrNull(use->get()))
      use->set(mapped);
}

void mlir::replacePropertySSAValue(Operation *root, Value from, Value to) {
  replacePropertySSAValueIf(root, from, to, [](Operation *) { return true; });
}

void mlir::replacePropertySSAValueIf(
    Operation *root, Value from, Value to,
    function_ref<bool(Operation *)> shouldReplaceOwner) {
  if (!from || !to)
    return;
  for (PropertySSAUse &use : llvm::make_early_inc_range(from.getPropertyUses()))
    if (isInPropertySSAUseScope(root, use.getOwner()) &&
        shouldReplaceOwner(use.getOwner()))
      use.set(to);
}

bool mlir::hasPropertySSAUses(Value value, Operation *root) {
  if (!value)
    return false;
  if (!root)
    return !value.property_use_empty();
  return llvm::any_of(value.getPropertyUses(), [&](PropertySSAUse &use) {
    return isInPropertySSAUseScope(root, use.getOwner());
  });
}

bool mlir::propertySSAUseEmpty(Value value, Operation *root) {
  return !hasPropertySSAUses(value, root);
}

SmallVector<Operation *> mlir::getPropertySSAUsers(Value value,
                                                   Operation *root) {
  SmallVector<Operation *> users;
  if (!value)
    return users;
  llvm::SmallPtrSet<Operation *, 8> seen;
  for (Operation *op : value.getPropertyUsers())
    if (isInPropertySSAUseScope(root, op) && seen.insert(op).second)
      users.push_back(op);
  return users;
}

bool mlir::hasPropertySSAResultUses(Operation *op, Operation *root) {
  if (!op)
    return false;
  if (!root)
    root = getPropertySSAUseSearchRoot(op);
  return llvm::any_of(op->getResults(), [&](Value result) {
    return hasPropertySSAUses(result, root);
  });
}

bool mlir::allUseEmpty(Value value, Operation *root) {
  if (!value)
    return true;
  return value.use_empty() && propertySSAUseEmpty(value, root);
}

SmallVector<Operation *> mlir::getAllUsers(Value value, Operation *root) {
  SmallVector<Operation *> users;
  if (!value)
    return users;
  llvm::SmallPtrSet<Operation *, 8> seen;
  for (Operation *user : value.getUsers())
    if (seen.insert(user).second)
      users.push_back(user);
  for (Operation *user : getPropertySSAUsers(value, root))
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
  for (std::unique_ptr<PropertySSAUse> &use : op->propertySSAUses)
    if (use->get() == from)
      use->set(to);
}

bool mlir::isOwnerSitePropertySSAUse(Operation *owner, Value value) {
  if (!owner || !value)
    return false;
  if (Operation *defOp = value.getDefiningOp())
    return !owner->isAncestor(defOp);
  auto blockArg = cast<BlockArgument>(value);
  Operation *argOwner =
      blockArg.getOwner() ? blockArg.getOwner()->getParentOp() : nullptr;
  return !argOwner || !owner->isAncestor(argOwner);
}

static Operation *getPropertySSAValueOwner(Value value) {
  if (Operation *defOp = value.getDefiningOp())
    return defOp;
  auto blockArg = cast<BlockArgument>(value);
  return blockArg.getOwner() ? blockArg.getOwner()->getParentOp() : nullptr;
}

bool mlir::crossesPropertySSAUseIsolatedFromAboveBoundary(Operation *owner,
                                                          Value value) {
  if (!owner || !value)
    return false;
  Operation *isolated =
      owner->hasTrait<OpTrait::IsIsolatedFromAbove>()
          ? owner
          : owner->getParentWithTrait<OpTrait::IsIsolatedFromAbove>();
  if (!isolated)
    return false;
  Operation *valueOwner = getPropertySSAValueOwner(value);
  return valueOwner && valueOwner != isolated &&
         !isolated->isAncestor(valueOwner);
}

LogicalResult mlir::verifyPropertySSAUseDominance(Operation *owner, Value value,
                                                  DominanceInfo &dominance) {
  if (!owner || !value || !isOwnerSitePropertySSAUse(owner, value))
    return success();
  if (crossesPropertySSAUseIsolatedFromAboveBoundary(owner, value))
    return owner->emitOpError() << "property SSA value illegally crosses an "
                                   "IsolatedFromAbove boundary";
  if (!dominance.properlyDominates(value, owner))
    return owner->emitOpError()
           << "property SSA value does not dominate this operation";
  return success();
}

LogicalResult mlir::verifyPropertySSAUseDominance(Operation *owner,
                                                  DominanceInfo &dominance) {
  LogicalResult result = success();
  walkPropertySSAValues(owner, [&](Value &value) {
    if (failed(result))
      return;
    result = verifyPropertySSAUseDominance(owner, value, dominance);
  });
  return result;
}
