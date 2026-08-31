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

    getOperation()->walk([](func::FuncOp func) {
      auto &props = func.getProperties();
      props.dependentTypeArgRefinements.clear();
      props.dependentTypeResultRefinements.clear();
      reattachPropertyOperands(func);
    });
  }
};

} // namespace
