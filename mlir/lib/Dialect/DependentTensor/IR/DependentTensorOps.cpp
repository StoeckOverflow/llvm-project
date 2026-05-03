//===- DependentTensorOps.cpp - DependentTensor op definitions ------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/DependentTensor/IR/DependentTensor.h"
#include "mlir/Interfaces/FunctionImplementation.h"
#include "llvm/ADT/DenseSet.h"

using namespace mlir;
using namespace mlir::dependent_tensor;

namespace {
static constexpr StringLiteral kDependentTensorSeedArgsAttrName =
    "dependent_tensor.seed_args";

static FailureOr<SmallVector<int32_t>>
getSeedArgPositions(Attribute attr, RankedTensorType type) {
  auto positions = dyn_cast_or_null<DenseI32ArrayAttr>(attr);
  if (!positions)
    return failure();
  if (positions.size() != static_cast<unsigned>(type.getRank()))
    return failure();

  SmallVector<int32_t> values;
  values.reserve(positions.size());
  for (int32_t position : positions.asArrayRef()) {
    if (position < 0)
      return failure();
    values.push_back(position);
  }
  return values;
}

static FailureOr<TensorValueSemantics>
buildValueSemantics(RankedTensorType type, ArrayRef<int32_t> seedArgPositions,
                    ValueRange availableSeeds,
                    ArrayRef<std::string> dimNames = {}) {
  if (type.getRank() != static_cast<int64_t>(seedArgPositions.size()))
    return failure();
  if (!dimNames.empty() &&
      type.getRank() != static_cast<int64_t>(dimNames.size()))
    return failure();

  TensorValueSemantics info{type, {}};
  info.dimSeeds.reserve(seedArgPositions.size());
  if (!dimNames.empty())
    info.dimNames.assign(dimNames.begin(), dimNames.end());
  for (int32_t position : seedArgPositions) {
    if (position < 0 || position >= static_cast<int32_t>(availableSeeds.size()))
      return failure();
    Value seed = availableSeeds[position];
    if (!seed.getType().isIndex())
      return failure();
    info.dimSeeds.push_back(seed);
  }
  return info;
}
} // namespace

StringAttr dependent_tensor::getSeedArgsAttrName(MLIRContext *context) {
  return StringAttr::get(context, kDependentTensorSeedArgsAttrName);
}

FailureOr<TensorValueSemantics> dependent_tensor::getValueSemantics(Value value) {
  auto rankedType = dyn_cast<RankedTensorType>(value.getType());
  if (!rankedType)
    return failure();

  if (auto arg = dyn_cast<BlockArgument>(value)) {
    auto *block = arg.getOwner();
    auto func =
        dyn_cast_or_null<func::FuncOp>(block ? block->getParentOp() : nullptr);
    if (!func || block != &func.getBody().front())
      return failure();
    DictionaryAttr argAttrs =
        function_interface_impl::getArgAttrDict(func, arg.getArgNumber());
    if (!argAttrs)
      return failure();
    auto seedPositions =
        getSeedArgPositions(argAttrs.get(getSeedArgsAttrName(func.getContext())),
                            rankedType);
    if (failed(seedPositions))
      return failure();
    return buildValueSemantics(rankedType, *seedPositions, func.getArguments());
  }

  auto result = cast<OpResult>(value);
  Operation *def = result.getOwner();
  if (auto op = dyn_cast<MakeOp>(def))
    return buildValueSemantics(rankedType, op.getDependencyMap(), op.getSeeds(),
                               op.getDimNames());

  if (auto op = dyn_cast<MatmulOp>(def)) {
    auto lhsInfo = getValueSemantics(op.getLhs());
    auto rhsInfo = getValueSemantics(op.getRhs());
    if (failed(lhsInfo) || failed(rhsInfo))
      return failure();
    if (lhsInfo->dimSeeds.size() != 2 || rhsInfo->dimSeeds.size() != 2 ||
        rankedType.getRank() != 2)
      return failure();
    TensorValueSemantics info{rankedType, {}};
    info.dimSeeds = {lhsInfo->dimSeeds[0], rhsInfo->dimSeeds[1]};
    if (lhsInfo->dimNames.size() == 2 && rhsInfo->dimNames.size() == 2)
      info.dimNames = {lhsInfo->dimNames[0], rhsInfo->dimNames[1]};
    return info;
  }

  if (auto op = dyn_cast<GemmOp>(def)) {
    auto accInfo = getValueSemantics(op.getAcc());
    if (failed(accInfo) || rankedType.getRank() != 2)
      return failure();
    TensorValueSemantics info{rankedType, {}};
    info.dimSeeds = accInfo->dimSeeds;
    info.dimNames = accInfo->dimNames;
    return info;
  }

  if (auto call = dyn_cast<func::CallOp>(def)) {
    auto callee = SymbolTable::lookupNearestSymbolFrom<func::FuncOp>(
        call, call.getCalleeAttr());
    if (!callee)
      return failure();
    DictionaryAttr resAttrs = function_interface_impl::getResultAttrDict(
        callee, result.getResultNumber());
    if (!resAttrs)
      return failure();
    auto seedPositions =
        getSeedArgPositions(resAttrs.get(getSeedArgsAttrName(call.getContext())),
                            rankedType);
    if (failed(seedPositions))
      return failure();
    return buildValueSemantics(rankedType, *seedPositions, call.getOperands());
  }

  return failure();
}

bool dependent_tensor::haveEqualSemantics(const TensorValueSemantics &lhs,
                                          const TensorValueSemantics &rhs) {
  return lhs.type == rhs.type && lhs.dimSeeds == rhs.dimSeeds;
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
  if (lhsDim >= lhsInfo->dimSeeds.size() || rhsDim >= rhsInfo->dimSeeds.size())
    return failure();
  return lhsInfo->dimSeeds[lhsDim] == rhsInfo->dimSeeds[rhsDim];
}

namespace {
static ParseResult parseDimNames(OpAsmParser &parser,
                                 SmallVectorImpl<std::string> &dimNames) {
  if (parser.parseKeyword("dims"))
    return failure();
  return parser.parseCommaSeparatedList(
      OpAsmParser::Delimiter::Square, [&]() -> ParseResult {
        std::string name;
        if (parser.parseKeywordOrString(&name))
          return failure();
        dimNames.push_back(name);
        return success();
      });
}

static void printDimNames(OpAsmPrinter &printer, ArrayRef<std::string> dimNames) {
  printer << " dims[";
  llvm::interleaveComma(dimNames, printer, [&](const std::string &name) {
    printer << name;
  });
  printer << "]";
}

static FailureOr<int32_t> findDimName(ArrayRef<std::string> dimNames,
                                      StringRef name) {
  for (auto [index, candidate] : llvm::enumerate(dimNames))
    if (candidate == name)
      return static_cast<int32_t>(index);
  return failure();
}

static ParseResult
parseSchemaDimList(OpAsmParser &parser, ArrayRef<std::string> dimNames,
                   SmallVectorImpl<int32_t> &indices) {
  return parser.parseCommaSeparatedList(
      OpAsmParser::Delimiter::Paren, [&]() -> ParseResult {
        std::string name;
        if (parser.parseKeywordOrString(&name))
          return failure();
        auto index = findDimName(dimNames, name);
        if (failed(index))
          return parser.emitError(parser.getCurrentLocation(),
                                  "schema references undeclared dim name");
        indices.push_back(*index);
        return success();
      });
}

static void printSchemaDimList(OpAsmPrinter &printer, ArrayRef<int32_t> indices,
                               ArrayRef<std::string> dimNames) {
  printer << "(";
  llvm::interleaveComma(indices, printer, [&](int32_t index) {
    printer << dimNames[index];
  });
  printer << ")";
}

static LogicalResult verifyUniqueDimNames(Operation *op,
                                          ArrayRef<std::string> dimNames) {
  llvm::SmallDenseSet<StringRef> seen;
  for (const std::string &name : dimNames) {
    if (!seen.insert(name).second)
      return op->emitOpError("requires unique dimension names");
  }
  return success();
}

static FailureOr<SmallVector<Value>>
resolveSchemaSeeds(const TensorValueSemantics &info,
                   ArrayRef<std::string> globalDimNames,
                   ArrayRef<int32_t> schemaDims) {
  if (info.dimNames.size() != info.dimSeeds.size())
    return failure();

  DenseMap<StringRef, Value> localSeeds;
  for (auto [name, seed] : llvm::zip_equal(info.dimNames, info.dimSeeds))
    localSeeds.try_emplace(name, seed);

  SmallVector<Value> seeds;
  seeds.reserve(schemaDims.size());
  for (int32_t index : schemaDims) {
    if (index < 0 || index >= static_cast<int32_t>(globalDimNames.size()))
      return failure();
    auto it = localSeeds.find(globalDimNames[index]);
    if (it == localSeeds.end())
      return failure();
    seeds.push_back(it->second);
  }
  return seeds;
}
} // namespace

ParseResult MakeOp::parse(OpAsmParser &parser, OperationState &result) {
  SmallVector<OpAsmParser::UnresolvedOperand> seeds;
  if (parser.parseOperandList(seeds))
    return failure();

  SmallVector<std::string> dimNames;
  if (parseDimNames(parser, dimNames))
    return failure();

  Type resultType;
  if (parser.parseColonType(resultType))
    return failure();

  auto rankedType = dyn_cast<RankedTensorType>(resultType);
  if (!rankedType)
    return parser.emitError(parser.getCurrentLocation(),
                            "expected ranked tensor result type");

  SmallVector<Type> seedTypes(seeds.size(), parser.getBuilder().getIndexType());
  if (parser.resolveOperands(seeds, seedTypes, parser.getCurrentLocation(),
                             result.operands))
    return failure();

  result.addTypes(resultType);
  auto &props = result.getOrAddProperties<MakeOp::Properties>();
  props.dim_names.assign(dimNames.begin(), dimNames.end());
  props.dependency_map.resize(seeds.size());
  for (auto [index, _] : llvm::enumerate(seeds))
    props.dependency_map[index] = static_cast<int32_t>(index);
  return success();
}

void MakeOp::print(OpAsmPrinter &p) {
  p << ' ';
  p.printOperands(getSeeds());
  printDimNames(p, getDimNames());
  p << " : ";
  p.printType(getResult().getType());
}

LogicalResult MakeOp::verify() {
  auto rankedType = dyn_cast<RankedTensorType>(getResult().getType());
  if (!rankedType)
    return emitOpError("requires ranked tensor result type");

  if (static_cast<int64_t>(getSeeds().size()) != rankedType.getRank())
    return emitOpError("requires one index seed operand per result dimension");

  if (static_cast<int64_t>(getDimNames().size()) != rankedType.getRank())
    return emitOpError("requires one dimension name per result dimension");

  if (getDependencyMap().size() != static_cast<size_t>(rankedType.getRank()))
    return emitOpError("requires dependency map arity to match result rank");

  if (failed(verifyUniqueDimNames(*this, getDimNames())))
    return failure();

  for (Value seed : getSeeds())
    if (!seed.getType().isIndex())
      return emitOpError("requires index-typed seed operands");

  for (auto [dim, position] : llvm::enumerate(getDependencyMap())) {
    if (!rankedType.isDynamicDim(dim))
      return emitOpError("requires dependent result dimensions to be dynamic");
    if (position != static_cast<int32_t>(dim))
      return emitOpError("requires positional dependency mapping in v1");
    if (position < 0 || position >= static_cast<int32_t>(getSeeds().size()))
      return emitOpError("references an out-of-range seed operand");
  }

  return success();
}

LogicalResult MatmulOp::verify() {
  auto lhsType = dyn_cast<RankedTensorType>(getLhs().getType());
  auto rhsType = dyn_cast<RankedTensorType>(getRhs().getType());
  auto resultType = dyn_cast<RankedTensorType>(getResult().getType());
  if (!lhsType || !rhsType || !resultType)
    return emitOpError("requires ranked tensor operands and result");
  if (lhsType.getRank() != 2 || rhsType.getRank() != 2 ||
      resultType.getRank() != 2)
    return emitOpError("requires rank-2 tensors");
  if (lhsType.getElementType() != rhsType.getElementType() ||
      lhsType.getElementType() != resultType.getElementType())
    return emitOpError("requires matching element types");

  auto equalContractingDim = haveEqualDimSemantics(getLhs(), 1, getRhs(), 0);
  if (failed(equalContractingDim))
    return emitOpError("requires operands with dependent_tensor semantics");
  if (!*equalContractingDim)
    return emitOpError("expected lhs dim 1 to equal rhs dim 0");
  return success();
}

ParseResult GemmOp::parse(OpAsmParser &parser, OperationState &result) {
  SmallVector<OpAsmParser::UnresolvedOperand> tensors;
  if (parser.parseOperandList(tensors))
    return failure();
  if (tensors.size() != 3)
    return parser.emitError(parser.getCurrentLocation(),
                            "expected three tensor operands");

  SmallVector<std::string> dimNames;
  if (parseDimNames(parser, dimNames))
    return failure();

  SmallVector<int32_t> lhsDims, rhsDims, accDims, resultDims;
  if (parseSchemaDimList(parser, dimNames, lhsDims) || parser.parseKeyword("x") ||
      parseSchemaDimList(parser, dimNames, rhsDims) || parser.parsePlus() ||
      parseSchemaDimList(parser, dimNames, accDims) || parser.parseArrow() ||
      parseSchemaDimList(parser, dimNames, resultDims))
    return failure();

  if (parser.parseColon())
    return failure();
  Type lhsType, rhsType, accType, resultType;
  if (parser.parseType(lhsType) || parser.parseComma() || parser.parseType(rhsType) ||
      parser.parseComma() || parser.parseType(accType) || parser.parseArrow() ||
      parser.parseType(resultType))
    return failure();

  if (parser.resolveOperand(tensors[0], lhsType, result.operands) ||
      parser.resolveOperand(tensors[1], rhsType, result.operands) ||
      parser.resolveOperand(tensors[2], accType, result.operands))
    return failure();

  result.addTypes(resultType);
  auto &props = result.getOrAddProperties<GemmOp::Properties>();
  props.dim_names.assign(dimNames.begin(), dimNames.end());
  props.lhs_dims.assign(lhsDims.begin(), lhsDims.end());
  props.rhs_dims.assign(rhsDims.begin(), rhsDims.end());
  props.acc_dims.assign(accDims.begin(), accDims.end());
  props.result_dims.assign(resultDims.begin(), resultDims.end());
  return success();
}

void GemmOp::print(OpAsmPrinter &p) {
  p << ' ';
  p.printOperand(getLhs());
  p << ", ";
  p.printOperand(getRhs());
  p << ", ";
  p.printOperand(getAcc());
  printDimNames(p, getDimNames());
  p << " ";
  printSchemaDimList(p, getLhsDims(), getDimNames());
  p << " x ";
  printSchemaDimList(p, getRhsDims(), getDimNames());
  p << " + ";
  printSchemaDimList(p, getAccDims(), getDimNames());
  p << " -> ";
  printSchemaDimList(p, getResultDims(), getDimNames());
  p << " : ";
  p.printType(getLhs().getType());
  p << ", ";
  p.printType(getRhs().getType());
  p << ", ";
  p.printType(getAcc().getType());
  p << " -> ";
  p.printType(getResult().getType());
}

LogicalResult GemmOp::verify() {
  auto lhsType = dyn_cast<RankedTensorType>(getLhs().getType());
  auto rhsType = dyn_cast<RankedTensorType>(getRhs().getType());
  auto accType = dyn_cast<RankedTensorType>(getAcc().getType());
  auto resultType = dyn_cast<RankedTensorType>(getResult().getType());
  if (!lhsType || !rhsType || !accType || !resultType)
    return emitOpError("requires ranked tensor operands and result");
  if (lhsType.getRank() != 2 || rhsType.getRank() != 2 || accType.getRank() != 2 ||
      resultType.getRank() != 2)
    return emitOpError("requires rank-2 tensors");
  if (lhsType.getElementType() != rhsType.getElementType() ||
      lhsType.getElementType() != accType.getElementType() ||
      lhsType.getElementType() != resultType.getElementType())
    return emitOpError("requires matching element types");

  if (failed(verifyUniqueDimNames(*this, getDimNames())))
    return failure();
  if (getDimNames().size() != 3)
    return emitOpError("requires exactly three named dimensions in v1");
  if (getLhsDims().size() != 2 || getRhsDims().size() != 2 ||
      getAccDims().size() != 2 || getResultDims().size() != 2)
    return emitOpError("requires rank-2 schema groups");

  auto lhsInfo = getValueSemantics(getLhs());
  auto rhsInfo = getValueSemantics(getRhs());
  auto accInfo = getValueSemantics(getAcc());
  if (failed(lhsInfo) || failed(rhsInfo) || failed(accInfo))
    return emitOpError("requires operands with dependent_tensor semantics");

  auto lhsSeeds = resolveSchemaSeeds(*lhsInfo, getDimNames(), getLhsDims());
  auto rhsSeeds = resolveSchemaSeeds(*rhsInfo, getDimNames(), getRhsDims());
  auto accSeeds = resolveSchemaSeeds(*accInfo, getDimNames(), getAccDims());
  auto resultSeeds = resolveSchemaSeeds(*accInfo, getDimNames(), getResultDims());
  if (failed(lhsSeeds) || failed(rhsSeeds) || failed(accSeeds) || failed(resultSeeds))
    return emitOpError("schema is incompatible with operand dimension labels");

  if ((*lhsSeeds)[1] != (*rhsSeeds)[0])
    return emitOpError("expected lhs contraction dim to equal rhs contraction dim");
  if ((*lhsSeeds)[0] != (*accSeeds)[0] || (*lhsSeeds)[0] != (*resultSeeds)[0])
    return emitOpError("expected lhs row dim to match accumulator/result row dim");
  if ((*rhsSeeds)[1] != (*accSeeds)[1] || (*rhsSeeds)[1] != (*resultSeeds)[1])
    return emitOpError("expected rhs col dim to match accumulator/result col dim");
  return success();
}

#define GET_OP_CLASSES
#include "mlir/Dialect/DependentTensor/IR/DependentTensorOps.cpp.inc"
