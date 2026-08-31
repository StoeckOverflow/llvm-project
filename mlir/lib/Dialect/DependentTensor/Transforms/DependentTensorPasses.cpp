//===- DependentTensorPasses.cpp - DependentTensor passes -----------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/Affine/IR/AffineOps.h"
#include "mlir/Dialect/DependentTensor/IR/DependentTensor.h"
#include "mlir/Dialect/DependentTensor/Transforms/Passes.h"
#include "mlir/Dialect/SCF/IR/SCF.h"
#include "mlir/IR/Dominance.h"
#include "mlir/IR/PropertySSAUseSupport.h"
#include "llvm/ADT/DenseSet.h"

namespace mlir {
namespace dependent_tensor {
#define GEN_PASS_DEF_VERIFYDEPENDENTTENSORREFINEMENTSPASS
#include "mlir/Dialect/DependentTensor/Transforms/Passes.h.inc"
} // namespace dependent_tensor
} // namespace mlir

using namespace mlir;
using namespace mlir::dependent_tensor;

namespace {
static FailureOr<TensorValueRefinement>
buildInfoFromStored(RankedTensorType type,
                    const DependentTensorValueRefinement &stored) {
  if (stored.rank != type.getRank() ||
      stored.dimValues.size() != static_cast<size_t>(type.getRank()))
    return failure();
  TensorValueRefinement info{type, {}};
  info.dimValues.reserve(stored.dimValues.size());
  for (const PropertyOperand &operand : stored.dimValues) {
    Value dimValue = operand.get();
    if (!dimValue || !dimValue.getType().isIndex())
      return failure();
    info.dimValues.push_back(dimValue);
  }
  return info;
}

static DependentTensorValueRefinement
convertToTensorRefinement(const DependentTypeValueRefinement &stored) {
  DependentTensorValueRefinement converted;
  converted.valueIndex = stored.valueIndex;
  converted.rank = stored.rank;
  converted.assignDimValues(stored.getDimValues());
  return converted;
}

static FailureOr<TensorValueRefinement>
buildInfoFromTypeRef(RankedTensorType type,
                     const DependentTensorTypeRef &stored) {
  if (stored.rank != type.getRank() ||
      stored.dimValues.size() != static_cast<size_t>(type.getRank()))
    return failure();
  TensorValueRefinement info{type, {}};
  info.dimValues.reserve(stored.dimValues.size());
  for (const PropertyOperand &operand : stored.dimValues) {
    Value dimValue = operand.get();
    if (!dimValue || !dimValue.getType().isIndex())
      return failure();
    info.dimValues.push_back(dimValue);
  }
  return info;
}

static LogicalResult
verifyStoredTensorTypeRef(Operation *owner, StringRef kind, Type type,
                          const DependentTensorTypeRef &stored,
                          DominanceInfo &dominance,
                          Operation *dominanceUseSite = nullptr) {
  auto rankedType = dyn_cast<RankedTensorType>(type);
  if (!rankedType)
    return owner->emitOpError() << "requires ranked tensor type for dependent "
                                << kind << " type refs";
  if (stored.rank != rankedType.getRank())
    return owner->emitOpError()
           << "requires dependent " << kind << " rank to match tensor rank";
  if (stored.dimValues.size() != static_cast<size_t>(rankedType.getRank()))
    return owner->emitOpError() << "requires one dependent dimension value per "
                                << kind << " tensor dimension";

  for (auto [dim, operand] : llvm::enumerate(stored.dimValues)) {
    Value dimValue = operand.get();
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
    Operation *useSite = dominanceUseSite ? dominanceUseSite : owner;
    if (!dominance.dominates(dimValue, useSite))
      return owner->emitOpError() << "dependent " << kind
                                  << " dimension value does not dominate owner";
  }
  return success();
}

static LogicalResult
verifyConcreteValueMatchesTypeRef(Operation *owner, StringRef message,
                                  Value value,
                                  const DependentTensorTypeRef &typeRef) {
  FailureOr<TensorValueRefinement> actual = getValueRefinement(value);
  if (failed(actual))
    return success();
  auto rankedType = dyn_cast<RankedTensorType>(value.getType());
  if (!rankedType)
    return owner->emitOpError()
           << "requires ranked tensor type for dependent " << message;
  FailureOr<TensorValueRefinement> expected =
      buildInfoFromTypeRef(rankedType, typeRef);
  if (failed(expected) || !haveEqualRefinements(*actual, *expected))
    return owner->emitOpError() << message;
  return success();
}

static LogicalResult
verifyStoredTensorRefinement(Operation *owner, StringRef kind, Type type,
                             const DependentTensorValueRefinement &stored,
                             unsigned expectedIndex, DominanceInfo &dominance,
                             Operation *dominanceUseSite = nullptr,
                             func::FuncOp funcBoundaryOwner = nullptr) {
  auto rankedType = dyn_cast<RankedTensorType>(type);
  if (!rankedType)
    return owner->emitOpError() << "requires ranked tensor type for dependent "
                                << kind << " refinements";
  if (stored.valueIndex != expectedIndex)
    return owner->emitOpError()
           << "has dependent " << kind << " refinements for wrong value index";
  if (stored.rank != rankedType.getRank())
    return owner->emitOpError()
           << "requires dependent " << kind << " rank to match tensor rank";
  if (stored.dimValues.size() != static_cast<size_t>(rankedType.getRank()))
    return owner->emitOpError() << "requires one dependent dimension value per "
                                << kind << " tensor dimension";

  for (auto [dim, dimValue] : llvm::enumerate(stored.getDimValues())) {
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

static const DependentTypeValueRefinement *
findStoredRefinement(ArrayRef<DependentTypeValueRefinement> refinements,
                     unsigned valueIndex) {
  for (const DependentTypeValueRefinement &candidate : refinements)
    if (candidate.valueIndex == valueIndex)
      return &candidate;
  return nullptr;
}

static LogicalResult verifyFuncBoundaryProperties(func::FuncOp func,
                                                  DominanceInfo &dominance) {
  llvm::SmallDenseSet<unsigned> seenArgRefinements;
  for (const DependentTypeValueRefinement &stored :
       func.getProperties().dependentTypeArgRefinements) {
    if (stored.valueIndex >= func.getNumArguments())
      return func.emitOpError()
             << "has dependent argument refinements out of range";
    if (!isa<RankedTensorType>(func.getArgument(stored.valueIndex).getType()))
      continue;
    if (!seenArgRefinements.insert(stored.valueIndex).second)
      return func.emitOpError()
             << "has duplicate dependent argument refinements";
    if (stored.hasExplicitLayout)
      return func.emitOpError()
             << "has layout on dependent tensor argument refinements";
    DependentTensorValueRefinement tensorRef =
        convertToTensorRefinement(stored);
    if (failed(verifyStoredTensorRefinement(
            func, "argument", func.getArgument(stored.valueIndex).getType(),
            tensorRef, stored.valueIndex, dominance,
            /*dominanceUseSite=*/nullptr, func)))
      return failure();
  }
  llvm::SmallDenseSet<unsigned> seenResultRefinements;
  for (const DependentTypeValueRefinement &stored :
       func.getProperties().dependentTypeResultRefinements) {
    if (stored.valueIndex >= func.getNumResults())
      return func.emitOpError()
             << "has dependent result refinements out of range";
    if (!isa<RankedTensorType>(func.getResultTypes()[stored.valueIndex]))
      continue;
    if (!seenResultRefinements.insert(stored.valueIndex).second)
      return func.emitOpError() << "has duplicate dependent result refinements";
    if (stored.hasExplicitLayout)
      return func.emitOpError()
             << "has layout on dependent tensor result refinements";
    DependentTensorValueRefinement tensorRef =
        convertToTensorRefinement(stored);
    if (failed(verifyStoredTensorRefinement(
            func, "result", func.getResultTypes()[stored.valueIndex], tensorRef,
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
    FailureOr<DependentTensorValueRefinement> stored =
        iface.getDependentTensorResultRefinement(result.getResultNumber());
    if (failed(stored))
      continue;
    if (failed(verifyStoredTensorRefinement(op, "result", result.getType(),
                                            *stored, result.getResultNumber(),
                                            dominance)))
      return failure();
  }

  for (auto [regionNumber, region] : llvm::enumerate(op->getRegions())) {
    for (auto [blockNumber, block] : llvm::enumerate(region)) {
      for (BlockArgument arg : block.getArguments()) {
        FailureOr<DependentTensorValueRefinement> stored =
            iface.getDependentTensorBlockArgumentRefinement(
                regionNumber, blockNumber, arg.getArgNumber());
        if (failed(stored))
          continue;
        if (failed(verifyStoredTensorRefinement(
                op, "block argument", arg.getType(), *stored,
                arg.getArgNumber(), dominance, op)))
          return failure();
      }
    }
  }
  return success();
}

static LogicalResult verifyReturnRefinements(func::FuncOp func,
                                             func::ReturnOp ret) {
  for (auto [i, operand] : llvm::enumerate(ret.getOperands())) {
    const DependentTypeValueRefinement *stored = findStoredRefinement(
        func.getProperties().dependentTypeResultRefinements, i);
    auto actual = getValueRefinement(operand);
    if (!stored || stored->hasExplicitLayout) {
      if (succeeded(actual))
        return ret.emitOpError()
               << "returned value carries dependent_tensor refinements not "
                  "declared in function result properties";
      continue;
    }

    auto rankedResultType =
        dyn_cast<RankedTensorType>(func.getResultTypes()[i]);
    DependentTensorValueRefinement tensorRef =
        convertToTensorRefinement(*stored);
    auto expected = buildInfoFromStored(rankedResultType, tensorRef);
    if (failed(actual) || failed(expected))
      return ret.emitOpError()
             << "failed to resolve dependent_tensor result refinements";
    if (!haveEqualRefinements(*actual, *expected))
      return ret.emitOpError() << "returned value does not match function "
                                  "result dependency metadata";
  }
  return success();
}

static LogicalResult verifyCallRefinements(func::CallOp call) {
  auto callee = SymbolTable::lookupNearestSymbolFrom<func::FuncOp>(
      call, call.getCalleeAttr());
  if (!callee)
    return call.emitOpError(
        "does not reference a valid callee for dependent_tensor verification");

  for (auto [i, operand] : llvm::enumerate(call.getOperands())) {
    const DependentTypeValueRefinement *stored = findStoredRefinement(
        callee.getProperties().dependentTypeArgRefinements, i);
    auto actual = getValueRefinement(operand);
    if (!stored || stored->hasExplicitLayout) {
      if (succeeded(actual))
        return call.emitOpError()
               << "operand #" << i
               << " carries dependent_tensor refinements not "
                  "declared by the callee";
      continue;
    }

    auto rankedArgType =
        dyn_cast<RankedTensorType>(callee.getArgumentTypes()[i]);
    SmallVector<Value> mappedDims;
    mappedDims.reserve(stored->dimValues.size());
    for (Value dimValue : stored->getDimValues()) {
      auto arg = dyn_cast<BlockArgument>(dimValue);
      if (!arg || callee.isExternal() ||
          arg.getOwner() != &callee.getBody().front() ||
          arg.getArgNumber() >= call.getNumOperands())
        return call.emitOpError() << "failed to map callee dependent_tensor "
                                     "refinements for operand #"
                                  << i;
      mappedDims.push_back(call.getOperand(arg.getArgNumber()));
    }
    DependentTensorValueRefinement mapped = convertToTensorRefinement(*stored);
    mapped.assignDimValues(mappedDims);
    auto expected = buildInfoFromStored(rankedArgType, mapped);
    if (failed(actual) || failed(expected))
      return call.emitOpError()
             << "failed to resolve dependent_tensor refinements for operand #"
             << i;
    if (!haveEqualRefinements(*actual, *expected))
      return call.emitOpError() << "operand #" << i
                                << " does not match callee dependency metadata";
  }
  for (OpResult result : call.getResults()) {
    const DependentTypeValueRefinement *stored = findStoredRefinement(
        callee.getProperties().dependentTypeResultRefinements,
        result.getResultNumber());
    if (!stored || stored->hasExplicitLayout)
      continue;
    if (failed(getValueRefinement(result)))
      return call.emitOpError()
             << "failed to resolve dependent_tensor refinements for result #"
             << result.getResultNumber();
  }
  return success();
}

static LogicalResult verifyLoopRefinements(
    Operation *owner, ArrayRef<DependentTensorLoopTypeRef> loopTypeRefs,
    ValueRange initOperands, TypeRange resultTypes, ValueRange yieldedValues,
    Operation *yieldUseSite, DominanceInfo &dominance) {
  llvm::SmallDenseSet<unsigned> seenLoopRefs;
  for (const DependentTensorLoopTypeRef &ref : loopTypeRefs) {
    if (!seenLoopRefs.insert(ref.valueIndex).second)
      return owner->emitOpError()
             << "has duplicate dependent tensor loop type refs";
    if (ref.valueIndex >= resultTypes.size() ||
        ref.valueIndex >= initOperands.size() ||
        ref.valueIndex >= yieldedValues.size())
      return owner->emitOpError()
             << "has dependent tensor loop type refs out of range";
    if (failed(verifyStoredTensorTypeRef(owner, "loop operand",
                                         initOperands[ref.valueIndex].getType(),
                                         ref.operandTypeRef, dominance, owner)))
      return failure();
    if (failed(verifyStoredTensorTypeRef(owner, "loop result",
                                         resultTypes[ref.valueIndex],
                                         ref.resultTypeRef, dominance, owner)))
      return failure();
    if (failed(verifyStoredTensorTypeRef(
            owner, "loop yield", yieldedValues[ref.valueIndex].getType(),
            ref.resultTypeRef, dominance, yieldUseSite)))
      return failure();
    if (failed(verifyConcreteValueMatchesTypeRef(
            owner,
            "loop operand type reference does not match init refinements",
            initOperands[ref.valueIndex], ref.operandTypeRef)))
      return failure();
    if (failed(verifyConcreteValueMatchesTypeRef(
            owner,
            "loop result type reference does not match yielded refinements",
            yieldedValues[ref.valueIndex], ref.resultTypeRef)))
      return failure();
  }
  return success();
}

static LogicalResult verifyScfForRefinements(scf::ForOp forOp,
                                             DominanceInfo &dominance) {
  auto yield = cast<scf::YieldOp>(forOp.getBody()->getTerminator());
  return verifyLoopRefinements(
      forOp.getOperation(), forOp.getProperties().dependentTensorLoopTypeRefs,
      forOp.getInitArgs(), forOp.getResultTypes(), yield.getResults(),
      yield.getOperation(), dominance);
}

static LogicalResult verifyAffineForRefinements(affine::AffineForOp forOp,
                                                DominanceInfo &dominance) {
  auto yield = cast<affine::AffineYieldOp>(forOp.getBody()->getTerminator());
  return verifyLoopRefinements(
      forOp.getOperation(), forOp.getProperties().dependentTensorLoopTypeRefs,
      forOp.getInits(), forOp.getResultTypes(), yield.getOperands(),
      yield.getOperation(), dominance);
}

struct VerifyDependentTensorRefinementsPass
    : public dependent_tensor::impl::VerifyDependentTensorRefinementsPassBase<
          VerifyDependentTensorRefinementsPass> {
  using VerifyDependentTensorRefinementsPassBase<
      VerifyDependentTensorRefinementsPass>::
      VerifyDependentTensorRefinementsPassBase;

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
        if (failed(verifyReturnRefinements(func, ret)))
          return signalPassFailure();
    }

    WalkResult callWalk = module.walk([&](func::CallOp call) {
      if (failed(verifyCallRefinements(call)))
        return WalkResult::interrupt();
      return WalkResult::advance();
    });
    if (callWalk.wasInterrupted())
      return signalPassFailure();

    WalkResult scfWalk = module.walk([&](scf::ForOp forOp) {
      if (failed(verifyScfForRefinements(forOp, dominance)))
        return WalkResult::interrupt();
      return WalkResult::advance();
    });
    if (scfWalk.wasInterrupted())
      return signalPassFailure();

    WalkResult affineWalk = module.walk([&](affine::AffineForOp forOp) {
      if (failed(verifyAffineForRefinements(forOp, dominance)))
        return WalkResult::interrupt();
      return WalkResult::advance();
    });
    if (affineWalk.wasInterrupted())
      return signalPassFailure();
  }
};
} // namespace
