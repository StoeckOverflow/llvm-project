#include "mlir/IR/DependentTensorSupport.h"
#include "mlir/IR/Builders.h"
#include "mlir/IR/Operation.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/ADT/SmallPtrSet.h"
#include <algorithm>
#include <optional>

using namespace mlir;

static llvm::hash_code
hashDependentTensorDimValues(ArrayRef<PropertyOperand> operands) {
  llvm::hash_code hash = llvm::hash_value(operands.size());
  for (const PropertyOperand &operand : operands)
    hash = llvm::hash_combine(hash, operand.get());
  return hash;
}

llvm::hash_code mlir::hash_value(const DependentTensorTypeRef &refinement) {
  return llvm::hash_combine(refinement.rank,
                            hashDependentTensorDimValues(refinement.dimValues));
}

llvm::hash_code
mlir::hash_value(const DependentTensorValueRefinement &refinement) {
  return llvm::hash_combine(refinement.valueIndex, refinement.rank,
                            hashDependentTensorDimValues(refinement.dimValues));
}

llvm::hash_code mlir::hash_value(const DependentTensorLoopTypeRef &refinement) {
  return llvm::hash_combine(refinement.valueIndex,
                            hash_value(refinement.operandTypeRef),
                            hash_value(refinement.resultTypeRef));
}

llvm::hash_code
mlir::hash_value(const DependentTensorDimValueRefinement &refinement) {
  return hashDependentTensorDimValues(refinement.dimValues);
}

llvm::hash_code
mlir::hash_value(const DependentMemRefValueRefinement &refinement) {
  return llvm::hash_combine(
      refinement.valueIndex, refinement.rank, refinement.offset,
      refinement.hasExplicitLayout,
      hashDependentTensorDimValues(refinement.dimValues),
      hashDependentTensorDimValues(refinement.strideValues));
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

static StringRef normalizeDependentTensorSSAName(StringRef name) {
  name.consume_front("%");
  return name;
}

static std::optional<unsigned>
findLoopIterArgIndex(ArrayRef<OpAsmParser::Argument> regionArgs,
                     StringRef name) {
  name = normalizeDependentTensorSSAName(name);
  for (auto [index, arg] : llvm::enumerate(regionArgs.drop_front()))
    if (normalizeDependentTensorSSAName(arg.ssaName.name) == name)
      return index;
  return std::nullopt;
}

static ParseResult
parsePendingTypeRef(OpAsmParser &parser,
                    dependent_tensor::PendingTypeRef &typeRef) {
  typeRef.loc = parser.getCurrentLocation();
  return dependent_tensor::parseTensorSpec(parser, typeRef.dims,
                                           typeRef.elementType);
}

ParseResult mlir::dependent_tensor::parseOptionalLoopTypeRefs(
    OpAsmParser &parser, StringRef keyword,
    ArrayRef<OpAsmParser::Argument> regionArgs,
    SmallVectorImpl<PendingLoopTypeRef> &pending) {
  if (failed(parser.parseOptionalHashKeyword(keyword)))
    return success();

  SmallVector<bool> seen(regionArgs.size() > 0 ? regionArgs.size() - 1 : 0,
                         false);
  if (parser.parseLSquare())
    return failure();

  while (failed(parser.parseOptionalRSquare())) {
    OpAsmParser::UnresolvedOperand arg;
    if (parser.parseOperand(arg))
      return failure();
    std::optional<unsigned> iterArgIndex =
        findLoopIterArgIndex(regionArgs, arg.name);
    if (!iterArgIndex)
      return parser.emitError(
          arg.location,
          "dependent tensor loop boundary values must be loop iter args");
    if (seen[*iterArgIndex])
      return parser.emitError(arg.location,
                              "duplicate dependent tensor loop boundary value");
    seen[*iterArgIndex] = true;

    PendingLoopTypeRef info;
    info.iterArgIndex = *iterArgIndex;
    info.iterLoc = arg.location;
    if (parser.parseColon() || parsePendingTypeRef(parser, info.input))
      return failure();

    pending.push_back(std::move(info));
    (void)parser.parseOptionalComma();
  }

  if (pending.empty())
    return parser.emitError(parser.getCurrentLocation(),
                            "expected at least one dependent tensor loop "
                            "boundary value");

  if (failed(parser.parseOptionalArrow()))
    return parser.emitError(parser.getCurrentLocation(),
                            "expected dependent tensor loop result refs");

  auto parseOutputRef = [&](PendingTypeRef &output) -> ParseResult {
    return parsePendingTypeRef(parser, output);
  };
  if (pending.size() == 1) {
    if (parseOutputRef(pending.front().output))
      return failure();
    return success();
  }

  unsigned resultIndex = 0;
  if (parser.parseCommaSeparatedList(
          OpAsmParser::Delimiter::Square, [&]() -> ParseResult {
            if (resultIndex >= pending.size())
              return parser.emitError(parser.getCurrentLocation(),
                                      "too many dependent tensor loop "
                                      "result refs");
            return parseOutputRef(pending[resultIndex++].output);
          }))
    return failure();
  if (resultIndex != pending.size())
    return parser.emitError(parser.getCurrentLocation(),
                            "expected one dependent tensor loop result ref "
                            "per loop boundary value");
  return success();
}

ParseResult mlir::dependent_tensor::resolvePendingTypeRef(
    OpAsmParser &parser, const PendingTypeRef &in, Type valueType,
    StringRef kind, DependentTensorTypeRef &out) {
  auto rankedType = dyn_cast<RankedTensorType>(valueType);
  if (!rankedType)
    return parser.emitError(in.loc)
           << "dependent tensor loop " << kind << " requires ranked tensor";
  if (in.dims.size() != static_cast<size_t>(rankedType.getRank()))
    return parser.emitError(in.loc)
           << "dependent tensor loop " << kind << " rank mismatch";
  if (in.elementType != rankedType.getElementType())
    return parser.emitError(in.loc) << "dependent tensor loop " << kind
                                    << " element type must match value type";

  SmallVector<Type> dimTypes(in.dims.size(),
                             parser.getBuilder().getIndexType());
  SmallVector<Value> resolvedDims;
  if (parser.resolveOperands(in.dims, dimTypes, in.loc, resolvedDims))
    return failure();
  out.rank = rankedType.getRank();
  out.assignDimValues(resolvedDims);
  return success();
}

const DependentTensorLoopTypeRef *mlir::dependent_tensor::findLoopTypeRef(
    ArrayRef<DependentTensorLoopTypeRef> typeRefs, unsigned valueIndex) {
  for (const DependentTensorLoopTypeRef &candidate : typeRefs)
    if (candidate.valueIndex == valueIndex)
      return &candidate;
  return nullptr;
}

void mlir::dependent_tensor::buildLoopTypeRefLookup(
    ArrayRef<DependentTensorLoopTypeRef> typeRefs, unsigned numValues,
    SmallVectorImpl<const DependentTensorLoopTypeRef *> &lookup) {
  lookup.clear();
  lookup.resize(numValues, nullptr);
  for (const DependentTensorLoopTypeRef &ref : typeRefs)
    if (ref.valueIndex < lookup.size())
      lookup[ref.valueIndex] = &ref;
}

static void resetPresence(SmallVectorImpl<bool> &presence, unsigned size) {
  presence.clear();
  presence.resize(size);
  for (unsigned i = 0; i < size; ++i)
    presence[i] = false;
}

static void markPresent(SmallVectorImpl<bool> &presence, unsigned index) {
  if (index >= presence.size()) {
    unsigned oldSize = presence.size();
    presence.resize(index + 1);
    for (unsigned i = oldSize; i < presence.size(); ++i)
      presence[i] = false;
  }
  presence[index] = true;
}

static bool isPresent(ArrayRef<bool> presence, unsigned index) {
  return index < presence.size() && presence[index];
}

void mlir::dependent_tensor::buildLoopTypeRefPresence(
    ArrayRef<DependentTensorLoopTypeRef> typeRefs, unsigned numValues,
    SmallVectorImpl<bool> &presence) {
  resetPresence(presence, numValues);
  for (const DependentTensorLoopTypeRef &ref : typeRefs)
    if (ref.valueIndex < presence.size())
      presence[ref.valueIndex] = true;
}

bool mlir::dependent_tensor::isValueOwnedByOperation(Value value,
                                                     Operation *op) {
  if (!value || !op)
    return false;
  if (auto result = dyn_cast<OpResult>(value))
    return result.getOwner() == op;
  auto arg = cast<BlockArgument>(value);
  Block *block = arg.getOwner();
  return block && block->getParentOp() == op;
}

FailureOr<DependentTensorTypeRef>
mlir::dependent_tensor::getTypeRefFromValueUnlessOwned(
    Value value, Operation *op,
    function_ref<FailureOr<DependentTensorTypeRef>(Value)>
        getTypeRefFromValue) {
  if (isValueOwnedByOperation(value, op))
    return failure();
  return getTypeRefFromValue(value);
}

static llvm::SmallPtrSet<Operation *, 4> &getActiveLoopTypeRefPopulations() {
  static thread_local llvm::SmallPtrSet<Operation *, 4> activePopulations;
  return activePopulations;
}

mlir::dependent_tensor::ScopedLoopTypeRefPopulation::
    ScopedLoopTypeRefPopulation(Operation *op)
    : op(op) {
  if (op)
    inserted = getActiveLoopTypeRefPopulations().insert(op).second;
}

mlir::dependent_tensor::ScopedLoopTypeRefPopulation::
    ~ScopedLoopTypeRefPopulation() {
  if (inserted)
    getActiveLoopTypeRefPopulations().erase(op);
}

void mlir::dependent_tensor::inferMissingLoopTypeRefs(
    TypeRange resultTypes, ValueRange initOperands,
    Block::BlockArgListType regionIterArgs, ValueRange yieldedValues,
    function_ref<FailureOr<DependentTensorTypeRef>(Value)> getTypeRefFromValue,
    SmallVectorImpl<DependentTensorLoopTypeRef> &loopTypeRefs) {
  unsigned slots = std::min<unsigned>(initOperands.size(), resultTypes.size());
  slots = std::min<unsigned>(slots, regionIterArgs.size());

  SmallVector<bool> loopRefPresent;
  buildLoopTypeRefPresence(loopTypeRefs, resultTypes.size(), loopRefPresent);
  loopTypeRefs.reserve(std::max<size_t>(loopTypeRefs.size(), slots));

  for (unsigned i = 0; i < slots; ++i) {
    if (!isa<RankedTensorType>(resultTypes[i]) || isPresent(loopRefPresent, i))
      continue;

    FailureOr<DependentTensorTypeRef> initRef =
        getTypeRefFromValue(initOperands[i]);
    FailureOr<DependentTensorTypeRef> yieldedRef = failure();
    if (i < yieldedValues.size())
      yieldedRef = getTypeRefFromValue(yieldedValues[i]);
    if (failed(initRef) && failed(yieldedRef))
      continue;

    DependentTensorLoopTypeRef &ref = loopTypeRefs.emplace_back();
    ref.valueIndex = i;
    ref.operandTypeRef = succeeded(initRef) ? *initRef : *yieldedRef;
    ref.resultTypeRef =
        succeeded(yieldedRef) ? *yieldedRef : ref.operandTypeRef;
    markPresent(loopRefPresent, i);
  }
}

ParseResult mlir::dependent_tensor::populateLoopTypeRefsFromInits(
    OpAsmParser &parser, TypeRange resultTypes, ValueRange initOperands,
    Block::BlockArgListType regionIterArgs, ValueRange yieldedValues,
    ArrayRef<PendingLoopTypeRef> pendingLoopRefs,
    function_ref<FailureOr<DependentTensorTypeRef>(Value)> getTypeRefFromValue,
    SmallVectorImpl<DependentTensorLoopTypeRef> &loopTypeRefs) {
  loopTypeRefs.clear();
  loopTypeRefs.reserve(initOperands.size());

  auto checkIndex = [&](const PendingLoopTypeRef &info) -> ParseResult {
    if (info.iterArgIndex >= resultTypes.size() ||
        info.iterArgIndex >= initOperands.size() ||
        info.iterArgIndex >= regionIterArgs.size())
      return parser.emitError(
          info.iterLoc, "dependent tensor loop boundary index out of range");
    return success();
  };
  for (const PendingLoopTypeRef &info : pendingLoopRefs)
    if (checkIndex(info))
      return failure();

  for (const PendingLoopTypeRef &info : pendingLoopRefs) {
    unsigned i = info.iterArgIndex;
    DependentTensorLoopTypeRef &ref = loopTypeRefs.emplace_back();
    ref.valueIndex = i;
    if (resolvePendingTypeRef(parser, info.input, initOperands[i].getType(),
                              "operand type reference", ref.operandTypeRef) ||
        resolvePendingTypeRef(parser, info.output, resultTypes[i],
                              "result type reference", ref.resultTypeRef))
      return failure();
  }

  inferMissingLoopTypeRefs(resultTypes, initOperands, regionIterArgs,
                           yieldedValues, getTypeRefFromValue, loopTypeRefs);
  return success();
}

bool mlir::dependent_tensor::isTypeRefVisibleFrom(
    Operation *op, const DependentTensorTypeRef &typeRef) {
  for (const PropertyOperand &operand : typeRef.dimValues) {
    Value dim = operand.get();
    if (!dim)
      return false;
    Region *region = nullptr;
    if (auto result = dyn_cast<OpResult>(dim))
      region = result.getOwner()->getParentRegion();
    else
      region = cast<BlockArgument>(dim).getOwner()->getParent();

    for (; region; region = region->getParentOp()
                                ? region->getParentOp()->getParentRegion()
                                : nullptr)
      if (region->getParentOp() == op)
        return false;
  }
  return true;
}

void mlir::dependent_tensor::printTypeRef(OpAsmPrinter &printer,
                                          const DependentTensorTypeRef &typeRef,
                                          Type elementType) {
  SmallVector<Value, 4> dimValues;
  typeRef.appendDimValuesTo(dimValues);
  printTensorSpec(printer, dimValues, elementType);
}

void mlir::dependent_tensor::printLoopTypeRefs(
    OpAsmPrinter &printer, Block::BlockArgListType regionIterArgs,
    TypeRange resultTypes, ArrayRef<DependentTensorLoopTypeRef> typeRefs) {
  if (typeRefs.empty())
    return;
  printer << " #types[";
  llvm::interleaveComma(typeRefs, printer, [&](const auto &ref) {
    BlockArgument arg = regionIterArgs[ref.valueIndex];
    printer.printOperand(arg);
    printer << " : ";
    auto type = cast<RankedTensorType>(arg.getType());
    printTypeRef(printer, ref.operandTypeRef, type.getElementType());
  });
  printer << "] -> ";
  auto printResultRef = [&](const DependentTensorLoopTypeRef &ref) {
    auto resultType = cast<RankedTensorType>(resultTypes[ref.valueIndex]);
    printTypeRef(printer, ref.resultTypeRef, resultType.getElementType());
  };
  if (typeRefs.size() == 1) {
    printResultRef(typeRefs.front());
    return;
  }
  printer << '[';
  llvm::interleaveComma(typeRefs, printer, printResultRef);
  printer << ']';
}
