//===- DependentTensorPasses.cpp - DependentTensor passes -----------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/DependentTensor/IR/DependentTensor.h"
#include "mlir/Dialect/DependentTensor/Transforms/Passes.h"
#include "mlir/Interfaces/FunctionInterfaces.h"

namespace mlir {
namespace dependent_tensor {
#define GEN_PASS_DEF_VERIFYDEPENDENTTENSORSEMANTICSPASS
#define GEN_PASS_DEF_DEPENDENTTENSORCLONELOCALPRODUCERPASS
#define GEN_PASS_DEF_DEPENDENTTENSORREPLACESEEDPASS
#include "mlir/Dialect/DependentTensor/Transforms/Passes.h.inc"
} // namespace dependent_tensor
} // namespace mlir

using namespace mlir;
using namespace mlir::dependent_tensor;

namespace {
static FailureOr<SmallVector<int32_t>>
getSeedPositionsFromMetadata(DictionaryAttr attrs, RankedTensorType type,
                             MLIRContext *context) {
  if (!attrs || !attrs.get(getSeedArgsAttrName(context)))
    return failure();
  auto positions =
      dyn_cast_or_null<DenseI32ArrayAttr>(attrs.get(getSeedArgsAttrName(context)));
  if (!positions || positions.size() != static_cast<unsigned>(type.getRank()))
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
getExpectedInfoFromMetadata(RankedTensorType type, DictionaryAttr attrs,
                            ValueRange functionArgs) {
  auto seedPositions =
      getSeedPositionsFromMetadata(attrs, type, type.getContext());
  if (failed(seedPositions))
    return failure();

  TensorValueSemantics info{type, {}};
  info.dimSeeds.reserve(seedPositions->size());
  for (int32_t seedPosition : *seedPositions) {
    if (seedPosition < 0 ||
        seedPosition >= static_cast<int32_t>(functionArgs.size()))
      return failure();
    Value seed = functionArgs[seedPosition];
    if (!seed.getType().isIndex())
      return failure();
    info.dimSeeds.push_back(seed);
  }
  return info;
}

static LogicalResult verifyFunctionMetadata(func::FuncOp func) {
  auto verifyOne = [&](Type type, DictionaryAttr attrs, StringRef kind,
                       unsigned index) -> LogicalResult {
    if (!attrs || !attrs.get(getSeedArgsAttrName(func.getContext())))
      return success();
    auto rankedType = dyn_cast<RankedTensorType>(type);
    if (!rankedType)
      return func.emitOpError() << "expects ranked tensor type for " << kind
                                << " metadata #" << index;
    auto expected =
        getExpectedInfoFromMetadata(rankedType, attrs, func.getArguments());
    if (failed(expected))
      return func.emitOpError() << "has invalid dependent_tensor metadata for "
                                << kind << " #" << index;
    return success();
  };

  for (auto [i, arg] : llvm::enumerate(func.getArgumentTypes()))
    if (failed(verifyOne(arg, function_interface_impl::getArgAttrDict(func, i),
                         "argument", i)))
      return failure();
  for (auto [i, res] : llvm::enumerate(func.getResultTypes()))
    if (failed(verifyOne(res, function_interface_impl::getResultAttrDict(func, i),
                         "result", i)))
      return failure();
  return success();
}

static LogicalResult verifyReturnSemantics(func::FuncOp func,
                                           func::ReturnOp ret) {
  for (auto [i, operand] : llvm::enumerate(ret.getOperands())) {
    auto resultAttrs = function_interface_impl::getResultAttrDict(func, i);
    auto actual = getValueSemantics(operand);
    if (!resultAttrs || !resultAttrs.get(getSeedArgsAttrName(func.getContext()))) {
      if (succeeded(actual))
        return ret.emitOpError()
               << "returned value carries dependent_tensor semantics not "
                  "declared in function result metadata";
      continue;
    }

    auto rankedResultType = dyn_cast<RankedTensorType>(func.getResultTypes()[i]);
    auto expected =
        getExpectedInfoFromMetadata(rankedResultType, resultAttrs,
                                    func.getArguments());
    if (failed(actual) || failed(expected))
      return ret.emitOpError()
             << "failed to resolve dependent_tensor result semantics";
    if (!haveEqualSemantics(*actual, *expected))
      return ret.emitOpError()
             << "returned value does not match function result dependency metadata";
  }
  return success();
}

static LogicalResult verifyCallSemantics(func::CallOp call) {
  auto callee = SymbolTable::lookupNearestSymbolFrom<func::FuncOp>(
      call, call.getCalleeAttr());
  if (!callee)
    return call.emitOpError(
        "does not reference a valid callee for dependent_tensor verification");

  for (auto [i, operand] : llvm::enumerate(call.getOperands())) {
    auto argAttrs = function_interface_impl::getArgAttrDict(callee, i);
    auto actual = getValueSemantics(operand);
    if (!argAttrs || !argAttrs.get(getSeedArgsAttrName(call.getContext()))) {
      if (succeeded(actual))
        return call.emitOpError()
               << "operand #" << i
               << " carries dependent_tensor semantics not declared by the callee";
      continue;
    }

    auto rankedArgType = dyn_cast<RankedTensorType>(callee.getArgumentTypes()[i]);
    auto expected =
        getExpectedInfoFromMetadata(rankedArgType, argAttrs, call.getOperands());
    if (failed(actual) || failed(expected))
      return call.emitOpError()
             << "failed to resolve dependent_tensor semantics for operand #"
             << i;
    if (!haveEqualSemantics(*actual, *expected))
      return call.emitOpError() << "operand #" << i
                                << " does not match callee dependency metadata";
  }
  return success();
}

struct VerifyDependentTensorSemanticsPass
    : public dependent_tensor::impl::VerifyDependentTensorSemanticsPassBase<
          VerifyDependentTensorSemanticsPass> {
  using VerifyDependentTensorSemanticsPassBase<
      VerifyDependentTensorSemanticsPass>::VerifyDependentTensorSemanticsPassBase;

  void runOnOperation() override {
    ModuleOp module = getOperation();
    for (func::FuncOp func : module.getOps<func::FuncOp>()) {
      if (failed(verifyFunctionMetadata(func)))
        return signalPassFailure();
      for (func::ReturnOp ret : func.getOps<func::ReturnOp>())
        if (failed(verifyReturnSemantics(func, ret)))
          return signalPassFailure();
    }

    WalkResult callWalk = module.walk([&](func::CallOp call) {
      if (failed(verifyCallSemantics(call)))
        return WalkResult::interrupt();
      return WalkResult::advance();
    });
    if (callWalk.wasInterrupted())
      return signalPassFailure();
  }
};

struct DependentTensorCloneLocalProducerPass
    : public dependent_tensor::impl::DependentTensorCloneLocalProducerPassBase<
          DependentTensorCloneLocalProducerPass> {
  using DependentTensorCloneLocalProducerPassBase<
      DependentTensorCloneLocalProducerPass>::DependentTensorCloneLocalProducerPassBase;

  void runOnOperation() override {
    Block &entry = getOperation().getBody().front();
    SmallVector<Operation *> toClone;
    for (Operation &op : entry) {
      if (op.hasTrait<OpTrait::IsTerminator>())
        break;
      toClone.push_back(&op);
    }
    if (toClone.empty()) {
      signalPassFailure();
      return;
    }

    IRMapping mapping;
    OpBuilder builder(getOperation().getContext());
    builder.setInsertionPoint(entry.getTerminator());
    for (Operation *op : toClone)
      builder.clone(*op, mapping);
  }
};

struct DependentTensorReplaceSeedPass
    : public dependent_tensor::impl::DependentTensorReplaceSeedPassBase<
          DependentTensorReplaceSeedPass> {
  using DependentTensorReplaceSeedPassBase<
      DependentTensorReplaceSeedPass>::DependentTensorReplaceSeedPassBase;

  void runOnOperation() override {
    SmallVector<Value> indexResults;
    for (Operation &op : getOperation().getBody().front())
      for (Value result : op.getResults())
        if (result.getType().isIndex())
          indexResults.push_back(result);
    if (indexResults.size() < 2)
      return;
    indexResults.front().replaceAllUsesWith(indexResults[1]);
  }
};
} // namespace
