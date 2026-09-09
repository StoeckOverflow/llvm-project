//===- DependentMemRefPasses.cpp - DependentMemRef passes -----------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/DependentMemRef/Transforms/Passes.h"

#include "mlir/Dialect/Affine/IR/AffineOps.h"
#include "mlir/Dialect/DependentMemRef/IR/DependentMemRef.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Dialect/SCF/IR/SCF.h"
#include "mlir/IR/BuiltinOps.h"
#include "llvm/ADT/DenseSet.h"

namespace mlir {
namespace dependent_memref {
#define GEN_PASS_DEF_VERIFYDEPENDENTMEMREFREFINEMENTSPASS
#include "mlir/Dialect/DependentMemRef/Transforms/Passes.h.inc"
} // namespace dependent_memref
} // namespace mlir

using namespace mlir;
using namespace mlir::dependent_memref;

namespace {
static WalkResult interruptIfFailed(LogicalResult result) {
  return failed(result) ? WalkResult::interrupt() : WalkResult::advance();
}

static DependentMemRefValueRefinement
convertToMemRefRefinement(const DependentTypeValueRefinement &stored) {
  DependentMemRefValueRefinement converted;
  converted.valueIndex = stored.valueIndex;
  converted.rank = stored.rank;
  converted.offset = stored.offset;
  converted.hasExplicitLayout = stored.hasExplicitLayout;
  converted.assignDimValues(stored.getDimValues());
  converted.assignStrideValues(stored.getStrideValues());
  return converted;
}

static bool haveEqualRefinements(const MemRefValueRefinement &lhs,
                                 const MemRefValueRefinement &rhs) {
  return lhs.type == rhs.type && lhs.dimValues == rhs.dimValues &&
         lhs.offset == rhs.offset && lhs.strideValues == rhs.strideValues &&
         lhs.hasExplicitLayout == rhs.hasExplicitLayout;
}

static FailureOr<MemRefValueRefinement>
decodeStoredRefinementForType(MemRefType type,
                              const DependentMemRefValueRefinement &stored) {
  bool flatCarrier = allowsFlatMemRefCarrier(type, stored);
  if (!flatCarrier && stored.rank != type.getRank())
    return failure();
  MemRefValueRefinement info{type, stored.getDimValues(), stored.offset,
                             stored.getStrideValues(),
                             stored.hasExplicitLayout};
  if (info.dimValues.size() != static_cast<size_t>(stored.rank))
    return failure();
  if (info.hasExplicitLayout &&
      info.strideValues.size() != static_cast<size_t>(stored.rank))
    return failure();
  return info;
}

static FailureOr<MemRefValueRefinement>
verifyAndBuildMemRefTypeRef(Operation *owner, StringRef kind, Type type,
                            const DependentTensorTypeRef &stored) {
  auto memrefType = dyn_cast<MemRefType>(type);
  if (!memrefType) {
    owner->emitOpError() << "requires memref type for dependent " << kind
                         << " type refs";
    return failure();
  }
  if (stored.rank != memrefType.getRank()) {
    owner->emitOpError() << "requires dependent " << kind
                         << " rank to match memref rank";
    return failure();
  }
  if (stored.dimValues.size() != static_cast<size_t>(memrefType.getRank())) {
    owner->emitOpError() << "requires one dependent dimension value per "
                         << kind << " memref dimension";
    return failure();
  }
  if (stored.hasExplicitLayout &&
      stored.strideValues.size() != static_cast<size_t>(stored.rank)) {
    owner->emitOpError() << "requires one dependent stride value per " << kind
                         << " memref dimension";
    return failure();
  }

  MemRefValueRefinement info{
      memrefType, {}, stored.offset, {}, stored.hasExplicitLayout};
  info.dimValues.reserve(stored.dimValues.size());
  for (auto [dim, operand] : llvm::enumerate(stored.dimValues)) {
    Value dimValue = operand.get();
    if (!memrefType.isDynamicDim(dim)) {
      owner->emitOpError()
          << "requires dependent " << kind
          << " dimensions to correspond to dynamic memref dims";
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
  info.strideValues.reserve(stored.strideValues.size());
  for (const PropertyOperand &operand : stored.strideValues) {
    Value strideValue = operand.get();
    if (!strideValue) {
      owner->emitOpError() << "has null dependent " << kind << " stride value";
      return failure();
    }
    if (!strideValue.getType().isIndex()) {
      owner->emitOpError() << "requires index-typed dependent " << kind
                           << " stride values";
      return failure();
    }
    info.strideValues.push_back(strideValue);
  }
  return info;
}

static LogicalResult
verifyStoredMemRefRefinement(Operation *owner, StringRef kind, Type type,
                             const DependentMemRefValueRefinement &stored,
                             unsigned expectedIndex,
                             func::FuncOp funcBoundaryOwner = nullptr) {
  auto memrefType = dyn_cast<MemRefType>(type);
  if (!memrefType)
    return owner->emitOpError()
           << "requires memref type for dependent " << kind << " refinements";
  if (stored.valueIndex != expectedIndex)
    return owner->emitOpError()
           << "has dependent " << kind << " refinements for wrong value index";

  bool flatCarrier = allowsFlatMemRefCarrier(memrefType, stored);
  if (!flatCarrier && stored.rank != memrefType.getRank())
    return owner->emitOpError()
           << "requires dependent " << kind << " rank to match memref rank";
  if (stored.dimValues.size() != static_cast<size_t>(stored.rank))
    return owner->emitOpError() << "requires one dependent dimension value per "
                                << kind << " memref dimension";
  if (stored.hasExplicitLayout &&
      stored.strideValues.size() != static_cast<size_t>(stored.rank))
    return owner->emitOpError() << "requires one dependent stride value per "
                                << kind << " memref dimension";

  for (auto [dim, dimValue] : llvm::enumerate(stored.getDimValues())) {
    if (!flatCarrier && !memrefType.isDynamicDim(dim))
      return owner->emitOpError()
             << "requires dependent " << kind
             << " dimensions to correspond to dynamic memref dims";
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
    }
  }
  for (Value strideValue : stored.getStrideValues()) {
    if (!strideValue)
      return owner->emitOpError()
             << "has null dependent " << kind << " stride value";
    if (!strideValue.getType().isIndex())
      return owner->emitOpError()
             << "requires index-typed dependent " << kind << " stride values";
    if (funcBoundaryOwner) {
      auto arg = dyn_cast<BlockArgument>(strideValue);
      if (!arg || funcBoundaryOwner.isExternal() ||
          arg.getOwner() != &funcBoundaryOwner.getBody().front())
        return owner->emitOpError()
               << "requires function boundary dependent " << kind
               << " strides to reference entry block arguments";
    }
  }
  return success();
}

static DependentMemRefValueRefinement
convertToMemRefRefinement(unsigned valueIndex,
                          const DependentTensorTypeRef &stored) {
  DependentMemRefValueRefinement converted;
  converted.valueIndex = valueIndex;
  converted.rank = stored.rank;
  converted.offset = stored.offset;
  converted.hasExplicitLayout = stored.hasExplicitLayout;
  converted.assignDimValues(stored.getDimValues());
  converted.assignStrideValues(stored.getStrideValues());
  return converted;
}

static LogicalResult verifyFuncBoundaryProperties(func::FuncOp func) {
  llvm::SmallDenseSet<unsigned> seenArgRefinements;
  for (const DependentTypeValueRefinement &stored :
       func.getProperties().dependentTypeArgRefinements) {
    if (stored.valueIndex >= func.getNumArguments())
      return func.emitOpError()
             << "has dependent argument refinements out of range";
    Value argument = func.getArgument(stored.valueIndex);
    if (!isa<MemRefType>(argument.getType()))
      continue;
    if (!seenArgRefinements.insert(stored.valueIndex).second)
      return func.emitOpError()
             << "has duplicate dependent argument refinements";
    DependentMemRefValueRefinement memrefRef =
        convertToMemRefRefinement(stored);
    if (failed(verifyStoredMemRefRefinement(func, "argument",
                                            argument.getType(), memrefRef,
                                            stored.valueIndex, func)))
      return failure();
  }

  llvm::SmallDenseSet<unsigned> seenResultRefinements;
  for (const DependentTypeValueRefinement &stored :
       func.getProperties().dependentTypeResultRefinements) {
    if (stored.valueIndex >= func.getNumResults())
      return func.emitOpError()
             << "has dependent result refinements out of range";
    Type resultType = func.getResultTypes()[stored.valueIndex];
    if (!isa<MemRefType>(resultType))
      continue;
    if (!seenResultRefinements.insert(stored.valueIndex).second)
      return func.emitOpError() << "has duplicate dependent result refinements";
    DependentMemRefValueRefinement memrefRef =
        convertToMemRefRefinement(stored);
    if (failed(verifyStoredMemRefRefinement(
            func, "result", resultType, memrefRef, stored.valueIndex, func)))
      return failure();
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

static FailureOr<MemRefValueRefinement> getValueRefinement(Value value);

static FailureOr<MemRefValueRefinement>
getFuncArgRefinement(BlockArgument arg, func::FuncOp func, MemRefType type) {
  const DependentTypeValueRefinement *stored = findStoredRefinement(
      func.getProperties().dependentTypeArgRefinements, arg.getArgNumber());
  if (!stored)
    return failure();
  return decodeStoredRefinementForType(type,
                                       convertToMemRefRefinement(*stored));
}

static LogicalResult
mapCalleeRefinementValues(func::CallOp call, func::FuncOp callee,
                          const DependentTypeValueRefinement &stored,
                          SmallVectorImpl<Value> &dims,
                          SmallVectorImpl<Value> &strides) {
  auto mapValue = [&](Value value) -> FailureOr<Value> {
    auto arg = dyn_cast<BlockArgument>(value);
    if (!arg || callee.isExternal() ||
        arg.getOwner() != &callee.getBody().front() ||
        arg.getArgNumber() >= call.getNumOperands())
      return failure();
    return call.getOperand(arg.getArgNumber());
  };

  dims.clear();
  dims.reserve(stored.dimValues.size());
  for (Value dimValue : stored.getDimValues()) {
    FailureOr<Value> mapped = mapValue(dimValue);
    if (failed(mapped))
      return failure();
    dims.push_back(*mapped);
  }
  strides.clear();
  strides.reserve(stored.strideValues.size());
  for (Value strideValue : stored.getStrideValues()) {
    FailureOr<Value> mapped = mapValue(strideValue);
    if (failed(mapped))
      return failure();
    strides.push_back(*mapped);
  }
  return success();
}

static FailureOr<MemRefValueRefinement>
getCallResultRefinement(OpResult result, func::CallOp call, func::FuncOp callee,
                        MemRefType type) {
  const DependentTypeValueRefinement *stored = findStoredRefinement(
      callee.getProperties().dependentTypeResultRefinements,
      result.getResultNumber());
  if (!stored)
    return failure();
  DependentMemRefValueRefinement mapped = convertToMemRefRefinement(*stored);
  SmallVector<Value> dims, strides;
  if (failed(mapCalleeRefinementValues(call, callee, *stored, dims, strides)))
    return failure();
  mapped.assignDimValues(dims);
  mapped.assignStrideValues(strides);
  return decodeStoredRefinementForType(type, mapped);
}

static FailureOr<MemRefValueRefinement>
getLoopResultRefinement(OpResult result, MemRefType type,
                        ArrayRef<DependentTensorLoopTypeRef> loopTypeRefs) {
  const DependentTensorLoopTypeRef *stored =
      dependent_tensor::findLoopTypeRef(loopTypeRefs, result.getResultNumber());
  if (!stored)
    return failure();
  return decodeStoredRefinementForType(
      type, convertToMemRefRefinement(result.getResultNumber(),
                                      stored->resultTypeRef));
}

static FailureOr<MemRefValueRefinement> getLoopBlockArgumentRefinement(
    unsigned iterIndex, MemRefType type,
    ArrayRef<DependentTensorLoopTypeRef> loopTypeRefs) {
  const DependentTensorLoopTypeRef *stored =
      dependent_tensor::findLoopTypeRef(loopTypeRefs, iterIndex);
  if (!stored)
    return failure();
  return decodeStoredRefinementForType(
      type, convertToMemRefRefinement(iterIndex, stored->operandTypeRef));
}

static FailureOr<MemRefValueRefinement>
getBlockArgumentRefinement(BlockArgument arg, MemRefType type) {
  Block *block = arg.getOwner();
  auto func =
      dyn_cast_or_null<func::FuncOp>(block ? block->getParentOp() : nullptr);
  if (func && block == &func.getBody().front())
    return getFuncArgRefinement(arg, func, type);

  Operation *parentOp = block ? block->getParentOp() : nullptr;
  if (auto forOp = dyn_cast_or_null<scf::ForOp>(parentOp)) {
    if (arg.getArgNumber() < forOp.getNumInductionVars())
      return failure();
    unsigned iterIndex = arg.getArgNumber() - forOp.getNumInductionVars();
    return getLoopBlockArgumentRefinement(
        iterIndex, type, forOp.getProperties().dependentTensorLoopTypeRefs);
  }
  if (auto forOp = dyn_cast_or_null<affine::AffineForOp>(parentOp)) {
    if (arg.getArgNumber() == 0)
      return failure();
    unsigned iterIndex = arg.getArgNumber() - 1;
    return getLoopBlockArgumentRefinement(
        iterIndex, type, forOp.getProperties().dependentTensorLoopTypeRefs);
  }
  return failure();
}

static FailureOr<MemRefValueRefinement> getValueRefinement(Value value) {
  auto type = dyn_cast<MemRefType>(value.getType());
  if (!type)
    return failure();

  if (auto arg = dyn_cast<BlockArgument>(value))
    return getBlockArgumentRefinement(arg, type);

  OpResult result = cast<OpResult>(value);
  Operation *def = result.getOwner();
  if (auto alloc = dyn_cast<AllocOp>(def))
    return decodeStoredRefinementForType(
        type, alloc.getProperties().result_refinement);
  if (auto cast = dyn_cast<CastOp>(def))
    return decodeStoredRefinementForType(
        type, cast.getProperties().result_refinement);
  if (auto reinterpret = dyn_cast<ReinterpretCastOp>(def))
    return decodeStoredRefinementForType(
        type, reinterpret.getProperties().result_refinement);
  if (auto call = dyn_cast<func::CallOp>(def)) {
    auto callee = SymbolTable::lookupNearestSymbolFrom<func::FuncOp>(
        call, call.getCalleeAttr());
    if (!callee)
      return failure();
    return getCallResultRefinement(result, call, callee, type);
  }
  if (auto forOp = dyn_cast<scf::ForOp>(def))
    return getLoopResultRefinement(
        result, type, forOp.getProperties().dependentTensorLoopTypeRefs);
  if (auto forOp = dyn_cast<affine::AffineForOp>(def))
    return getLoopResultRefinement(
        result, type, forOp.getProperties().dependentTensorLoopTypeRefs);
  return failure();
}

static LogicalResult verifyReturnRefinements(func::FuncOp func,
                                             func::ReturnOp ret) {
  for (auto [i, operand] : llvm::enumerate(ret.getOperands())) {
    const DependentTypeValueRefinement *stored = findStoredRefinement(
        func.getProperties().dependentTypeResultRefinements, i);
    auto actual = getValueRefinement(operand);
    if (!stored) {
      if (succeeded(actual))
        return ret.emitOpError()
               << "returned value carries dependent_memref refinements not "
                  "declared in function result properties";
      continue;
    }
    if (!isa<MemRefType>(func.getResultTypes()[i]))
      continue;

    auto resultType = cast<MemRefType>(func.getResultTypes()[i]);
    FailureOr<MemRefValueRefinement> expected = decodeStoredRefinementForType(
        resultType, convertToMemRefRefinement(*stored));
    if (failed(actual) || failed(expected))
      return ret.emitOpError()
             << "failed to resolve dependent_memref result refinements";
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
        "does not reference a valid callee for dependent_memref verification");

  for (auto [i, operand] : llvm::enumerate(call.getOperands())) {
    const DependentTypeValueRefinement *stored = findStoredRefinement(
        callee.getProperties().dependentTypeArgRefinements, i);
    auto actual = getValueRefinement(operand);
    if (!stored) {
      if (succeeded(actual))
        return call.emitOpError()
               << "operand #" << i
               << " carries dependent_memref refinements not declared by the "
                  "callee";
      continue;
    }
    if (!isa<MemRefType>(callee.getArgumentTypes()[i]))
      continue;

    auto argType = cast<MemRefType>(callee.getArgumentTypes()[i]);
    DependentMemRefValueRefinement mapped = convertToMemRefRefinement(*stored);
    SmallVector<Value> dims, strides;
    if (failed(mapCalleeRefinementValues(call, callee, *stored, dims, strides)))
      return call.emitOpError() << "failed to map callee dependent_memref "
                                   "refinements for operand #"
                                << i;
    mapped.assignDimValues(dims);
    mapped.assignStrideValues(strides);
    FailureOr<MemRefValueRefinement> expected =
        decodeStoredRefinementForType(argType, mapped);
    if (failed(actual) || failed(expected))
      return call.emitOpError()
             << "failed to resolve dependent_memref refinements for operand #"
             << i;
    if (!haveEqualRefinements(*actual, *expected))
      return call.emitOpError() << "operand #" << i
                                << " does not match callee dependency metadata";
  }
  for (OpResult result : call.getResults()) {
    const DependentTypeValueRefinement *stored = findStoredRefinement(
        callee.getProperties().dependentTypeResultRefinements,
        result.getResultNumber());
    if (!stored || !isa<MemRefType>(result.getType()))
      continue;
    if (failed(getValueRefinement(result)))
      return call.emitOpError()
             << "failed to resolve dependent_memref refinements for result #"
             << result.getResultNumber();
  }
  return success();
}

static LogicalResult verifyLoopRefinements(
    Operation *owner, ArrayRef<DependentTensorLoopTypeRef> loopTypeRefs,
    ValueRange initOperands, TypeRange resultTypes, ValueRange yieldedValues) {
  llvm::SmallDenseSet<unsigned> seenLoopRefs;
  for (const DependentTensorLoopTypeRef &ref : loopTypeRefs) {
    if (!seenLoopRefs.insert(ref.valueIndex).second)
      return owner->emitOpError()
             << "has duplicate dependent memref loop type refs";
    if (ref.valueIndex >= resultTypes.size() ||
        ref.valueIndex >= initOperands.size() ||
        ref.valueIndex >= yieldedValues.size())
      return owner->emitOpError()
             << "has dependent memref loop type refs out of range";
    if (!isa<MemRefType>(resultTypes[ref.valueIndex]) &&
        !isa<MemRefType>(initOperands[ref.valueIndex].getType()) &&
        !isa<MemRefType>(yieldedValues[ref.valueIndex].getType()))
      continue;
    FailureOr<MemRefValueRefinement> operandExpected =
        verifyAndBuildMemRefTypeRef(owner, "loop operand",
                                    initOperands[ref.valueIndex].getType(),
                                    ref.operandTypeRef);
    if (failed(operandExpected))
      return failure();
    FailureOr<MemRefValueRefinement> resultExpected =
        verifyAndBuildMemRefTypeRef(owner, "loop result",
                                    resultTypes[ref.valueIndex],
                                    ref.resultTypeRef);
    if (failed(resultExpected))
      return failure();
    FailureOr<MemRefValueRefinement> actualInit =
        getValueRefinement(initOperands[ref.valueIndex]);
    if (succeeded(actualInit) &&
        !haveEqualRefinements(*actualInit, *operandExpected))
      return owner->emitOpError()
             << "loop operand type reference does not match init refinements";
    FailureOr<MemRefValueRefinement> actualYield =
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
      forOp.getInitArgs(), forOp.getResultTypes(), yield.getResults());
}

static LogicalResult verifyAffineForRefinements(affine::AffineForOp forOp) {
  auto yield = cast<affine::AffineYieldOp>(forOp.getBody()->getTerminator());
  return verifyLoopRefinements(
      forOp.getOperation(), forOp.getProperties().dependentTensorLoopTypeRefs,
      forOp.getInits(), forOp.getResultTypes(), yield.getOperands());
}

struct VerifyDependentMemRefRefinementsPass
    : public dependent_memref::impl::VerifyDependentMemRefRefinementsPassBase<
          VerifyDependentMemRefRefinementsPass> {
  using VerifyDependentMemRefRefinementsPassBase<
      VerifyDependentMemRefRefinementsPass>::
      VerifyDependentMemRefRefinementsPassBase;

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

    WalkResult walk = module.walk([&](Operation *op) {
      if (auto alloc = dyn_cast<AllocOp>(op))
        return interruptIfFailed(verifyStoredRefinement(
            op, alloc.getMemref(), alloc.getProperties().result_refinement));
      if (auto cast = dyn_cast<CastOp>(op))
        return interruptIfFailed(verifyStoredRefinement(
            op, cast.getResult(), cast.getProperties().result_refinement));
      if (auto reinterpret = dyn_cast<ReinterpretCastOp>(op))
        return interruptIfFailed(verifyStoredRefinement(
            op, reinterpret.getResult(),
            reinterpret.getProperties().result_refinement));
      if (auto dim = dyn_cast<DimOp>(op))
        return interruptIfFailed(verifyStoredRefinement(
            op, dim.getSource(), dim.getProperties().source_refinement));
      if (auto dimExact = dyn_cast<DimExactOp>(op))
        return interruptIfFailed(
            verifyStoredRefinement(op, dimExact.getSource(),
                                   dimExact.getProperties().source_refinement));
      if (auto load = dyn_cast<LoadOp>(op))
        return interruptIfFailed(verifyStoredRefinement(
            op, load.getSource(), load.getProperties().source_refinement));
      if (auto store = dyn_cast<StoreOp>(op))
        return interruptIfFailed(verifyStoredRefinement(
            op, store.getSource(), store.getProperties().source_refinement));
      return WalkResult::advance();
    });
    if (walk.wasInterrupted())
      signalPassFailure();
  }
};
} // namespace
