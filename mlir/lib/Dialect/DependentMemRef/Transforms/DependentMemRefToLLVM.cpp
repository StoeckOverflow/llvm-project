//===- DependentMemRefToLLVM.cpp - DependentMemRef to LLVM ---------------===//

#include "mlir/Dialect/DependentMemRef/Transforms/Passes.h"

#include "mlir/Conversion/ArithToLLVM/ArithToLLVM.h"
#include "mlir/Conversion/ControlFlowToLLVM/ControlFlowToLLVM.h"
#include "mlir/Conversion/IndexToLLVM/IndexToLLVM.h"
#include "mlir/Conversion/LLVMCommon/TypeConverter.h"
#include "mlir/Conversion/SCFToControlFlow/SCFToControlFlow.h"
#include "mlir/Dialect/DependentMemRef/IR/DependentMemRef.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Dialect/LLVMIR/FunctionCallUtils.h"
#include "mlir/Dialect/LLVMIR/LLVMDialect.h"
#include "mlir/IR/BuiltinOps.h"
#include "mlir/IR/PatternMatch.h"
#include "mlir/Transforms/DialectConversion.h"

namespace mlir {
namespace dependent_memref {
#define GEN_PASS_DEF_LOWERDEPENDENTMEMREFTOLLVMPASS
#include "mlir/Dialect/DependentMemRef/Transforms/Passes.h.inc"
} // namespace dependent_memref
} // namespace mlir

using namespace mlir;
using namespace mlir::dependent_memref;

namespace {
struct DependentMemRefLLVMTypeConverter : public LLVMTypeConverter {
  explicit DependentMemRefLLVMTypeConverter(MLIRContext *ctx)
      : LLVMTypeConverter(ctx, [&] {
          LowerToLLVMOptions options(ctx);
          options.useBarePtrCallConv = true;
          return options;
        }()) {
    addConversion([ctx](MemRefType type) -> Type {
      return LLVM::LLVMPointerType::get(ctx, type.getMemorySpaceAsInt());
    });
    addTargetMaterialization([](OpBuilder &, Type resultType, ValueRange inputs,
                                Location, Type originalType) -> Value {
      if (!isa_and_nonnull<MemRefType>(originalType) || inputs.size() != 1)
        return Value();
      if (!isa<LLVM::LLVMPointerType>(resultType) ||
          inputs.front().getType() != resultType)
        return Value();
      return inputs.front();
    });
  }
};

static Value remappedOrSelf(ConversionPatternRewriter &rewriter, Value value) {
  if (Value remapped = rewriter.getRemappedValue(value))
    return remapped;
  return value;
}

static Value llvmIndexConstant(OpBuilder &builder, Location loc, Type indexType,
                               int64_t value) {
  return LLVM::ConstantOp::create(builder, loc, indexType,
                                  builder.getIntegerAttr(indexType, value));
}

static bool isLLVMIndexConstant(Value value, int64_t expected) {
  auto constant = value.getDefiningOp<LLVM::ConstantOp>();
  if (!constant)
    return false;
  auto attr = dyn_cast<IntegerAttr>(constant.getValue());
  return attr && attr.getInt() == expected;
}

static Value maybeMul(ConversionPatternRewriter &rewriter, Location loc,
                      Type indexType, Value lhs, Value rhs) {
  if (isLLVMIndexConstant(lhs, 0) || isLLVMIndexConstant(rhs, 0))
    return llvmIndexConstant(rewriter, loc, indexType, 0);
  if (isLLVMIndexConstant(lhs, 1))
    return rhs;
  if (isLLVMIndexConstant(rhs, 1))
    return lhs;
  return LLVM::MulOp::create(rewriter, loc, indexType, lhs, rhs);
}

static Value maybeAdd(ConversionPatternRewriter &rewriter, Location loc,
                      Type indexType, Value lhs, Value rhs) {
  if (isLLVMIndexConstant(lhs, 0))
    return rhs;
  if (isLLVMIndexConstant(rhs, 0))
    return lhs;
  return LLVM::AddOp::create(rewriter, loc, indexType, lhs, rhs);
}

static unsigned elementSizeBytes(Type type) {
  if (auto intOrFloat = dyn_cast<IntegerType>(type))
    return std::max(1u, (intOrFloat.getWidth() + 7) / 8);
  if (auto floatType = dyn_cast<FloatType>(type))
    return std::max(1u, (floatType.getWidth() + 7) / 8);
  return 8;
}

static SmallVector<Value>
materializeDefaultStrides(ConversionPatternRewriter &rewriter, Location loc,
                          Type indexType, ArrayRef<Value> dims) {
  SmallVector<Value> strides(dims.size());
  if (dims.empty())
    return strides;
  strides.back() = Value();
  for (int64_t i = static_cast<int64_t>(dims.size()) - 2; i >= 0; --i) {
    Value innerStride = strides[i + 1];
    strides[i] = innerStride ? maybeMul(rewriter, loc, indexType, dims[i + 1],
                                        innerStride)
                             : dims[i + 1];
  }
  return strides;
}

static SmallVector<Value> remapValues(ConversionPatternRewriter &rewriter,
                                      ValueRange values) {
  SmallVector<Value> remapped;
  remapped.reserve(values.size());
  for (Value value : values)
    remapped.push_back(remappedOrSelf(rewriter, value));
  return remapped;
}

static FailureOr<LLVM::LLVMFunctionType>
convertFunctionTypeForDependentMemRef(func::FuncOp op,
                                      const TypeConverter &converter) {
  SmallVector<Type> inputs;
  if (failed(converter.convertTypes(op.getFunctionType().getInputs(), inputs)))
    return failure();

  Type resultType = LLVM::LLVMVoidType::get(op.getContext());
  TypeRange results = op.getFunctionType().getResults();
  if (results.size() == 1) {
    resultType = converter.convertType(results.front());
    if (!resultType)
      return failure();
  } else if (!results.empty()) {
    SmallVector<Type> convertedResults;
    if (failed(converter.convertTypes(results, convertedResults)))
      return failure();
    resultType =
        LLVM::LLVMStructType::getLiteral(op.getContext(), convertedResults);
  }

  return LLVM::LLVMFunctionType::get(resultType, inputs,
                                     /*isVarArg=*/false);
}

struct LowerFuncOp : public OpConversionPattern<func::FuncOp> {
  using OpConversionPattern::OpConversionPattern;
  LogicalResult
  matchAndRewrite(func::FuncOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    FailureOr<LLVM::LLVMFunctionType> llvmType =
        convertFunctionTypeForDependentMemRef(op, *getTypeConverter());
    if (failed(llvmType))
      return failure();

    TypeConverter::SignatureConversion signature(op.getNumArguments());
    for (auto [index, type] :
         llvm::enumerate(op.getFunctionType().getInputs())) {
      Type converted = getTypeConverter()->convertType(type);
      if (!converted)
        return failure();
      signature.addInputs(index, converted);
    }

    rewriter.setInsertionPoint(op);
    auto newFunc = LLVM::LLVMFuncOp::create(rewriter, op.getLoc(), op.getName(),
                                            *llvmType, LLVM::Linkage::External);
    newFunc.setVisibility(op.getVisibility());
    rewriter.inlineRegionBefore(op.getBody(), newFunc.getBody(), newFunc.end());
    if (!newFunc.getBody().empty())
      rewriter.applySignatureConversion(&newFunc.getBody().front(), signature,
                                        getTypeConverter());
    rewriter.eraseOp(op);
    return success();
  }
};

struct LowerReturnOp : public OpConversionPattern<func::ReturnOp> {
  using OpConversionPattern::OpConversionPattern;
  LogicalResult
  matchAndRewrite(func::ReturnOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    if (adaptor.getOperands().size() > 1)
      return rewriter.notifyMatchFailure(op,
                                         "multiple return values unsupported");
    rewriter.replaceOpWithNewOp<LLVM::ReturnOp>(op, TypeRange(),
                                                adaptor.getOperands());
    return success();
  }
};

struct LowerCallOp : public OpConversionPattern<func::CallOp> {
  using OpConversionPattern::OpConversionPattern;
  LogicalResult
  matchAndRewrite(func::CallOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    SmallVector<Type> resultTypes;
    if (failed(
            getTypeConverter()->convertTypes(op.getResultTypes(), resultTypes)))
      return failure();
    if (resultTypes.size() > 1)
      return rewriter.notifyMatchFailure(op,
                                         "multiple call results unsupported");
    auto call = LLVM::CallOp::create(rewriter, op.getLoc(), resultTypes,
                                     op.getCalleeAttr(), adaptor.getOperands());
    rewriter.replaceOp(op, call->getResults());
    return success();
  }
};

static FailureOr<Value>
linearizeIndex(ConversionPatternRewriter &rewriter, Location loc,
               Type indexType, ValueRange indices,
               const DependentMemRefValueRefinement &stored) {
  SmallVector<Value> idxs = remapValues(rewriter, indices);
  SmallVector<Value> dims = remapValues(rewriter, stored.getDimValues());
  SmallVector<Value> strides =
      stored.hasExplicitLayout
          ? remapValues(rewriter, stored.getStrideValues())
          : materializeDefaultStrides(rewriter, loc, indexType, dims);
  if (idxs.size() != strides.size())
    return failure();
  Value linear;
  if (stored.offset != 0)
    linear = llvmIndexConstant(rewriter, loc, indexType, stored.offset);
  for (auto [idx, stride] : llvm::zip_equal(idxs, strides)) {
    Value term = stride ? maybeMul(rewriter, loc, indexType, idx, stride) : idx;
    if (!linear)
      linear = term;
    else
      linear = maybeAdd(rewriter, loc, indexType, linear, term);
  }
  if (!linear)
    return llvmIndexConstant(rewriter, loc, indexType, 0);
  return linear;
}

static Value gepForElement(ConversionPatternRewriter &rewriter, Location loc,
                           Value base, Type elementType, Value linear) {
  auto ptrType = LLVM::LLVMPointerType::get(rewriter.getContext());
  return LLVM::GEPOp::create(rewriter, loc, ptrType, elementType, base, linear);
}

struct LowerAllocOp : public OpConversionPattern<AllocOp> {
  using OpConversionPattern::OpConversionPattern;
  LogicalResult
  matchAndRewrite(AllocOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    auto memrefType = cast<MemRefType>(op.getMemref().getType());
    Type indexType = getTypeConverter()->convertType(rewriter.getIndexType());
    auto module = op->getParentOfType<ModuleOp>();
    FailureOr<LLVM::LLVMFuncOp> mallocFn =
        LLVM::lookupOrCreateMallocFn(rewriter, module, indexType);
    if (failed(mallocFn))
      return failure();
    SmallVector<Value> dims = remapValues(
        rewriter, op.getProperties().result_refinement.getDimValues());
    Value numElems = llvmIndexConstant(rewriter, op.getLoc(), indexType, 1);
    for (Value dim : dims)
      numElems =
          LLVM::MulOp::create(rewriter, op.getLoc(), indexType, numElems, dim);
    Value elemBytes =
        llvmIndexConstant(rewriter, op.getLoc(), indexType,
                          elementSizeBytes(memrefType.getElementType()));
    Value sizeBytes = LLVM::MulOp::create(rewriter, op.getLoc(), indexType,
                                          numElems, elemBytes);
    auto call = LLVM::CallOp::create(rewriter, op.getLoc(), mallocFn.value(),
                                     sizeBytes);
    rewriter.replaceOp(op, call.getResult());
    return success();
  }
};

struct LowerDeallocOp : public OpConversionPattern<DeallocOp> {
  using OpConversionPattern::OpConversionPattern;
  LogicalResult
  matchAndRewrite(DeallocOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    auto module = op->getParentOfType<ModuleOp>();
    FailureOr<LLVM::LLVMFuncOp> freeFn =
        LLVM::lookupOrCreateFreeFn(rewriter, module);
    if (failed(freeFn))
      return failure();
    LLVM::CallOp::create(rewriter, op.getLoc(), freeFn.value(),
                         adaptor.getMemref());
    rewriter.eraseOp(op);
    return success();
  }
};

struct LowerLoadOp : public OpConversionPattern<LoadOp> {
  using OpConversionPattern::OpConversionPattern;
  LogicalResult
  matchAndRewrite(LoadOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    Type indexType = getTypeConverter()->convertType(rewriter.getIndexType());
    FailureOr<Value> linear =
        linearizeIndex(rewriter, op.getLoc(), indexType, adaptor.getIndices(),
                       op.getProperties().source_refinement);
    if (failed(linear))
      return failure();
    auto memrefType = cast<MemRefType>(op.getSource().getType());
    Value ptr = gepForElement(rewriter, op.getLoc(), adaptor.getSource(),
                              memrefType.getElementType(), *linear);
    rewriter.replaceOpWithNewOp<LLVM::LoadOp>(op, op.getResult().getType(),
                                              ptr);
    return success();
  }
};

struct LowerStoreOp : public OpConversionPattern<StoreOp> {
  using OpConversionPattern::OpConversionPattern;
  LogicalResult
  matchAndRewrite(StoreOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    Type indexType = getTypeConverter()->convertType(rewriter.getIndexType());
    FailureOr<Value> linear =
        linearizeIndex(rewriter, op.getLoc(), indexType, adaptor.getIndices(),
                       op.getProperties().source_refinement);
    if (failed(linear))
      return failure();
    auto memrefType = cast<MemRefType>(op.getSource().getType());
    Value ptr = gepForElement(rewriter, op.getLoc(), adaptor.getSource(),
                              memrefType.getElementType(), *linear);
    rewriter.replaceOpWithNewOp<LLVM::StoreOp>(op, adaptor.getValue(), ptr);
    return success();
  }
};

struct LowerPointerForwardingOp : public ConversionPattern {
  LowerPointerForwardingOp(TypeConverter &converter, MLIRContext *ctx,
                           StringRef name)
      : ConversionPattern(converter, name, 1, ctx) {}
  LogicalResult
  matchAndRewrite(Operation *op, ArrayRef<Value> operands,
                  ConversionPatternRewriter &rewriter) const override {
    if (operands.empty() || op->getNumResults() != 1)
      return failure();
    rewriter.replaceOp(op, operands.front());
    return success();
  }
};

struct LowerDimExactOp : public OpConversionPattern<DimExactOp> {
  using OpConversionPattern::OpConversionPattern;
  LogicalResult
  matchAndRewrite(DimExactOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    int64_t axis = op.getAxis();
    auto dims = op.getProperties().source_refinement.getDimValues();
    if (axis < 0 || static_cast<size_t>(axis) >= dims.size())
      return failure();
    rewriter.replaceOp(op, remappedOrSelf(rewriter, dims[axis]));
    return success();
  }
};

struct LowerDimOp : public OpConversionPattern<DimOp> {
  using OpConversionPattern::OpConversionPattern;
  LogicalResult
  matchAndRewrite(DimOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    std::optional<uint64_t> dim;
    if (auto defining =
            op.getDimension().getDefiningOp<arith::ConstantIndexOp>())
      dim = defining.value();
    if (!dim)
      return failure();
    auto dims = op.getProperties().source_refinement.getDimValues();
    if (*dim >= dims.size())
      return failure();
    rewriter.replaceOp(op, remappedOrSelf(rewriter, dims[*dim]));
    return success();
  }
};

struct LowerDependentMemRefToLLVMPass
    : public dependent_memref::impl::LowerDependentMemRefToLLVMPassBase<
          LowerDependentMemRefToLLVMPass> {
  using LowerDependentMemRefToLLVMPassBase::LowerDependentMemRefToLLVMPassBase;

  void runOnOperation() override {
    MLIRContext *ctx = &getContext();
    DependentMemRefLLVMTypeConverter converter(ctx);
    RewritePatternSet patterns(ctx);
    ConversionTarget target(*ctx);

    target.addLegalDialect<LLVM::LLVMDialect>();
    target.addLegalOp<ModuleOp>();
    target.addIllegalDialect<dependent_memref::DependentMemRefDialect>();
    target.addIllegalDialect<func::FuncDialect>();
    target.addIllegalDialect<scf::SCFDialect>();
    target.addIllegalDialect<arith::ArithDialect>();

    arith::populateArithToLLVMConversionPatterns(converter, patterns);
    populateSCFToControlFlowConversionPatterns(patterns);
    cf::populateControlFlowToLLVMConversionPatterns(converter, patterns);
    index::populateIndexToLLVMConversionPatterns(converter, patterns);
    patterns.add<LowerFuncOp, LowerReturnOp, LowerCallOp, LowerAllocOp,
                 LowerDeallocOp, LowerLoadOp, LowerStoreOp, LowerDimOp,
                 LowerDimExactOp>(converter, ctx);
    patterns.add<LowerPointerForwardingOp>(converter, ctx,
                                           CastOp::getOperationName());
    patterns.add<LowerPointerForwardingOp>(
        converter, ctx, ReinterpretCastOp::getOperationName());

    if (failed(applyPartialConversion(getOperation(), target,
                                      std::move(patterns))))
      signalPassFailure();
  }
};
} // namespace
