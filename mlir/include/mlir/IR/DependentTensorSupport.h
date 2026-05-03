#ifndef MLIR_IR_DEPENDENTTENSORSUPPORT_H
#define MLIR_IR_DEPENDENTTENSORSUPPORT_H

#include "mlir/IR/BuiltinAttributes.h"
#include "mlir/IR/DependentTensorInterfaces.h"
#include "mlir/IR/Diagnostics.h"
#include "mlir/IR/IRMapping.h"
#include "mlir/IR/Types.h"
#include "mlir/IR/Value.h"
#include "llvm/ADT/ArrayRef.h"
#include "llvm/ADT/DenseMap.h"
#include "llvm/ADT/Hashing.h"
#include "llvm/ADT/SmallVector.h"
#include <cstdint>

namespace mlir {
class AsmState;
class Block;
class Operation;
class Region;
class TensorType;

enum class AnchorOwnerKind : uint8_t {
  ScopeOwner,
  ResultOwner,
};

struct AnchorKey {
  AnchorOwnerKind ownerKind = AnchorOwnerKind::ScopeOwner;
  DistinctAttr ownerTag;
  uint32_t slot = 0;
  uint32_t generation = 0;

  bool operator==(const AnchorKey &other) const {
    return ownerKind == other.ownerKind && ownerTag == other.ownerTag &&
           slot == other.slot && generation == other.generation;
  }
};

llvm::hash_code hash_value(const AnchorKey &key);

struct DependentDimExpr {
  enum class Kind : uint8_t {
    Constant,
    Anchor,
  };

  static DependentDimExpr getConstant(int64_t value) {
    DependentDimExpr expr;
    expr.kind = Kind::Constant;
    expr.constantValue = value;
    return expr;
  }
  static DependentDimExpr getAnchor(AnchorKey key) {
    DependentDimExpr expr;
    expr.kind = Kind::Anchor;
    expr.anchor = key;
    return expr;
  }

  Kind kind = Kind::Constant;
  int64_t constantValue = 0;
  AnchorKey anchor;

  bool isConstant() const { return kind == Kind::Constant; }
  bool isAnchor() const { return kind == Kind::Anchor; }

  bool operator==(const DependentDimExpr &other) const {
    if (kind != other.kind)
      return false;
    if (isConstant())
      return constantValue == other.constantValue;
    return anchor == other.anchor;
  }
};

llvm::hash_code hash_value(const DependentDimExpr &expr);

namespace detail {
enum class AnchorSubjectKind : uint8_t {
  ResultValue,
  BlockArgument,
};

struct AnchorSlotState {
  uint32_t slot = 0;
  uint32_t generation = 0;
  bool alive = false;
  AnchorSubjectKind subjectKind = AnchorSubjectKind::ResultValue;
  uint32_t valueIndex = 0;
  SmallVector<uint32_t, 8> path;
};

struct ProvisionalAnchorOwnerState {
  MLIRContext *context = nullptr;
  DistinctAttr ownerTag;
  uint32_t nextSlot = 0;
  SmallVector<AnchorSlotState, 4> slots;
};
} // namespace detail

class DependentTensorType;

enum class AnchorResolutionResult : uint8_t {
  Success,
  MissingOwner,
  MissingSlot,
  StaleGeneration,
  Dead,
  InvalidSlot,
};

bool isDependentTensorType(Type type);
DependentTensorType getDependentTensorType(Type type);

FailureOr<AnchorKey> createAnchorKeyForValue(Value value);
FailureOr<AnchorKey> createProvisionalDependentTensorBlockArgAnchor(
    Region *scopeOwnerBodyRegion, uint32_t argIndex);
AnchorResolutionResult resolveAnchorKey(
    AnchorKey key, Operation *useSite, Value &resolvedValue,
    detail::AnchorSlotState *resolvedState = nullptr,
    Operation **resolvedOwner = nullptr);
FailureOr<Value> resolveAnchorKey(AnchorKey key, Operation *useSite);
LogicalResult verifyDependentTypeAnchors(Type type, Operation *useSite,
                                         function_ref<InFlightDiagnostic()>
                                             emitError);
LogicalResult verifyDependentTypeAnchors(BlockArgument arg,
                                         function_ref<InFlightDiagnostic()>
                                             emitError);

Type remapDependentTensorType(Type type, IRMapping &mapping,
                              Operation *anchorSearchRoot);
Type replaceDependentAnchorInType(Type type, Value from, Value to,
                                  Operation *anchorSearchRoot);

void printDependentDimExpr(raw_ostream &os, DependentDimExpr expr,
                           AsmState &state, Operation *fallbackUseSite);
void printDependentDimExpr(raw_ostream &os, DependentDimExpr expr,
                           Operation *fallbackUseSite);

void registerProvisionalDependentTensorScopeOwner(
    Region *scopeOwnerBodyRegion, MLIRContext *context,
    detail::ProvisionalAnchorOwnerState &provisionalState);
void unregisterProvisionalDependentTensorScopeOwner(Region *scopeOwnerBodyRegion);
void registerProvisionalDependentTensorBlock(Region *scopeOwnerBodyRegion,
                                             Block *block,
                                             uint32_t blockIndex);
void unregisterProvisionalDependentTensorBlock(Block *block);
ArrayAttr serializeDependentTensorAnchorSlots(
    MLIRContext *context, ArrayRef<detail::AnchorSlotState> slots);

Operation *findDependentAnchorOwner(Operation *useSite, AnchorOwnerKind ownerKind,
                                    DistinctAttr ownerTag);
void registerDependentTypeUse(Value value);
void unregisterDependentTypeUse(Value value);
void registerDependentTypeUse(Type type, Operation *useSite);
void registerDependentTypeUse(BlockArgument arg);
void unregisterDependentTypeUse(Type type, Operation *useSite);
void unregisterDependentTypeUse(BlockArgument arg);
void remapDependentTypeUsesOnValueChange(Value from, Value to);
LogicalResult checkDependentAnchorValueCanMove(
    Value value, function_ref<InFlightDiagnostic()> emitError);
LogicalResult checkDependentAnchorValueCanErase(
    Value value, function_ref<InFlightDiagnostic()> emitError);
LogicalResult removeDependentAnchorForValue(Value value);
LogicalResult markDependentAnchorDead(Value value);
LogicalResult bumpDependentAnchorGeneration(Value value);
LogicalResult checkDependentAnchorOwnerCanErase(
    Operation *op, function_ref<InFlightDiagnostic()> emitError);
void resetDependentTensorOwnerProperties(Operation *op);

bool isDependentTensorScopeOwner(Operation *op);
bool isDependentTensorResultOwner(Operation *op);
DependentTensorScopeOwnerOpInterface getDependentTensorScopeOwner(Operation *op);
DependentTensorResultOwnerOpInterface
getDependentTensorResultOwner(Operation *op);

} // namespace mlir

#endif // MLIR_IR_DEPENDENTTENSORSUPPORT_H
