#include "mlir/IR/PropertySSAUseSupport.h"

#include "mlir/IR/Dominance.h"
#include "mlir/IR/Operation.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/ADT/SmallPtrSet.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/raw_ostream.h"
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

void mlir::walkPropertyOperands(
    Operation *op, function_ref<void(PropertyOperand &)> callback) {
  if (!op)
    return;
  if (std::optional<RegisteredOperationName> registeredInfo =
          op->getName().getRegisteredInfo()) {
    // Property SSA refs live in concrete op properties, so only ops that
    // explicitly register the interface can expose embedded operands. Avoid
    // dialect fallback interfaces here: this helper is also used from teardown
    // assertions, where a dialect may be destroying cached unrelated IR.
    if (auto *iface = registeredInfo->getInterface<PropertySSAUseOpInterface>())
      iface->walkPropertySSAUses(iface, op, callback);
    return;
  }
  auto iface = dyn_cast<PropertySSAUseOpInterface>(op);
  if (!iface)
    return;
  iface.walkPropertySSAUses(callback);
}

void mlir::detachPropertyOperands(Operation *op) {
  if (!op)
    return;
  walkPropertyOperands(op, [](PropertyOperand &operand) {
    if (operand.getOwner())
      operand.detach();
  });
}

void mlir::attachPropertyOperands(Operation *op) {
  if (!op)
    return;
  walkPropertyOperands(op, [&](PropertyOperand &operand) {
    if (!operand.getOwner())
      operand.attach(op);
  });
}

void mlir::reattachPropertyOperands(Operation *op) {
  detachPropertyOperands(op);
  attachPropertyOperands(op);
}

void mlir::remapPropertySSAValues(Operation *op, IRMapping &mapping) {
  op->walkSSAUses([&](SSAUse use) {
    if (!use.isProperty())
      return;
    if (Value mapped = mapping.lookupOrNull(use.get()))
      use.set(mapped);
  });
}

void mlir::replacePropertySSAValue(Operation *root, Value from, Value to) {
  replacePropertySSAValueIf(root, from, to, [](Operation *) { return true; });
}

void mlir::replacePropertySSAValueIf(
    Operation *root, Value from, Value to,
    function_ref<bool(Operation *)> shouldReplaceOwner) {
  if (!from || !to)
    return;
  for (PropertyOperand &use :
       llvm::make_early_inc_range(from.getPropertyUses()))
    if (isInPropertySSAUseScope(root, use.getOwner()) &&
        shouldReplaceOwner(use.getOwner()))
      use.set(to);
}

bool mlir::hasPropertySSAUses(Value value, Operation *root) {
  if (!value)
    return false;
  if (!root)
    return !value.property_use_empty();
  return llvm::any_of(value.getPropertyUses(), [&](PropertyOperand &use) {
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

LogicalResult mlir::verifyPropertyOperandAttachment(Operation *op) {
  if (!op)
    return success();

  unsigned index = 0;
  LogicalResult result = success();
  walkPropertyOperands(op, [&](PropertyOperand &operand) {
    if (failed(result))
      return;
    if (operand.getOwner() != op) {
      result = op->emitOpError()
               << "has property operand with incorrect or missing owner";
      return;
    }
    Value value = operand.get();
    if (value &&
        !llvm::any_of(value.getPropertyUses(), [&](PropertyOperand &candidate) {
          return &candidate == &operand;
        })) {
      result = op->emitOpError()
               << "has stale property SSA use-list membership for property "
                  "operand #"
               << index;
      return;
    }
    ++index;
  });
  return result;
}

LogicalResult mlir::verifyNoPropertySSAUses(Value value, Operation *root,
                                            Location loc) {
  if (hasPropertySSAUses(value, root))
    return emitError(loc) << "value is referenced from property SSA uses";
  return success();
}

void mlir::reportFatalPropertySSAUseError(Value value, StringRef action) {
  std::string message;
  llvm::raw_string_ostream os(message);
  os << "cannot " << action << "; ";
  if (auto arg = dyn_cast<BlockArgument>(value)) {
    os << "block argument #" << arg.getArgNumber();
  } else if (Operation *defOp = value.getDefiningOp()) {
    os << "result of '" << defOp->getName() << "' op";
  } else {
    os << "value";
  }
  os << " has live property SSA use";
  for (PropertyOperand &use : value.getPropertyUses()) {
    os << " owned by '" << use.getOwner()->getName() << "' op";
    break;
  }
  os.flush();
  llvm::report_fatal_error(StringRef(message));
}

void mlir::replaceUsesOfWithIncludingPropertySSAUses(Operation *op, Value from,
                                                     Value to) {
  if (!op || from == to)
    return;
  op->replaceUsesOfWith(from, to);
  op->walkSSAUses([&](SSAUse use) {
    if (use.isProperty() && use.get() == from)
      use.set(to);
  });
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

LogicalResult mlir::verifySSAUseDominance(SSAUse use,
                                          DominanceInfo &dominance) {
  if (use.isProperty())
    return verifyPropertySSAUseDominance(use.getOwner(), use.get(), dominance);
  if (!dominance.properlyDominates(use.get(), use.getOwner()))
    return use.getOwner()->emitError("operand #")
           << use.getOperand().getOperandNumber()
           << " does not dominate this use";
  return success();
}

LogicalResult mlir::verifyPropertySSAUseDominance(Operation *owner,
                                                  DominanceInfo &dominance) {
  LogicalResult result = success();
  owner->walkSSAUses([&](SSAUse use) {
    if (failed(result))
      return;
    if (use.isProperty())
      result = verifySSAUseDominance(use, dominance);
  });
  return result;
}
