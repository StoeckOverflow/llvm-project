//===- FuncOps.cpp - Func Dialect Operations ------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/Func/IR/FuncOps.h"

#include "mlir/Conversion/ConvertToEmitC/ToEmitCInterface.h"
#include "mlir/Conversion/ConvertToLLVM/ToLLVMInterface.h"
#include "mlir/Dialect/Bufferization/IR/BufferizableOpInterface.h"
#include "mlir/IR/BuiltinTypes.h"
#include "mlir/IR/DependentTensorSupport.h"
#include "mlir/IR/IRMapping.h"
#include "mlir/IR/Matchers.h"
#include "mlir/IR/OpImplementation.h"
#include "mlir/IR/PatternMatch.h"
#include "mlir/IR/SymbolTable.h"
#include "mlir/IR/TypeUtilities.h"
#include "mlir/IR/Value.h"
#include "mlir/Interfaces/CallInterfaces.h"
#include "mlir/Interfaces/FunctionImplementation.h"
#include "mlir/Transforms/InliningUtils.h"
#include "llvm/ADT/APFloat.h"
#include "llvm/ADT/DenseMap.h"
#include "llvm/ADT/MapVector.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/ADT/ScopeExit.h"
#include "llvm/ADT/SmallVectorExtras.h"

#include "mlir/Dialect/Func/IR/FuncOpsDialect.cpp.inc"

using namespace mlir;
using namespace mlir::func;

namespace {
static ParseResult parseDependentTensorAwareFunctionSignature(
    OpAsmParser &parser, Region &bodyRegion,
    SmallVectorImpl<OpAsmParser::Argument> &arguments, bool &isVariadic,
    SmallVectorImpl<Type> &resultTypes,
    SmallVectorImpl<DictionaryAttr> &resultAttrs) {
  isVariadic = false;
  if (parser.parseCommaSeparatedList(
          OpAsmParser::Delimiter::Paren, [&]() -> ParseResult {
            if (isVariadic)
              return parser.emitError(
                  parser.getCurrentLocation(),
                  "variadic arguments must be in the end of the argument list");

            OpAsmParser::Argument argument;
            auto argPresent = parser.parseOptionalArgument(
                argument, /*allowType=*/true, /*allowAttrs=*/true);
            if (argPresent.has_value()) {
              if (failed(argPresent.value()))
                return failure();
              if (!arguments.empty() && arguments.back().ssaName.name.empty())
                return parser.emitError(
                    argument.ssaName.location,
                    "expected type instead of SSA identifier");
            } else {
              argument.ssaName.location = parser.getCurrentLocation();
              if (!arguments.empty() && !arguments.back().ssaName.name.empty())
                return parser.emitError(argument.ssaName.location,
                                        "expected SSA identifier");

              NamedAttrList attrs;
              if (parser.parseType(argument.type) ||
                  parser.parseOptionalAttrDict(attrs) ||
                  parser.parseOptionalLocationSpecifier(argument.sourceLoc))
                return failure();
              argument.attrs = attrs.getDictionary(parser.getContext());
            }

            arguments.push_back(argument);
            return success();
          }))
    return failure();

  if (succeeded(parser.parseOptionalArrow()))
    return call_interface_impl::parseFunctionResultList(parser, resultTypes,
                                                        resultAttrs);
  return success();
}

static StringRef normalizeSSAName(StringRef name) {
  name.consume_front("%");
  return name;
}

static bool hasDependentTensorSeedArgsAttr(DictionaryAttr attrs) {
  return attrs && attrs.get("dependent_tensor.seed_args");
}

struct PendingDependentTensorValueRefinement {
  uint32_t valueIndex = 0;
  RankedTensorType type;
  SmallVector<OpAsmParser::UnresolvedOperand> dims;
};

struct PendingDependentTypeValueRefinement {
  uint32_t valueIndex = 0;
  MemRefType type;
  dependent_memref::PendingMemRefSpec spec;
};

static ParseResult parseDependentTypesBoundary(
    OpAsmParser &parser, ArrayRef<OpAsmParser::Argument> entryArgs,
    ArrayRef<Type> argTypes, ArrayRef<Type> resultTypes,
    SmallVectorImpl<PendingDependentTensorValueRefinement> &argTensorRefs,
    SmallVectorImpl<PendingDependentTensorValueRefinement> &resultTensorRefs,
    SmallVectorImpl<PendingDependentTypeValueRefinement> &argMemRefRefs,
    SmallVectorImpl<PendingDependentTypeValueRefinement> &resultMemRefRefs) {
  if (failed(parser.parseOptionalHashKeyword("types")))
    return success();

  DenseMap<StringRef, unsigned> functionArgIndices;
  functionArgIndices.reserve(entryArgs.size());
  for (auto [index, arg] : llvm::enumerate(entryArgs)) {
    StringRef name = normalizeSSAName(arg.ssaName.name);
    if (!name.empty())
      functionArgIndices.try_emplace(name, index);
  }

  auto parseArgRefinement =
      [&](OpAsmParser::UnresolvedOperand arg) -> ParseResult {
    auto it = functionArgIndices.find(normalizeSSAName(arg.name));
    if (it == functionArgIndices.end())
      return parser.emitError(
          arg.location, "dependent boundary values must be function arguments");
    unsigned argIndex = it->second;
    Type argType = argTypes[argIndex];
    if (auto rankedType = dyn_cast<RankedTensorType>(argType)) {
      PendingDependentTensorValueRefinement info;
      info.valueIndex = argIndex;
      info.type = rankedType;
      if (parser.parseColon() ||
          dependent_tensor::parseTensorSpec(parser, rankedType, info.dims))
        return failure();
      argTensorRefs.push_back(std::move(info));
      return success();
    }
    if (auto memRefType = dyn_cast<MemRefType>(argType)) {
      PendingDependentTypeValueRefinement info;
      info.valueIndex = argIndex;
      info.type = memRefType;
      if (parser.parseColon() ||
          dependent_memref::parseMemRefSpec(parser, info.spec))
        return failure();
      argMemRefRefs.push_back(std::move(info));
      return success();
    }
    return parser.emitError(arg.location,
                            "dependent boundary requires tensor or memref");
  };

  if (parser.parseLSquare())
    return failure();
  while (failed(parser.parseOptionalRSquare())) {
    OpAsmParser::UnresolvedOperand arg;
    if (parser.parseOperand(arg) || parseArgRefinement(arg))
      return failure();
    (void)parser.parseOptionalComma();
  }

  if (failed(parser.parseOptionalArrow()))
    return success();

  if (resultTypes.empty()) {
    if (parser.parseLParen() || parser.parseRParen())
      return failure();
    return success();
  }

  auto parseResultRefinement = [&](unsigned resultIndex) -> ParseResult {
    Type resultType = resultTypes[resultIndex];
    if (auto rankedType = dyn_cast<RankedTensorType>(resultType)) {
      PendingDependentTensorValueRefinement resultInfo;
      resultInfo.valueIndex = resultIndex;
      resultInfo.type = rankedType;
      if (dependent_tensor::parseTensorSpec(parser, rankedType,
                                            resultInfo.dims))
        return failure();
      resultTensorRefs.push_back(std::move(resultInfo));
      return success();
    }
    if (auto memRefType = dyn_cast<MemRefType>(resultType)) {
      PendingDependentTypeValueRefinement resultInfo;
      resultInfo.valueIndex = resultIndex;
      resultInfo.type = memRefType;
      if (dependent_memref::parseMemRefSpec(parser, resultInfo.spec))
        return failure();
      resultMemRefRefs.push_back(std::move(resultInfo));
      return success();
    }
    return parser.emitError(parser.getCurrentLocation(),
                            "dependent boundary requires tensor or memref");
  };

  if (resultTypes.size() == 1)
    return parseResultRefinement(/*resultIndex=*/0);

  unsigned resultIndex = 0;
  if (parser.parseCommaSeparatedList(
          OpAsmParser::Delimiter::Square, [&]() -> ParseResult {
            if (resultIndex >= resultTypes.size())
              return parser.emitError(
                  parser.getCurrentLocation(),
                  "too many dependent result boundary entries");
            return parseResultRefinement(resultIndex++);
          }))
    return failure();
  if (resultIndex != resultTypes.size())
    return parser.emitError(parser.getCurrentLocation(),
                            "expected one dependent result boundary entry per "
                            "function result");
  return success();
}

static ParseResult resolveDependentTensorTypesBoundary(
    OpAsmParser &parser, ArrayRef<OpAsmParser::Argument> entryArgs,
    Region &body,
    ArrayRef<PendingDependentTensorValueRefinement> pendingArgRefinements,
    ArrayRef<PendingDependentTensorValueRefinement> pendingResultRefinements,
    SmallVectorImpl<DependentTypeValueRefinement> &argRefinements,
    SmallVectorImpl<DependentTypeValueRefinement> &resultRefinements) {
  if (pendingArgRefinements.empty() && pendingResultRefinements.empty())
    return success();
  if (body.empty())
    return parser.emitError(
        parser.getCurrentLocation(),
        "dependent tensor function boundaries require a body");

  DenseMap<StringRef, Value> functionArgNames;
  functionArgNames.reserve(entryArgs.size());
  for (auto [arg, value] :
       llvm::zip_equal(entryArgs, body.front().getArguments())) {
    StringRef name = normalizeSSAName(arg.ssaName.name);
    if (!name.empty())
      functionArgNames.try_emplace(name, value);
  }

  auto resolveOne =
      [&](const PendingDependentTensorValueRefinement &pending,
          SmallVectorImpl<DependentTypeValueRefinement> &out) -> ParseResult {
    DependentTypeValueRefinement info;
    info.valueIndex = pending.valueIndex;
    info.rank = pending.type.getRank();
    for (const OpAsmParser::UnresolvedOperand &dim : pending.dims) {
      auto it = functionArgNames.find(normalizeSSAName(dim.name));
      if (it == functionArgNames.end())
        return parser.emitError(
            dim.location,
            "dependent tensor boundary dims must be function arguments");
      if (!it->second.getType().isIndex())
        return parser.emitError(
            dim.location,
            "dependent tensor boundary dims must be index values");
      info.dimValues.emplace_back(it->second);
    }
    out.push_back(std::move(info));
    return success();
  };

  for (const PendingDependentTensorValueRefinement &pending :
       pendingArgRefinements)
    if (resolveOne(pending, argRefinements))
      return failure();
  for (const PendingDependentTensorValueRefinement &pending :
       pendingResultRefinements)
    if (resolveOne(pending, resultRefinements))
      return failure();
  return success();
}

static ParseResult resolveDependentMemRefTypesBoundary(
    OpAsmParser &parser, ArrayRef<OpAsmParser::Argument> entryArgs,
    Region &body,
    ArrayRef<PendingDependentTypeValueRefinement> pendingArgRefinements,
    ArrayRef<PendingDependentTypeValueRefinement> pendingResultRefinements,
    SmallVectorImpl<DependentTypeValueRefinement> &argRefinements,
    SmallVectorImpl<DependentTypeValueRefinement> &resultRefinements) {
  if (pendingArgRefinements.empty() && pendingResultRefinements.empty())
    return success();
  if (body.empty())
    return parser.emitError(
        parser.getCurrentLocation(),
        "dependent memref function boundaries require a body");

  DenseMap<StringRef, Value> functionArgNames;
  functionArgNames.reserve(entryArgs.size());
  for (auto [arg, value] :
       llvm::zip_equal(entryArgs, body.front().getArguments())) {
    StringRef name = normalizeSSAName(arg.ssaName.name);
    if (!name.empty())
      functionArgNames.try_emplace(name, value);
  }

  auto resolveIndexOperand =
      [&](const OpAsmParser::UnresolvedOperand &operand) -> FailureOr<Value> {
    auto it = functionArgNames.find(normalizeSSAName(operand.name));
    if (it == functionArgNames.end()) {
      parser.emitError(
          operand.location,
          "dependent memref boundary values must be function arguments");
      return failure();
    }
    if (!it->second.getType().isIndex()) {
      parser.emitError(operand.location,
                       "dependent memref boundary values must be index values");
      return failure();
    }
    return it->second;
  };

  auto resolveOne =
      [&](const PendingDependentTypeValueRefinement &pending,
          SmallVectorImpl<DependentTypeValueRefinement> &out) -> ParseResult {
    const dependent_memref::PendingMemRefSpec &spec = pending.spec;
    bool flatCarrier = pending.type.getRank() == 0 && !spec.dims.empty();
    int64_t logicalRank = flatCarrier ? static_cast<int64_t>(spec.dims.size())
                                      : pending.type.getRank();
    if (static_cast<int64_t>(spec.dims.size()) != logicalRank)
      return parser.emitError(spec.loc, "dependent memref rank mismatch");
    if (spec.elementType != pending.type.getElementType())
      return parser.emitError(
          spec.loc, "dependent memref element type must match value type");
    if (spec.hasExplicitLayout &&
        static_cast<int64_t>(spec.strides.size()) != logicalRank)
      return parser.emitError(spec.loc,
                              "dependent memref stride count must match rank");

    SmallVector<Value> dims;
    dims.reserve(spec.dims.size());
    for (const OpAsmParser::UnresolvedOperand &dim : spec.dims) {
      FailureOr<Value> value = resolveIndexOperand(dim);
      if (failed(value))
        return failure();
      dims.push_back(*value);
    }

    SmallVector<Value> strides;
    strides.reserve(spec.strides.size());
    for (const OpAsmParser::UnresolvedOperand &stride : spec.strides) {
      FailureOr<Value> value = resolveIndexOperand(stride);
      if (failed(value))
        return failure();
      strides.push_back(*value);
    }

    DependentTypeValueRefinement info;
    info.valueIndex = pending.valueIndex;
    info.rank = logicalRank;
    info.offset = spec.offset;
    info.hasExplicitLayout = spec.hasExplicitLayout;
    info.assignDimValues(dims);
    info.assignStrideValues(strides);
    out.push_back(std::move(info));
    return success();
  };

  for (const PendingDependentTypeValueRefinement &pending :
       pendingArgRefinements)
    if (resolveOne(pending, argRefinements))
      return failure();
  for (const PendingDependentTypeValueRefinement &pending :
       pendingResultRefinements)
    if (resolveOne(pending, resultRefinements))
      return failure();
  return success();
}

static DependentTensorValueRefinement convertToDependentTensorValueRefinement(
    const DependentTypeValueRefinement &refinement) {
  DependentTensorValueRefinement converted;
  converted.valueIndex = refinement.valueIndex;
  converted.rank = refinement.rank;
  converted.assignDimValues(refinement.getDimValues());
  return converted;
}

static const DependentTypeValueRefinement *
findBoundaryRefinement(ArrayRef<DependentTypeValueRefinement> refinements,
                       unsigned valueIndex) {
  for (const DependentTypeValueRefinement &candidate : refinements)
    if (candidate.valueIndex == valueIndex)
      return &candidate;
  return nullptr;
}
} // namespace

//===----------------------------------------------------------------------===//
// FuncDialect
//===----------------------------------------------------------------------===//

void FuncDialect::initialize() {
  addOperations<
#define GET_OP_LIST
#include "mlir/Dialect/Func/IR/FuncOps.cpp.inc"
      >();
  declarePromisedInterface<ConvertToEmitCPatternInterface, FuncDialect>();
  declarePromisedInterface<DialectInlinerInterface, FuncDialect>();
  declarePromisedInterface<ConvertToLLVMPatternInterface, FuncDialect>();
  declarePromisedInterfaces<bufferization::BufferizableOpInterface, CallOp,
                            FuncOp, ReturnOp>();
}

/// Materialize a single constant operation from a given attribute value with
/// the desired resultant type.
Operation *FuncDialect::materializeConstant(OpBuilder &builder, Attribute value,
                                            Type type, Location loc) {
  if (ConstantOp::isBuildableWith(value, type))
    return ConstantOp::create(builder, loc, type,
                              llvm::cast<FlatSymbolRefAttr>(value));
  return nullptr;
}

//===----------------------------------------------------------------------===//
// CallOp
//===----------------------------------------------------------------------===//

LogicalResult CallOp::verifySymbolUses(SymbolTableCollection &symbolTable) {
  // Check that the callee attribute was specified.
  auto fnAttr = (*this)->getAttrOfType<FlatSymbolRefAttr>("callee");
  if (!fnAttr)
    return emitOpError("requires a 'callee' symbol reference attribute");
  FuncOp fn = symbolTable.lookupNearestSymbolFrom<FuncOp>(*this, fnAttr);
  if (!fn)
    return emitOpError() << "'" << fnAttr.getValue()
                         << "' does not reference a valid function";

  // Verify that the operand and result types match the callee.
  auto fnType = fn.getFunctionType();
  if (fnType.getNumInputs() != getNumOperands())
    return emitOpError("incorrect number of operands for callee");

  for (unsigned i = 0, e = fnType.getNumInputs(); i != e; ++i)
    if (getOperand(i).getType() != fnType.getInput(i))
      return emitOpError("operand type mismatch: expected operand type ")
             << fnType.getInput(i) << ", but provided "
             << getOperand(i).getType() << " for operand number " << i;

  if (fnType.getNumResults() != getNumResults())
    return emitOpError("incorrect number of results for callee");

  for (unsigned i = 0, e = fnType.getNumResults(); i != e; ++i)
    if (getResult(i).getType() != fnType.getResult(i)) {
      auto diag = emitOpError("result type mismatch at index ") << i;
      diag.attachNote() << "      op result types: " << getResultTypes();
      diag.attachNote() << "function result types: " << fnType.getResults();
      return diag;
    }

  return success();
}

FunctionType CallOp::getCalleeType() {
  return FunctionType::get(getContext(), getOperandTypes(), getResultTypes());
}

//===----------------------------------------------------------------------===//
// CallIndirectOp
//===----------------------------------------------------------------------===//

/// Fold indirect calls that have a constant function as the callee operand.
LogicalResult CallIndirectOp::canonicalize(CallIndirectOp indirectCall,
                                           PatternRewriter &rewriter) {
  // Check that the callee is a constant callee.
  SymbolRefAttr calledFn;
  if (!matchPattern(indirectCall.getCallee(), m_Constant(&calledFn)))
    return failure();

  // Replace with a direct call.
  rewriter.replaceOpWithNewOp<CallOp>(indirectCall, calledFn,
                                      indirectCall.getResultTypes(),
                                      indirectCall.getArgOperands());
  return success();
}

//===----------------------------------------------------------------------===//
// ConstantOp
//===----------------------------------------------------------------------===//

LogicalResult ConstantOp::verifySymbolUses(SymbolTableCollection &symbolTable) {
  StringRef fnName = getValue();
  Type type = getType();

  // Try to find the referenced function.
  auto fn = symbolTable.lookupNearestSymbolFrom<FuncOp>(
      this->getOperation(), StringAttr::get(getContext(), fnName));
  if (!fn)
    return emitOpError() << "reference to undefined function '" << fnName
                         << "'";

  // Check that the referenced function has the correct type.
  if (fn.getFunctionType() != type)
    return emitOpError("reference to function with mismatched type");

  return success();
}

OpFoldResult ConstantOp::fold(FoldAdaptor adaptor) { return getValueAttr(); }

void ConstantOp::getAsmResultNames(
    function_ref<void(Value, StringRef)> setNameFn) {
  setNameFn(getResult(), "f");
}

bool ConstantOp::isBuildableWith(Attribute value, Type type) {
  return llvm::isa<FlatSymbolRefAttr>(value) && llvm::isa<FunctionType>(type);
}

//===----------------------------------------------------------------------===//
// FuncOp
//===----------------------------------------------------------------------===//

FuncOp FuncOp::create(Location location, StringRef name, FunctionType type,
                      ArrayRef<NamedAttribute> attrs) {
  OpBuilder builder(location->getContext());
  OperationState state(location, getOperationName());
  FuncOp::build(builder, state, name, type, attrs);
  return cast<FuncOp>(Operation::create(state));
}
FuncOp FuncOp::create(Location location, StringRef name, FunctionType type,
                      Operation::dialect_attr_range attrs) {
  SmallVector<NamedAttribute, 8> attrRef(attrs);
  return create(location, name, type, llvm::ArrayRef(attrRef));
}
FuncOp FuncOp::create(Location location, StringRef name, FunctionType type,
                      ArrayRef<NamedAttribute> attrs,
                      ArrayRef<DictionaryAttr> argAttrs) {
  FuncOp func = create(location, name, type, attrs);
  func.setAllArgAttrs(argAttrs);
  return func;
}

void FuncOp::build(OpBuilder &builder, OperationState &state, StringRef name,
                   FunctionType type, ArrayRef<NamedAttribute> attrs,
                   ArrayRef<DictionaryAttr> argAttrs) {
  state.addAttribute(SymbolTable::getSymbolAttrName(),
                     builder.getStringAttr(name));
  state.addAttribute(getFunctionTypeAttrName(state.name), TypeAttr::get(type));
  state.attributes.append(attrs.begin(), attrs.end());
  state.addRegion();

  if (argAttrs.empty())
    return;
  assert(type.getNumInputs() == argAttrs.size());
  call_interface_impl::addArgAndResultAttrs(
      builder, state, argAttrs, /*resultAttrs=*/{},
      getArgAttrsAttrName(state.name), getResAttrsAttrName(state.name));
}

ParseResult FuncOp::parse(OpAsmParser &parser, OperationState &result) {
  auto buildFuncType =
      [](Builder &builder, ArrayRef<Type> argTypes, ArrayRef<Type> results,
         function_interface_impl::VariadicFlag,
         std::string &) { return builder.getFunctionType(argTypes, results); };
  auto &builder = parser.getBuilder();
  SmallVector<OpAsmParser::Argument> entryArgs;
  SmallVector<DictionaryAttr> resultAttrs;
  SmallVector<Type> resultTypes;

  (void)impl::parseOptionalVisibilityKeyword(parser, result.attributes);

  StringAttr nameAttr;
  if (parser.parseSymbolName(nameAttr, SymbolTable::getSymbolAttrName(),
                             result.attributes))
    return failure();

  auto *body = result.addRegion();

  SMLoc signatureLocation = parser.getCurrentLocation();
  bool isVariadic = false;
  if (parseDependentTensorAwareFunctionSignature(
          parser, *body, entryArgs, isVariadic, resultTypes, resultAttrs))
    return failure();
  for (OpAsmParser::Argument &arg : entryArgs) {
    if (hasDependentTensorSeedArgsAttr(arg.attrs))
      return parser.emitError(
          arg.ssaName.location,
          "dependent_tensor.seed_args is no longer supported");
  }
  for (DictionaryAttr attrs : resultAttrs) {
    if (hasDependentTensorSeedArgsAttr(attrs))
      return parser.emitError(
          signatureLocation,
          "dependent_tensor.seed_args is no longer supported");
  }

  std::string errorMessage;
  SmallVector<Type> argTypes;
  argTypes.reserve(entryArgs.size());
  for (OpAsmParser::Argument &arg : entryArgs)
    argTypes.push_back(arg.type);
  Type type = buildFuncType(builder, argTypes, resultTypes,
                            function_interface_impl::VariadicFlag(isVariadic),
                            errorMessage);
  if (!type) {
    return parser.emitError(signatureLocation)
           << "failed to construct function type"
           << (errorMessage.empty() ? "" : ": ") << errorMessage;
  }
  result.addAttribute(getFunctionTypeAttrName(result.name),
                      TypeAttr::get(type));

  NamedAttrList parsedAttributes;
  SMLoc attributeDictLocation = parser.getCurrentLocation();
  if (parser.parseOptionalAttrDictWithKeyword(parsedAttributes))
    return failure();
  if (parsedAttributes.get("dependent_tensor.seed_args"))
    return parser.emitError(
        attributeDictLocation,
        "dependent_tensor.seed_args is no longer supported");

  for (StringRef disallowed :
       {SymbolTable::getVisibilityAttrName(), SymbolTable::getSymbolAttrName(),
        getFunctionTypeAttrName(result.name).getValue()}) {
    if (parsedAttributes.get(disallowed))
      return parser.emitError(attributeDictLocation, "'")
             << disallowed
             << "' is an inferred attribute and should not be specified in the "
                "explicit attribute dictionary";
  }
  result.attributes.append(parsedAttributes);

  assert(resultAttrs.size() == resultTypes.size());
  call_interface_impl::addArgAndResultAttrs(
      builder, result, entryArgs, resultAttrs, getArgAttrsAttrName(result.name),
      getResAttrsAttrName(result.name));

  SmallVector<PendingDependentTensorValueRefinement> pendingArgRefinements;
  SmallVector<PendingDependentTensorValueRefinement> pendingResultRefinements;
  SmallVector<PendingDependentTypeValueRefinement, 2> pendingTypeArgRefinements;
  SmallVector<PendingDependentTypeValueRefinement, 2>
      pendingTypeResultRefinements;
  if (parseDependentTypesBoundary(
          parser, entryArgs, argTypes, resultTypes, pendingArgRefinements,
          pendingResultRefinements, pendingTypeArgRefinements,
          pendingTypeResultRefinements))
    return failure();

  SMLoc loc = parser.getCurrentLocation();
  OptionalParseResult parseResult =
      parser.parseOptionalRegion(*body, entryArgs,
                                 /*enableNameShadowing=*/false);
  if (parseResult.has_value()) {
    if (failed(*parseResult))
      return failure();
    if (body->empty())
      return parser.emitError(loc, "expected non-empty function body");
  }

  auto &properties = result.getOrAddProperties<FuncOp::Properties>();
  properties.dependentTypeArgRefinements.clear();
  properties.dependentTypeResultRefinements.clear();
  if (resolveDependentTensorTypesBoundary(
          parser, entryArgs, *body, pendingArgRefinements,
          pendingResultRefinements, properties.dependentTypeArgRefinements,
          properties.dependentTypeResultRefinements))
    return failure();
  if (resolveDependentMemRefTypesBoundary(
          parser, entryArgs, *body, pendingTypeArgRefinements,
          pendingTypeResultRefinements, properties.dependentTypeArgRefinements,
          properties.dependentTypeResultRefinements))
    return failure();
  return success();
}

void FuncOp::print(OpAsmPrinter &p) {
  p << ' ';
  StringRef visibilityAttrName = SymbolTable::getVisibilityAttrName();
  if (auto visibility = (*this)->getAttrOfType<StringAttr>(visibilityAttrName))
    p << visibility.getValue() << ' ';
  p.printSymbolName(getName());

  ArrayRef<Type> argTypes = getArgumentTypes();
  ArrayRef<Type> resultTypes = getResultTypes();
  function_interface_impl::printFunctionSignature(
      p, *this, argTypes, /*isVariadic=*/false, resultTypes);
  function_interface_impl::printFunctionAttributes(
      p, *this,
      {visibilityAttrName, getFunctionTypeAttrName().getValue(),
       getArgAttrsAttrName().getValue(), getResAttrsAttrName().getValue()});

  const auto &typeArgRefinements = getProperties().dependentTypeArgRefinements;
  const auto &typeResultRefinements =
      getProperties().dependentTypeResultRefinements;
  if (!typeArgRefinements.empty() || !typeResultRefinements.empty()) {
    p << " #types[";
    llvm::interleaveComma(typeArgRefinements, p, [&](const auto &refinement) {
      p.printOperand(getArgument(refinement.valueIndex));
      p << " : ";
      Type type = getArgument(refinement.valueIndex).getType();
      if (auto tensorType = dyn_cast<RankedTensorType>(type)) {
        DependentTensorValueRefinement tensorRef =
            convertToDependentTensorValueRefinement(refinement);
        dependent_tensor::printTensorSpec(p, tensorRef.getDimValues(),
                                          tensorType.getElementType());
        return;
      }
      auto memRefType = cast<MemRefType>(type);
      dependent_memref::printMemRefSpec(p, refinement,
                                        memRefType.getElementType());
    });
    p << "]";
    if (typeResultRefinements.empty()) {
      if (getNumResults() == 0)
        p << " -> ()";
    } else {
      p << " -> ";
      auto printResultRefinement = [&](const auto &refinement) {
        Type type = getFunctionType().getResult(refinement.valueIndex);
        if (auto tensorType = dyn_cast<RankedTensorType>(type)) {
          DependentTensorValueRefinement tensorRef =
              convertToDependentTensorValueRefinement(refinement);
          dependent_tensor::printTensorSpec(p, tensorRef.getDimValues(),
                                            tensorType.getElementType());
          return;
        }
        auto memRefType = cast<MemRefType>(type);
        dependent_memref::printMemRefSpec(p, refinement,
                                          memRefType.getElementType());
      };
      if (typeResultRefinements.size() == 1) {
        printResultRefinement(typeResultRefinements.front());
      } else {
        p << "[";
        llvm::interleaveComma(typeResultRefinements, p, printResultRefinement);
        p << "]";
      }
    }
  }

  Region &body = getBody();
  if (!body.empty()) {
    p << ' ';
    p.printRegion(body, /*printEntryBlockArgs=*/false,
                  /*printBlockTerminators=*/true);
    return;
  }
}

void FuncOp::walkPropertySSAUses(
    function_ref<void(PropertyOperand &)> callback) {
  for (DependentTypeValueRefinement &refinement :
       getProperties().dependentTypeArgRefinements) {
    for (PropertyOperand &operand : refinement.dimValues)
      callback(operand);
    for (PropertyOperand &operand : refinement.strideValues)
      callback(operand);
  }
  for (DependentTypeValueRefinement &refinement :
       getProperties().dependentTypeResultRefinements) {
    for (PropertyOperand &operand : refinement.dimValues)
      callback(operand);
    for (PropertyOperand &operand : refinement.strideValues)
      callback(operand);
  }
}

void FuncOp::walkDependentTensorPropertyUses(
    function_ref<void(PropertyOperand &)> callback) {
  walkPropertySSAUses(callback);
}

static unsigned countErasedBefore(const BitVector &indices, unsigned index) {
  unsigned count = 0;
  for (unsigned i = 0; i < index; ++i)
    count += indices[i];
  return count;
}

static DependentTypeValueRefinement cloneDependentTypeRefinementWithIndex(
    const DependentTypeValueRefinement &refinement, unsigned valueIndex) {
  DependentTypeValueRefinement cloned;
  cloned.valueIndex = valueIndex;
  cloned.rank = refinement.rank;
  cloned.offset = refinement.offset;
  cloned.hasExplicitLayout = refinement.hasExplicitLayout;
  cloned.assignDimValues(refinement.getDimValues());
  cloned.assignStrideValues(refinement.getStrideValues());
  return cloned;
}

static std::optional<unsigned>
getErasedFunctionArgumentRef(FuncOp func, Value value,
                             const BitVector &argIndices) {
  auto arg = dyn_cast<BlockArgument>(value);
  if (!arg || func.isExternal() || arg.getOwner() != &func.getBody().front())
    return std::nullopt;
  unsigned argNumber = arg.getArgNumber();
  if (argNumber >= argIndices.size() || !argIndices[argNumber])
    return std::nullopt;
  return argNumber;
}

static LogicalResult verifyNoErasedFunctionArgumentRefs(
    FuncOp func, const DependentTypeValueRefinement &refinement,
    const BitVector &argIndices, StringRef boundaryKind) {
  auto checkValue = [&](Value value) -> LogicalResult {
    if (std::optional<unsigned> argNumber =
            getErasedFunctionArgumentRef(func, value, argIndices)) {
      return func.emitOpError()
             << "cannot erase function argument #" << *argNumber
             << " because it is used by surviving dependent type "
             << boundaryKind << " boundary refinements";
    }
    return success();
  };
  for (Value dimValue : refinement.getDimValues())
    if (failed(checkValue(dimValue)))
      return failure();
  for (Value strideValue : refinement.getStrideValues())
    if (failed(checkValue(strideValue)))
      return failure();
  return success();
}

LogicalResult FuncOp::updateFunctionPropertiesForArgumentErasure(
    const BitVector &argIndices) {
  auto &properties = getProperties();
  SmallVector<DependentTypeValueRefinement, 2> newTypeArgRefinements;
  SmallVector<DependentTypeValueRefinement, 2> newTypeResultRefinements;

  for (const DependentTypeValueRefinement &refinement :
       properties.dependentTypeArgRefinements) {
    if (refinement.valueIndex >= argIndices.size())
      return emitOpError("dependent type argument boundary index is out of "
                         "range during argument erasure");
    if (argIndices[refinement.valueIndex])
      continue;
    if (failed(verifyNoErasedFunctionArgumentRefs(*this, refinement, argIndices,
                                                  "argument")))
      return failure();
    unsigned newIndex = refinement.valueIndex -
                        countErasedBefore(argIndices, refinement.valueIndex);
    newTypeArgRefinements.push_back(
        cloneDependentTypeRefinementWithIndex(refinement, newIndex));
  }

  for (const DependentTypeValueRefinement &refinement :
       properties.dependentTypeResultRefinements) {
    if (failed(verifyNoErasedFunctionArgumentRefs(*this, refinement, argIndices,
                                                  "result")))
      return failure();
    newTypeResultRefinements.push_back(cloneDependentTypeRefinementWithIndex(
        refinement, refinement.valueIndex));
  }

  properties.dependentTypeArgRefinements = std::move(newTypeArgRefinements);
  properties.dependentTypeResultRefinements =
      std::move(newTypeResultRefinements);
  reattachPropertyOperands(*this);
  return success();
}

LogicalResult FuncOp::updateFunctionPropertiesForResultErasure(
    const BitVector &resultIndices) {
  auto &properties = getProperties();
  SmallVector<DependentTypeValueRefinement, 2> newTypeResultRefinements;
  for (const DependentTypeValueRefinement &refinement :
       properties.dependentTypeResultRefinements) {
    if (refinement.valueIndex >= resultIndices.size())
      return emitOpError("dependent type result boundary index is out of "
                         "range during result erasure");
    if (resultIndices[refinement.valueIndex])
      continue;
    unsigned newIndex = refinement.valueIndex -
                        countErasedBefore(resultIndices, refinement.valueIndex);
    newTypeResultRefinements.push_back(
        cloneDependentTypeRefinementWithIndex(refinement, newIndex));
  }

  properties.dependentTypeResultRefinements =
      std::move(newTypeResultRefinements);
  reattachPropertyOperands(*this);
  return success();
}

FailureOr<DependentTensorValueRefinement>
FuncOp::getDependentTensorBlockArgumentRefinement(unsigned regionNumber,
                                                  unsigned blockNumber,
                                                  unsigned argumentNumber) {
  if (regionNumber != 0 || blockNumber != 0)
    return failure();
  const DependentTypeValueRefinement *refinement = findBoundaryRefinement(
      getProperties().dependentTypeArgRefinements, argumentNumber);
  if (!refinement)
    return failure();
  if (refinement->hasExplicitLayout ||
      !isa<RankedTensorType>(getArgument(argumentNumber).getType()))
    return failure();
  return convertToDependentTensorValueRefinement(*refinement);
}

/// Clone the internal blocks from this function into dest and all attributes
/// from this function to dest.
void FuncOp::cloneInto(FuncOp dest, IRMapping &mapper) {
  // Add the attributes of this function to dest.
  llvm::MapVector<StringAttr, Attribute> newAttrMap;
  for (const auto &attr : dest->getAttrs())
    newAttrMap.insert({attr.getName(), attr.getValue()});
  for (const auto &attr : (*this)->getAttrs())
    newAttrMap.insert({attr.getName(), attr.getValue()});

  auto newAttrs = llvm::map_to_vector(
      newAttrMap, [](std::pair<StringAttr, Attribute> attrPair) {
        return NamedAttribute(attrPair.first, attrPair.second);
      });
  dest->setAttrs(DictionaryAttr::get(getContext(), newAttrs));

  // Clone the body.
  getBody().cloneInto(&dest.getBody(), mapper);
  remapDependentTensorPropertyValues(dest.getOperation(), mapper);
}

/// Create a deep copy of this function and all of its blocks, remapping
/// any operands that use values outside of the function using the map that is
/// provided (leaving them alone if no entry is present). Replaces references
/// to cloned sub-values with the corresponding value that is copied, and adds
/// those mappings to the mapper.
FuncOp FuncOp::clone(IRMapping &mapper) {
  // Create the new function.
  FuncOp newFunc = cast<FuncOp>(getOperation()->cloneWithoutRegions());

  // If the function has a body, then the user might be deleting arguments to
  // the function by specifying them in the mapper. If so, we don't add the
  // argument to the input type vector.
  if (!isExternal()) {
    FunctionType oldType = getFunctionType();

    unsigned oldNumArgs = oldType.getNumInputs();
    SmallVector<Type, 4> newInputs;
    newInputs.reserve(oldNumArgs);
    for (unsigned i = 0; i != oldNumArgs; ++i)
      if (!mapper.contains(getArgument(i)))
        newInputs.push_back(oldType.getInput(i));

    /// If any of the arguments were dropped, update the type and drop any
    /// necessary argument attributes.
    if (newInputs.size() != oldNumArgs) {
      newFunc.setType(FunctionType::get(oldType.getContext(), newInputs,
                                        oldType.getResults()));

      if (ArrayAttr argAttrs = getAllArgAttrs()) {
        SmallVector<Attribute> newArgAttrs;
        newArgAttrs.reserve(newInputs.size());
        for (unsigned i = 0; i != oldNumArgs; ++i)
          if (!mapper.contains(getArgument(i)))
            newArgAttrs.push_back(argAttrs[i]);
        newFunc.setAllArgAttrs(newArgAttrs);
      }
    }
  }

  /// Clone the current function into the new one and return it.
  cloneInto(newFunc, mapper);
  remapPropertySSAValues(newFunc, mapper);
  return newFunc;
}
FuncOp FuncOp::clone() {
  IRMapping mapper;
  return clone(mapper);
}

//===----------------------------------------------------------------------===//
// ReturnOp
//===----------------------------------------------------------------------===//

LogicalResult FuncOp::verifyRegions() {
  // External declarations have no body to check.
  if (isDeclaration())
    return success();
  // Hoist the result types once; they are the same for every return site.
  auto resultTypes = getFunctionType().getResults();
  for (Block &block : getBody()) {
    if (block.empty())
      continue;
    // Check func.return or other return-like terminators ops (e.g.
    // llvm.return, test.return).
    auto returnOp = dyn_cast<RegionBranchTerminatorOpInterface>(&block.back());
    if (!returnOp)
      continue;
    auto operands =
        returnOp.getMutableSuccessorOperands(RegionSuccessor::parent());
    if (operands.size() != resultTypes.size())
      return returnOp->emitOpError("has ")
             << operands.size() << " operands, but enclosing function (@"
             << getName() << ") returns " << resultTypes.size();

    for (auto [i, opType] : llvm::enumerate(llvm::zip(operands, resultTypes))) {
      auto [operand, resTy] = opType;
      if (operand.get().getType() != resTy)
        return returnOp->emitError() << "type of return operand " << i << " ("
                                     << operand.get().getType()
                                     << ") doesn't match function result type ("
                                     << resTy << ") in function @" << getName();
    }
  }

  return success();
}

//===----------------------------------------------------------------------===//
// TableGen'd op method definitions
//===----------------------------------------------------------------------===//

#define GET_OP_CLASSES
#include "mlir/Dialect/Func/IR/FuncOps.cpp.inc"
