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
#include "llvm/ADT/ScopeExit.h"
#include "llvm/ADT/STLExtras.h"
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
                return parser.emitError(argument.ssaName.location,
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

static ParseResult parseBoundaryDimNames(
    OpAsmParser &parser, SmallVectorImpl<std::string> &dimNames) {
  if (parser.parseKeyword("names"))
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

static void printBoundaryDimNames(OpAsmPrinter &printer,
                                  ArrayRef<std::string> dimNames) {
  printer << " names[";
  llvm::interleaveComma(dimNames, printer, [&](const std::string &name) {
    printer << name;
  });
  printer << "]";
}

static ParseResult parseBoundarySemanticsList(
    OpAsmParser &parser, StringRef keyword, ArrayRef<Type> valueTypes,
    const DenseMap<StringRef, Value> &functionArgNames,
    SmallVectorImpl<DependentTensorValueSemantics> &semantics) {
  if (parser.parseKeyword(keyword))
    return failure();
  return parser.parseCommaSeparatedList(
      OpAsmParser::Delimiter::Square, [&]() -> ParseResult {
        uint32_t valueIndex;
        if (parser.parseInteger(valueIndex))
          return failure();
        if (valueIndex >= valueTypes.size())
          return parser.emitError(parser.getCurrentLocation(),
                                  "dependent tensor boundary index out of range");
        auto rankedType = dyn_cast<RankedTensorType>(valueTypes[valueIndex]);
        if (!rankedType)
          return parser.emitError(parser.getCurrentLocation(),
                                  "dependent tensor boundary requires ranked tensor");
        if (parser.parseKeyword("dims"))
          return failure();

        SmallVector<OpAsmParser::UnresolvedOperand> dims;
        if (parser.parseCommaSeparatedList(
                OpAsmParser::Delimiter::Square, [&]() -> ParseResult {
                  OpAsmParser::UnresolvedOperand dim;
                  if (parser.parseOperand(dim))
                    return failure();
                  dims.push_back(dim);
                  return success();
                }))
          return failure();
        if (static_cast<int64_t>(dims.size()) != rankedType.getRank())
          return parser.emitError(parser.getCurrentLocation(),
                                  "dependent tensor boundary rank mismatch");

        SmallVector<std::string> dimNames;
        if (parseBoundaryDimNames(parser, dimNames))
          return failure();

        DependentTensorValueSemantics info;
        info.valueIndex = valueIndex;
        info.rank = rankedType.getRank();
        info.dimNames.assign(dimNames.begin(), dimNames.end());
        for (OpAsmParser::UnresolvedOperand dim : dims) {
          auto it = functionArgNames.find(normalizeSSAName(dim.name));
          if (it == functionArgNames.end())
            return parser.emitError(dim.location,
                                    "dependent tensor boundary dims must be function arguments");
          if (!it->second.getType().isIndex())
            return parser.emitError(dim.location,
                                    "dependent tensor boundary dims must be index values");
          info.dimValues.push_back(it->second);
        }
        semantics.push_back(std::move(info));
        return success();
      });
}

static ParseResult parseDependentTensorBoundary(
    OpAsmParser &parser, ArrayRef<OpAsmParser::Argument> entryArgs,
    ArrayRef<Type> argTypes, ArrayRef<Type> resultTypes, Region &body,
    SmallVectorImpl<DependentTensorValueSemantics> &argSemantics,
    SmallVectorImpl<DependentTensorValueSemantics> &resultSemantics) {
  if (failed(parser.parseOptionalKeyword("dependent_tensor_boundary")))
    return success();
  if (body.empty())
    return parser.emitError(parser.getCurrentLocation(),
                            "dependent tensor function boundaries require a body");

  DenseMap<StringRef, Value> functionArgNames;
  functionArgNames.reserve(entryArgs.size());
  for (auto [arg, value] :
       llvm::zip_equal(entryArgs, body.front().getArguments())) {
    StringRef name = normalizeSSAName(arg.ssaName.name);
    if (!name.empty())
      functionArgNames.try_emplace(name, value);
  }

  return failure(
      failed(parseBoundarySemanticsList(parser, "args", argTypes,
                                        functionArgNames, argSemantics)) ||
      failed(parseBoundarySemanticsList(parser, "results", resultTypes,
                                        functionArgNames, resultSemantics)));
}

static const DependentTensorValueSemantics *
findBoundarySemantics(ArrayRef<DependentTensorValueSemantics> semantics,
                      unsigned valueIndex) {
  for (const DependentTensorValueSemantics &candidate : semantics)
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

OpFoldResult ConstantOp::fold(FoldAdaptor adaptor) {
  return getValueAttr();
}

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
      return parser.emitError(arg.ssaName.location,
                              "dependent_tensor.seed_args is no longer supported");
  }
  for (DictionaryAttr attrs : resultAttrs) {
    if (hasDependentTensorSeedArgsAttr(attrs))
      return parser.emitError(signatureLocation,
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
  result.addAttribute(getFunctionTypeAttrName(result.name), TypeAttr::get(type));

  NamedAttrList parsedAttributes;
  SMLoc attributeDictLocation = parser.getCurrentLocation();
  if (parser.parseOptionalAttrDictWithKeyword(parsedAttributes))
    return failure();
  if (parsedAttributes.get("dependent_tensor.seed_args"))
    return parser.emitError(attributeDictLocation,
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
  properties.dependentTensorArgSemantics.clear();
  properties.dependentTensorResultSemantics.clear();
  if (parseDependentTensorBoundary(
          parser, entryArgs, argTypes, resultTypes, *body,
          properties.dependentTensorArgSemantics,
          properties.dependentTensorResultSemantics))
    return failure();
  return success();
}

void FuncOp::print(OpAsmPrinter &p) {
  function_interface_impl::printFunctionOp(
      p, *this, /*isVariadic=*/false, getFunctionTypeAttrName(),
      getArgAttrsAttrName(), getResAttrsAttrName());
  const auto &argSemantics = getProperties().dependentTensorArgSemantics;
  const auto &resultSemantics = getProperties().dependentTensorResultSemantics;
  if (argSemantics.empty() && resultSemantics.empty())
    return;

  p << " dependent_tensor_boundary args[";
  llvm::interleaveComma(argSemantics, p, [&](const auto &semantics) {
    p << semantics.valueIndex << " dims[";
    llvm::interleaveComma(semantics.dimValues, p,
                          [&](Value value) { p.printOperand(value); });
    p << "]";
    printBoundaryDimNames(p, semantics.dimNames);
  });
  p << "] results[";
  llvm::interleaveComma(resultSemantics, p, [&](const auto &semantics) {
    p << semantics.valueIndex << " dims[";
    llvm::interleaveComma(semantics.dimValues, p,
                          [&](Value value) { p.printOperand(value); });
    p << "]";
    printBoundaryDimNames(p, semantics.dimNames);
  });
  p << "]";
}

void FuncOp::walkDependentTensorPropertyValues(
    function_ref<void(Value &)> callback) {
  for (DependentTensorValueSemantics &semantics :
       getProperties().dependentTensorArgSemantics)
    for (Value &value : semantics.dimValues)
      callback(value);
  for (DependentTensorValueSemantics &semantics :
       getProperties().dependentTensorResultSemantics)
    for (Value &value : semantics.dimValues)
      callback(value);
}

FailureOr<DependentTensorValueSemantics>
FuncOp::getDependentTensorBlockArgumentSemantics(unsigned regionNumber,
                                                 unsigned blockNumber,
                                                 unsigned argumentNumber) {
  if (regionNumber != 0 || blockNumber != 0)
    return failure();
  if (const DependentTensorValueSemantics *semantics = findBoundarySemantics(
          getProperties().dependentTensorArgSemantics, argumentNumber))
    return *semantics;
  return failure();
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
