//===- DependentTensorOps.cpp - DependentTensor op definitions ------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/DependentTensor/IR/DependentTensor.h"
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

static DependentTensorValueSemantics
buildStored(unsigned valueIndex, RankedTensorType type,
            ArrayRef<Value> dimValues) {
  DependentTensorValueSemantics stored;
  stored.valueIndex = valueIndex;
  stored.rank = type.getRank();
  stored.dimValues.assign(dimValues.begin(), dimValues.end());
  return stored;
}

static DependentTensorValueSemantics
buildStoredFromRange(unsigned valueIndex, RankedTensorType type,
                     ValueRange dimValues) {
  SmallVector<Value> values(dimValues.begin(), dimValues.end());
  return buildStored(valueIndex, type, ArrayRef<Value>(values));
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
getCallResultSemantics(OpResult result, func::CallOp call,
                       func::FuncOp callee, RankedTensorType rankedType) {
  if (const DependentTensorValueSemantics *stored =
          findStoredSemantics(callee.getProperties().dependentTensorResultSemantics,
                              result.getResultNumber())) {
    SmallVector<Value> mappedDims;
    mappedDims.reserve(stored->dimValues.size());
    for (Value dimValue : stored->dimValues) {
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
  unsigned valueIndex = 0;
  if (auto result = dyn_cast<OpResult>(value))
    valueIndex = result.getResultNumber();
  else if (auto arg = dyn_cast<BlockArgument>(value))
    valueIndex = arg.getArgNumber();
  if (stored.valueIndex != valueIndex || stored.rank != rankedType.getRank())
    return failure();
  return buildValueSemantics(rankedType, stored.dimValues);
}

FailureOr<TensorValueSemantics> dependent_tensor::getValueSemantics(Value value) {
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
  if (lhsDim >= lhsInfo->dimValues.size() || rhsDim >= rhsInfo->dimValues.size())
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

static LogicalResult
verifyStoredSemantics(Operation *op, Value value,
                      const DependentTensorValueSemantics &stored,
                      ValueRange dimOperands = {}) {
  auto rankedType = dyn_cast<RankedTensorType>(value.getType());
  if (!rankedType)
    return op->emitOpError("requires ranked tensor value semantics");
  if (stored.valueIndex != cast<OpResult>(value).getResultNumber())
    return op->emitOpError("has dependent tensor semantics for wrong result");
  if (stored.rank != rankedType.getRank())
    return op->emitOpError("requires dependent tensor rank to match result rank");
  if (stored.dimValues.size() != static_cast<size_t>(rankedType.getRank()))
    return op->emitOpError("requires one dependent dimension value per result dimension");
  if (!dimOperands.empty() && !llvm::equal(stored.dimValues, dimOperands))
    return op->emitOpError("requires dependent dimension operands to match stored semantics");
  for (auto [dim, dimValue] : llvm::enumerate(stored.dimValues)) {
    if (!rankedType.isDynamicDim(dim))
      return op->emitOpError("requires dependent result dimensions to be dynamic");
    if (!dimValue || !dimValue.getType().isIndex())
      return op->emitOpError("requires index-typed dependent dimension values");
  }
  return success();
}
} // namespace

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
    return parser.emitError(specLoc,
                            "dependent tensor element type must match result type");

  SmallVector<Type> dimTypes(dims.size(), parser.getBuilder().getIndexType());
  if (parser.resolveOperands(dims, dimTypes, parser.getCurrentLocation(),
                             result.operands))
    return failure();

  result.addTypes(resultType);
  auto &props = result.getOrAddProperties<MakeOp::Properties>();
  props.result_semantics = buildStored(
      /*valueIndex=*/0, rankedType, ArrayRef<Value>(result.operands));
  return success();
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

  if (static_cast<int64_t>(getDimValues().size()) != rankedType.getRank())
    return emitOpError("requires one index dimension operand per result dimension");

  if (failed(verifyStoredSemantics(*this, getResult(),
                                   getProperties().result_semantics,
                                   getDimValues())))
    return failure();
  return success();
}

void MakeOp::walkPropertySSAValues(function_ref<void(Value &)> callback) {
  for (Value &value : getProperties().result_semantics.dimValues)
    callback(value);
}

void MakeOp::walkDependentTensorPropertyValues(
    function_ref<void(Value &)> callback) {
  walkPropertySSAValues(callback);
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
  Type sourceType;
  if (parser.parseOperand(source) || parser.parseComma() ||
      parser.parseOperand(dimension) || parser.parseColonType(sourceType))
    return failure();
  if (parser.resolveOperand(source, sourceType, result.operands) ||
      parser.resolveOperand(dimension, parser.getBuilder().getIndexType(),
                            result.operands))
    return failure();
  result.addTypes(parser.getBuilder().getIndexType());
  return success();
}

void DimOp::print(OpAsmPrinter &p) {
  p << ' ';
  p.printOperand(getSource());
  p << ", ";
  p.printOperand(getDimension());
  p << " : ";
  p.printType(getSource().getType());
}

LogicalResult DimOp::verify() {
  auto sourceType = dyn_cast<RankedTensorType>(getSource().getType());
  if (!sourceType)
    return emitOpError("requires ranked tensor source");
  if (failed(getValueSemantics(getSource())))
    return emitOpError("requires source with dependent_tensor semantics");
  return success();
}

ParseResult ExtractOp::parse(OpAsmParser &parser, OperationState &result) {
  OpAsmParser::UnresolvedOperand source;
  SmallVector<OpAsmParser::UnresolvedOperand> indices;
  Type sourceType;
  if (parser.parseOperand(source) ||
      parser.parseOperandList(indices, OpAsmParser::Delimiter::Square) ||
      parser.parseColonType(sourceType))
    return failure();

  auto tensorType = dyn_cast<RankedTensorType>(sourceType);
  if (!tensorType)
    return parser.emitError(parser.getCurrentLocation(),
                            "expected ranked tensor source type");
  if (parser.resolveOperand(source, sourceType, result.operands))
    return failure();
  SmallVector<Type> indexTypes(indices.size(), parser.getBuilder().getIndexType());
  if (parser.resolveOperands(indices, indexTypes, parser.getCurrentLocation(),
                             result.operands))
    return failure();
  result.addTypes(tensorType.getElementType());
  return success();
}

void ExtractOp::print(OpAsmPrinter &p) {
  p << ' ';
  p.printOperand(getSource());
  printValueList(p, getIndices());
  p << " : ";
  p.printType(getSource().getType());
}

LogicalResult ExtractOp::verify() {
  auto sourceType = dyn_cast<RankedTensorType>(getSource().getType());
  if (!sourceType)
    return emitOpError("requires ranked tensor source");
  if (static_cast<int64_t>(getIndices().size()) != sourceType.getRank())
    return emitOpError("requires one index operand per tensor dimension");
  if (getResult().getType() != sourceType.getElementType())
    return emitOpError("requires result type to match tensor element type");
  if (failed(getValueSemantics(getSource())))
    return emitOpError("requires source with dependent_tensor semantics");
  return success();
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
  if (static_cast<int64_t>(resultDims.size()) != tensorType.getRank())
    return parser.emitError(specLoc, "dependent tensor rank mismatch");
  if (resultElementType != tensorType.getElementType())
    return parser.emitError(specLoc,
                            "dependent tensor element type must match value type");
  if (parser.resolveOperand(scalar, scalarType, result.operands) ||
      parser.resolveOperand(dest, destType, result.operands))
    return failure();
  SmallVector<Type> indexTypes(indices.size(), parser.getBuilder().getIndexType());
  if (parser.resolveOperands(indices, indexTypes, parser.getCurrentLocation(),
                             result.operands))
    return failure();
  SmallVector<Type> dimTypes(resultDims.size(), parser.getBuilder().getIndexType());
  if (parser.resolveOperands(resultDims, dimTypes, parser.getCurrentLocation(),
                             result.operands))
    return failure();
  result.addAttribute(
      InsertOp::getOperandSegmentSizeAttr(),
      parser.getBuilder().getDenseI32ArrayAttr(
          {1, 1, static_cast<int32_t>(indices.size()),
           static_cast<int32_t>(resultDims.size())}));
  result.addTypes(destType);

  auto &props = result.getOrAddProperties<InsertOp::Properties>();
  ValueRange dimValues =
      ArrayRef<Value>(result.operands).drop_front(2 + indices.size());
  props.result_semantics =
      buildStoredFromRange(/*valueIndex=*/0, tensorType, dimValues);
  return success();
}

void InsertOp::print(OpAsmPrinter &p) {
  p << ' ';
  p.printOperand(getScalar());
  p << " into ";
  p.printOperand(getDest());
  printValueList(p, getIndices());
  p << " ";
  auto rankedType = cast<RankedTensorType>(getResult().getType());
  dependent_tensor::printTensorSpec(p, getResultDimValues(),
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

  auto destInfo = getValueSemantics(getDest());
  if (failed(destInfo))
    return emitOpError("requires destination with dependent_tensor semantics");
  if (failed(verifyStoredSemantics(*this, getResult(),
                                   getProperties().result_semantics,
                                   getResultDimValues())))
    return failure();
  if (getProperties().result_semantics.dimValues != destInfo->dimValues)
    return emitOpError("stored result semantics must match destination semantics");
  return success();
}

void InsertOp::walkPropertySSAValues(function_ref<void(Value &)> callback) {
  for (Value &value : getProperties().result_semantics.dimValues)
    callback(value);
}

void InsertOp::walkDependentTensorPropertyValues(
    function_ref<void(Value &)> callback) {
  walkPropertySSAValues(callback);
}

FailureOr<DependentTensorValueSemantics>
InsertOp::getDependentTensorResultSemantics(unsigned resultNumber) {
  if (resultNumber != 0)
    return failure();
  return getProperties().result_semantics;
}

#define GET_OP_CLASSES
#include "mlir/Dialect/DependentTensor/IR/DependentTensorOps.cpp.inc"
