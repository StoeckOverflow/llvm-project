//===- DependentTensorToDependentMemRef.cpp - Tensor to DepMemRef ---------===//

#include "mlir/Dialect/DependentMemRef/Transforms/Passes.h"

#include "mlir/Dialect/DependentMemRef/IR/DependentMemRef.h"
#include "mlir/Dialect/DependentTensor/IR/DependentTensor.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Dialect/Func/Transforms/FuncConversions.h"
#include "mlir/Dialect/SCF/IR/SCF.h"
#include "mlir/Dialect/SCF/Transforms/Patterns.h"
#include "mlir/IR/BuiltinOps.h"
#include "mlir/IR/PatternMatch.h"
#include "mlir/Transforms/DialectConversion.h"
#include "llvm/ADT/DenseMap.h"
#include "llvm/ADT/StringMap.h"
#include <optional>

namespace mlir {
namespace dependent_memref {
#define GEN_PASS_DEF_CONVERTDEPENDENTTENSORTODEPENDENTMEMREFPASS
#include "mlir/Dialect/DependentMemRef/Transforms/Passes.h.inc"
} // namespace dependent_memref
} // namespace mlir

using namespace mlir;
using namespace mlir::dependent_memref;

namespace {
static MemRefType tensorToMemRefType(RankedTensorType type) {
  return MemRefType::get(type.getShape(), type.getElementType());
}

using TensorDimRefinementMap = llvm::DenseMap<Value, SmallVector<Value, 4>>;

static void collectTensorDimRefinements(Operation *root,
                                        TensorDimRefinementMap &refinements) {
  auto record = [&](Value value) {
    if (!isa<RankedTensorType>(value.getType()))
      return;
    FailureOr<dependent_tensor::TensorValueRefinement> info =
        dependent_tensor::getValueRefinement(value);
    if (succeeded(info))
      refinements.try_emplace(value, info->dimValues);
  };

  root->walk([&](Operation *op) {
    for (Value result : op->getResults())
      record(result);
    for (Region &region : op->getRegions())
      for (Block &block : region)
        for (BlockArgument argument : block.getArguments())
          record(argument);
  });
}

static DependentMemRefValueRefinement
memrefRefinementFromTensor(Value originalValue, Value convertedValue,
                           const TensorDimRefinementMap &tensorDims) {
  auto memrefType = cast<MemRefType>(convertedValue.getType());
  SmallVector<Value> dims;
  auto mapped = tensorDims.find(originalValue);
  if (mapped != tensorDims.end())
    dims.assign(mapped->second.begin(), mapped->second.end());
  else if (auto tensorType =
               dyn_cast<RankedTensorType>(originalValue.getType()))
    dims.assign(tensorType.getRank(), Value());
  else
    dims.assign(memrefType.getRank(), Value());
  return buildStoredRefinement(/*valueIndex=*/0, memrefType, dims);
}

struct BoundaryRefinementSnapshot {
  DependentTypeValueRefinement refinement;
  SmallVector<unsigned, 4> dimArgIndices;
  SmallVector<unsigned, 4> strideArgIndices;
};

struct FunctionBoundaryRefinementSnapshot {
  SmallVector<BoundaryRefinementSnapshot, 4> argRefinements;
  SmallVector<BoundaryRefinementSnapshot, 1> resultRefinements;
};

using FunctionBoundaryRefinementMap =
    llvm::StringMap<FunctionBoundaryRefinementSnapshot>;

static std::optional<unsigned> getFunctionArgumentIndex(func::FuncOp func,
                                                        Value value) {
  auto arg = dyn_cast<BlockArgument>(value);
  if (!arg || arg.getOwner() != &func.getBody().front())
    return std::nullopt;
  return arg.getArgNumber();
}

static std::optional<BoundaryRefinementSnapshot>
snapshotBoundaryRefinement(func::FuncOp func,
                           const DependentTypeValueRefinement &refinement) {
  BoundaryRefinementSnapshot snapshot;
  snapshot.refinement = refinement;
  snapshot.refinement.dimValues.clear();
  snapshot.refinement.strideValues.clear();

  for (const PropertyOperand &operand : refinement.dimValues) {
    std::optional<unsigned> index =
        getFunctionArgumentIndex(func, operand.get());
    if (!index)
      return std::nullopt;
    snapshot.dimArgIndices.push_back(*index);
  }
  for (const PropertyOperand &operand : refinement.strideValues) {
    std::optional<unsigned> index =
        getFunctionArgumentIndex(func, operand.get());
    if (!index)
      return std::nullopt;
    snapshot.strideArgIndices.push_back(*index);
  }
  return snapshot;
}

static void
collectFunctionBoundaryRefinements(ModuleOp module,
                                   FunctionBoundaryRefinementMap &snapshots) {
  module.walk([&](func::FuncOp func) {
    if (func.getBody().empty())
      return;

    FunctionBoundaryRefinementSnapshot snapshot;
    TypeRange inputs = func.getFunctionType().getInputs();
    for (const DependentTypeValueRefinement &refinement :
         func.getProperties().dependentTypeArgRefinements) {
      if (refinement.valueIndex >= inputs.size() ||
          !isa<RankedTensorType>(inputs[refinement.valueIndex]))
        continue;
      if (std::optional<BoundaryRefinementSnapshot> saved =
              snapshotBoundaryRefinement(func, refinement))
        snapshot.argRefinements.push_back(std::move(*saved));
    }

    TypeRange results = func.getFunctionType().getResults();
    for (const DependentTypeValueRefinement &refinement :
         func.getProperties().dependentTypeResultRefinements) {
      if (refinement.valueIndex >= results.size() ||
          !isa<RankedTensorType>(results[refinement.valueIndex]))
        continue;
      if (std::optional<BoundaryRefinementSnapshot> saved =
              snapshotBoundaryRefinement(func, refinement))
        snapshot.resultRefinements.push_back(std::move(*saved));
    }

    if (!snapshot.argRefinements.empty() || !snapshot.resultRefinements.empty())
      snapshots[func.getName()] = std::move(snapshot);
  });
}

static DependentTypeValueRefinement
restoreBoundaryRefinement(func::FuncOp func,
                          const BoundaryRefinementSnapshot &snapshot) {
  DependentTypeValueRefinement restored = snapshot.refinement;
  SmallVector<Value> dims;
  dims.reserve(snapshot.dimArgIndices.size());
  for (unsigned index : snapshot.dimArgIndices)
    dims.push_back(func.getArgument(index));
  restored.assignDimValues(dims);

  SmallVector<Value> strides;
  strides.reserve(snapshot.strideArgIndices.size());
  for (unsigned index : snapshot.strideArgIndices)
    strides.push_back(func.getArgument(index));
  restored.assignStrideValues(strides);
  return restored;
}

static void restoreFunctionBoundaryRefinements(
    ModuleOp module, const FunctionBoundaryRefinementMap &snapshots) {
  module.walk([&](func::FuncOp func) {
    auto it = snapshots.find(func.getName());
    if (it == snapshots.end()) {
      reattachPropertyOperands(func);
      return;
    }

    auto &props = func.getProperties();
    props.dependentTypeArgRefinements.clear();
    props.dependentTypeResultRefinements.clear();

    TypeRange inputs = func.getFunctionType().getInputs();
    for (const BoundaryRefinementSnapshot &snapshot :
         it->second.argRefinements) {
      if (snapshot.refinement.valueIndex < inputs.size() &&
          isa<MemRefType>(inputs[snapshot.refinement.valueIndex]))
        props.dependentTypeArgRefinements.push_back(
            restoreBoundaryRefinement(func, snapshot));
    }

    TypeRange results = func.getFunctionType().getResults();
    for (const BoundaryRefinementSnapshot &snapshot :
         it->second.resultRefinements) {
      if (snapshot.refinement.valueIndex < results.size() &&
          isa<MemRefType>(results[snapshot.refinement.valueIndex]))
        props.dependentTypeResultRefinements.push_back(
            restoreBoundaryRefinement(func, snapshot));
    }
    reattachPropertyOperands(func);
  });
}

static Operation *createAllocLike(PatternRewriter &rewriter, Location loc,
                                  MemRefType resultType, ValueRange dims) {
  OperationState state(loc, AllocOp::getOperationName());
  state.addTypes(resultType);
  state.getOrAddProperties<AllocOp::Properties>().result_refinement =
      buildStoredRefinement(/*valueIndex=*/0, resultType, dims);
  Operation *op = rewriter.create(state);
  reattachPropertyOperands(op);
  return op;
}

static Operation *createLoadLike(PatternRewriter &rewriter, Location loc,
                                 Value source, ValueRange indices,
                                 Type resultType,
                                 const DependentMemRefValueRefinement &ref) {
  OperationState state(loc, LoadOp::getOperationName());
  state.addOperands(source);
  state.addOperands(indices);
  state.addTypes(resultType);
  state.getOrAddProperties<LoadOp::Properties>().source_refinement = ref;
  Operation *op = rewriter.create(state);
  reattachPropertyOperands(op);
  return op;
}

static Operation *createStoreLike(PatternRewriter &rewriter, Location loc,
                                  Value value, Value source, ValueRange indices,
                                  const DependentMemRefValueRefinement &ref) {
  OperationState state(loc, StoreOp::getOperationName());
  state.addOperands(value);
  state.addOperands(source);
  state.addOperands(indices);
  state.getOrAddProperties<StoreOp::Properties>().source_refinement = ref;
  Operation *op = rewriter.create(state);
  reattachPropertyOperands(op);
  return op;
}

struct TensorToMemRefTypeConverter : public TypeConverter {
  TensorToMemRefTypeConverter() {
    addConversion([](Type type) { return type; });
    addConversion(
        [](RankedTensorType type) -> Type { return tensorToMemRefType(type); });
  }
};

struct ConvertMakeOp : public OpConversionPattern<dependent_tensor::MakeOp> {
  using OpConversionPattern::OpConversionPattern;
  LogicalResult
  matchAndRewrite(dependent_tensor::MakeOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    auto tensorType = cast<RankedTensorType>(op.getResult().getType());
    auto memrefType = tensorToMemRefType(tensorType);
    Operation *alloc =
        createAllocLike(rewriter, op.getLoc(), memrefType, op.getDimValues());
    rewriter.replaceOp(op, alloc->getResults());
    return success();
  }
};

struct ConvertExtractOp
    : public OpConversionPattern<dependent_tensor::ExtractOp> {
  ConvertExtractOp(TypeConverter &converter, MLIRContext *ctx,
                   const TensorDimRefinementMap &tensorDims)
      : OpConversionPattern(converter, ctx), tensorDims(&tensorDims) {}

  const TensorDimRefinementMap *tensorDims;
  LogicalResult
  matchAndRewrite(dependent_tensor::ExtractOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    auto ref = memrefRefinementFromTensor(op.getSource(), adaptor.getSource(),
                                          *tensorDims);
    Operation *load =
        createLoadLike(rewriter, op.getLoc(), adaptor.getSource(),
                       adaptor.getIndices(), op.getResult().getType(), ref);
    rewriter.replaceOp(op, load->getResults());
    return success();
  }
};

struct ConvertInsertOp
    : public OpConversionPattern<dependent_tensor::InsertOp> {
  ConvertInsertOp(TypeConverter &converter, MLIRContext *ctx,
                  const TensorDimRefinementMap &tensorDims)
      : OpConversionPattern(converter, ctx), tensorDims(&tensorDims) {}

  const TensorDimRefinementMap *tensorDims;
  LogicalResult
  matchAndRewrite(dependent_tensor::InsertOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    auto ref = memrefRefinementFromTensor(op.getDest(), adaptor.getDest(),
                                          *tensorDims);
    createStoreLike(rewriter, op.getLoc(), adaptor.getScalar(),
                    adaptor.getDest(), adaptor.getIndices(), ref);
    rewriter.replaceOp(op, adaptor.getDest());
    return success();
  }
};

struct ConvertDimOp : public OpConversionPattern<dependent_tensor::DimOp> {
  ConvertDimOp(TypeConverter &converter, MLIRContext *ctx,
               const TensorDimRefinementMap &tensorDims)
      : OpConversionPattern(converter, ctx), tensorDims(&tensorDims) {}

  const TensorDimRefinementMap *tensorDims;
  LogicalResult
  matchAndRewrite(dependent_tensor::DimOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    auto ref = memrefRefinementFromTensor(op.getSource(), adaptor.getSource(),
                                          *tensorDims);
    OperationState state(op.getLoc(), DimOp::getOperationName());
    state.addOperands(adaptor.getSource());
    state.addOperands(adaptor.getDimension());
    state.addTypes(rewriter.getIndexType());
    state.getOrAddProperties<DimOp::Properties>().source_refinement = ref;
    Operation *dim = rewriter.create(state);
    reattachPropertyOperands(dim);
    rewriter.replaceOp(op, dim->getResults());
    return success();
  }
};

struct ConvertDependentTensorToDependentMemRefPass
    : public dependent_memref::impl::
          ConvertDependentTensorToDependentMemRefPassBase<
              ConvertDependentTensorToDependentMemRefPass> {
  using ConvertDependentTensorToDependentMemRefPassBase::
      ConvertDependentTensorToDependentMemRefPassBase;

  void runOnOperation() override {
    MLIRContext *ctx = &getContext();
    TensorToMemRefTypeConverter converter;
    RewritePatternSet patterns(ctx);
    ConversionTarget target(*ctx);

    target.addLegalDialect<arith::ArithDialect,
                           dependent_memref::DependentMemRefDialect,
                           func::FuncDialect, scf::SCFDialect>();
    target.addIllegalDialect<dependent_tensor::DependentTensorDialect>();
    target.addDynamicallyLegalOp<func::FuncOp>([&](func::FuncOp op) {
      return converter.isSignatureLegal(op.getFunctionType()) &&
             converter.isLegal(&op.getBody());
    });
    target.addDynamicallyLegalOp<func::ReturnOp>([&](func::ReturnOp op) {
      return converter.isLegal(op.getOperandTypes());
    });

    populateFunctionOpInterfaceTypeConversionPattern<func::FuncOp>(patterns,
                                                                   converter);
    populateCallOpTypeConversionPattern(patterns, converter);
    populateReturnOpTypeConversionPattern(patterns, converter);
    scf::populateSCFStructuralTypeConversionsAndLegality(converter, patterns,
                                                         target);
    FunctionBoundaryRefinementMap functionBoundaryRefinements;
    collectFunctionBoundaryRefinements(getOperation(),
                                       functionBoundaryRefinements);

    TensorDimRefinementMap tensorDims;
    collectTensorDimRefinements(getOperation(), tensorDims);

    patterns.add<ConvertMakeOp>(converter, ctx);
    patterns.add<ConvertExtractOp, ConvertInsertOp, ConvertDimOp>(
        converter, ctx, tensorDims);

    if (failed(applyPartialConversion(getOperation(), target,
                                      std::move(patterns)))) {
      signalPassFailure();
      return;
    }

    restoreFunctionBoundaryRefinements(getOperation(),
                                       functionBoundaryRefinements);
  }
};

} // namespace
