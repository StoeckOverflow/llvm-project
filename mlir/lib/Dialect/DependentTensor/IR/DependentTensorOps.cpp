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
static FailureOr<TensorValueRefinement>
buildValueRefinement(RankedTensorType type, ArrayRef<Value> dimValues) {
  if (type.getRank() != static_cast<int64_t>(dimValues.size()))
    return failure();

  TensorValueRefinement info{type, {}};
  info.dimValues.reserve(dimValues.size());
  for (Value dimValue : dimValues) {
    if (!dimValue || !dimValue.getType().isIndex())
      return failure();
    info.dimValues.push_back(dimValue);
  }
  return info;
}

static DependentTensorValueRefinement buildStored(unsigned valueIndex,
                                                  RankedTensorType type,
                                                  ArrayRef<Value> dimValues) {
  DependentTensorValueRefinement stored;
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
static const DependentTypeValueRefinement *
findStoredRefinement(Range &&range, unsigned valueIndex) {
  for (const DependentTypeValueRefinement &refinement : range)
    if (refinement.valueIndex == valueIndex)
      return &refinement;
  return nullptr;
}

static DependentTensorValueRefinement
convertToTensorRefinement(const DependentTypeValueRefinement &refinement) {
  DependentTensorValueRefinement converted;
  converted.valueIndex = refinement.valueIndex;
  converted.rank = refinement.rank;
  converted.assignDimValues(refinement.getDimValues());
  return converted;
}

static FailureOr<TensorValueRefinement>
getFuncArgRefinement(BlockArgument arg, func::FuncOp func,
                     RankedTensorType rankedType) {
  if (const DependentTypeValueRefinement *stored =
          findStoredRefinement(func.getProperties().dependentTypeArgRefinements,
                               arg.getArgNumber())) {
    if (stored->hasExplicitLayout)
      return failure();
    DependentTensorValueRefinement tensorRef =
        convertToTensorRefinement(*stored);
    return decodeStoredRefinement(arg, tensorRef);
  }
  return failure();
}

static FailureOr<TensorValueRefinement>
getCallResultRefinement(OpResult result, func::CallOp call, func::FuncOp callee,
                        RankedTensorType rankedType) {
  if (const DependentTypeValueRefinement *stored = findStoredRefinement(
          callee.getProperties().dependentTypeResultRefinements,
          result.getResultNumber())) {
    if (stored->hasExplicitLayout)
      return failure();
    SmallVector<Value> mappedDims;
    mappedDims.reserve(stored->dimValues.size());
    for (Value dimValue : stored->getDimValues()) {
      auto arg = dyn_cast<BlockArgument>(dimValue);
      if (!arg || arg.getOwner() != &callee.getBody().front() ||
          arg.getArgNumber() >= call.getNumOperands())
        return failure();
      mappedDims.push_back(call.getOperand(arg.getArgNumber()));
    }
    return buildValueRefinement(rankedType, mappedDims);
  }
  return failure();
}
} // namespace

DependentTensorValueRefinement dependent_tensor::buildStoredRefinement(
    unsigned valueIndex, RankedTensorType type, ArrayRef<Value> dimValues) {
  return buildStored(valueIndex, type, dimValues);
}

FailureOr<TensorValueRefinement> dependent_tensor::decodeStoredRefinement(
    Value value, const DependentTensorValueRefinement &stored) {
  auto rankedType = dyn_cast<RankedTensorType>(value.getType());
  if (!rankedType)
    return failure();
  unsigned valueIndex = getValueIndex(value);
  if (stored.valueIndex != valueIndex || stored.rank != rankedType.getRank())
    return failure();
  return buildValueRefinement(rankedType, stored.getDimValues());
}

FailureOr<TensorValueRefinement>
dependent_tensor::getValueRefinement(Value value) {
  auto rankedType = dyn_cast<RankedTensorType>(value.getType());
  if (!rankedType)
    return failure();

  if (auto arg = dyn_cast<BlockArgument>(value)) {
    auto *block = arg.getOwner();
    auto func =
        dyn_cast_or_null<func::FuncOp>(block ? block->getParentOp() : nullptr);
    if (func && block == &func.getBody().front())
      return getFuncArgRefinement(arg, func, rankedType);

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
    FailureOr<DependentTensorValueRefinement> stored =
        iface.getDependentTensorBlockArgumentRefinement(
            regionNumber, blockNumber, arg.getArgNumber());
    if (failed(stored))
      return failure();
    return decodeStoredRefinement(value, *stored);
  }

  auto result = cast<OpResult>(value);
  Operation *def = result.getOwner();
  if (auto iface = dyn_cast<DependentTensorPropertyOpInterface>(def)) {
    FailureOr<DependentTensorValueRefinement> stored =
        iface.getDependentTensorResultRefinement(result.getResultNumber());
    if (succeeded(stored))
      return decodeStoredRefinement(value, *stored);
  }

  if (auto call = dyn_cast<func::CallOp>(def)) {
    auto callee = SymbolTable::lookupNearestSymbolFrom<func::FuncOp>(
        call, call.getCalleeAttr());
    if (!callee)
      return failure();
    return getCallResultRefinement(result, call, callee, rankedType);
  }

  return failure();
}

bool dependent_tensor::haveEqualRefinements(const TensorValueRefinement &lhs,
                                            const TensorValueRefinement &rhs) {
  return lhs.type == rhs.type && lhs.dimValues == rhs.dimValues;
}

FailureOr<bool> dependent_tensor::haveEqualRefinements(Value lhs, Value rhs) {
  auto lhsInfo = getValueRefinement(lhs);
  auto rhsInfo = getValueRefinement(rhs);
  if (failed(lhsInfo) || failed(rhsInfo))
    return failure();
  return haveEqualRefinements(*lhsInfo, *rhsInfo);
}

FailureOr<bool> dependent_tensor::haveEqualDimRefinements(Value lhs,
                                                          unsigned lhsDim,
                                                          Value rhs,
                                                          unsigned rhsDim) {
  auto lhsInfo = getValueRefinement(lhs);
  auto rhsInfo = getValueRefinement(rhs);
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

static LogicalResult
verifyStoredRefinement(Operation *op, Value value,
                       const DependentTensorValueRefinement &stored) {
  auto rankedType = dyn_cast<RankedTensorType>(value.getType());
  if (!rankedType)
    return op->emitOpError("requires ranked tensor value refinements");
  if (stored.valueIndex != cast<OpResult>(value).getResultNumber())
    return op->emitOpError("has dependent tensor refinements for wrong result");
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
  props.result_refinement =
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
  props.result_refinement = buildStored(
      /*valueIndex=*/0, rankedType, ArrayRef<Value>(resolvedDims));
  return success();
}

SmallVector<Value, 4> MakeOp::getDimValues() {
  return getProperties().result_refinement.getDimValues();
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

  if (failed(verifyStoredRefinement(*this, getResult(),
                                    getProperties().result_refinement)))
    return failure();
  return success();
}

void MakeOp::walkPropertySSAUses(
    function_ref<void(PropertyOperand &)> callback) {
  for (PropertyOperand &operand : getProperties().result_refinement.dimValues)
    callback(operand);
}

void MakeOp::walkDependentTensorPropertyUses(
    function_ref<void(PropertyOperand &)> callback) {
  walkPropertySSAUses(callback);
}

FailureOr<DependentTensorValueRefinement>
MakeOp::getDependentTensorResultRefinement(unsigned resultNumber) {
  if (resultNumber != 0)
    return failure();
  return getProperties().result_refinement;
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

    Value dimensionValue = result.operands[1];
    if (!getConstantDim(dimensionValue))
      return parser.emitError(
          assertedDimLoc,
          "requires constant dimension operand for #dim assertion");

    auto &props = result.getOrAddProperties<DimOp::Properties>();
    props.dim_value_refinement.assignDimValues(resolvedDims);
  }

  result.addTypes(parser.getBuilder().getIndexType());
  return success();
}

void DimOp::print(OpAsmPrinter &p) {
  p << ' ';
  p.printOperand(getSource());
  p << ", ";
  p.printOperand(getDimension());
  SmallVector<Value, 1> assertedDims =
      getProperties().dim_value_refinement.getDimValues();
  if (!assertedDims.empty()) {
    p << ", #dim ";
    p.printOperand(assertedDims.front());
  }
  p << " : ";
  p.printType(getSource().getType());
}

LogicalResult DimOp::verify() {
  auto sourceType = dyn_cast<RankedTensorType>(getSource().getType());
  if (!sourceType)
    return emitOpError("requires ranked tensor source");
  FailureOr<TensorValueRefinement> sourceInfo = getValueRefinement(getSource());
  if (failed(sourceInfo))
    return emitOpError("requires source with dependent_tensor refinements");

  SmallVector<Value, 1> assertedDims =
      getProperties().dim_value_refinement.getDimValues();
  if (assertedDims.empty())
    return success();
  if (assertedDims.size() != 1)
    return emitOpError("requires at most one dependent dimension assertion");
  if (!assertedDims.front() || !assertedDims.front().getType().isIndex())
    return emitOpError("requires index-typed dependent dimension assertion");

  std::optional<uint64_t> dim = getConstantDim(getDimension());
  if (!dim)
    return emitOpError(
        "requires constant dimension operand for #dim assertion");
  if (*dim >= sourceInfo->dimValues.size())
    return emitOpError("requires #dim assertion within source rank");
  if (assertedDims.front() != sourceInfo->dimValues[*dim])
    return emitOpError("#dim assertion must match source refinements");
  return success();
}

void DimOp::walkPropertySSAUses(
    function_ref<void(PropertyOperand &)> callback) {
  for (PropertyOperand &operand :
       getProperties().dim_value_refinement.dimValues)
    callback(operand);
}

OpFoldResult DimOp::fold(FoldAdaptor adaptor) {
  auto dimAttr = dyn_cast_or_null<IntegerAttr>(adaptor.getDimension());
  if (!dimAttr)
    return {};
  uint64_t dim = dimAttr.getValue().getZExtValue();
  FailureOr<TensorValueRefinement> sourceInfo = getValueRefinement(getSource());
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
  FailureOr<TensorValueRefinement> sourceInfo = getValueRefinement(getSource());
  if (failed(sourceInfo))
    return emitOpError("requires source with dependent_tensor refinements");
  return success();
}

void InsertOp::build(OpBuilder &builder, OperationState &result, Value scalar,
                     Value dest, ValueRange indices,
                     ValueRange resultDimValues) {
  result.addOperands(scalar);
  result.addOperands(dest);
  result.addOperands(indices);
  result.addTypes(dest.getType());

  auto resultType = cast<RankedTensorType>(dest.getType());
  auto &props = result.getOrAddProperties<InsertOp::Properties>();
  SmallVector<Value> dims(resultDimValues.begin(), resultDimValues.end());
  props.result_refinement =
      buildStored(/*valueIndex=*/0, resultType, ArrayRef<Value>(dims));
}

void InsertOp::build(OpBuilder &builder, OperationState &result, Value scalar,
                     Value dest, ValueRange indices) {
  FailureOr<TensorValueRefinement> destInfo = getValueRefinement(dest);
  assert(succeeded(destInfo) &&
         "insert convenience builder requires destination refinements");
  build(builder, result, scalar, dest, indices, destInfo->dimValues);
}

ParseResult InsertOp::parse(OpAsmParser &parser, OperationState &result) {
  OpAsmParser::UnresolvedOperand scalar;
  OpAsmParser::UnresolvedOperand dest;
  SmallVector<OpAsmParser::UnresolvedOperand> indices;
  SmallVector<OpAsmParser::UnresolvedOperand> resultDims;
  Type resultElementType;
  Type scalarType;
  Type destType;
  SMLoc specLoc;
  if (parser.parseOperand(scalar) || parser.parseKeyword("into") ||
      parser.parseOperand(dest) ||
      parser.parseOperandList(indices, OpAsmParser::Delimiter::Square))
    return failure();

  specLoc = parser.getCurrentLocation();
  if (dependent_tensor::parseTensorSpec(parser, resultDims,
                                        resultElementType) ||
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

  SmallVector<Value> resolvedDims;
  if (resolveTensorRefinement(parser, specLoc, tensorType, resultDims,
                              resultElementType, resolvedDims))
    return failure();

  result.addTypes(destType);
  auto &props = result.getOrAddProperties<InsertOp::Properties>();
  props.result_refinement = buildStored(
      /*valueIndex=*/0, tensorType, ArrayRef<Value>(resolvedDims));
  return success();
}

void InsertOp::print(OpAsmPrinter &p) {
  p << ' ';
  p.printOperand(getScalar());
  p << " into ";
  p.printOperand(getDest());
  printValueList(p, getIndices());
  auto rankedType = cast<RankedTensorType>(getResult().getType());
  p << ' ';
  dependent_tensor::printTensorSpec(
      p, getProperties().result_refinement.getDimValues(),
      rankedType.getElementType());
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

  if (failed(verifyStoredRefinement(*this, getResult(),
                                    getProperties().result_refinement)))
    return failure();

  auto destInfo = getValueRefinement(getDest());
  if (failed(destInfo))
    return emitOpError(
        "requires destination with dependent_tensor refinements");
  FailureOr<TensorValueRefinement> resultInfo =
      decodeStoredRefinement(getResult(), getProperties().result_refinement);
  if (failed(resultInfo) || !haveEqualRefinements(*resultInfo, *destInfo))
    return emitOpError(
        "stored result refinements must match destination refinements");
  return success();
}

void InsertOp::walkPropertySSAUses(
    function_ref<void(PropertyOperand &)> callback) {
  for (PropertyOperand &operand : getProperties().result_refinement.dimValues)
    callback(operand);
}

void InsertOp::walkDependentTensorPropertyUses(
    function_ref<void(PropertyOperand &)> callback) {
  walkPropertySSAUses(callback);
}

FailureOr<DependentTensorValueRefinement>
InsertOp::getDependentTensorResultRefinement(unsigned resultNumber) {
  if (resultNumber != 0)
    return failure();
  return getProperties().result_refinement;
}

LogicalResult
dependent_tensor::refreshDependentTensorForwardingRefinement(Operation *op) {
  if (!op)
    return failure();
  auto insertOp = dyn_cast<InsertOp>(op);
  if (!insertOp)
    return success();

  auto resultType = dyn_cast<RankedTensorType>(insertOp.getResult().getType());
  if (!resultType)
    return failure();
  FailureOr<TensorValueRefinement> destInfo =
      getValueRefinement(insertOp.getDest());
  if (failed(destInfo))
    return failure();

  insertOp.getProperties().result_refinement =
      buildStored(/*valueIndex=*/0, resultType, destInfo->dimValues);
  reattachPropertyOperands(insertOp);
  return success();
}

#define GET_OP_CLASSES
#include "mlir/Dialect/DependentTensor/IR/DependentTensorOps.cpp.inc"
