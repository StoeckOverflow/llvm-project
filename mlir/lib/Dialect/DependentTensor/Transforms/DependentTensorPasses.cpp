//===- DependentTensorPasses.cpp - DependentTensor passes -----------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/DependentTensor/IR/DependentTensor.h"
#include "mlir/Dialect/DependentTensor/Transforms/Passes.h"
#include "mlir/Dialect/SCF/IR/SCF.h"
#include "mlir/IR/Dominance.h"
#include "mlir/IR/PropertySSAUseSupport.h"
#include "llvm/ADT/DenseSet.h"

namespace mlir {
namespace dependent_tensor {
#define GEN_PASS_DEF_VERIFYDEPENDENTTENSORSEMANTICSPASS
#include "mlir/Dialect/DependentTensor/Transforms/Passes.h.inc"
} // namespace dependent_tensor
} // namespace mlir

using namespace mlir;
using namespace mlir::dependent_tensor;

namespace {
static FailureOr<TensorValueSemantics>
buildInfoFromStored(RankedTensorType type,
                    const DependentTensorValueSemantics &stored) {
  if (stored.rank != type.getRank() ||
      stored.dimValues.size() != static_cast<size_t>(type.getRank()))
    return failure();
  TensorValueSemantics info{type, {}};
  info.dimValues.reserve(stored.dimValues.size());
  for (Value dimValue : stored.dimValues) {
    if (!dimValue || !dimValue.getType().isIndex())
      return failure();
    info.dimValues.push_back(dimValue);
  }
  return info;
}

static LogicalResult
verifyStoredTensorSemantics(Operation *owner, StringRef kind, Type type,
                            const DependentTensorValueSemantics &stored,
                            unsigned expectedIndex, DominanceInfo &dominance,
                            Operation *dominanceUseSite = nullptr,
                            func::FuncOp funcBoundaryOwner = nullptr) {
  auto rankedType = dyn_cast<RankedTensorType>(type);
  if (!rankedType)
    return owner->emitOpError() << "requires ranked tensor type for dependent "
                                << kind << " semantics";
  if (stored.valueIndex != expectedIndex)
    return owner->emitOpError()
           << "has dependent " << kind << " semantics for wrong value index";
  if (stored.rank != rankedType.getRank())
    return owner->emitOpError()
           << "requires dependent " << kind << " rank to match tensor rank";
  if (stored.dimValues.size() != static_cast<size_t>(rankedType.getRank()))
    return owner->emitOpError() << "requires one dependent dimension value per "
                                << kind << " tensor dimension";

  for (auto [dim, dimValue] : llvm::enumerate(stored.dimValues)) {
    if (!rankedType.isDynamicDim(dim))
      return owner->emitOpError()
             << "requires dependent " << kind
             << " dimensions to correspond to dynamic tensor dimensions";
    if (!dimValue)
      return owner->emitOpError()
             << "has null dependent " << kind << " dimension value";
    if (!dimValue.getType().isIndex())
      return owner->emitOpError() << "requires index-typed dependent " << kind
                                  << " dimension values";
    if (crossesPropertySSAUseIsolatedFromAboveBoundary(owner, dimValue))
      return owner->emitOpError() << "dependent " << kind
                                  << " dimension value illegally crosses an "
                                     "IsolatedFromAbove boundary";
    if (funcBoundaryOwner) {
      auto arg = dyn_cast<BlockArgument>(dimValue);
      if (!arg || funcBoundaryOwner.isExternal() ||
          arg.getOwner() != &funcBoundaryOwner.getBody().front())
        return owner->emitOpError()
               << "requires function boundary dependent " << kind
               << " dimensions to reference entry block arguments";
      continue;
    }
    Operation *useSite = dominanceUseSite ? dominanceUseSite : owner;
    if (!dominance.dominates(dimValue, useSite))
      return owner->emitOpError() << "dependent " << kind
                                  << " dimension value does not dominate owner";
  }
  return success();
}

static const DependentTensorValueSemantics *
findStoredSemantics(ArrayRef<DependentTensorValueSemantics> semantics,
                    unsigned valueIndex) {
  for (const DependentTensorValueSemantics &candidate : semantics)
    if (candidate.valueIndex == valueIndex)
      return &candidate;
  return nullptr;
}

static LogicalResult verifyFuncBoundaryProperties(func::FuncOp func,
                                                  DominanceInfo &dominance) {
  llvm::SmallDenseSet<unsigned> seenArgSemantics;
  for (const DependentTensorValueSemantics &stored :
       func.getProperties().dependentTensorArgSemantics) {
    if (!seenArgSemantics.insert(stored.valueIndex).second)
      return func.emitOpError() << "has duplicate dependent argument semantics";
    if (stored.valueIndex >= func.getNumArguments())
      return func.emitOpError()
             << "has dependent argument semantics out of range";
    if (failed(verifyStoredTensorSemantics(
            func, "argument", func.getArgument(stored.valueIndex).getType(),
            stored, stored.valueIndex, dominance, /*dominanceUseSite=*/nullptr,
            func)))
      return failure();
  }
  llvm::SmallDenseSet<unsigned> seenResultSemantics;
  for (const DependentTensorValueSemantics &stored :
       func.getProperties().dependentTensorResultSemantics) {
    if (!seenResultSemantics.insert(stored.valueIndex).second)
      return func.emitOpError() << "has duplicate dependent result semantics";
    if (stored.valueIndex >= func.getNumResults())
      return func.emitOpError()
             << "has dependent result semantics out of range";
    if (failed(verifyStoredTensorSemantics(
            func, "result", func.getResultTypes()[stored.valueIndex], stored,
            stored.valueIndex, dominance, /*dominanceUseSite=*/nullptr, func)))
      return failure();
  }
  return success();
}

static LogicalResult verifyInterfaceProperties(Operation *op,
                                               DominanceInfo &dominance) {
  auto iface = dyn_cast<DependentTensorPropertyOpInterface>(op);
  if (!iface)
    return success();
  if (isa<func::FuncOp>(op))
    return success();

  for (OpResult result : op->getResults()) {
    FailureOr<DependentTensorValueSemantics> stored =
        iface.getDependentTensorResultSemantics(result.getResultNumber());
    if (failed(stored))
      continue;
    if (failed(verifyStoredTensorSemantics(op, "result", result.getType(),
                                           *stored, result.getResultNumber(),
                                           dominance)))
      return failure();
  }

  for (auto [regionNumber, region] : llvm::enumerate(op->getRegions())) {
    for (auto [blockNumber, block] : llvm::enumerate(region)) {
      for (BlockArgument arg : block.getArguments()) {
        FailureOr<DependentTensorValueSemantics> stored =
            iface.getDependentTensorBlockArgumentSemantics(
                regionNumber, blockNumber, arg.getArgNumber());
        if (failed(stored))
          continue;
        if (failed(verifyStoredTensorSemantics(
                op, "block argument", arg.getType(), *stored,
                arg.getArgNumber(), dominance, op)))
          return failure();
      }
    }
  }
  return success();
}

static LogicalResult verifyReturnSemantics(func::FuncOp func,
                                           func::ReturnOp ret) {
  for (auto [i, operand] : llvm::enumerate(ret.getOperands())) {
    const DependentTensorValueSemantics *stored = findStoredSemantics(
        func.getProperties().dependentTensorResultSemantics, i);
    auto actual = getValueSemantics(operand);
    if (!stored) {
      if (succeeded(actual))
        return ret.emitOpError()
               << "returned value carries dependent_tensor semantics not "
                  "declared in function result properties";
      continue;
    }

    auto rankedResultType =
        dyn_cast<RankedTensorType>(func.getResultTypes()[i]);
    auto expected = buildInfoFromStored(rankedResultType, *stored);
    if (failed(actual) || failed(expected))
      return ret.emitOpError()
             << "failed to resolve dependent_tensor result semantics";
    if (!haveEqualSemantics(*actual, *expected))
      return ret.emitOpError() << "returned value does not match function "
                                  "result dependency metadata";
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
    const DependentTensorValueSemantics *stored = findStoredSemantics(
        callee.getProperties().dependentTensorArgSemantics, i);
    auto actual = getValueSemantics(operand);
    if (!stored) {
      if (succeeded(actual))
        return call.emitOpError() << "operand #" << i
                                  << " carries dependent_tensor semantics not "
                                     "declared by the callee";
      continue;
    }

    auto rankedArgType =
        dyn_cast<RankedTensorType>(callee.getArgumentTypes()[i]);
    SmallVector<Value> mappedDims;
    mappedDims.reserve(stored->dimValues.size());
    for (Value dimValue : stored->dimValues) {
      auto arg = dyn_cast<BlockArgument>(dimValue);
      if (!arg || callee.isExternal() ||
          arg.getOwner() != &callee.getBody().front() ||
          arg.getArgNumber() >= call.getNumOperands())
        return call.emitOpError() << "failed to map callee dependent_tensor "
                                     "semantics for operand #"
                                  << i;
      mappedDims.push_back(call.getOperand(arg.getArgNumber()));
    }
    DependentTensorValueSemantics mapped = *stored;
    mapped.dimValues = std::move(mappedDims);
    auto expected = buildInfoFromStored(rankedArgType, mapped);
    if (failed(actual) || failed(expected))
      return call.emitOpError()
             << "failed to resolve dependent_tensor semantics for operand #"
             << i;
    if (!haveEqualSemantics(*actual, *expected))
      return call.emitOpError() << "operand #" << i
                                << " does not match callee dependency metadata";
  }
  for (OpResult result : call.getResults()) {
    const DependentTensorValueSemantics *stored = findStoredSemantics(
        callee.getProperties().dependentTensorResultSemantics,
        result.getResultNumber());
    if (!stored)
      continue;
    if (failed(getValueSemantics(result)))
      return call.emitOpError()
             << "failed to resolve dependent_tensor semantics for result #"
             << result.getResultNumber();
  }
  return success();
}

static LogicalResult verifyScfForSemantics(scf::ForOp forOp) {
  auto yield = cast<scf::YieldOp>(forOp.getBody()->getTerminator());
  for (OpResult result : forOp.getResults()) {
    auto resultInfo = getValueSemantics(result);
    if (failed(resultInfo))
      continue;
    unsigned index = result.getResultNumber();
    auto initInfo = getValueSemantics(forOp.getInitArgs()[index]);
    auto iterInfo = getValueSemantics(forOp.getRegionIterArg(index));
    auto yieldInfo = getValueSemantics(yield.getOperand(index));
    if (failed(initInfo) || failed(iterInfo) || failed(yieldInfo))
      return forOp.emitOpError()
             << "failed to resolve loop-carried dependent_tensor semantics";
    if (!haveEqualSemantics(*resultInfo, *initInfo) ||
        !haveEqualSemantics(*resultInfo, *iterInfo) ||
        !haveEqualSemantics(*resultInfo, *yieldInfo))
      return forOp.emitOpError()
             << "loop-carried dependent_tensor semantics do not match";
  }
  return success();
}

struct VerifyDependentTensorSemanticsPass
    : public dependent_tensor::impl::VerifyDependentTensorSemanticsPassBase<
          VerifyDependentTensorSemanticsPass> {
  using VerifyDependentTensorSemanticsPassBase<
      VerifyDependentTensorSemanticsPass>::
      VerifyDependentTensorSemanticsPassBase;

  void runOnOperation() override {
    ModuleOp module = getOperation();
    DominanceInfo dominance(module);
    WalkResult propertyWalk = module.walk([&](Operation *op) {
      if (failed(verifyInterfaceProperties(op, dominance)))
        return WalkResult::interrupt();
      return WalkResult::advance();
    });
    if (propertyWalk.wasInterrupted())
      return signalPassFailure();

    for (func::FuncOp func : module.getOps<func::FuncOp>()) {
      if (failed(verifyFuncBoundaryProperties(func, dominance)))
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

    WalkResult scfWalk = module.walk([&](scf::ForOp forOp) {
      if (failed(verifyScfForSemantics(forOp)))
        return WalkResult::interrupt();
      return WalkResult::advance();
    });
    if (scfWalk.wasInterrupted())
      return signalPassFailure();
  }
};
} // namespace
