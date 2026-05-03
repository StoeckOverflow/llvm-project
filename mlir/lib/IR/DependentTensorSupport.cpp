#include "mlir/IR/DependentTensorSupport.h"
#include "mlir/IR/AsmState.h"
#include "mlir/IR/Builders.h"
#include "mlir/IR/BuiltinTypes.h"
#include "mlir/IR/Dominance.h"
#include "mlir/IR/OpDefinition.h"
#include "mlir/IR/Operation.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/ADT/SmallPtrSet.h"
#include "llvm/ADT/SmallVector.h"

using namespace mlir;

namespace {
struct AnchorSubjectDescriptor {
  detail::AnchorSubjectKind subjectKind = detail::AnchorSubjectKind::ResultValue;
  uint32_t valueIndex = 0;
  SmallVector<uint32_t, 8> path;

  bool operator==(const AnchorSubjectDescriptor &other) const {
    return subjectKind == other.subjectKind && valueIndex == other.valueIndex &&
           path == other.path;
  }
};

struct AnchorOwnerProperties {
  DistinctAttr ownerTag;
  uint32_t nextSlot = 0;
  SmallVector<detail::AnchorSlotState, 4> slots;
};

struct ProvisionalScopeOwnerRegistration {
  Region *bodyRegion = nullptr;
  detail::ProvisionalAnchorOwnerState *state = nullptr;
};

struct ProvisionalBlockRegistration {
  Region *bodyRegion = nullptr;
  Block *block = nullptr;
  uint32_t blockIndex = 0;
};

static constexpr StringLiteral kSlotField = "slot";
static constexpr StringLiteral kGenerationField = "generation";
static constexpr StringLiteral kAliveField = "alive";
static constexpr StringLiteral kSubjectKindField = "subject_kind";
static constexpr StringLiteral kValueIndexField = "value_index";
static constexpr StringLiteral kPathField = "path";
static constexpr StringLiteral kSubjectKindBlockArg = "block_argument";
static constexpr StringLiteral kSubjectKindResult = "result_value";

static thread_local SmallVector<ProvisionalScopeOwnerRegistration, 2>
    provisionalScopeOwnerRegistrations;
static thread_local SmallVector<ProvisionalBlockRegistration, 2>
    provisionalBlockRegistrations;
static thread_local SmallVector<
    std::pair<AnchorKey, SmallPtrSet<detail::ValueImpl *, 4>>, 8>
    dependentTypeUsesByKey;
static thread_local DenseMap<detail::ValueImpl *, SmallVector<AnchorKey, 2>>
    dependentTypeKeysByValue;

template <typename OwnerInterface>
static AnchorOwnerProperties loadOwnerProperties(OwnerInterface owner) {
  AnchorOwnerProperties properties;
  if (!owner)
    return properties;

  properties.ownerTag = owner.getDependentTensorOwnerTagValue();
  properties.nextSlot = owner.getDependentTensorNextSlotValue();

  ArrayAttr slotsAttr = owner.getDependentTensorAnchorSlotsValue();
  if (!slotsAttr)
    return properties;

  for (Attribute attr : slotsAttr) {
    auto dict = dyn_cast<DictionaryAttr>(attr);
    if (!dict)
      continue;

    detail::AnchorSlotState slot;
    if (auto slotAttr = dyn_cast_or_null<IntegerAttr>(dict.get(kSlotField)))
      slot.slot = slotAttr.getInt();
    if (auto generationAttr =
            dyn_cast_or_null<IntegerAttr>(dict.get(kGenerationField)))
      slot.generation = generationAttr.getInt();
    if (auto aliveAttr = dyn_cast_or_null<BoolAttr>(dict.get(kAliveField)))
      slot.alive = aliveAttr.getValue();
    if (auto valueIndexAttr =
            dyn_cast_or_null<IntegerAttr>(dict.get(kValueIndexField)))
      slot.valueIndex = valueIndexAttr.getInt();
    if (auto subjectKindAttr =
            dyn_cast_or_null<StringAttr>(dict.get(kSubjectKindField))) {
      slot.subjectKind =
          subjectKindAttr.getValue() == kSubjectKindBlockArg
              ? detail::AnchorSubjectKind::BlockArgument
              : detail::AnchorSubjectKind::ResultValue;
    }
    if (auto pathAttr = dyn_cast_or_null<DenseI32ArrayAttr>(dict.get(kPathField)))
      llvm::append_range(slot.path, pathAttr.asArrayRef());

    properties.slots.push_back(std::move(slot));
  }

  return properties;
}

template <typename OwnerInterface>
static void saveOwnerProperties(OwnerInterface owner,
                                const AnchorOwnerProperties &properties) {
  if (!owner)
    return;

  MLIRContext *context = owner->getContext();
  Builder builder(context);
  owner.setDependentTensorOwnerTagValue(properties.ownerTag);
  owner.setDependentTensorNextSlotValue(properties.nextSlot);

  SmallVector<Attribute> slots;
  slots.reserve(properties.slots.size());
  for (const detail::AnchorSlotState &slot : properties.slots) {
    SmallVector<NamedAttribute> fields;
    fields.emplace_back(builder.getStringAttr(kSlotField),
                        builder.getI32IntegerAttr(slot.slot));
    fields.emplace_back(builder.getStringAttr(kGenerationField),
                        builder.getI32IntegerAttr(slot.generation));
    fields.emplace_back(builder.getStringAttr(kAliveField),
                        builder.getBoolAttr(slot.alive));
    fields.emplace_back(builder.getStringAttr(kSubjectKindField),
                        builder.getStringAttr(
                            slot.subjectKind ==
                                    detail::AnchorSubjectKind::BlockArgument
                                ? kSubjectKindBlockArg
                                : kSubjectKindResult));
    fields.emplace_back(builder.getStringAttr(kValueIndexField),
                        builder.getI32IntegerAttr(slot.valueIndex));
    SmallVector<int32_t> path;
    path.reserve(slot.path.size());
    for (uint32_t index : slot.path)
      path.push_back(static_cast<int32_t>(index));
    fields.emplace_back(builder.getStringAttr(kPathField),
                        DenseI32ArrayAttr::get(context, path));
    slots.push_back(DictionaryAttr::get(context, fields));
  }
  owner.setDependentTensorAnchorSlotsValue(ArrayAttr::get(context, slots));
}

template <typename OwnerInterface>
static void clearOwnerProperties(OwnerInterface owner) {
  if (!owner)
    return;
  owner.setDependentTensorOwnerTagValue(DistinctAttr());
  owner.setDependentTensorAnchorSlotsValue(ArrayAttr());
  owner.setDependentTensorNextSlotValue(0);
}

static Operation *getTopLevelOwner(Operation *op) {
  if (!op)
    return nullptr;
  while (Operation *parent = op->getParentOp())
    op = parent;
  return op;
}

static uint32_t getRegionIndex(Region &region) {
  return region.getRegionNumber();
}

static uint32_t getBlockIndex(Block &block) { return block.computeBlockNumber(); }

static uint32_t getOperationIndex(Operation &op) {
  return std::distance(op.getBlock()->begin(), op.getIterator());
}

static std::optional<ProvisionalBlockRegistration>
getProvisionalBlockRegistration(Block *block) {
  for (const ProvisionalBlockRegistration &registration :
       llvm::reverse(provisionalBlockRegistrations))
    if (registration.block == block)
      return registration;
  return std::nullopt;
}

static AnchorOwnerProperties
loadOwnerProperties(detail::ProvisionalAnchorOwnerState &state) {
  AnchorOwnerProperties properties;
  properties.ownerTag = state.ownerTag;
  properties.nextSlot = state.nextSlot;
  properties.slots = llvm::to_vector(state.slots);
  return properties;
}

static void saveOwnerProperties(detail::ProvisionalAnchorOwnerState &state,
                                const AnchorOwnerProperties &properties) {
  state.ownerTag = properties.ownerTag;
  state.nextSlot = properties.nextSlot;
  state.slots = llvm::to_vector(properties.slots);
}

static LogicalResult computePathToOp(Operation *owner, Operation *target,
                                     SmallVectorImpl<uint32_t> &path) {
  if (!owner || !target)
    return failure();

  if (target->getParentOp() == owner) {
    Region *region = target->getBlock()->getParent();
    if (!region || region->getParentOp() != owner)
      return failure();
    path.push_back(getRegionIndex(*region));
    path.push_back(getBlockIndex(*target->getBlock()));
    path.push_back(getOperationIndex(*target));
    return success();
  }

  Operation *parentOp = target->getParentOp();
  if (!parentOp || failed(computePathToOp(owner, parentOp, path)))
    return failure();

  Region *region = target->getBlock()->getParent();
  if (!region || region->getParentOp() != parentOp)
    return failure();
  path.push_back(getRegionIndex(*region));
  path.push_back(getBlockIndex(*target->getBlock()));
  path.push_back(getOperationIndex(*target));
  return success();
}

static LogicalResult computePathToBlock(Operation *owner, Block *target,
                                        SmallVectorImpl<uint32_t> &path) {
  if (!owner || !target)
    return failure();

  Region *region = target->getParent();
  if (!region)
    return failure();
  if (region->getParentOp() == owner) {
    path.push_back(getRegionIndex(*region));
    path.push_back(getBlockIndex(*target));
    return success();
  }

  Operation *parentOp = region->getParentOp();
  if (!parentOp || failed(computePathToOp(owner, parentOp, path)))
    return failure();
  path.push_back(getRegionIndex(*region));
  path.push_back(getBlockIndex(*target));
  return success();
}

static LogicalResult computePathToOp(Region *ownerBodyRegion, Operation *target,
                                     SmallVectorImpl<uint32_t> &path) {
  if (!ownerBodyRegion || !target)
    return failure();

  Region *targetRegion = target->getBlock()->getParent();
  if (!targetRegion) {
    std::optional<ProvisionalBlockRegistration> registration =
        getProvisionalBlockRegistration(target->getBlock());
    if (!registration || registration->bodyRegion != ownerBodyRegion)
      return failure();
    path.push_back(0);
    path.push_back(registration->blockIndex);
    path.push_back(getOperationIndex(*target));
    return success();
  }
  if (!targetRegion)
    return failure();

  if (targetRegion == ownerBodyRegion) {
    path.push_back(0);
    path.push_back(getBlockIndex(*target->getBlock()));
    path.push_back(getOperationIndex(*target));
    return success();
  }

  Operation *parentOp = target->getParentOp();
  if (!parentOp || failed(computePathToOp(ownerBodyRegion, parentOp, path)))
    return failure();

  if (targetRegion->getParentOp() != parentOp)
    return failure();
  path.push_back(getRegionIndex(*targetRegion));
  path.push_back(getBlockIndex(*target->getBlock()));
  path.push_back(getOperationIndex(*target));
  return success();
}

static LogicalResult computePathToBlock(Region *ownerBodyRegion, Block *target,
                                        SmallVectorImpl<uint32_t> &path) {
  if (!ownerBodyRegion || !target)
    return failure();

  Region *region = target->getParent();
  if (!region) {
    std::optional<ProvisionalBlockRegistration> registration =
        getProvisionalBlockRegistration(target);
    if (!registration || registration->bodyRegion != ownerBodyRegion)
      return failure();
    path.push_back(0);
    path.push_back(registration->blockIndex);
    return success();
  }
  if (!region)
    return failure();
  if (region == ownerBodyRegion) {
    path.push_back(0);
    path.push_back(getBlockIndex(*target));
    return success();
  }

  Operation *parentOp = region->getParentOp();
  if (!parentOp || failed(computePathToOp(ownerBodyRegion, parentOp, path)))
    return failure();
  path.push_back(getRegionIndex(*region));
  path.push_back(getBlockIndex(*target));
  return success();
}

static FailureOr<AnchorSubjectDescriptor>
getScopeOwnedSubjectDescriptor(Operation *owner, Value value) {
  AnchorSubjectDescriptor descriptor;
  if (auto blockArg = dyn_cast<BlockArgument>(value)) {
    descriptor.subjectKind = detail::AnchorSubjectKind::BlockArgument;
    descriptor.valueIndex = blockArg.getArgNumber();
    if (failed(computePathToBlock(owner, blockArg.getOwner(), descriptor.path)))
      return failure();
    return descriptor;
  }

  auto result = cast<OpResult>(value);
  descriptor.subjectKind = detail::AnchorSubjectKind::ResultValue;
  descriptor.valueIndex = result.getResultNumber();
  if (failed(computePathToOp(owner, result.getOwner(), descriptor.path)))
    return failure();
  return descriptor;
}

static FailureOr<AnchorSubjectDescriptor>
getScopeOwnedSubjectDescriptor(Region *ownerBodyRegion, Value value) {
  AnchorSubjectDescriptor descriptor;
  if (auto blockArg = dyn_cast<BlockArgument>(value)) {
    descriptor.subjectKind = detail::AnchorSubjectKind::BlockArgument;
    descriptor.valueIndex = blockArg.getArgNumber();
    if (failed(
            computePathToBlock(ownerBodyRegion, blockArg.getOwner(), descriptor.path)))
      return failure();
    return descriptor;
  }

  auto result = cast<OpResult>(value);
  descriptor.subjectKind = detail::AnchorSubjectKind::ResultValue;
  descriptor.valueIndex = result.getResultNumber();
  if (failed(computePathToOp(ownerBodyRegion, result.getOwner(), descriptor.path)))
    return failure();
  return descriptor;
}

static AnchorSubjectDescriptor getResultOwnedSubjectDescriptor(OpResult result) {
  AnchorSubjectDescriptor descriptor;
  descriptor.subjectKind = detail::AnchorSubjectKind::ResultValue;
  descriptor.valueIndex = result.getResultNumber();
  return descriptor;
}

static bool matchesSubject(const detail::AnchorSlotState &slot,
                           const AnchorSubjectDescriptor &descriptor) {
  return slot.subjectKind == descriptor.subjectKind &&
         slot.valueIndex == descriptor.valueIndex &&
         slot.path == descriptor.path;
}

static detail::AnchorSlotState *
findSlotState(AnchorOwnerProperties &properties, uint32_t slot) {
  for (detail::AnchorSlotState &state : properties.slots)
    if (state.slot == slot)
      return &state;
  return nullptr;
}

static detail::AnchorSlotState *
findSlotState(AnchorOwnerProperties &properties,
              const AnchorSubjectDescriptor &descriptor) {
  for (detail::AnchorSlotState &state : properties.slots)
    if (matchesSubject(state, descriptor))
      return &state;
  return nullptr;
}

static FailureOr<Operation *> findNearestScopeOwner(Operation *start) {
  for (Operation *op = start; op; op = op->getParentOp())
    if (isa<DependentTensorScopeOwnerOpInterface>(op))
      return op;
  return failure();
}

static std::pair<Region *, detail::ProvisionalAnchorOwnerState *>
findProvisionalScopeOwnerState(Region *startRegion) {
  for (Region *region = startRegion; region;) {
    for (ProvisionalScopeOwnerRegistration &registration :
         provisionalScopeOwnerRegistrations)
      if (registration.bodyRegion == region)
        return {region, registration.state};

    Operation *parentOp = region->getParentOp();
    if (!parentOp || !parentOp->getBlock())
      break;
    region = parentOp->getBlock()->getParent();
  }
  return {nullptr, nullptr};
}

static std::pair<Region *, detail::ProvisionalAnchorOwnerState *>
findProvisionalScopeOwnerState(Value value) {
  if (auto blockArg = dyn_cast<BlockArgument>(value)) {
    Region *region = blockArg.getOwner()->getParent();
    if (!region) {
      std::optional<ProvisionalBlockRegistration> registration =
          getProvisionalBlockRegistration(blockArg.getOwner());
      region = registration ? registration->bodyRegion : nullptr;
    }
    return findProvisionalScopeOwnerState(region);
  }
  if (auto result = dyn_cast<OpResult>(value)) {
    Block *block = result.getOwner()->getBlock();
    Region *region = block ? block->getParent() : nullptr;
    if (!region) {
      std::optional<ProvisionalBlockRegistration> registration =
          getProvisionalBlockRegistration(block);
      region = registration ? registration->bodyRegion : nullptr;
    }
    return findProvisionalScopeOwnerState(region);
  }
  return {nullptr, nullptr};
}

static FailureOr<std::pair<AnchorOwnerKind, Operation *>>
getOwnerForValue(Value value) {
  if (auto blockArg = dyn_cast<BlockArgument>(value)) {
    Region *region = blockArg.getOwner()->getParent();
    if (!region)
      return failure();
    FailureOr<Operation *> owner = findNearestScopeOwner(region->getParentOp());
    if (failed(owner))
      return failure();
    return std::make_pair(AnchorOwnerKind::ScopeOwner, *owner);
  }

  auto result = cast<OpResult>(value);
  Operation *definingOp = result.getOwner();
  if (isa<DependentTensorResultOwnerOpInterface>(definingOp))
    return std::make_pair(AnchorOwnerKind::ResultOwner, definingOp);

  FailureOr<Operation *> owner = findNearestScopeOwner(definingOp);
  if (failed(owner))
    return failure();
  return std::make_pair(AnchorOwnerKind::ScopeOwner, *owner);
}

static FailureOr<AnchorSubjectDescriptor>
getSubjectDescriptor(AnchorOwnerKind ownerKind, Operation *owner, Value value) {
  if (ownerKind == AnchorOwnerKind::ResultOwner) {
    auto result = dyn_cast<OpResult>(value);
    if (!result || result.getOwner() != owner)
      return failure();
    return getResultOwnedSubjectDescriptor(result);
  }
  return getScopeOwnedSubjectDescriptor(owner, value);
}

template <typename OwnerInterface>
static DistinctAttr ensureOwnerTag(OwnerInterface owner,
                                   AnchorOwnerProperties &properties) {
  if (properties.ownerTag)
    return properties.ownerTag;
  properties.ownerTag = DistinctAttr::create(UnitAttr::get(owner->getContext()));
  return properties.ownerTag;
}

static FailureOr<Value> resolvePathValue(Operation *owner,
                                         const detail::AnchorSlotState &slot) {
  if (!owner)
    return failure();

  if (slot.subjectKind == detail::AnchorSubjectKind::ResultValue &&
      slot.path.empty()) {
    if (slot.valueIndex >= owner->getNumResults())
      return failure();
    return owner->getResult(slot.valueIndex);
  }

  Operation *currentOp = owner;
  size_t index = 0;
  while (index + 1 < slot.path.size()) {
    uint32_t regionIndex = slot.path[index++];
    if (regionIndex >= currentOp->getNumRegions())
      return failure();
    Region &region = currentOp->getRegion(regionIndex);
    uint32_t blockIndex = slot.path[index++];
    if (blockIndex >= region.getBlocks().size())
      return failure();
    Block *block = &*std::next(region.begin(), blockIndex);

    if (index == slot.path.size()) {
      if (slot.subjectKind != detail::AnchorSubjectKind::BlockArgument ||
          slot.valueIndex >= block->getNumArguments())
        return failure();
      return block->getArgument(slot.valueIndex);
    }

    uint32_t opIndex = slot.path[index++];
    if (opIndex >= block->getOperations().size())
      return failure();
    Operation *op = &*std::next(block->begin(), opIndex);

    if (index == slot.path.size()) {
      if (slot.subjectKind != detail::AnchorSubjectKind::ResultValue ||
          slot.valueIndex >= op->getNumResults())
        return failure();
      return op->getResult(slot.valueIndex);
    }

    currentOp = op;
  }

  return failure();
}

static SmallVector<AnchorKey, 2> collectAnchorKeys(Type type) {
  SmallVector<AnchorKey, 2> keys;
  auto tensorType = llvm::dyn_cast<DependentTensorType>(type);
  if (!tensorType)
    return keys;

  for (DependentDimExpr expr : tensorType.getDimensionExprs()) {
    if (!expr.isAnchor())
      continue;
    AnchorKey key = expr.anchor;
    if (llvm::find(keys, key) == keys.end())
      keys.push_back(key);
  }
  return keys;
}

static void registerDependentTypeUseImpl(Value value) {
  SmallVector<AnchorKey, 2> keys = collectAnchorKeys(value.getType());
  if (keys.empty())
    return;

  SmallVector<AnchorKey, 2> &existing = dependentTypeKeysByValue[value.getImpl()];
  if (!existing.empty())
    return;

  existing = keys;
  for (AnchorKey key : keys) {
    auto it =
        llvm::find_if(dependentTypeUsesByKey, [&](const auto &entry) {
          return entry.first == key;
        });
    if (it == dependentTypeUsesByKey.end()) {
      dependentTypeUsesByKey.push_back({key, {}});
      it = std::prev(dependentTypeUsesByKey.end());
    }
    it->second.insert(value.getImpl());
  }
}

static void unregisterDependentTypeUseImpl(Value value) {
  auto it = dependentTypeKeysByValue.find(value.getImpl());
  if (it == dependentTypeKeysByValue.end())
    return;

  for (AnchorKey key : it->second) {
    auto usesIt =
        llvm::find_if(dependentTypeUsesByKey, [&](const auto &entry) {
          return entry.first == key;
        });
    if (usesIt == dependentTypeUsesByKey.end())
      continue;
    usesIt->second.erase(value.getImpl());
    if (usesIt->second.empty())
      dependentTypeUsesByKey.erase(usesIt);
  }
  dependentTypeKeysByValue.erase(it);
}

static SmallVector<Value, 4> getRegisteredDependentTypeUses(AnchorKey key) {
  SmallVector<Value, 4> uses;
  auto it = llvm::find_if(dependentTypeUsesByKey, [&](const auto &entry) {
    return entry.first == key;
  });
  if (it == dependentTypeUsesByKey.end())
    return uses;

  uses.reserve(it->second.size());
  for (detail::ValueImpl *impl : it->second)
    uses.push_back(Value(impl));
  return uses;
}

static bool hasExternalRegisteredUseOfKey(
    AnchorKey key, function_ref<bool(Operation *)> skipOp,
    function_ref<bool(BlockArgument)> skipArg) {
  for (Value value : getRegisteredDependentTypeUses(key)) {
    if (auto blockArg = dyn_cast<BlockArgument>(value)) {
      if (!skipArg(blockArg))
        return true;
    } else {
      if (!skipOp(cast<OpResult>(value).getOwner()))
        return true;
    }

    for (OpOperand &use : value.getUses())
      if (!skipOp(use.getOwner()))
        return true;
  }
  return false;
}

static LogicalResult findLiveAnchorState(Value value, Operation *&owner,
                                         AnchorOwnerKind &ownerKind,
                                         detail::AnchorSlotState &slotState) {
  FailureOr<std::pair<AnchorOwnerKind, Operation *>> ownerInfo =
      getOwnerForValue(value);
  if (failed(ownerInfo))
    return failure();
  ownerKind = ownerInfo->first;
  owner = ownerInfo->second;

  FailureOr<AnchorSubjectDescriptor> descriptor =
      getSubjectDescriptor(ownerKind, owner, value);
  if (failed(descriptor))
    return failure();

  AnchorOwnerProperties properties =
      ownerKind == AnchorOwnerKind::ScopeOwner
          ? loadOwnerProperties(cast<DependentTensorScopeOwnerOpInterface>(owner))
          : loadOwnerProperties(
                cast<DependentTensorResultOwnerOpInterface>(owner));
  detail::AnchorSlotState *state = findSlotState(properties, *descriptor);
  if (!state)
    return failure();
  slotState = *state;
  return success();
}

static FailureOr<AnchorKey> getLiveAnchorKeyForValue(Value value) {
  Operation *owner = nullptr;
  AnchorOwnerKind ownerKind = AnchorOwnerKind::ScopeOwner;
  detail::AnchorSlotState slotState;
  if (failed(findLiveAnchorState(value, owner, ownerKind, slotState)))
    return failure();

  DistinctAttr ownerTag =
      ownerKind == AnchorOwnerKind::ScopeOwner
          ? cast<DependentTensorScopeOwnerOpInterface>(owner)
                .getDependentTensorOwnerTagValue()
          : cast<DependentTensorResultOwnerOpInterface>(owner)
                .getDependentTensorOwnerTagValue();
  if (!ownerTag)
    return failure();
  return AnchorKey{ownerKind, ownerTag, slotState.slot, slotState.generation};
}

enum class AnchorUseSiteResult : uint8_t {
  Success,
  InvalidValueOwner,
  IllegalRegion,
  NonDominating,
};

static AnchorUseSiteResult checkResolvedAnchorUseSite(Value value,
                                                      Operation *useSite) {
  if (!value)
    return AnchorUseSiteResult::InvalidValueOwner;

  Operation *valueOwner = value.getDefiningOp();
  if (!valueOwner) {
    auto arg = dyn_cast<BlockArgument>(value);
    Region *region = arg ? arg.getOwner()->getParent() : nullptr;
    valueOwner = region ? region->getParentOp() : nullptr;
  }
  if (!valueOwner)
    return AnchorUseSiteResult::InvalidValueOwner;

  for (Operation *scope = useSite; scope; scope = scope->getParentOp()) {
    if (scope == valueOwner)
      break;
    if (!scope->hasTrait<OpTrait::IsIsolatedFromAbove>())
      continue;

    if (Operation *definingOp = value.getDefiningOp()) {
      if (definingOp != scope && !scope->isProperAncestor(definingOp))
        return AnchorUseSiteResult::IllegalRegion;
      continue;
    }

    auto blockArg = cast<BlockArgument>(value);
    Operation *argOwner = blockArg.getOwner()->getParentOp();
    if (argOwner != scope && !scope->isProperAncestor(argOwner))
      return AnchorUseSiteResult::IllegalRegion;
  }

  DominanceInfo domInfo(useSite);
  if (!domInfo.properlyDominates(value, useSite))
    return AnchorUseSiteResult::NonDominating;
  return AnchorUseSiteResult::Success;
}

static bool isValidSlotForOwnerKind(AnchorOwnerKind ownerKind,
                                    const detail::AnchorSlotState &slot) {
  if (ownerKind == AnchorOwnerKind::ResultOwner)
    return slot.subjectKind == detail::AnchorSubjectKind::ResultValue &&
           slot.path.empty();
  return true;
}

static InFlightDiagnostic emitAnchorFailure(function_ref<InFlightDiagnostic()>
                                                emitError,
                                            StringRef message, AnchorKey key) {
  auto diag = emitError();
  diag << message << " {kind="
       << (key.ownerKind == AnchorOwnerKind::ScopeOwner ? "scope" : "result")
       << ", slot=" << key.slot << ", generation=" << key.generation << "}";
  return diag;
}

static LogicalResult verifyAnchorAtUseSite(
    AnchorKey key, Operation *useSite,
    function_ref<InFlightDiagnostic()> emitError) {
  Value value;
  switch (resolveAnchorKey(key, useSite, value)) {
  case AnchorResolutionResult::Success:
    break;
  case AnchorResolutionResult::MissingOwner:
    emitAnchorFailure(emitError, "missing dependent tensor anchor owner", key);
    return failure();
  case AnchorResolutionResult::MissingSlot:
    emitAnchorFailure(emitError, "missing dependent tensor anchor slot", key);
    return failure();
  case AnchorResolutionResult::StaleGeneration:
    emitAnchorFailure(emitError, "stale dependent tensor anchor generation",
                      key);
    return failure();
  case AnchorResolutionResult::Dead:
    emitAnchorFailure(emitError, "dead dependent tensor anchor", key);
    return failure();
  case AnchorResolutionResult::InvalidSlot:
    emitAnchorFailure(emitError,
                      "invalid dependent tensor anchor slot interpretation",
                      key);
    return failure();
  }

  switch (checkResolvedAnchorUseSite(value, useSite)) {
  case AnchorUseSiteResult::Success:
    return success();
  case AnchorUseSiteResult::InvalidValueOwner:
    emitAnchorFailure(emitError,
                      "dependent tensor anchor resolved without a visible owner",
                      key);
    return failure();
  case AnchorUseSiteResult::IllegalRegion:
    emitAnchorFailure(
        emitError,
        "dependent tensor anchor crosses an isolated-from-above boundary", key);
    return failure();
  case AnchorUseSiteResult::NonDominating:
    emitAnchorFailure(
        emitError,
        "dependent tensor anchor does not dominate dependent type use", key);
    return failure();
  }

  return success();
}

static void printFallbackAnchor(raw_ostream &os, AnchorKey key) {
  os << "anchor<"
     << (key.ownerKind == AnchorOwnerKind::ScopeOwner ? "scope" : "result")
     << ", " << key.ownerTag << ", " << key.slot << ", " << key.generation
     << ">";
}
} // namespace

llvm::hash_code mlir::hash_value(const AnchorKey &key) {
  return llvm::hash_combine(static_cast<unsigned>(key.ownerKind), key.ownerTag,
                            key.slot, key.generation);
}

llvm::hash_code mlir::hash_value(const DependentDimExpr &expr) {
  if (expr.isConstant())
    return llvm::hash_combine(static_cast<unsigned>(expr.kind),
                              expr.constantValue);
  return llvm::hash_combine(static_cast<unsigned>(expr.kind), expr.anchor);
}

bool mlir::isDependentTensorType(Type type) {
  return llvm::isa<DependentTensorType>(type);
}

DependentTensorType mlir::getDependentTensorType(Type type) {
  return llvm::dyn_cast<DependentTensorType>(type);
}

bool mlir::isDependentTensorScopeOwner(Operation *op) {
  return op && isa<DependentTensorScopeOwnerOpInterface>(op);
}

bool mlir::isDependentTensorResultOwner(Operation *op) {
  return op && isa<DependentTensorResultOwnerOpInterface>(op);
}

void mlir::resetDependentTensorOwnerProperties(Operation *op) {
  if (auto scopeOwner = dyn_cast_or_null<DependentTensorScopeOwnerOpInterface>(op))
    clearOwnerProperties(scopeOwner);
  if (auto resultOwner =
          dyn_cast_or_null<DependentTensorResultOwnerOpInterface>(op))
    clearOwnerProperties(resultOwner);
}

DependentTensorScopeOwnerOpInterface
mlir::getDependentTensorScopeOwner(Operation *op) {
  return dyn_cast_or_null<DependentTensorScopeOwnerOpInterface>(op);
}

DependentTensorResultOwnerOpInterface
mlir::getDependentTensorResultOwner(Operation *op) {
  return dyn_cast_or_null<DependentTensorResultOwnerOpInterface>(op);
}

FailureOr<AnchorKey> mlir::createAnchorKeyForValue(Value value) {
  FailureOr<std::pair<AnchorOwnerKind, Operation *>> ownerInfo =
      getOwnerForValue(value);
  if (failed(ownerInfo)) {
    auto [ownerBodyRegion, provisionalState] =
        findProvisionalScopeOwnerState(value);
    if (!provisionalState)
      return failure();

    FailureOr<AnchorSubjectDescriptor> descriptor =
        getScopeOwnedSubjectDescriptor(ownerBodyRegion, value);
    if (failed(descriptor))
      return failure();

    AnchorOwnerProperties properties = loadOwnerProperties(*provisionalState);
    if (!properties.ownerTag)
      properties.ownerTag =
          DistinctAttr::create(UnitAttr::get(value.getContext()));

    detail::AnchorSlotState *state = findSlotState(properties, *descriptor);
    if (!state) {
      detail::AnchorSlotState newState;
      newState.slot = properties.nextSlot++;
      newState.generation = 1;
      newState.alive = true;
      newState.subjectKind = descriptor->subjectKind;
      newState.valueIndex = descriptor->valueIndex;
      newState.path = descriptor->path;
      properties.slots.push_back(newState);
      state = &properties.slots.back();
    }
    saveOwnerProperties(*provisionalState, properties);
    return AnchorKey{AnchorOwnerKind::ScopeOwner, properties.ownerTag,
                     state->slot, state->generation};
  }

  AnchorOwnerKind ownerKind = ownerInfo->first;
  Operation *owner = ownerInfo->second;
  FailureOr<AnchorSubjectDescriptor> descriptor =
      getSubjectDescriptor(ownerKind, owner, value);
  if (failed(descriptor))
    return failure();

  if (ownerKind == AnchorOwnerKind::ScopeOwner) {
    auto ownerInterface = cast<DependentTensorScopeOwnerOpInterface>(owner);
    AnchorOwnerProperties properties = loadOwnerProperties(ownerInterface);
    DistinctAttr ownerTag = ensureOwnerTag(ownerInterface, properties);

    detail::AnchorSlotState *state = findSlotState(properties, *descriptor);
    if (!state) {
      detail::AnchorSlotState newState;
      newState.slot = properties.nextSlot++;
      newState.generation = 1;
      newState.alive = true;
      newState.subjectKind = descriptor->subjectKind;
      newState.valueIndex = descriptor->valueIndex;
      newState.path = descriptor->path;
      properties.slots.push_back(newState);
      state = &properties.slots.back();
    }
    saveOwnerProperties(ownerInterface, properties);
    return AnchorKey{ownerKind, ownerTag, state->slot, state->generation};
  }

  auto ownerInterface = cast<DependentTensorResultOwnerOpInterface>(owner);
  AnchorOwnerProperties properties = loadOwnerProperties(ownerInterface);
  DistinctAttr ownerTag = ensureOwnerTag(ownerInterface, properties);

  detail::AnchorSlotState *state = findSlotState(properties, *descriptor);
  if (!state) {
    detail::AnchorSlotState newState;
    newState.slot = properties.nextSlot++;
    newState.generation = 1;
    newState.alive = true;
    newState.subjectKind = descriptor->subjectKind;
    newState.valueIndex = descriptor->valueIndex;
    newState.path = descriptor->path;
    properties.slots.push_back(newState);
    state = &properties.slots.back();
  }
  saveOwnerProperties(ownerInterface, properties);
  return AnchorKey{ownerKind, ownerTag, state->slot, state->generation};
}

FailureOr<AnchorKey> mlir::createProvisionalDependentTensorBlockArgAnchor(
    Region *scopeOwnerBodyRegion, uint32_t argIndex) {
  auto [registeredRegion, provisionalState] =
      findProvisionalScopeOwnerState(scopeOwnerBodyRegion);
  if (!provisionalState)
    return failure();

  AnchorSubjectDescriptor descriptor;
  descriptor.subjectKind = detail::AnchorSubjectKind::BlockArgument;
  descriptor.valueIndex = argIndex;
  descriptor.path.push_back(0);
  descriptor.path.push_back(0);

  AnchorOwnerProperties properties = loadOwnerProperties(*provisionalState);
  if (!properties.ownerTag)
    properties.ownerTag = DistinctAttr::create(
        UnitAttr::get(provisionalState->context));

  detail::AnchorSlotState *state = findSlotState(properties, descriptor);
  if (!state) {
    detail::AnchorSlotState newState;
    newState.slot = properties.nextSlot++;
    newState.generation = 1;
    newState.alive = true;
    newState.subjectKind = descriptor.subjectKind;
    newState.valueIndex = descriptor.valueIndex;
    newState.path = descriptor.path;
    properties.slots.push_back(newState);
    state = &properties.slots.back();
  }

  saveOwnerProperties(*provisionalState, properties);
  return AnchorKey{AnchorOwnerKind::ScopeOwner, properties.ownerTag,
                   state->slot, state->generation};
}

Operation *mlir::findDependentAnchorOwner(Operation *useSite,
                                          AnchorOwnerKind ownerKind,
                                          DistinctAttr ownerTag) {
  if (!useSite || !ownerTag)
    return nullptr;

  Operation *root = getTopLevelOwner(useSite);
  Operation *found = nullptr;
  root->walk([&](Operation *nested) {
    if (ownerKind == AnchorOwnerKind::ScopeOwner) {
      auto owner = dyn_cast<DependentTensorScopeOwnerOpInterface>(nested);
      if (owner && owner.getDependentTensorOwnerTagValue() == ownerTag) {
        found = nested;
        return WalkResult::interrupt();
      }
      return WalkResult::advance();
    }

    auto owner = dyn_cast<DependentTensorResultOwnerOpInterface>(nested);
    if (owner && owner.getDependentTensorOwnerTagValue() == ownerTag) {
      found = nested;
      return WalkResult::interrupt();
    }
    return WalkResult::advance();
  });
  return found;
}

FailureOr<Value> mlir::resolveAnchorKey(AnchorKey key, Operation *useSite) {
  Value resolvedValue;
  if (resolveAnchorKey(key, useSite, resolvedValue) !=
      AnchorResolutionResult::Success)
    return failure();
  return resolvedValue;
}

AnchorResolutionResult mlir::resolveAnchorKey(
    AnchorKey key, Operation *useSite, Value &resolvedValue,
    detail::AnchorSlotState *resolvedState, Operation **resolvedOwner) {
  resolvedValue = Value();
  Operation *owner = findDependentAnchorOwner(useSite, key.ownerKind, key.ownerTag);
  if (!owner)
    return AnchorResolutionResult::MissingOwner;
  if (resolvedOwner)
    *resolvedOwner = owner;

  AnchorOwnerProperties properties =
      key.ownerKind == AnchorOwnerKind::ScopeOwner
          ? loadOwnerProperties(cast<DependentTensorScopeOwnerOpInterface>(owner))
          : loadOwnerProperties(
                cast<DependentTensorResultOwnerOpInterface>(owner));
  const detail::AnchorSlotState *state = findSlotState(properties, key.slot);
  if (!state)
    return AnchorResolutionResult::MissingSlot;
  if (resolvedState)
    *resolvedState = *state;
  if (state->generation != key.generation)
    return AnchorResolutionResult::StaleGeneration;
  if (!state->alive)
    return AnchorResolutionResult::Dead;
  if (!isValidSlotForOwnerKind(key.ownerKind, *state))
    return AnchorResolutionResult::InvalidSlot;

  FailureOr<Value> value = resolvePathValue(owner, *state);
  if (failed(value))
    return AnchorResolutionResult::InvalidSlot;
  resolvedValue = *value;
  return AnchorResolutionResult::Success;
}

void mlir::registerProvisionalDependentTensorScopeOwner(
    Region *scopeOwnerBodyRegion, MLIRContext *context,
    detail::ProvisionalAnchorOwnerState &provisionalState) {
  provisionalState.context = context;
  provisionalScopeOwnerRegistrations.push_back(
      {scopeOwnerBodyRegion, &provisionalState});
}

void mlir::unregisterProvisionalDependentTensorScopeOwner(
    Region *scopeOwnerBodyRegion) {
  auto it = llvm::find_if(
      llvm::reverse(provisionalScopeOwnerRegistrations),
      [&](const ProvisionalScopeOwnerRegistration &registration) {
        return registration.bodyRegion == scopeOwnerBodyRegion;
      });
  if (it != provisionalScopeOwnerRegistrations.rend())
    provisionalScopeOwnerRegistrations.erase(std::prev(it.base()));
}

void mlir::registerProvisionalDependentTensorBlock(Region *scopeOwnerBodyRegion,
                                                   Block *block,
                                                   uint32_t blockIndex) {
  provisionalBlockRegistrations.push_back(
      {scopeOwnerBodyRegion, block, blockIndex});
}

void mlir::unregisterProvisionalDependentTensorBlock(Block *block) {
  auto it = llvm::find_if(
      llvm::reverse(provisionalBlockRegistrations),
      [&](const ProvisionalBlockRegistration &registration) {
        return registration.block == block;
      });
  if (it != provisionalBlockRegistrations.rend())
    provisionalBlockRegistrations.erase(std::prev(it.base()));
}

ArrayAttr mlir::serializeDependentTensorAnchorSlots(
    MLIRContext *context, ArrayRef<detail::AnchorSlotState> slots) {
  Builder builder(context);
  SmallVector<Attribute> slotAttrs;
  slotAttrs.reserve(slots.size());
  for (const detail::AnchorSlotState &slot : slots) {
    SmallVector<NamedAttribute> fields;
    fields.emplace_back(builder.getStringAttr(kSlotField),
                        builder.getI32IntegerAttr(slot.slot));
    fields.emplace_back(builder.getStringAttr(kGenerationField),
                        builder.getI32IntegerAttr(slot.generation));
    fields.emplace_back(builder.getStringAttr(kAliveField),
                        builder.getBoolAttr(slot.alive));
    fields.emplace_back(builder.getStringAttr(kSubjectKindField),
                        builder.getStringAttr(
                            slot.subjectKind ==
                                    detail::AnchorSubjectKind::BlockArgument
                                ? kSubjectKindBlockArg
                                : kSubjectKindResult));
    fields.emplace_back(builder.getStringAttr(kValueIndexField),
                        builder.getI32IntegerAttr(slot.valueIndex));
    SmallVector<int32_t> path;
    path.reserve(slot.path.size());
    for (uint32_t index : slot.path)
      path.push_back(static_cast<int32_t>(index));
    fields.emplace_back(builder.getStringAttr(kPathField),
                        DenseI32ArrayAttr::get(context, path));
    slotAttrs.push_back(DictionaryAttr::get(context, fields));
  }
  return ArrayAttr::get(context, slotAttrs);
}

void mlir::registerDependentTypeUse(Value value) {
  registerDependentTypeUseImpl(value);
}

void mlir::unregisterDependentTypeUse(Value value) {
  unregisterDependentTypeUseImpl(value);
}

void mlir::registerDependentTypeUse(Type, Operation *) {}

void mlir::registerDependentTypeUse(BlockArgument arg) {
  registerDependentTypeUse(Value(arg));
}

void mlir::unregisterDependentTypeUse(Type, Operation *) {}

void mlir::unregisterDependentTypeUse(BlockArgument arg) {
  unregisterDependentTypeUse(Value(arg));
}

void mlir::remapDependentTypeUsesOnValueChange(Value from, Value to) {
  if (!from || !to || from == to)
    return;

  Operation *anchorSearchRoot =
      from.getDefiningOp()
          ? getTopLevelOwner(from.getDefiningOp())
          : getTopLevelOwner(cast<BlockArgument>(from).getOwner()->getParentOp());
  if (!anchorSearchRoot)
    return;

  auto remapValueType = [&](Value typedValue) {
    Type type = typedValue.getType();
    if (!isDependentTensorType(type))
      return;
    Type remappedType =
        replaceDependentAnchorInType(type, from, to, anchorSearchRoot);
    if (remappedType != type)
      typedValue.setType(remappedType);
  };

  for (Region &region : anchorSearchRoot->getRegions()) {
    for (Block &block : region.getBlocks()) {
      for (BlockArgument arg : block.getArguments())
        remapValueType(arg);
      for (Operation &op : block)
        for (Value result : op.getResults())
          remapValueType(result);
    }
  }

  anchorSearchRoot->walk([&](Operation *nested) {
    if (nested == anchorSearchRoot)
      return;
    for (Region &region : nested->getRegions()) {
      for (Block &block : region.getBlocks()) {
        for (BlockArgument arg : block.getArguments())
          remapValueType(arg);
      }
    }
    for (Value result : nested->getResults())
      remapValueType(result);
  });
}

LogicalResult mlir::verifyDependentTypeAnchors(
    Type type, Operation *useSite,
    function_ref<InFlightDiagnostic()> emitError) {
  auto tensorType = llvm::dyn_cast<DependentTensorType>(type);
  if (!tensorType)
    return success();

  for (DependentDimExpr expr : tensorType.getDimensionExprs()) {
    if (expr.isConstant())
      continue;
    if (failed(verifyAnchorAtUseSite(expr.anchor, useSite, emitError)))
      return failure();
  }
  return success();
}

LogicalResult mlir::verifyDependentTypeAnchors(
    BlockArgument arg, function_ref<InFlightDiagnostic()> emitError) {
  Block *block = arg.getOwner();
  if (!block)
    return success();

  // Block argument dependent types are verified at the first operation in the
  // block. An empty block falls back to the parent op so scope and dominance
  // are still checked against a concrete use site inside the enclosing region.
  Operation *useSite = !block->empty() ? &block->front() : block->getParentOp();
  if (!useSite)
    return success();
  return verifyDependentTypeAnchors(arg.getType(), useSite, emitError);
}

Type mlir::remapDependentTensorType(Type type, IRMapping &mapping,
                                    Operation *anchorSearchRoot) {
  auto tensorType = llvm::dyn_cast<DependentTensorType>(type);
  if (!tensorType)
    return type;

  SmallVector<DependentDimExpr> remappedDims;
  remappedDims.reserve(tensorType.getDimensionExprs().size());
  for (DependentDimExpr expr : tensorType.getDimensionExprs()) {
    if (expr.isConstant()) {
      remappedDims.push_back(expr);
      continue;
    }

    FailureOr<Value> resolved = resolveAnchorKey(expr.anchor, anchorSearchRoot);
    if (failed(resolved)) {
      remappedDims.push_back(expr);
      continue;
    }

    Value mapped = mapping.lookupOrNull(*resolved);
    if (!mapped) {
      remappedDims.push_back(expr);
      continue;
    }

    FailureOr<AnchorKey> newKey = createAnchorKeyForValue(mapped);
    if (failed(newKey)) {
      remappedDims.push_back(expr);
      continue;
    }
    remappedDims.push_back(DependentDimExpr::getAnchor(*newKey));
  }

  return DependentTensorType::get(type.getContext(), remappedDims,
                                  tensorType.getElementType());
}

Type mlir::replaceDependentAnchorInType(Type type, Value from, Value to,
                                        Operation *anchorSearchRoot) {
  IRMapping mapping;
  mapping.map(from, to);
  return remapDependentTensorType(type, mapping, anchorSearchRoot);
}

void mlir::printDependentDimExpr(raw_ostream &os, DependentDimExpr expr,
                                 AsmState &state,
                                 Operation *fallbackUseSite) {
  if (expr.isConstant()) {
    os << expr.constantValue;
    return;
  }
  FailureOr<Value> value = resolveAnchorKey(expr.anchor, fallbackUseSite);
  if (failed(value)) {
    printFallbackAnchor(os, expr.anchor);
    return;
  }
  value->printAsOperand(os, state);
}

void mlir::printDependentDimExpr(raw_ostream &os, DependentDimExpr expr,
                                 Operation *fallbackUseSite) {
  if (expr.isConstant()) {
    os << expr.constantValue;
    return;
  }
  FailureOr<Value> value = resolveAnchorKey(expr.anchor, fallbackUseSite);
  if (failed(value)) {
    printFallbackAnchor(os, expr.anchor);
    return;
  }
  value->printAsOperand(os, OpPrintingFlags());
}

LogicalResult mlir::checkDependentAnchorOwnerCanErase(
    Operation *op, function_ref<InFlightDiagnostic()> emitError) {
  if (!op)
    return success();

  auto scopeOwner = dyn_cast<DependentTensorScopeOwnerOpInterface>(op);
  auto resultOwner = dyn_cast<DependentTensorResultOwnerOpInterface>(op);
  if (!scopeOwner && !resultOwner)
    return success();

  AnchorOwnerKind ownerKind =
      scopeOwner ? AnchorOwnerKind::ScopeOwner : AnchorOwnerKind::ResultOwner;
  AnchorOwnerProperties properties =
      scopeOwner ? loadOwnerProperties(scopeOwner) : loadOwnerProperties(resultOwner);
  if (properties.slots.empty() || !properties.ownerTag)
    return success();

  for (const detail::AnchorSlotState &state : properties.slots) {
    if (!state.alive)
      continue;
    AnchorKey key{ownerKind, properties.ownerTag, state.slot, state.generation};
    if (hasExternalRegisteredUseOfKey(
            key,
            [&](Operation *nested) {
              return nested == op || op->isProperAncestor(nested);
            },
            [&](BlockArgument arg) {
              Operation *argOwner = arg.getOwner()->getParentOp();
              return argOwner == op || (argOwner && op->isProperAncestor(argOwner));
            }))
      return emitError() << "cannot erase anchor owner with live dependent tensor "
                            "references";
  }
  return success();
}

LogicalResult mlir::checkDependentAnchorValueCanMove(
    Value value, function_ref<InFlightDiagnostic()> emitError) {
  FailureOr<AnchorKey> key = getLiveAnchorKeyForValue(value);
  if (failed(key) || key->ownerKind != AnchorOwnerKind::ScopeOwner)
    return success();

  if (!getRegisteredDependentTypeUses(*key).empty())
    return emitError() << "cannot move scope-owned anchor value with live "
                          "dependent tensor references";
  return success();
}

LogicalResult mlir::checkDependentAnchorValueCanErase(
    Value value, function_ref<InFlightDiagnostic()> emitError) {
  Operation *owner = nullptr;
  AnchorOwnerKind ownerKind = AnchorOwnerKind::ScopeOwner;
  detail::AnchorSlotState slotState;
  if (failed(findLiveAnchorState(value, owner, ownerKind, slotState)))
    return success();

  FailureOr<std::pair<AnchorOwnerKind, Operation *>> ownerInfo =
      getOwnerForValue(value);
  if (failed(ownerInfo))
    return success();
  DistinctAttr ownerTag =
      ownerKind == AnchorOwnerKind::ScopeOwner
          ? cast<DependentTensorScopeOwnerOpInterface>(owner)
                .getDependentTensorOwnerTagValue()
          : cast<DependentTensorResultOwnerOpInterface>(owner)
                .getDependentTensorOwnerTagValue();
  AnchorKey key{ownerKind, ownerTag, slotState.slot, slotState.generation};
  if (!hasExternalRegisteredUseOfKey(
          key, [&](Operation *) { return false; },
          [&](BlockArgument arg) { return arg == dyn_cast<BlockArgument>(value); }))
    return success();

  return emitError() << "cannot erase anchor value with live dependent tensor "
                        "references";
}

LogicalResult mlir::removeDependentAnchorForValue(Value value) {
  FailureOr<std::pair<AnchorOwnerKind, Operation *>> ownerInfo =
      getOwnerForValue(value);
  if (failed(ownerInfo))
    return failure();
  AnchorOwnerKind ownerKind = ownerInfo->first;
  Operation *owner = ownerInfo->second;
  FailureOr<AnchorSubjectDescriptor> descriptor =
      getSubjectDescriptor(ownerKind, owner, value);
  if (failed(descriptor))
    return failure();

  if (ownerKind == AnchorOwnerKind::ScopeOwner) {
    auto ownerInterface = cast<DependentTensorScopeOwnerOpInterface>(owner);
    AnchorOwnerProperties properties = loadOwnerProperties(ownerInterface);
    auto it =
        llvm::find_if(properties.slots, [&](const detail::AnchorSlotState &state) {
          return matchesSubject(state, *descriptor);
        });
    if (it == properties.slots.end())
      return failure();
    properties.slots.erase(it);
    saveOwnerProperties(ownerInterface, properties);
    return success();
  }

  auto ownerInterface = cast<DependentTensorResultOwnerOpInterface>(owner);
  AnchorOwnerProperties properties = loadOwnerProperties(ownerInterface);
  auto it =
      llvm::find_if(properties.slots, [&](const detail::AnchorSlotState &state) {
        return matchesSubject(state, *descriptor);
      });
  if (it == properties.slots.end())
    return failure();
  properties.slots.erase(it);
  saveOwnerProperties(ownerInterface, properties);
  return success();
}

LogicalResult mlir::markDependentAnchorDead(Value value) {
  FailureOr<std::pair<AnchorOwnerKind, Operation *>> ownerInfo =
      getOwnerForValue(value);
  if (failed(ownerInfo))
    return failure();
  AnchorOwnerKind ownerKind = ownerInfo->first;
  Operation *owner = ownerInfo->second;
  FailureOr<AnchorSubjectDescriptor> descriptor =
      getSubjectDescriptor(ownerKind, owner, value);
  if (failed(descriptor))
    return failure();

  if (ownerKind == AnchorOwnerKind::ScopeOwner) {
    auto ownerInterface = cast<DependentTensorScopeOwnerOpInterface>(owner);
    AnchorOwnerProperties properties = loadOwnerProperties(ownerInterface);
    detail::AnchorSlotState *state = findSlotState(properties, *descriptor);
    if (!state)
      return failure();
    state->alive = false;
    saveOwnerProperties(ownerInterface, properties);
    return success();
  }

  auto ownerInterface = cast<DependentTensorResultOwnerOpInterface>(owner);
  AnchorOwnerProperties properties = loadOwnerProperties(ownerInterface);
  detail::AnchorSlotState *state = findSlotState(properties, *descriptor);
  if (!state)
    return failure();
  state->alive = false;
  saveOwnerProperties(ownerInterface, properties);
  return success();
}

LogicalResult mlir::bumpDependentAnchorGeneration(Value value) {
  FailureOr<std::pair<AnchorOwnerKind, Operation *>> ownerInfo =
      getOwnerForValue(value);
  if (failed(ownerInfo))
    return failure();
  AnchorOwnerKind ownerKind = ownerInfo->first;
  Operation *owner = ownerInfo->second;
  FailureOr<AnchorSubjectDescriptor> descriptor =
      getSubjectDescriptor(ownerKind, owner, value);
  if (failed(descriptor))
    return failure();

  if (ownerKind == AnchorOwnerKind::ScopeOwner) {
    auto ownerInterface = cast<DependentTensorScopeOwnerOpInterface>(owner);
    AnchorOwnerProperties properties = loadOwnerProperties(ownerInterface);
    detail::AnchorSlotState *state = findSlotState(properties, *descriptor);
    if (!state)
      return failure();
    ++state->generation;
    saveOwnerProperties(ownerInterface, properties);
    return success();
  }

  auto ownerInterface = cast<DependentTensorResultOwnerOpInterface>(owner);
  AnchorOwnerProperties properties = loadOwnerProperties(ownerInterface);
  detail::AnchorSlotState *state = findSlotState(properties, *descriptor);
  if (!state)
    return failure();
  ++state->generation;
  saveOwnerProperties(ownerInterface, properties);
  return success();
}
