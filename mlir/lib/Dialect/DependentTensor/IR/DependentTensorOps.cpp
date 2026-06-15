//===- DependentTensorOps.cpp - DependentTensor op definitions ------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/DependentTensor/IR/DependentTensor.h"
#include "mlir/IR/Matchers.h"
#include "llvm/ADT/STLExtras.h"

using namespace mlir;
using namespace mlir::dependent_tensor;

namespace {
static FailureOr<TensorValueSemantics>
buildValueSemantics(RankedTensorType type, ArrayRef<Value> dimValues) {
  if (type.getRank() != static_cast<int64_t>(dimValues.size()))
    return failure();

  TensorValueSemantics info{type, {}};
  info.dimValues.reserve(dimValues.size());
  for (Value dimValue : dimValues) {
    if (!dimValue || !dimValue.getType().isIndex())
      return failure();
    info.dimValues.push_back(dimValue);
  }
  return info;
}

static DependentTensorValueSemantics buildStored(unsigned valueIndex,
                                                 RankedTensorType type,
                                                 ArrayRef<Value> dimValues) {
  DependentTensorValueSemantics stored;
  stored.valueIndex = valueIndex;
  stored.rank = type.getRank();
  stored.assignDimValues(dimValues);
  return stored;
}

static unsigned getValueIndex(Value value) {
  if (auto result = dyn_cast<OpResult>(value))
    return result.getResultNumber();
  if (auto arg = dyn_cast<BlockArgument>(value))
    return arg.getArgNumber();
  return 0;
}

static std::optional<uint64_t> getConstantDim(Value value) {
  IntegerAttr attr;
  if (!matchPattern(value, m_Constant(&attr)))
    return std::nullopt;
  return attr.getValue().getZExtValue();
}

template <typename Range>
static const DependentTensorValueSemantics *
findStoredSemantics(Range &&range, unsigned valueIndex) {
  for (const DependentTensorValueSemantics &semantics : range)
    if (semantics.valueIndex == valueIndex)
      return &semantics;
  return nullptr;
}

static FailureOr<TensorValueSemantics>
getFuncArgSemantics(BlockArgument arg, func::FuncOp func,
                    RankedTensorType rankedType) {
  if (const DependentTensorValueSemantics *stored = findStoredSemantics(
          func.getProperties().dependentTensorArgSemantics, arg.getArgNumber()))
    return decodeStoredSemantics(arg, *stored);
  return failure();
}

static FailureOr<TensorValueSemantics>
getCallResultSemantics(OpResult result, func::CallOp call, func::FuncOp callee,
                       RankedTensorType rankedType) {
  if (const DependentTensorValueSemantics *stored = findStoredSemantics(
          callee.getProperties().dependentTensorResultSemantics,
          result.getResultNumber())) {
    SmallVector<Value> mappedDims;
    mappedDims.reserve(stored->dimValues.size());
    for (Value dimValue : stored->getDimValues()) {
      auto arg = dyn_cast<BlockArgument>(dimValue);
      if (!arg || arg.getOwner() != &callee.getBody().front() ||
          arg.getArgNumber() >= call.getNumOperands())
        return failure();
      mappedDims.push_back(call.getOperand(arg.getArgNumber()));
    }
    return buildValueSemantics(rankedType, mappedDims);
  }
  return failure();
}
} // namespace

DependentTensorValueSemantics dependent_tensor::buildStoredSemantics(
    unsigned valueIndex, RankedTensorType type, ArrayRef<Value> dimValues) {
  return buildStored(valueIndex, type, dimValues);
}

FailureOr<TensorValueSemantics> dependent_tensor::decodeStoredSemantics(
    Value value, const DependentTensorValueSemantics &stored) {
  auto rankedType = dyn_cast<RankedTensorType>(value.getType());
  if (!rankedType)
    return failure();
  unsigned valueIndex = getValueIndex(value);
  if (stored.valueIndex != valueIndex || stored.rank != rankedType.getRank())
    return failure();
  return buildValueSemantics(rankedType, stored.getDimValues());
}

FailureOr<TensorValueSemantics>
dependent_tensor::getValueSemantics(Value value) {
  auto rankedType = dyn_cast<RankedTensorType>(value.getType());
  if (!rankedType)
    return failure();

  if (auto arg = dyn_cast<BlockArgument>(value)) {
    auto *block = arg.getOwner();
    auto func =
        dyn_cast_or_null<func::FuncOp>(block ? block->getParentOp() : nullptr);
    if (func && block == &func.getBody().front())
      return getFuncArgSemantics(arg, func, rankedType);

    Operation *parentOp = block ? block->getParentOp() : nullptr;
    auto iface = dyn_cast_or_null<DependentTensorPropertyOpInterface>(parentOp);
    if (!iface)
      return failure();
    unsigned regionNumber = 0;
    unsigned blockNumber = 0;
    bool foundRegion = false;
    bool foundBlock = false;
    for (Region &region : parentOp->getRegions()) {
      if (&region == block->getParent()) {
        foundRegion = true;
        for (Block &candidate : region) {
          if (&candidate == block) {
            foundBlock = true;
            break;
          }
          ++blockNumber;
        }
        break;
      }
      ++regionNumber;
    }
    if (!foundRegion || !foundBlock)
      return failure();
    FailureOr<DependentTensorValueSemantics> stored =
        iface.getDependentTensorBlockArgumentSemantics(
            regionNumber, blockNumber, arg.getArgNumber());
    if (failed(stored))
      return failure();
    return decodeStoredSemantics(value, *stored);
  }

  auto result = cast<OpResult>(value);
  Operation *def = result.getOwner();
  if (auto iface = dyn_cast<DependentTensorPropertyOpInterface>(def)) {
    FailureOr<DependentTensorValueSemantics> stored =
        iface.getDependentTensorResultSemantics(result.getResultNumber());
    if (succeeded(stored))
      return decodeStoredSemantics(value, *stored);
  }

  if (auto call = dyn_cast<func::CallOp>(def)) {
    auto callee = SymbolTable::lookupNearestSymbolFrom<func::FuncOp>(
        call, call.getCalleeAttr());
    if (!callee)
      return failure();
    return getCallResultSemantics(result, call, callee, rankedType);
  }

  return failure();
}

bool dependent_tensor::haveEqualSemantics(const TensorValueSemantics &lhs,
                                          const TensorValueSemantics &rhs) {
  return lhs.type == rhs.type && lhs.dimValues == rhs.dimValues;
}

FailureOr<bool> dependent_tensor::haveEqualSemantics(Value lhs, Value rhs) {
  auto lhsInfo = getValueSemantics(lhs);
  auto rhsInfo = getValueSemantics(rhs);
  if (failed(lhsInfo) || failed(rhsInfo))
    return failure();
  return haveEqualSemantics(*lhsInfo, *rhsInfo);
}

FailureOr<bool> dependent_tensor::haveEqualDimSemantics(Value lhs,
                                                        unsigned lhsDim,
                                                        Value rhs,
                                                        unsigned rhsDim) {
  auto lhsInfo = getValueSemantics(lhs);
  auto rhsInfo = getValueSemantics(rhs);
  if (failed(lhsInfo) || failed(rhsInfo))
    return failure();
  if (lhsDim >= lhsInfo->dimValues.size() ||
      rhsDim >= rhsInfo->dimValues.size())
    return failure();
  return lhsInfo->dimValues[lhsDim] == rhsInfo->dimValues[rhsDim];
}

namespace {
static void printValueList(OpAsmPrinter &printer, ValueRange values) {
  printer << "[";
  llvm::interleaveComma(values, printer,
                        [&](Value value) { printer.printOperand(value); });
  printer << "]";
}

static ParseResult
parseOptionalTensorSpec(OpAsmParser &parser, bool &hasSpec,
                        SmallVectorImpl<OpAsmParser::UnresolvedOperand> &dims,
                        Type &elementType) {
  hasSpec = false;
  if (failed(parser.parseOptionalHashKeyword("tensor")))
    return success();
  hasSpec = true;
  return dependent_tensor::parseTensorSpecBody(parser, dims, elementType);
}

static ParseResult resolveTensorRefinement(
    OpAsmParser &parser, SMLoc specLoc, RankedTensorType tensorType,
    ArrayRef<OpAsmParser::UnresolvedOperand> dims, Type elementType,
    SmallVectorImpl<Value> &resolvedDims) {
  if (static_cast<int64_t>(dims.size()) != tensorType.getRank())
    return parser.emitError(specLoc, "dependent tensor rank mismatch");
  if (elementType != tensorType.getElementType())
    return parser.emitError(
        specLoc, "dependent tensor element type must match value type");

  SmallVector<Type> dimTypes(dims.size(), parser.getBuilder().getIndexType());
  if (parser.resolveOperands(dims, dimTypes, parser.getCurrentLocation(),
                             resolvedDims))
    return failure();
  return success();
}

static ParseResult verifyTensorRefinement(OpAsmParser &parser, SMLoc specLoc,
                                          ArrayRef<Value> resolvedDims,
                                          ArrayRef<Value> expectedDims,
                                          StringRef mismatchMessage) {
  if (!llvm::equal(resolvedDims, expectedDims))
    return parser.emitError(specLoc, mismatchMessage);
  return success();
}

static LogicalResult
verifyStoredSemantics(Operation *op, Value value,
                      const DependentTensorValueSemantics &stored) {
  auto rankedType = dyn_cast<RankedTensorType>(value.getType());
  if (!rankedType)
    return op->emitOpError("requires ranked tensor value semantics");
  if (stored.valueIndex != cast<OpResult>(value).getResultNumber())
    return op->emitOpError("has dependent tensor semantics for wrong result");
  if (stored.rank != rankedType.getRank())
    return op->emitOpError(
        "requires dependent tensor rank to match result rank");
  if (stored.dimValues.size() != static_cast<size_t>(rankedType.getRank()))
    return op->emitOpError(
        "requires one dependent dimension value per result dimension");
  for (auto [dim, dimValue] : llvm::enumerate(stored.getDimValues())) {
    if (!rankedType.isDynamicDim(dim))
      return op->emitOpError(
          "requires dependent result dimensions to be dynamic");
    if (!dimValue || !dimValue.getType().isIndex())
      return op->emitOpError("requires index-typed dependent dimension values");
  }
  return success();
}
} // namespace

void MakeOp::build(OpBuilder &builder, OperationState &result,
                   RankedTensorType resultType, ValueRange dimValues) {
  result.addTypes(resultType);
  auto &props = result.getOrAddProperties<MakeOp::Properties>();
  SmallVector<Value> dims(dimValues.begin(), dimValues.end());
  props.result_semantics =
      buildStored(/*valueIndex=*/0, resultType, ArrayRef<Value>(dims));
}

ParseResult MakeOp::parse(OpAsmParser &parser, OperationState &result) {
  SmallVector<OpAsmParser::UnresolvedOperand> dims;
  Type specElementType;

  SMLoc specLoc = parser.getCurrentLocation();
  if (parser.parseLParen() || parser.parseRParen() ||
      dependent_tensor::parseTensorSpec(parser, dims, specElementType))
    return failure();

  Type resultType;
  if (parser.parseColonType(resultType))
    return failure();

  auto rankedType = dyn_cast<RankedTensorType>(resultType);
  if (!rankedType)
    return parser.emitError(parser.getCurrentLocation(),
                            "expected ranked tensor result type");
  if (static_cast<int64_t>(dims.size()) != rankedType.getRank())
    return parser.emitError(specLoc, "dependent tensor rank mismatch");
  if (rankedType.getElementType() != specElementType)
    return parser.emitError(
        specLoc, "dependent tensor element type must match result type");

  SmallVector<Type> dimTypes(dims.size(), parser.getBuilder().getIndexType());
  SmallVector<Value> resolvedDims;
  if (parser.resolveOperands(dims, dimTypes, parser.getCurrentLocation(),
                             resolvedDims))
    return failure();

  result.addTypes(resultType);
  auto &props = result.getOrAddProperties<MakeOp::Properties>();
  props.result_semantics = buildStored(
      /*valueIndex=*/0, rankedType, ArrayRef<Value>(resolvedDims));
  return success();
}

SmallVector<Value, 4> MakeOp::getDimValues() {
  return getProperties().result_semantics.getDimValues();
}

void MakeOp::print(OpAsmPrinter &p) {
  p << " () ";
  auto rankedType = cast<RankedTensorType>(getResult().getType());
  dependent_tensor::printTensorSpec(p, getDimValues(),
                                    rankedType.getElementType());
  p << " : ";
  p.printType(getResult().getType());
}

LogicalResult MakeOp::verify() {
  auto rankedType = dyn_cast<RankedTensorType>(getResult().getType());
  if (!rankedType)
    return emitOpError("requires ranked tensor result type");

  if (failed(verifyStoredSemantics(*this, getResult(),
                                   getProperties().result_semantics)))
    return failure();
  return success();
}

void MakeOp::walkPropertySSAUses(
    function_ref<void(PropertyOperand &)> callback) {
  for (PropertyOperand &operand : getProperties().result_semantics.dimValues)
    callback(operand);
}

void MakeOp::walkDependentTensorPropertyUses(
    function_ref<void(PropertyOperand &)> callback) {
  walkPropertySSAUses(callback);
}

FailureOr<DependentTensorValueSemantics>
MakeOp::getDependentTensorResultSemantics(unsigned resultNumber) {
  if (resultNumber != 0)
    return failure();
  return getProperties().result_semantics;
}

ParseResult DimOp::parse(OpAsmParser &parser, OperationState &result) {
  OpAsmParser::UnresolvedOperand source;
  OpAsmParser::UnresolvedOperand dimension;
  OpAsmParser::UnresolvedOperand assertedDim;
  bool hasAssertedDim = false;
  SMLoc assertedDimLoc;
  Type sourceType;
  if (parser.parseOperand(source) || parser.parseComma() ||
      parser.parseOperand(dimension))
    return failure();
  if (succeeded(parser.parseOptionalComma())) {
    if (parser.parseHashKeyword("dim"))
      return failure();
    hasAssertedDim = true;
    assertedDimLoc = parser.getCurrentLocation();
    if (parser.parseOperand(assertedDim))
      return failure();
  }
  if (parser.parseColonType(sourceType))
    return failure();
  if (parser.resolveOperand(source, sourceType, result.operands) ||
      parser.resolveOperand(dimension, parser.getBuilder().getIndexType(),
                            result.operands))
    return failure();

  if (hasAssertedDim) {
    SmallVector<Value> resolvedDims;
    if (parser.resolveOperand(assertedDim, parser.getBuilder().getIndexType(),
                              resolvedDims))
      return failure();

    Value sourceValue = result.operands[0];
    Value dimensionValue = result.operands[1];
    std::optional<uint64_t> dim = getConstantDim(dimensionValue);
    if (!dim)
      return parser.emitError(
          assertedDimLoc,
          "requires constant dimension operand for #dim assertion");

    FailureOr<TensorValueSemantics> sourceInfo = getValueSemantics(sourceValue);
    if (succeeded(sourceInfo)) {
      if (*dim >= sourceInfo->dimValues.size())
        return parser.emitError(assertedDimLoc,
                                "requires #dim assertion within source rank");
      if (resolvedDims.front() != sourceInfo->dimValues[*dim])
        return parser.emitError(assertedDimLoc,
                                "#dim assertion must match source semantics");
    }
  }

  result.addTypes(parser.getBuilder().getIndexType());
  return success();
}

static Value getPrintableDimAssertion(Value source, Value dimension) {
  std::optional<uint64_t> dim = getConstantDim(dimension);
  if (!dim)
    return {};
  FailureOr<TensorValueSemantics> sourceInfo = getValueSemantics(source);
  if (failed(sourceInfo) || *dim >= sourceInfo->dimValues.size())
    return {};
  return sourceInfo->dimValues[*dim];
}

void DimOp::print(OpAsmPrinter &p) {
  p << ' ';
  p.printOperand(getSource());
  p << ", ";
  p.printOperand(getDimension());
  if (Value asserted = getPrintableDimAssertion(getSource(), getDimension())) {
    p << ", #dim ";
    p.printOperand(asserted);
  }
  p << " : ";
  p.printType(getSource().getType());
}

LogicalResult DimOp::verify() {
  auto sourceType = dyn_cast<RankedTensorType>(getSource().getType());
  if (!sourceType)
    return emitOpError("requires ranked tensor source");
  FailureOr<TensorValueSemantics> sourceInfo = getValueSemantics(getSource());
  if (failed(sourceInfo))
    return emitOpError("requires source with dependent_tensor semantics");
  return success();
}

OpFoldResult DimOp::fold(FoldAdaptor adaptor) {
  auto dimAttr = dyn_cast_or_null<IntegerAttr>(adaptor.getDimension());
  if (!dimAttr)
    return {};
  uint64_t dim = dimAttr.getValue().getZExtValue();
  FailureOr<TensorValueSemantics> sourceInfo = getValueSemantics(getSource());
  if (failed(sourceInfo) || dim >= sourceInfo->dimValues.size())
    return {};
  return sourceInfo->dimValues[dim];
}

ParseResult ExtractOp::parse(OpAsmParser &parser, OperationState &result) {
  OpAsmParser::UnresolvedOperand source;
  SmallVector<OpAsmParser::UnresolvedOperand> indices;
  Type resultType;
  if (parser.parseOperand(source) ||
      parser.parseOperandList(indices, OpAsmParser::Delimiter::Square) ||
      parser.parseColonType(resultType))
    return failure();

  auto tensorType = RankedTensorType::get(
      SmallVector<int64_t>(indices.size(), ShapedType::kDynamic), resultType);

  if (parser.resolveOperand(source, tensorType, result.operands))
    return failure();
  SmallVector<Type> indexTypes(indices.size(),
                               parser.getBuilder().getIndexType());
  if (parser.resolveOperands(indices, indexTypes, parser.getCurrentLocation(),
                             result.operands))
    return failure();

  result.addTypes(resultType);
  return success();
}

void ExtractOp::print(OpAsmPrinter &p) {
  p << ' ';
  p.printOperand(getSource());
  printValueList(p, getIndices());
  p << " : ";
  p.printType(getResult().getType());
}

LogicalResult ExtractOp::verify() {
  auto sourceType = dyn_cast<RankedTensorType>(getSource().getType());
  if (!sourceType)
    return emitOpError("requires ranked tensor source");
  if (static_cast<int64_t>(getIndices().size()) != sourceType.getRank())
    return emitOpError("requires one index operand per tensor dimension");
  if (getResult().getType() != sourceType.getElementType())
    return emitOpError("requires result type to match tensor element type");
  FailureOr<TensorValueSemantics> sourceInfo = getValueSemantics(getSource());
  if (failed(sourceInfo))
    return emitOpError("requires source with dependent_tensor semantics");
  return success();
}

void InsertOp::build(OpBuilder &builder, OperationState &result, Value scalar,
                     Value dest, ValueRange indices) {
  result.addOperands(scalar);
  result.addOperands(dest);
  result.addOperands(indices);
  result.addTypes(dest.getType());
}

ParseResult InsertOp::parse(OpAsmParser &parser, OperationState &result) {
  OpAsmParser::UnresolvedOperand scalar;
  OpAsmParser::UnresolvedOperand dest;
  SmallVector<OpAsmParser::UnresolvedOperand> indices;
  SmallVector<OpAsmParser::UnresolvedOperand> refinementDims;
  Type refinementElementType;
  bool hasRefinement = false;
  Type scalarType;
  Type destType;
  SMLoc refinementLoc;
  if (parser.parseOperand(scalar) || parser.parseKeyword("into") ||
      parser.parseOperand(dest) ||
      parser.parseOperandList(indices, OpAsmParser::Delimiter::Square))
    return failure();

  refinementLoc = parser.getCurrentLocation();
  if (parseOptionalTensorSpec(parser, hasRefinement, refinementDims,
                              refinementElementType) ||
      parser.parseColonType(scalarType) || parser.parseKeyword("into") ||
      parser.parseType(destType))
    return failure();

  auto tensorType = dyn_cast<RankedTensorType>(destType);
  if (!tensorType)
    return parser.emitError(parser.getCurrentLocation(),
                            "expected ranked tensor destination type");
  if (parser.resolveOperand(scalar, scalarType, result.operands) ||
      parser.resolveOperand(dest, destType, result.operands))
    return failure();
  SmallVector<Type> indexTypes(indices.size(),
                               parser.getBuilder().getIndexType());
  if (parser.resolveOperands(indices, indexTypes, parser.getCurrentLocation(),
                             result.operands))
    return failure();

  if (hasRefinement) {
    SmallVector<Value> resolvedDims;
    if (resolveTensorRefinement(parser, refinementLoc, tensorType,
                                refinementDims, refinementElementType,
                                resolvedDims))
      return failure();

    FailureOr<TensorValueSemantics> destInfo =
        getValueSemantics(result.operands[1]);
    if (succeeded(destInfo) &&
        verifyTensorRefinement(
            parser, refinementLoc, resolvedDims, destInfo->dimValues,
            "#tensor assertion must match destination semantics"))
      return failure();
  }

  result.addTypes(destType);
  return success();
}

void InsertOp::print(OpAsmPrinter &p) {
  p << ' ';
  p.printOperand(getScalar());
  p << " into ";
  p.printOperand(getDest());
  printValueList(p, getIndices());
  FailureOr<TensorValueSemantics> destInfo = getValueSemantics(getDest());
  if (succeeded(destInfo)) {
    auto rankedType = cast<RankedTensorType>(getResult().getType());
    p << ' ';
    dependent_tensor::printTensorSpec(p, destInfo->dimValues,
                                      rankedType.getElementType());
  }
  p << " : ";
  p.printType(getScalar().getType());
  p << " into ";
  p.printType(getDest().getType());
}

LogicalResult InsertOp::verify() {
  auto destType = dyn_cast<RankedTensorType>(getDest().getType());
  auto resultType = dyn_cast<RankedTensorType>(getResult().getType());
  if (!destType || !resultType)
    return emitOpError("requires ranked tensor destination and result");
  if (destType != resultType)
    return emitOpError("requires result type to match destination type");
  if (getScalar().getType() != destType.getElementType())
    return emitOpError("requires scalar type to match tensor element type");
  if (static_cast<int64_t>(getIndices().size()) != destType.getRank())
    return emitOpError("requires one index operand per tensor dimension");

  auto destInfo = getValueSemantics(getDest());
  if (failed(destInfo))
    return emitOpError("requires destination with dependent_tensor semantics");
  return success();
}

void InsertOp::walkPropertySSAUses(
    function_ref<void(PropertyOperand &)> callback) {
  (void)callback;
}

void InsertOp::walkDependentTensorPropertyUses(
    function_ref<void(PropertyOperand &)> callback) {
  walkPropertySSAUses(callback);
}

FailureOr<DependentTensorValueSemantics>
InsertOp::getDependentTensorResultSemantics(unsigned resultNumber) {
  if (resultNumber != 0)
    return failure();
  auto resultType = dyn_cast<RankedTensorType>(getResult().getType());
  if (!resultType)
    return failure();
  auto destInfo = getValueSemantics(getDest());
  if (failed(destInfo))
    return failure();
  return buildStored(/*valueIndex=*/0, resultType, destInfo->dimValues);
}

#define GET_OP_CLASSES
#include "mlir/Dialect/DependentTensor/IR/DependentTensorOps.cpp.inc"
