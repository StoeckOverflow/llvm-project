//===- DependentMemRefOps.cpp - DependentMemRef op definitions ------------===//

#include "mlir/Dialect/DependentMemRef/IR/DependentMemRef.h"
#include "mlir/IR/Builders.h"
#include "mlir/IR/Matchers.h"
#include "llvm/ADT/STLExtras.h"

using namespace mlir;
using namespace mlir::dependent_memref;

namespace {
struct ParsedMemRefSpec {
  SmallVector<OpAsmParser::UnresolvedOperand> dims;
  SmallVector<OpAsmParser::UnresolvedOperand> strides;
  Type elementType;
  int64_t offset = 0;
  bool hasExplicitLayout = false;
  SMLoc loc;
};

static ParseResult parseMemRefSpec(OpAsmParser &parser,
                                   ParsedMemRefSpec &spec) {
  spec.loc = parser.getCurrentLocation();
  if (parser.parseHashKeyword("memref") || parser.parseLess())
    return failure();
  if (parser.parseCommaSeparatedList(OpAsmParser::Delimiter::Square,
                                     [&]() -> ParseResult {
                                       OpAsmParser::UnresolvedOperand dim;
                                       if (parser.parseOperand(dim))
                                         return failure();
                                       spec.dims.push_back(dim);
                                       return success();
                                     }))
    return failure();
  if (parser.parseComma() || parser.parseType(spec.elementType))
    return failure();

  if (succeeded(parser.parseOptionalComma())) {
    spec.hasExplicitLayout = true;
    if (parser.parseKeyword("offset") || parser.parseColon() ||
        parser.parseInteger(spec.offset) || parser.parseComma() ||
        parser.parseKeyword("strides") || parser.parseColon())
      return failure();
    if (parser.parseCommaSeparatedList(OpAsmParser::Delimiter::Square,
                                       [&]() -> ParseResult {
                                         OpAsmParser::UnresolvedOperand stride;
                                         if (parser.parseOperand(stride))
                                           return failure();
                                         spec.strides.push_back(stride);
                                         return success();
                                       }))
      return failure();
  }
  return parser.parseGreater();
}

static ParseResult
resolveMemRefSpec(OpAsmParser &parser, MemRefType type,
                  const ParsedMemRefSpec &spec, unsigned valueIndex,
                  DependentMemRefValueRefinement &refinement) {
  if (static_cast<int64_t>(spec.dims.size()) != type.getRank())
    return parser.emitError(spec.loc, "dependent memref rank mismatch");
  if (spec.elementType != type.getElementType())
    return parser.emitError(
        spec.loc, "dependent memref element type must match value type");
  if (spec.hasExplicitLayout &&
      static_cast<int64_t>(spec.strides.size()) != type.getRank())
    return parser.emitError(spec.loc,
                            "dependent memref stride count must match rank");

  SmallVector<Type> indexTypes(spec.dims.size(),
                               parser.getBuilder().getIndexType());
  SmallVector<Value> resolvedDims;
  if (parser.resolveOperands(spec.dims, indexTypes, parser.getCurrentLocation(),
                             resolvedDims))
    return failure();

  SmallVector<Value> resolvedStrides;
  if (spec.hasExplicitLayout) {
    SmallVector<Type> strideTypes(spec.strides.size(),
                                  parser.getBuilder().getIndexType());
    if (parser.resolveOperands(spec.strides, strideTypes,
                               parser.getCurrentLocation(), resolvedStrides))
      return failure();
  }

  refinement.valueIndex = valueIndex;
  refinement.rank = type.getRank();
  refinement.offset = spec.offset;
  refinement.hasExplicitLayout = spec.hasExplicitLayout;
  refinement.assignDimValues(resolvedDims);
  refinement.assignStrideValues(resolvedStrides);
  return success();
}

static void printValueList(OpAsmPrinter &printer, ValueRange values) {
  printer << "[";
  llvm::interleaveComma(values, printer,
                        [&](Value value) { printer.printOperand(value); });
  printer << "]";
}

static void walkRefinement(DependentMemRefValueRefinement &refinement,
                           function_ref<void(PropertyOperand &)> callback) {
  for (PropertyOperand &operand : refinement.dimValues)
    callback(operand);
  for (PropertyOperand &operand : refinement.strideValues)
    callback(operand);
}

static FailureOr<MemRefValueRefinement>
decodeStored(Value value, const DependentMemRefValueRefinement &stored) {
  auto type = dyn_cast<MemRefType>(value.getType());
  if (!type || stored.rank != type.getRank())
    return failure();
  MemRefValueRefinement info{type, stored.getDimValues(), stored.offset,
                             stored.getStrideValues(),
                             stored.hasExplicitLayout};
  if (info.dimValues.size() != static_cast<size_t>(type.getRank()))
    return failure();
  if (info.hasExplicitLayout &&
      info.strideValues.size() != static_cast<size_t>(type.getRank()))
    return failure();
  return info;
}
} // namespace

DependentMemRefValueRefinement
dependent_memref::buildStoredRefinement(unsigned valueIndex, MemRefType type,
                                        ValueRange dimValues, int64_t offset,
                                        ValueRange strideValues) {
  DependentMemRefValueRefinement stored;
  stored.valueIndex = valueIndex;
  stored.rank = type.getRank();
  stored.offset = offset;
  stored.hasExplicitLayout = !strideValues.empty();
  stored.assignDimValues(dimValues);
  stored.assignStrideValues(strideValues);
  return stored;
}

FailureOr<MemRefValueRefinement> dependent_memref::decodeStoredRefinement(
    Value value, const DependentMemRefValueRefinement &stored) {
  return decodeStored(value, stored);
}

LogicalResult dependent_memref::verifyStoredRefinement(
    Operation *op, Value value, const DependentMemRefValueRefinement &stored) {
  auto type = dyn_cast<MemRefType>(value.getType());
  if (!type)
    return op->emitOpError("requires memref value refinements");
  if (stored.rank != type.getRank())
    return op->emitOpError(
        "requires dependent memref rank to match value rank");
  if (stored.dimValues.size() != static_cast<size_t>(type.getRank()))
    return op->emitOpError(
        "requires one dependent dimension value per memref dimension");
  if (stored.hasExplicitLayout &&
      stored.strideValues.size() != static_cast<size_t>(type.getRank()))
    return op->emitOpError(
        "requires one dependent stride value per memref dimension");
  for (auto [dim, operand] : llvm::enumerate(stored.dimValues)) {
    if (!type.isDynamicDim(dim))
      return op->emitOpError(
          "requires dependent dimensions to correspond to dynamic memref dims");
    Value dimValue = operand.get();
    if (!dimValue || !dimValue.getType().isIndex())
      return op->emitOpError("requires index-typed dependent dimensions");
  }
  for (const PropertyOperand &operand : stored.strideValues) {
    Value strideValue = operand.get();
    if (!strideValue || !strideValue.getType().isIndex())
      return op->emitOpError("requires index-typed dependent strides");
  }
  return success();
}

void dependent_memref::printMemRefSpec(
    OpAsmPrinter &printer, const DependentMemRefValueRefinement &refinement,
    Type elementType) {
  printer << "#memref<";
  printValueList(printer, refinement.getDimValues());
  printer << ", ";
  printer.printType(elementType);
  if (refinement.hasExplicitLayout) {
    printer << ", offset: " << refinement.offset << ", strides: ";
    printValueList(printer, refinement.getStrideValues());
  }
  printer << ">";
}

ParseResult AllocOp::parse(OpAsmParser &parser, OperationState &result) {
  ParsedMemRefSpec spec;
  Type resultType;
  if (parseMemRefSpec(parser, spec) || parser.parseColonType(resultType))
    return failure();
  auto memrefType = dyn_cast<MemRefType>(resultType);
  if (!memrefType)
    return parser.emitError(parser.getCurrentLocation(),
                            "expected memref result type");
  auto &props = result.getOrAddProperties<AllocOp::Properties>();
  if (resolveMemRefSpec(parser, memrefType, spec, 0, props.result_refinement))
    return failure();
  result.addTypes(resultType);
  return success();
}

void AllocOp::print(OpAsmPrinter &p) {
  p << " ";
  auto type = cast<MemRefType>(getMemref().getType());
  printMemRefSpec(p, getProperties().result_refinement, type.getElementType());
  p << " : ";
  p.printType(type);
}

LogicalResult AllocOp::verify() {
  return verifyStoredRefinement(*this, getMemref(),
                                getProperties().result_refinement);
}

void AllocOp::walkPropertySSAUses(function_ref<void(PropertyOperand &)> cb) {
  walkRefinement(getProperties().result_refinement, cb);
}

ParseResult ReinterpretCastOp::parse(OpAsmParser &parser,
                                     OperationState &result) {
  OpAsmParser::UnresolvedOperand source;
  ParsedMemRefSpec spec;
  Type sourceType, resultType;
  if (parser.parseOperand(source) || parser.parseComma())
    return failure();
  if (parseMemRefSpec(parser, spec) || parser.parseColonType(sourceType) ||
      parser.parseKeyword("to") || parser.parseType(resultType))
    return failure();
  auto memrefType = dyn_cast<MemRefType>(resultType);
  if (!memrefType)
    return parser.emitError(parser.getCurrentLocation(),
                            "expected memref result type");
  if (parser.resolveOperand(source, sourceType, result.operands))
    return failure();
  auto &props = result.getOrAddProperties<ReinterpretCastOp::Properties>();
  if (resolveMemRefSpec(parser, memrefType, spec, 0, props.result_refinement))
    return failure();
  result.addTypes(resultType);
  return success();
}

void ReinterpretCastOp::print(OpAsmPrinter &p) {
  p << " ";
  p.printOperand(getSource());
  p << ", ";
  auto type = cast<MemRefType>(getResult().getType());
  printMemRefSpec(p, getProperties().result_refinement, type.getElementType());
  p << " : ";
  p.printType(getSource().getType());
  p << " to ";
  p.printType(getResult().getType());
}

LogicalResult ReinterpretCastOp::verify() {
  auto srcType = dyn_cast<MemRefType>(getSource().getType());
  auto resType = dyn_cast<MemRefType>(getResult().getType());
  if (!srcType || !resType)
    return emitOpError("requires memref source and result");
  if (srcType.getElementType() != resType.getElementType())
    return emitOpError("requires matching source and result element types");
  return verifyStoredRefinement(*this, getResult(),
                                getProperties().result_refinement);
}

void ReinterpretCastOp::walkPropertySSAUses(
    function_ref<void(PropertyOperand &)> cb) {
  walkRefinement(getProperties().result_refinement, cb);
}

ParseResult CastOp::parse(OpAsmParser &parser, OperationState &result) {
  OpAsmParser::UnresolvedOperand source;
  ParsedMemRefSpec spec;
  Type sourceType, resultType;
  if (parser.parseOperand(source) || parser.parseComma())
    return failure();
  if (parseMemRefSpec(parser, spec) || parser.parseColonType(sourceType) ||
      parser.parseKeyword("to") || parser.parseType(resultType))
    return failure();
  auto memrefType = dyn_cast<MemRefType>(resultType);
  if (!memrefType)
    return parser.emitError(parser.getCurrentLocation(),
                            "expected memref result type");
  if (parser.resolveOperand(source, sourceType, result.operands))
    return failure();
  auto &props = result.getOrAddProperties<CastOp::Properties>();
  if (resolveMemRefSpec(parser, memrefType, spec, 0, props.result_refinement))
    return failure();
  result.addTypes(resultType);
  return success();
}

void CastOp::print(OpAsmPrinter &p) {
  p << " ";
  p.printOperand(getSource());
  p << ", ";
  auto type = cast<MemRefType>(getResult().getType());
  printMemRefSpec(p, getProperties().result_refinement, type.getElementType());
  p << " : ";
  p.printType(getSource().getType());
  p << " to ";
  p.printType(getResult().getType());
}

LogicalResult CastOp::verify() {
  auto srcType = dyn_cast<MemRefType>(getSource().getType());
  auto resType = dyn_cast<MemRefType>(getResult().getType());
  if (!srcType || !resType)
    return emitOpError("requires memref source and result");
  if (srcType.getElementType() != resType.getElementType())
    return emitOpError("requires matching source and result element types");
  return verifyStoredRefinement(*this, getResult(),
                                getProperties().result_refinement);
}

void CastOp::walkPropertySSAUses(function_ref<void(PropertyOperand &)> cb) {
  walkRefinement(getProperties().result_refinement, cb);
}

static ParseResult
parseSourceRefinedOp(OpAsmParser &parser, OperationState &result,
                     OpAsmParser::UnresolvedOperand &source,
                     SmallVectorImpl<OpAsmParser::UnresolvedOperand> *indices,
                     Type &sourceType, Type *resultType,
                     DependentMemRefValueRefinement &refinement) {
  ParsedMemRefSpec spec;
  if (parser.parseOperand(source))
    return failure();
  if (indices &&
      parser.parseOperandList(*indices, OpAsmParser::Delimiter::Square))
    return failure();
  if (parseMemRefSpec(parser, spec) || parser.parseColonType(sourceType))
    return failure();
  if (resultType) {
    if (parser.parseArrow() || parser.parseType(*resultType))
      return failure();
  }
  auto memrefType = dyn_cast<MemRefType>(sourceType);
  if (!memrefType)
    return parser.emitError(parser.getCurrentLocation(),
                            "expected memref source type");
  if (resolveMemRefSpec(parser, memrefType, spec, 0, refinement))
    return failure();
  return success();
}

ParseResult DimOp::parse(OpAsmParser &parser, OperationState &result) {
  OpAsmParser::UnresolvedOperand source, dimension;
  Type sourceType;
  if (parser.parseOperand(source) || parser.parseComma() ||
      parser.parseOperand(dimension) || parser.parseComma())
    return failure();
  ParsedMemRefSpec spec;
  if (parseMemRefSpec(parser, spec) || parser.parseColonType(sourceType))
    return failure();
  if (parser.resolveOperand(source, sourceType, result.operands) ||
      parser.resolveOperand(dimension, parser.getBuilder().getIndexType(),
                            result.operands))
    return failure();
  auto memrefType = dyn_cast<MemRefType>(sourceType);
  if (!memrefType)
    return parser.emitError(parser.getCurrentLocation(),
                            "expected memref source type");
  auto &props = result.getOrAddProperties<DimOp::Properties>();
  if (resolveMemRefSpec(parser, memrefType, spec, 0, props.source_refinement))
    return failure();
  result.addTypes(parser.getBuilder().getIndexType());
  return success();
}

void DimOp::print(OpAsmPrinter &p) {
  p << " ";
  p.printOperand(getSource());
  p << ", ";
  p.printOperand(getDimension());
  p << ", ";
  auto type = cast<MemRefType>(getSource().getType());
  printMemRefSpec(p, getProperties().source_refinement, type.getElementType());
  p << " : ";
  p.printType(type);
}

LogicalResult DimOp::verify() {
  return verifyStoredRefinement(*this, getSource(),
                                getProperties().source_refinement);
}

void DimOp::walkPropertySSAUses(function_ref<void(PropertyOperand &)> cb) {
  walkRefinement(getProperties().source_refinement, cb);
}

OpFoldResult DimOp::fold(FoldAdaptor adaptor) {
  auto dimAttr = dyn_cast_or_null<IntegerAttr>(adaptor.getDimension());
  if (!dimAttr)
    return {};
  uint64_t dim = dimAttr.getValue().getZExtValue();
  auto dims = getProperties().source_refinement.getDimValues();
  if (dim >= dims.size())
    return {};
  return dims[dim];
}

ParseResult DimExactOp::parse(OpAsmParser &parser, OperationState &result) {
  OpAsmParser::UnresolvedOperand source;
  Type sourceType;
  IntegerAttr axis;
  if (parser.parseOperand(source) || parser.parseKeyword("axis") ||
      parser.parseLParen() || parser.parseAttribute(axis) ||
      parser.parseRParen())
    return failure();
  ParsedMemRefSpec spec;
  if (parseMemRefSpec(parser, spec) || parser.parseColonType(sourceType))
    return failure();
  if (parser.resolveOperand(source, sourceType, result.operands))
    return failure();
  auto memrefType = dyn_cast<MemRefType>(sourceType);
  if (!memrefType)
    return parser.emitError(parser.getCurrentLocation(),
                            "expected memref source type");
  auto &props = result.getOrAddProperties<DimExactOp::Properties>();
  props.axis = axis;
  if (resolveMemRefSpec(parser, memrefType, spec, 0, props.source_refinement))
    return failure();
  result.addTypes(parser.getBuilder().getIndexType());
  return success();
}

void DimExactOp::print(OpAsmPrinter &p) {
  p << " ";
  p.printOperand(getSource());
  p << " axis(" << getAxis() << ") ";
  auto type = cast<MemRefType>(getSource().getType());
  printMemRefSpec(p, getProperties().source_refinement, type.getElementType());
  p << " : ";
  p.printType(type);
}

LogicalResult DimExactOp::verify() {
  if (failed(verifyStoredRefinement(*this, getSource(),
                                    getProperties().source_refinement)))
    return failure();
  int64_t axis = getAxis();
  if (axis < 0 || axis >= getProperties().source_refinement.rank)
    return emitOpError("requires axis within source rank");
  return success();
}

void DimExactOp::walkPropertySSAUses(function_ref<void(PropertyOperand &)> cb) {
  walkRefinement(getProperties().source_refinement, cb);
}

OpFoldResult DimExactOp::fold(FoldAdaptor adaptor) {
  int64_t axis = getAxis();
  auto dims = getProperties().source_refinement.getDimValues();
  if (axis < 0 || static_cast<size_t>(axis) >= dims.size())
    return {};
  return dims[axis];
}

ParseResult LoadOp::parse(OpAsmParser &parser, OperationState &result) {
  OpAsmParser::UnresolvedOperand source;
  SmallVector<OpAsmParser::UnresolvedOperand> indices;
  Type sourceType, resultType;
  auto &props = result.getOrAddProperties<LoadOp::Properties>();
  if (parseSourceRefinedOp(parser, result, source, &indices, sourceType,
                           &resultType, props.source_refinement))
    return failure();
  if (parser.resolveOperand(source, sourceType, result.operands))
    return failure();
  SmallVector<Type> indexTypes(indices.size(),
                               parser.getBuilder().getIndexType());
  if (parser.resolveOperands(indices, indexTypes, parser.getCurrentLocation(),
                             result.operands))
    return failure();
  result.addTypes(resultType);
  return success();
}

void LoadOp::print(OpAsmPrinter &p) {
  p << " ";
  p.printOperand(getSource());
  printValueList(p, getIndices());
  p << " ";
  auto type = cast<MemRefType>(getSource().getType());
  printMemRefSpec(p, getProperties().source_refinement, type.getElementType());
  p << " : ";
  p.printType(type);
  p << " -> ";
  p.printType(getResult().getType());
}

LogicalResult LoadOp::verify() {
  auto type = dyn_cast<MemRefType>(getSource().getType());
  if (!type)
    return emitOpError("requires memref source");
  if (static_cast<int64_t>(getIndices().size()) != type.getRank())
    return emitOpError("requires one index per memref dimension");
  if (getResult().getType() != type.getElementType())
    return emitOpError("requires result type to match memref element type");
  return verifyStoredRefinement(*this, getSource(),
                                getProperties().source_refinement);
}

void LoadOp::walkPropertySSAUses(function_ref<void(PropertyOperand &)> cb) {
  walkRefinement(getProperties().source_refinement, cb);
}

ParseResult StoreOp::parse(OpAsmParser &parser, OperationState &result) {
  OpAsmParser::UnresolvedOperand value, source;
  SmallVector<OpAsmParser::UnresolvedOperand> indices;
  Type valueType, sourceType;
  if (parser.parseOperand(value) || parser.parseComma())
    return failure();
  auto &props = result.getOrAddProperties<StoreOp::Properties>();
  if (parseSourceRefinedOp(parser, result, source, &indices, sourceType,
                           nullptr, props.source_refinement) ||
      parser.parseComma() || parser.parseType(valueType))
    return failure();
  if (parser.resolveOperand(value, valueType, result.operands) ||
      parser.resolveOperand(source, sourceType, result.operands))
    return failure();
  SmallVector<Type> indexTypes(indices.size(),
                               parser.getBuilder().getIndexType());
  if (parser.resolveOperands(indices, indexTypes, parser.getCurrentLocation(),
                             result.operands))
    return failure();
  return success();
}

void StoreOp::print(OpAsmPrinter &p) {
  p << " ";
  p.printOperand(getValue());
  p << ", ";
  p.printOperand(getSource());
  printValueList(p, getIndices());
  p << " ";
  auto type = cast<MemRefType>(getSource().getType());
  printMemRefSpec(p, getProperties().source_refinement, type.getElementType());
  p << " : ";
  p.printType(type);
  p << ", ";
  p.printType(getValue().getType());
}

LogicalResult StoreOp::verify() {
  auto type = dyn_cast<MemRefType>(getSource().getType());
  if (!type)
    return emitOpError("requires memref source");
  if (static_cast<int64_t>(getIndices().size()) != type.getRank())
    return emitOpError("requires one index per memref dimension");
  if (getValue().getType() != type.getElementType())
    return emitOpError(
        "requires stored value type to match memref element type");
  return verifyStoredRefinement(*this, getSource(),
                                getProperties().source_refinement);
}

void StoreOp::walkPropertySSAUses(function_ref<void(PropertyOperand &)> cb) {
  walkRefinement(getProperties().source_refinement, cb);
}

void DeallocOp::print(OpAsmPrinter &p) {
  p << " ";
  p.printOperand(getMemref());
  p << " : ";
  p.printType(getMemref().getType());
}

ParseResult DeallocOp::parse(OpAsmParser &parser, OperationState &result) {
  OpAsmParser::UnresolvedOperand memref;
  Type type;
  if (parser.parseOperand(memref) || parser.parseColonType(type))
    return failure();
  if (parser.resolveOperand(memref, type, result.operands))
    return failure();
  return success();
}

#define GET_OP_CLASSES
#include "mlir/Dialect/DependentMemRef/IR/DependentMemRefOps.cpp.inc"
