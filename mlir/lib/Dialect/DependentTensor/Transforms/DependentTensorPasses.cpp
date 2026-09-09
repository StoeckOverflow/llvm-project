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
                    const DependentTypeValueRefinement &stored) {
  if (stored.rank != type.getRank() || stored.hasExplicitLayout ||
      !stored.strideValues.empty() ||
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

static FailureOr<TensorValueRefinement>
verifyAndBuildTensorTypeRef(Operation *owner, StringRef kind, Type type,
                            const DependentTensorTypeRef &stored) {
  auto rankedType = dyn_cast<RankedTensorType>(type);
  if (!rankedType) {
    owner->emitOpError() << "requires ranked tensor type for dependent " << kind
                         << " type refs";
    return failure();
  }
  if (stored.hasExplicitLayout) {
    owner->emitOpError() << "has layout on dependent tensor " << kind
                         << " type refs";
    return failure();
  }
  if (stored.rank != rankedType.getRank()) {
    owner->emitOpError() << "requires dependent " << kind
                         << " rank to match tensor rank";
    return failure();
  }
  if (stored.dimValues.size() != static_cast<size_t>(rankedType.getRank())) {
    owner->emitOpError() << "requires one dependent dimension value per "
                         << kind << " tensor dimension";
    return failure();
  }

  TensorValueRefinement info{rankedType, {}};
  info.dimValues.reserve(stored.dimValues.size());
  for (auto [dim, operand] : llvm::enumerate(stored.dimValues)) {
    Value dimValue = operand.get();
    if (!rankedType.isDynamicDim(dim)) {
      owner->emitOpError()
          << "requires dependent " << kind
          << " dimensions to correspond to dynamic tensor dimensions";
      return failure();
    }
    if (!dimValue) {
      owner->emitOpError() << "has null dependent " << kind
                           << " dimension value";
      return failure();
    }
    if (!dimValue.getType().isIndex()) {
      owner->emitOpError() << "requires index-typed dependent " << kind
                           << " dimension values";
      return failure();
    }
    info.dimValues.push_back(dimValue);
  }
  return info;
}

static LogicalResult
verifyStoredTensorRefinement(Operation *owner, StringRef kind, Type type,
                             const DependentTypeValueRefinement &stored,
                             unsigned expectedIndex,
                             func::FuncOp funcBoundaryOwner = nullptr) {
  auto rankedType = dyn_cast<RankedTensorType>(type);
  if (!rankedType)
    return owner->emitOpError() << "requires ranked tensor type for dependent "
                                << kind << " refinements";
  if (stored.valueIndex != expectedIndex)
    return owner->emitOpError()
           << "has dependent " << kind << " refinements for wrong value index";
  if (stored.hasExplicitLayout || !stored.strideValues.empty())
    return owner->emitOpError()
           << "has layout on dependent tensor " << kind << " refinements";
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
    if (funcBoundaryOwner) {
      auto arg = dyn_cast<BlockArgument>(dimValue);
      if (!arg || funcBoundaryOwner.isExternal() ||
          arg.getOwner() != &funcBoundaryOwner.getBody().front())
        return owner->emitOpError()
               << "requires function boundary dependent " << kind
               << " dimensions to reference entry block arguments";
      continue;
    }
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

// Verify func.func #types metadata such as
//   #types[%A : #tensor<[%n, %m], f32>]
// The referenced value index must name the described argument/result, and all
// symbolic dims must be entry block args. This stays out of FuncOp's verifier
// so Func does not need to interpret dependent_tensor #tensor specs.
static LogicalResult verifyFuncBoundaryProperties(func::FuncOp func) {
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
    if (failed(verifyStoredTensorRefinement(
            func, "argument", func.getArgument(stored.valueIndex).getType(),
            stored, stored.valueIndex, func)))
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
    if (failed(verifyStoredTensorRefinement(
            func, "result", func.getResultTypes()[stored.valueIndex], stored,
            stored.valueIndex, func)))
      return failure();
  }
  return success();
}

// Verify that returned tensors satisfy the enclosing function's declared
// result #types. Example: returning %A to -> #tensor<[%n, %m], f32> requires
// %A to carry that same refinement.
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
    auto expected = buildInfoFromStored(rankedResultType, *stored);
    if (failed(actual) || failed(expected))
      return ret.emitOpError()
             << "failed to resolve dependent_tensor result refinements";
    if (!haveEqualRefinements(*actual, *expected))
      return ret.emitOpError() << "returned value does not match function "
                                  "result dependency metadata";
  }
  return success();
}

// Verify that call operands/results match the callee's #types contract after
// substituting callee entry block args with the actual call operands.
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
    DependentTypeValueRefinement mapped = *stored;
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

// Verify loop-carried refinements across the whole loop boundary: the init
// operand, region block argument, yielded value, and loop result must describe
// the same dependent tensor.
static LogicalResult
verifyLoopRefinements(Operation *owner,
                      ArrayRef<DependentTensorLoopTypeRef> loopTypeRefs,
                      ValueRange initOperands, TypeRange resultTypes,
                      ValueRange yieldedValues, Operation *yieldUseSite) {
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
    FailureOr<TensorValueRefinement> operandExpected =
        verifyAndBuildTensorTypeRef(owner, "loop operand",
                                    initOperands[ref.valueIndex].getType(),
                                    ref.operandTypeRef);
    if (failed(operandExpected))
      return failure();
    FailureOr<TensorValueRefinement> resultExpected =
        verifyAndBuildTensorTypeRef(owner, "loop result",
                                    resultTypes[ref.valueIndex],
                                    ref.resultTypeRef);
    if (failed(resultExpected))
      return failure();
    FailureOr<TensorValueRefinement> actualInit =
        getValueRefinement(initOperands[ref.valueIndex]);
    if (succeeded(actualInit) &&
        !haveEqualRefinements(*actualInit, *operandExpected))
      return owner->emitOpError()
             << "loop operand type reference does not match init refinements";
    FailureOr<TensorValueRefinement> actualYield =
        getValueRefinement(yieldedValues[ref.valueIndex]);
    if (succeeded(actualYield) &&
        !haveEqualRefinements(*actualYield, *resultExpected))
      return owner->emitOpError()
             << "loop result type reference does not match yielded refinements";
  }
  return success();
}

static LogicalResult verifyScfForRefinements(scf::ForOp forOp) {
  auto yield = cast<scf::YieldOp>(forOp.getBody()->getTerminator());
  return verifyLoopRefinements(
      forOp.getOperation(), forOp.getProperties().dependentTensorLoopTypeRefs,
      forOp.getInitArgs(), forOp.getResultTypes(), yield.getResults(),
      yield.getOperation());
}

static LogicalResult verifyAffineForRefinements(affine::AffineForOp forOp) {
  auto yield = cast<affine::AffineYieldOp>(forOp.getBody()->getTerminator());
  return verifyLoopRefinements(
      forOp.getOperation(), forOp.getProperties().dependentTensorLoopTypeRefs,
      forOp.getInits(), forOp.getResultTypes(), yield.getOperands(),
      yield.getOperation());
}

struct VerifyDependentTensorRefinementsPass
    : public dependent_tensor::impl::VerifyDependentTensorRefinementsPassBase<
          VerifyDependentTensorRefinementsPass> {
  using VerifyDependentTensorRefinementsPassBase<
      VerifyDependentTensorRefinementsPass>::
      VerifyDependentTensorRefinementsPassBase;

  void runOnOperation() override {
    ModuleOp module = getOperation();
    for (func::FuncOp func : module.getOps<func::FuncOp>()) {
      if (failed(verifyFuncBoundaryProperties(func)))
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
      if (failed(verifyScfForRefinements(forOp)))
        return WalkResult::interrupt();
      return WalkResult::advance();
    });
    if (scfWalk.wasInterrupted())
      return signalPassFailure();

    WalkResult affineWalk = module.walk([&](affine::AffineForOp forOp) {
      if (failed(verifyAffineForRefinements(forOp)))
        return WalkResult::interrupt();
      return WalkResult::advance();
    });
    if (affineWalk.wasInterrupted())
      return signalPassFailure();
  }
};
} // namespace
