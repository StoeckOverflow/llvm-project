//===- TestDependentTensorTransforms.cpp - DependentTensor test passes ----===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Dialect/DependentTensor/IR/DependentTensor.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Dialect/SCF/IR/SCF.h"
#include "mlir/IR/Builders.h"
#include "mlir/IR/BuiltinOps.h"
#include "mlir/IR/Dominance.h"
#include "mlir/IR/IRMapping.h"
#include "mlir/IR/PatternMatch.h"
#include "mlir/IR/PropertySSAUseSupport.h"
#include "mlir/Interfaces/SideEffectInterfaces.h"
#include "mlir/Pass/Pass.h"
#include "mlir/Transforms/DialectConversion.h"
#include "mlir/Transforms/Inliner.h"
#include "mlir/Transforms/InliningUtils.h"
#include "llvm/ADT/STLExtras.h"

using namespace mlir;

namespace {
static constexpr StringLiteral kExpectRefinementsEqualAttr =
    "test.expect_refinements_equal";
static constexpr StringLiteral kExpectDimEqualAttr = "test.expect_dim_equal";
static constexpr StringLiteral kDimPairAttr = "test.dim_pair";

static FailureOr<bool> getRequiredBoolAttr(func::FuncOp func, StringRef name) {
  auto attr = func->getAttrOfType<BoolAttr>(name);
  if (!attr) {
    func.emitOpError() << "requires bool attr '" << name << "'";
    return failure();
  }
  return attr.getValue();
}

static FailureOr<SmallVector<int32_t>> getDimPair(func::FuncOp func) {
  auto attr = func->getAttrOfType<DenseI32ArrayAttr>(kDimPairAttr);
  if (!attr || attr.size() != 2) {
    func.emitOpError() << "requires '" << kDimPairAttr
                       << "' = array<i32: lhsDim, rhsDim>";
    return failure();
  }
  return SmallVector<int32_t>(attr.asArrayRef().begin(),
                              attr.asArrayRef().end());
}

struct TestDependentTensorInlinerInterface : public InlinerInterface {
  using InlinerInterface::InlinerInterface;

  bool isLegalToInline(Operation *call, Operation *callable,
                       bool wouldBeCloned) const override {
    return true;
  }
  bool isLegalToInline(Region *dest, Region *src, bool wouldBeCloned,
                       IRMapping &valueMapping) const override {
    return true;
  }
  bool isLegalToInline(Operation *op, Region *dest, bool wouldBeCloned,
                       IRMapping &valueMapping) const override {
    return true;
  }
};

struct TestDependentTensorEqualityPass
    : public PassWrapper<TestDependentTensorEqualityPass,
                         OperationPass<func::FuncOp>> {
  MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(TestDependentTensorEqualityPass)

  StringRef getArgument() const final {
    return "test-dependent-tensor-equality";
  }
  StringRef getDescription() const final {
    return "Exercise dependent_tensor refinement equality helpers";
  }

  void runOnOperation() override {
    func::FuncOp func = getOperation();
    auto ret = dyn_cast<func::ReturnOp>(func.getBody().front().getTerminator());
    if (!ret || ret.getNumOperands() < 2)
      return;

    Value lhs = ret.getOperand(0);
    Value rhs = ret.getOperand(1);

    if (func->hasAttr(kExpectRefinementsEqualAttr)) {
      auto expected = getRequiredBoolAttr(func, kExpectRefinementsEqualAttr);
      auto actual = dependent_tensor::haveEqualRefinements(lhs, rhs);
      if (failed(expected) || failed(actual))
        return signalPassFailure();
      if (*expected != *actual) {
        func.emitOpError() << "expected refinement equality to be "
                           << (*expected ? "true" : "false");
        return signalPassFailure();
      }
    }

    if (func->hasAttr(kExpectDimEqualAttr)) {
      auto expected = getRequiredBoolAttr(func, kExpectDimEqualAttr);
      auto pair = getDimPair(func);
      if (failed(expected) || failed(pair))
        return signalPassFailure();
      auto actual = dependent_tensor::haveEqualDimRefinements(
          lhs, static_cast<unsigned>((*pair)[0]), rhs,
          static_cast<unsigned>((*pair)[1]));
      if (failed(actual))
        return signalPassFailure();
      if (*expected != *actual) {
        func.emitOpError() << "expected dim equality to be "
                           << (*expected ? "true" : "false");
        return signalPassFailure();
      }
    }
  }
};

struct TestDependentTensorCloneLocalProducerPass
    : public PassWrapper<TestDependentTensorCloneLocalProducerPass,
                         OperationPass<func::FuncOp>> {
  MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(
      TestDependentTensorCloneLocalProducerPass)

  StringRef getArgument() const final {
    return "test-dependent-tensor-clone-local-producer";
  }
  StringRef getDescription() const final {
    return "Exercise dependent tensor property remapping during cloning";
  }

  void runOnOperation() override {
    Block &entry = getOperation().getBody().front();
    SmallVector<Operation *> toClone;
    for (Operation &op : entry) {
      if (op.hasTrait<OpTrait::IsTerminator>())
        break;
      toClone.push_back(&op);
    }
    if (toClone.empty())
      return;

    IRMapping mapping;
    OpBuilder builder(getOperation().getContext());
    builder.setInsertionPoint(entry.getTerminator());
    for (Operation *op : toClone)
      builder.clone(*op, mapping);
  }
};

struct TestDependentTensorCloneFuncBoundaryPass
    : public PassWrapper<TestDependentTensorCloneFuncBoundaryPass,
                         OperationPass<ModuleOp>> {
  MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(
      TestDependentTensorCloneFuncBoundaryPass)

  StringRef getArgument() const final {
    return "test-dependent-tensor-clone-func-boundary";
  }
  StringRef getDescription() const final {
    return "Exercise function boundary property remapping during cloning";
  }

  void runOnOperation() override {
    ModuleOp module = getOperation();
    auto source =
        module.lookupSymbol<func::FuncOp>("clone_func_boundary_source");
    if (!source)
      return;

    func::FuncOp clone = source.clone();
    clone.setName("clone_func_boundary_source_clone");
    module.push_back(clone);
  }
};

struct TestDependentTensorReplaceDimValuePass
    : public PassWrapper<TestDependentTensorReplaceDimValuePass,
                         OperationPass<func::FuncOp>> {
  MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(
      TestDependentTensorReplaceDimValuePass)

  StringRef getArgument() const final {
    return "test-dependent-tensor-replace-dim-value";
  }
  StringRef getDescription() const final {
    return "Exercise dependent tensor property-aware replaceAllUsesWith";
  }

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

struct TestDependentTensorRewriterReplaceOpPass
    : public PassWrapper<TestDependentTensorRewriterReplaceOpPass,
                         OperationPass<func::FuncOp>> {
  MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(
      TestDependentTensorRewriterReplaceOpPass)

  StringRef getArgument() const final {
    return "test-dependent-tensor-rewriter-replace-op";
  }
  StringRef getDescription() const final {
    return "Exercise RewriterBase::replaceOp for property SSA uses";
  }

  void runOnOperation() override {
    if (getOperation().getName() != "rewriter_replace_op_property_ref")
      return;

    arith::ConstantIndexOp oldDim;
    for (Operation &op : getOperation().getBody().front()) {
      auto constant = dyn_cast<arith::ConstantIndexOp>(op);
      if (constant && constant.value() == 1) {
        oldDim = constant;
        break;
      }
    }
    if (!oldDim)
      return;

    IRRewriter rewriter(getOperation().getContext());
    rewriter.setInsertionPointAfter(oldDim);
    auto replacement =
        arith::ConstantIndexOp::create(rewriter, oldDim.getLoc(), 9);
    rewriter.replaceOp(oldDim, replacement.getResult());
  }
};

struct ReplaceConstantElevenPattern
    : public OpConversionPattern<arith::ConstantOp> {
  using OpConversionPattern<arith::ConstantOp>::OpConversionPattern;

  LogicalResult
  matchAndRewrite(arith::ConstantOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const override {
    auto value = dyn_cast<IntegerAttr>(op.getValue());
    if (!value || !op.getType().isIndex() || value.getInt() != 11)
      return failure();
    auto replacement =
        arith::ConstantIndexOp::create(rewriter, op.getLoc(), 12);
    rewriter.replaceOp(op, replacement.getResult());
    return success();
  }
};

struct TestDependentTensorDialectConversionRemapPass
    : public PassWrapper<TestDependentTensorDialectConversionRemapPass,
                         OperationPass<func::FuncOp>> {
  MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(
      TestDependentTensorDialectConversionRemapPass)

  StringRef getArgument() const final {
    return "test-dependent-tensor-dialect-conversion-remap";
  }
  StringRef getDescription() const final {
    return "Exercise dialect conversion replacement for property SSA uses";
  }

  void runOnOperation() override {
    if (getOperation().getName() != "dialect_conversion_property_ref")
      return;

    ConversionTarget target(getContext());
    target.markUnknownOpDynamicallyLegal([](Operation *) { return true; });
    target.addDynamicallyLegalOp<arith::ConstantOp>([](arith::ConstantOp op) {
      auto value = dyn_cast<IntegerAttr>(op.getValue());
      return !value || !op.getType().isIndex() || value.getInt() != 11;
    });

    RewritePatternSet patterns(&getContext());
    patterns.add<ReplaceConstantElevenPattern>(&getContext());
    if (failed(applyPartialConversion(getOperation(), target,
                                      std::move(patterns)))) {
      getOperation()->emitError()
          << "dependent tensor dialect conversion remap failed";
      signalPassFailure();
    }
  }
};

struct TestDependentTensorInlineCalleePass
    : public PassWrapper<TestDependentTensorInlineCalleePass,
                         OperationPass<ModuleOp>> {
  MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(
      TestDependentTensorInlineCalleePass)

  StringRef getArgument() const final {
    return "test-dependent-tensor-inline-callee";
  }
  StringRef getDescription() const final {
    return "Exercise inliner remapping for dependent tensor property SSA uses";
  }

  void runOnOperation() override {
    ModuleOp module = getOperation();
    auto caller =
        module.lookupSymbol<func::FuncOp>("inline_property_ssa_caller");
    auto callee =
        module.lookupSymbol<func::FuncOp>("inline_property_ssa_callee");
    if (!caller || !callee)
      return;

    func::CallOp call;
    caller.walk([&](func::CallOp candidate) {
      if (!call && candidate.getCallee() == callee.getName())
        call = candidate;
    });
    if (!call)
      return;

    InlinerConfig config;
    TestDependentTensorInlinerInterface interface(&getContext());
    if (failed(inlineRegion(interface, config.getCloneCallback(),
                            &callee.getBody(), call, call.getArgOperands(),
                            call.getResults(), call.getLoc(),
                            /*shouldCloneInlinedRegion=*/true))) {
      call.emitError() << "failed to inline dependent tensor callee";
      signalPassFailure();
      return;
    }

    call.erase();
  }
};

struct TestDependentTensorReplaceDimValueExceptPass
    : public PassWrapper<TestDependentTensorReplaceDimValueExceptPass,
                         OperationPass<func::FuncOp>> {
  MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(
      TestDependentTensorReplaceDimValueExceptPass)

  StringRef getArgument() const final {
    return "test-dependent-tensor-replace-dim-value-except";
  }
  StringRef getDescription() const final {
    return "Exercise dependent tensor property-aware replaceAllUsesExcept";
  }

  void runOnOperation() override {
    if (getOperation().getName() != "replace_dim_value_except")
      return;

    SmallVector<Value> indexResults;
    for (Operation &op : getOperation().getBody().front())
      for (Value result : op.getResults())
        if (result.getType().isIndex())
          indexResults.push_back(result);
    if (indexResults.size() < 2)
      return;

    Operation *exceptedOwner = nullptr;
    for (Operation &op : getOperation().getBody().front()) {
      walkDependentTensorPropertyUses(
          &op, [&](PropertyOperand &propertyOperand) {
            Value propertyValue = propertyOperand.get();
            if (!exceptedOwner && propertyValue == indexResults.front())
              exceptedOwner = &op;
          });
      if (exceptedOwner)
        break;
    }
    if (!exceptedOwner)
      return;

    indexResults.front().replaceAllUsesExcept(indexResults[1], exceptedOwner);
  }
};

struct TestDependentTensorRewriterReplaceDimValueExceptPass
    : public PassWrapper<TestDependentTensorRewriterReplaceDimValueExceptPass,
                         OperationPass<func::FuncOp>> {
  MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(
      TestDependentTensorRewriterReplaceDimValueExceptPass)

  StringRef getArgument() const final {
    return "test-dependent-tensor-rewriter-replace-dim-value-except";
  }
  StringRef getDescription() const final {
    return "Exercise RewriterBase::replaceAllUsesExcept for property-only refs";
  }

  void runOnOperation() override {
    if (getOperation().getName() != "rewriter_replace_dim_value_except")
      return;

    SmallVector<Value> indexResults;
    for (Operation &op : getOperation().getBody().front())
      for (Value result : op.getResults())
        if (result.getType().isIndex())
          indexResults.push_back(result);
    if (indexResults.size() < 2)
      return;

    Operation *exceptedOwner = nullptr;
    for (Operation &op : getOperation().getBody().front()) {
      walkDependentTensorPropertyUses(
          &op, [&](PropertyOperand &propertyOperand) {
            Value propertyValue = propertyOperand.get();
            if (!exceptedOwner && propertyValue == indexResults.front())
              exceptedOwner = &op;
          });
      if (exceptedOwner)
        break;
    }
    if (!exceptedOwner)
      return;

    IRRewriter rewriter(getOperation().getContext());
    rewriter.replaceAllUsesExcept(indexResults.front(), indexResults[1],
                                  exceptedOwner);
  }
};

struct TestDependentTensorReplaceDimValueIfPass
    : public PassWrapper<TestDependentTensorReplaceDimValueIfPass,
                         OperationPass<func::FuncOp>> {
  MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(
      TestDependentTensorReplaceDimValueIfPass)

  StringRef getArgument() const final {
    return "test-dependent-tensor-replace-dim-value-if";
  }
  StringRef getDescription() const final {
    return "Exercise native-only replaceUsesWithIf behavior";
  }

  void runOnOperation() override {
    if (getOperation().getName() != "replace_dim_value_if")
      return;

    SmallVector<BlockArgument> indexArgs;
    for (BlockArgument arg : getOperation().getArguments())
      if (arg.getType().isIndex())
        indexArgs.push_back(arg);
    if (indexArgs.size() < 2)
      return;

    indexArgs.front().replaceUsesWithIf(indexArgs[1], [](OpOperand &use) {
      return isa<arith::AddIOp>(use.getOwner());
    });
  }
};

struct TestDependentTensorReplaceDimValueSSAIfPass
    : public PassWrapper<TestDependentTensorReplaceDimValueSSAIfPass,
                         OperationPass<func::FuncOp>> {
  MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(
      TestDependentTensorReplaceDimValueSSAIfPass)

  StringRef getArgument() const final {
    return "test-dependent-tensor-replace-dim-value-ssa-if";
  }
  StringRef getDescription() const final {
    return "Exercise replaceSSAUsesWithIf for precise property SSA refs";
  }

  void runOnOperation() override {
    if (getOperation().getName() != "replace_dim_value_ssa_if" &&
        getOperation().getName() != "rewriter_replace_dim_value_ssa_if")
      return;

    SmallVector<BlockArgument> indexArgs;
    for (BlockArgument arg : getOperation().getArguments())
      if (arg.getType().isIndex())
        indexArgs.push_back(arg);
    if (indexArgs.size() < 2)
      return signalPassFailure();

    auto shouldReplacePropertyOnly = [](SSAUse use) {
      return use.isProperty();
    };
    if (getOperation().getName() == "replace_dim_value_ssa_if") {
      indexArgs.front().replaceSSAUsesWithIf(indexArgs[1],
                                             shouldReplacePropertyOnly);
      return;
    }

    bool allUsesReplaced = true;
    IRRewriter rewriter(getOperation().getContext());
    rewriter.replaceSSAUsesWithIf(indexArgs.front(), indexArgs[1],
                                  shouldReplacePropertyOnly, &allUsesReplaced);
    if (allUsesReplaced) {
      getOperation().emitOpError(
          "expected native operand uses to remain unreplaced");
      return signalPassFailure();
    }
  }
};

struct TestDependentTensorReplaceOpUsesPass
    : public PassWrapper<TestDependentTensorReplaceOpUsesPass,
                         OperationPass<func::FuncOp>> {
  MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(
      TestDependentTensorReplaceOpUsesPass)

  StringRef getArgument() const final {
    return "test-dependent-tensor-replace-op-uses";
  }
  StringRef getDescription() const final {
    return "Exercise operation-local replacement including property refs";
  }

  void runOnOperation() override {
    if (getOperation().getName() == "replace_insert_destination_refinement") {
      SmallVector<dependent_tensor::MakeOp> makeOps;
      SmallVector<dependent_tensor::InsertOp> insertOps;
      getOperation().walk([&](Operation *op) {
        if (auto makeOp = dyn_cast<dependent_tensor::MakeOp>(op))
          makeOps.push_back(makeOp);
        if (auto insertOp = dyn_cast<dependent_tensor::InsertOp>(op))
          insertOps.push_back(insertOp);
      });
      if (makeOps.size() < 2 || insertOps.empty())
        return signalPassFailure();
      for (Operation &op : getOperation().getBody().front())
        replaceUsesOfWithIncludingDependentTensorProperties(
            &op, makeOps.front().getResult(), makeOps[1].getResult());
      for (dependent_tensor::InsertOp insertOp : insertOps)
        if (failed(dependent_tensor::refreshDependentTensorForwardingRefinement(
                insertOp)))
          return signalPassFailure();
      return;
    }

    SmallVector<Value> indexResults;
    for (Operation &op : getOperation().getBody().front())
      for (Value result : op.getResults())
        if (result.getType().isIndex())
          indexResults.push_back(result);
    if (indexResults.size() < 2)
      return;
    for (Operation &op : getOperation().getBody().front())
      replaceUsesOfWithIncludingDependentTensorProperties(
          &op, indexResults.front(), indexResults[1]);
  }
};

struct TestDependentTensorEraseScfForResultPass
    : public PassWrapper<TestDependentTensorEraseScfForResultPass,
                         OperationPass<func::FuncOp>> {
  MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(
      TestDependentTensorEraseScfForResultPass)

  StringRef getArgument() const final {
    return "test-dependent-tensor-erase-scf-for-result";
  }
  StringRef getDescription() const final {
    return "Exercise RewriterBase::eraseOpResults for loop property metadata";
  }

  void runOnOperation() override {
    if (getOperation().getName() != "erase_scf_for_result_refinement")
      return;

    scf::ForOp forOp;
    getOperation().walk([&](scf::ForOp op) {
      if (!forOp)
        forOp = op;
    });
    if (!forOp || forOp.getNumResults() < 2 || forOp.getInitArgs().size() < 2)
      return signalPassFailure();

    auto yieldOp = dyn_cast<scf::YieldOp>(forOp.getBody()->getTerminator());
    if (!yieldOp || yieldOp->getNumOperands() < 2)
      return signalPassFailure();

    IRRewriter rewriter(getOperation().getContext());
    rewriter.modifyOpInPlace(forOp, [&]() {
      yieldOp->eraseOperand(0);
      forOp.getBody()->eraseArgument(forOp.getNumInductionVars());
      forOp->eraseOperand(3);
    });

    BitVector erasedResults(forOp.getNumResults());
    erasedResults.set(0);
    rewriter.eraseOpResults(forOp, erasedResults);
  }
};

struct TestDependentTensorEraseFunctionSignaturePass
    : public PassWrapper<TestDependentTensorEraseFunctionSignaturePass,
                         OperationPass<func::FuncOp>> {
  MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(
      TestDependentTensorEraseFunctionSignaturePass)

  StringRef getArgument() const final {
    return "test-dependent-tensor-erase-function-signature";
  }
  StringRef getDescription() const final {
    return "Exercise function signature erasure for dependent tensor metadata";
  }

  void runOnOperation() override {
    func::FuncOp func = getOperation();
    if (func.getName() == "erase_func_boundary_arg_metadata") {
      BitVector erasedArgs(func.getNumArguments());
      erasedArgs.set(0);
      erasedArgs.set(3);
      if (failed(func.eraseArguments(erasedArgs)))
        return signalPassFailure();
      return;
    }

    if (func.getName() == "erase_func_boundary_result_metadata") {
      auto returnOp =
          dyn_cast<func::ReturnOp>(func.getBody().front().getTerminator());
      if (!returnOp || returnOp.getNumOperands() < 2)
        return signalPassFailure();
      returnOp->eraseOperand(0);
      BitVector erasedResults(func.getNumResults());
      erasedResults.set(0);
      if (failed(func.eraseResults(erasedResults)))
        return signalPassFailure();
      return;
    }

    if (func.getName() == "erase_func_boundary_live_dim_arg") {
      BitVector erasedArgs(func.getNumArguments());
      erasedArgs.set(0);
      if (failed(func.eraseArguments(erasedArgs)))
        return signalPassFailure();
      func.emitOpError(
          "expected erasing live dependent tensor dim arg to fail");
      return signalPassFailure();
    }
  }
};

struct TestDependentTensorReplaceOpUsesNoRefreshPass
    : public PassWrapper<TestDependentTensorReplaceOpUsesNoRefreshPass,
                         OperationPass<func::FuncOp>> {
  MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(
      TestDependentTensorReplaceOpUsesNoRefreshPass)

  StringRef getArgument() const final {
    return "test-dependent-tensor-replace-op-uses-no-refresh";
  }
  StringRef getDescription() const final {
    return "Rewrite insert destination without refreshing cached refinement";
  }

  void runOnOperation() override {
    if (getOperation().getName() != "stale_insert_destination_refinement")
      return;

    SmallVector<dependent_tensor::MakeOp> makeOps;
    getOperation().walk(
        [&](dependent_tensor::MakeOp op) { makeOps.push_back(op); });
    if (makeOps.size() < 2)
      return signalPassFailure();

    for (Operation &op : getOperation().getBody().front())
      replaceUsesOfWithIncludingDependentTensorProperties(
          &op, makeOps.front().getResult(), makeOps[1].getResult());
  }
};

struct TestDependentTensorRefreshPropertyUsesPass
    : public PassWrapper<TestDependentTensorRefreshPropertyUsesPass,
                         OperationPass<func::FuncOp>> {
  MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(
      TestDependentTensorRefreshPropertyUsesPass)

  StringRef getArgument() const final {
    return "test-dependent-tensor-refresh-property-uses";
  }
  StringRef getDescription() const final {
    return "Exercise property SSA use-list refresh after direct mutation";
  }

  void runOnOperation() override {
    if (getOperation().getName() != "refresh_property_use_membership")
      return;

    SmallVector<Value> indexArgs;
    for (BlockArgument arg : getOperation().getArguments())
      if (arg.getType().isIndex())
        indexArgs.push_back(arg);
    if (indexArgs.size() < 2)
      return signalPassFailure();

    Value oldValue = indexArgs[0];
    Value newValue = indexArgs[1];
    bool replaced = false;
    walkDependentTensorPropertyUses(
        getOperation(), [&](PropertyOperand &propertyOperand) {
          if (!replaced && propertyOperand.get() == oldValue) {
            propertyOperand.set(newValue);
            replaced = true;
          }
        });
    if (!replaced)
      return signalPassFailure();

    Operation *owner = getOperation();
    reattachPropertyOperands(owner);
    if (!oldValue.property_use_empty() || newValue.property_use_empty()) {
      getOperation().emitOpError("expected refreshed property SSA use-list");
      return signalPassFailure();
    }
    if (!llvm::is_contained(newValue.getPropertyUsers(), owner)) {
      getOperation().emitOpError("expected new value property user");
      return signalPassFailure();
    }
    if (!oldValue.use_empty() || !newValue.use_empty()) {
      getOperation().emitOpError(
          "expected native use-list to stay operand-only");
      return signalPassFailure();
    }
  }
};

struct TestDependentTensorReplaceFirstBlockArgPass
    : public PassWrapper<TestDependentTensorReplaceFirstBlockArgPass,
                         OperationPass<func::FuncOp>> {
  MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(
      TestDependentTensorReplaceFirstBlockArgPass)

  StringRef getArgument() const final {
    return "test-dependent-tensor-replace-first-block-arg";
  }
  StringRef getDescription() const final {
    return "Exercise dependent tensor property-aware block argument RAUW";
  }

  void runOnOperation() override {
    SmallVector<BlockArgument> indexArgs;
    for (BlockArgument arg : getOperation().getArguments())
      if (arg.getType().isIndex())
        indexArgs.push_back(arg);
    if (indexArgs.size() < 2)
      return;
    indexArgs.front().replaceAllUsesWith(indexArgs[1]);
  }
};

struct TestDependentTensorCheckPropertyUsesPass
    : public PassWrapper<TestDependentTensorCheckPropertyUsesPass,
                         OperationPass<func::FuncOp>> {
  MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(
      TestDependentTensorCheckPropertyUsesPass)

  StringRef getArgument() const final {
    return "test-dependent-tensor-check-property-uses";
  }
  StringRef getDescription() const final {
    return "Exercise dependent tensor second-class use query helpers";
  }

  void runOnOperation() override {
    Operation *root = getOperation();
    if (getOperation().getName() == "check_repeated_property_users") {
      Value value = getOperation().getArgument(0);
      unsigned propertyUseCount = 0;
      for (PropertyOperand &use : value.getPropertyUses())
        if (root->isAncestor(use.getOwner()))
          ++propertyUseCount;
      if (propertyUseCount != 3) {
        root->emitOpError("expected three property SSA use nodes");
        return signalPassFailure();
      }
      if (getDependentTensorPropertyUsers(value, root).size() != 2) {
        root->emitOpError("expected two deduplicated property users");
        return signalPassFailure();
      }
      return;
    }

    if (getOperation().getName() == "check_multi_result_property_use") {
      Operation *producer = nullptr;
      getOperation().walk([&](scf::IfOp ifOp) {
        if (!producer)
          producer = ifOp.getOperation();
      });
      if (!producer || producer->getNumResults() != 2)
        return signalPassFailure();
      if (producer->getResult(0).property_use_empty() ||
          producer->getResult(0).all_use_empty()) {
        root->emitOpError("expected first result to have property SSA use");
        return signalPassFailure();
      }
      if (!producer->getResult(1).property_use_empty() ||
          !producer->getResult(1).all_use_empty()) {
        root->emitOpError("expected second result to be unused");
        return signalPassFailure();
      }
      if (!hasDependentTensorResultUses(producer, root)) {
        root->emitOpError("expected producer result property uses");
        return signalPassFailure();
      }
      return;
    }

    if (getOperation().getName() == "check_func_boundary_property_users") {
      Value value = getOperation().getArgument(0);
      if (value.property_use_empty() || value.getPropertyUsers().empty()) {
        root->emitOpError("expected function boundary property SSA use");
        return signalPassFailure();
      }
      if (value.use_empty() || value.getUsers().empty()) {
        root->emitOpError(
            "expected native and property user queries to stay distinct");
        return signalPassFailure();
      }
      return;
    }

    if (getOperation().getName() == "check_property_use_list_api") {
      Value value = getOperation().getArgument(0);
      if (value.property_use_empty() || value.all_use_empty() ||
          value.getPropertyUsers().empty() || value.getAllUsers().empty()) {
        root->emitOpError("expected intrusive property SSA uses");
        return signalPassFailure();
      }
      unsigned nativeUseCount = llvm::range_size(value.getUses());
      unsigned propertyUseCount = llvm::range_size(value.getPropertyUses());
      unsigned allUseCount = llvm::range_size(value.getAllUses());
      if (nativeUseCount == 0 || propertyUseCount == 0 ||
          allUseCount != nativeUseCount + propertyUseCount) {
        root->emitOpError()
            << "expected unified SSA use range to include native and property "
               "uses, got native="
            << nativeUseCount << ", property=" << propertyUseCount
            << ", all=" << allUseCount;
        return signalPassFailure();
      }
      scf::ForOp forOp;
      getOperation().walk([&](scf::ForOp candidate) {
        if (!forOp)
          forOp = candidate;
      });
      unsigned ownerOperandUseCount = 0;
      unsigned ownerPropertyUseCount = 0;
      if (forOp)
        forOp->walkSSAUses([&](SSAUse use) {
          if (use.isOperand())
            ++ownerOperandUseCount;
          else
            ++ownerPropertyUseCount;
        });
      if (!forOp || ownerOperandUseCount == 0 || ownerPropertyUseCount == 0) {
        root->emitOpError("expected operation unified SSA use walk to include "
                          "native and property uses");
        return signalPassFailure();
      }
      if (value.use_empty() || value.getUsers().empty()) {
        root->emitOpError(
            "expected native use-list to remain operand-only but non-empty");
        return signalPassFailure();
      }
      return;
    }

    if (getOperation().getName() ==
        "check_refinements_are_direct_property_uses") {
      Value value = getOperation().getArgument(0);
      unsigned makeUserCount = 0;
      unsigned dimUserCount = 0;
      unsigned insertUserCount = 0;
      for (Operation *user : value.getPropertyUsers()) {
        makeUserCount += isa<dependent_tensor::MakeOp>(user);
        dimUserCount += isa<dependent_tensor::DimOp>(user);
        insertUserCount += isa<dependent_tensor::InsertOp>(user);
      }
      if (!value.use_empty() || !value.getUsers().empty()) {
        root->emitOpError(
            "expected refinement dimension to have no native uses");
        return signalPassFailure();
      }
      if (makeUserCount != 1 || dimUserCount != 1 || insertUserCount != 1) {
        root->emitOpError(
            "expected make, dim, and insert to own direct property uses");
        return signalPassFailure();
      }
      dependent_tensor::InsertOp insertOp;
      getOperation().walk([&](dependent_tensor::InsertOp op) {
        if (!insertOp)
          insertOp = op;
      });
      if (!insertOp || insertOp->getNumOperands() != 3) {
        root->emitOpError(
            "expected insert refinement dimensions not to be native operands");
        return signalPassFailure();
      }
      return;
    }

    if (getOperation().getName() == "check_make_dims_property_only") {
      Value value = getOperation().getArgument(0);
      unsigned propertyUseCount = llvm::range_size(value.getPropertyUses());
      unsigned allUseCount = llvm::range_size(value.getAllUses());
      if (!value.use_empty() || !value.getUsers().empty()) {
        root->emitOpError("expected make dimension to have no native uses");
        return signalPassFailure();
      }
      if (value.property_use_empty() || value.all_use_empty() ||
          value.getPropertyUsers().empty() || propertyUseCount == 0 ||
          allUseCount != propertyUseCount) {
        root->emitOpError(
            "expected make dimension to be used only by properties");
        return signalPassFailure();
      }
      return;
    }

    if (getOperation().getName() == "check_physical_unified_use_list_api") {
      Value value = getOperation().getArgument(0);
      unsigned nativeUseCount = llvm::range_size(value.getUses());
      unsigned propertyUseCount = llvm::range_size(value.getPropertyUses());
      unsigned allUseCount = llvm::range_size(value.getAllUses());
      if (nativeUseCount == 0 || propertyUseCount == 0 ||
          allUseCount != nativeUseCount + propertyUseCount) {
        root->emitOpError("expected one raw use-list with filtered views");
        return signalPassFailure();
      }

      SmallVector<unsigned> nativeIdentity;
      for (unsigned i = 0; i < nativeUseCount; ++i)
        nativeIdentity.push_back(i);
      value.shuffleUseList(nativeIdentity);
      if (llvm::range_size(value.getUses()) != nativeUseCount ||
          llvm::range_size(value.getPropertyUses()) != propertyUseCount ||
          llvm::range_size(value.getAllUses()) != allUseCount) {
        root->emitOpError(
            "expected native use-list shuffle to preserve property uses");
        return signalPassFailure();
      }

      Value propertyOnly;
      for (BlockArgument arg : getOperation().getArguments()) {
        if (arg.use_empty() && !arg.property_use_empty()) {
          propertyOnly = arg;
          break;
        }
      }
      for (Operation &op : getOperation().getBody().front()) {
        if (propertyOnly)
          break;
        if (!isa<arith::ConstantIndexOp>(op))
          continue;
        Value result = op.getResult(0);
        if (result.use_empty() && !result.property_use_empty()) {
          propertyOnly = result;
          break;
        }
      }
      if (!propertyOnly)
        return signalPassFailure();
      if (!propertyOnly.use_empty() || propertyOnly.hasOneUse() ||
          !propertyOnly.getUsers().empty()) {
        root->emitOpError(
            "expected native use queries to ignore property-only uses");
        return signalPassFailure();
      }
      if (propertyOnly.property_use_empty() || propertyOnly.all_use_empty() ||
          propertyOnly.getAllUsers().empty() ||
          llvm::range_size(propertyOnly.getAllUses()) !=
              llvm::range_size(propertyOnly.getPropertyUses())) {
        root->emitOpError(
            "expected all-use queries to include property-only uses");
        return signalPassFailure();
      }
      propertyOnly.shuffleUseList({});
      if (propertyOnly.property_use_empty() || propertyOnly.all_use_empty()) {
        root->emitOpError(
            "expected native empty shuffle to preserve property-only uses");
        return signalPassFailure();
      }
      return;
    }

    Value value;
    for (Operation &op : getOperation().getBody().front()) {
      for (Value result : op.getResults()) {
        if (result.getType().isIndex() &&
            hasDependentTensorPropertyUses(result, root)) {
          value = result;
          break;
        }
      }
      if (value)
        break;
    }
    if (!value)
      return;
    if (value.property_use_empty() || value.all_use_empty() ||
        value.getPropertyUsers().empty() || value.getAllUsers().empty()) {
      root->emitOpError("expected intrusive property SSA uses");
      return signalPassFailure();
    }
    if (!hasDependentTensorPropertyUses(value, root) ||
        dependentTensorUseEmpty(value, root) ||
        getDependentTensorPropertyUsers(value, root).empty()) {
      root->emitOpError("expected dependent tensor property uses");
      return signalPassFailure();
    }
    if (Operation *def = value.getDefiningOp())
      if (!hasDependentTensorResultUses(def, root)) {
        root->emitOpError("expected dependent tensor result uses");
        return signalPassFailure();
      }
  }
};

struct TestDependentTensorDceLocalDimsPass
    : public PassWrapper<TestDependentTensorDceLocalDimsPass,
                         OperationPass<func::FuncOp>> {
  MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(
      TestDependentTensorDceLocalDimsPass)

  StringRef getArgument() const final {
    return "test-dependent-tensor-dce-local-dims";
  }
  StringRef getDescription() const final {
    return "Exercise property-only liveness for local dimension DCE";
  }

  void runOnOperation() override {
    Operation *scope = getOperation();
    SmallVector<Operation *> toErase;
    scope->walk([&](Operation *op) {
      if (op == scope || op->getNumResults() != 1 || op->getNumRegions() != 0)
        return;
      Value result = op->getResult(0);
      if (!result.getType().isIndex() || !result.use_empty())
        return;
      // Native use_empty() only sees OpOperand uses. Dependent tensor
      // properties carry second-class SSA refs, so check those explicitly
      // before erasing a dimension producer.
      if (!dependentTensorUseEmpty(result, scope))
        return;
      if (!wouldOpBeTriviallyDead(op))
        return;
      toErase.push_back(op);
    });

    for (Operation *op : toErase)
      op->erase();
  }
};

struct TestDependentTensorEraseLiveEntryBlockPass
    : public PassWrapper<TestDependentTensorEraseLiveEntryBlockPass,
                         OperationPass<func::FuncOp>> {
  MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(
      TestDependentTensorEraseLiveEntryBlockPass)

  StringRef getArgument() const final {
    return "test-dependent-tensor-erase-live-entry-block";
  }
  StringRef getDescription() const final {
    return "Exercise release-mode block erasure guards for property SSA uses";
  }

  void runOnOperation() override {
    if (getOperation().getName() != "erase_live_entry_block")
      return;
    getOperation().getBody().front().erase();
  }
};

struct TestDependentTensorCorruptRefinementsPass
    : public PassWrapper<TestDependentTensorCorruptRefinementsPass,
                         OperationPass<ModuleOp>> {
  MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(
      TestDependentTensorCorruptRefinementsPass)

  StringRef getArgument() const final {
    return "test-dependent-tensor-corrupt-refinements";
  }
  StringRef getDescription() const final {
    return "Inject invalid dependent tensor metadata for verifier tests";
  }

  void runOnOperation() override {
    ModuleOp module = getOperation();
    if (failed(corruptAndVerifyGenericPropertyDominance(module)))
      return signalPassFailure();
    corruptSelfResultPropertyUse(module);
    corruptDominance(module);
    corruptCycleLikeDimension(module);
    corruptIsolatedCapture(module);
    corruptFuncBoundaryIsolatedCapture(module);
    corruptScfForBoundaryDominance(module);
  }

  static void setFirstPropertyValue(Operation *op, Value replacement) {
    bool replaced = false;
    walkDependentTensorPropertyUses(op, [&](PropertyOperand &propertyOperand) {
      if (!replaced) {
        propertyOperand.set(replacement);
        replaced = true;
      }
    });
    if (replaced)
      reattachPropertyOperands(op);
  }

  static dependent_tensor::MakeOp findFirstMake(func::FuncOp func) {
    dependent_tensor::MakeOp makeOp;
    func.walk([&](dependent_tensor::MakeOp op) {
      if (!makeOp)
        makeOp = op;
    });
    return makeOp;
  }

  static void corruptDominance(ModuleOp module) {
    auto func = module.lookupSymbol<func::FuncOp>(
        "refinement_bad_dominance_property_owner");
    if (!func)
      return;
    dependent_tensor::MakeOp makeOp = findFirstMake(func);
    if (!makeOp)
      return;

    Value lateIndex;
    for (Operation &op : func.getBody().front())
      for (Value result : op.getResults())
        if (result.getType().isIndex())
          lateIndex = result;
    if (lateIndex)
      setFirstPropertyValue(makeOp, lateIndex);
  }

  static LogicalResult
  corruptAndVerifyGenericPropertyDominance(ModuleOp module) {
    auto func =
        module.lookupSymbol<func::FuncOp>("generic_bad_property_dominance");
    if (!func)
      return success();
    dependent_tensor::MakeOp makeOp = findFirstMake(func);
    if (!makeOp)
      return success();

    Value lateIndex;
    for (Operation &op : func.getBody().front())
      for (Value result : op.getResults())
        if (result.getType().isIndex())
          lateIndex = result;
    if (!lateIndex)
      return success();

    setFirstPropertyValue(makeOp, lateIndex);
    DominanceInfo dominance(module);
    return verifyPropertySSAUseDominance(makeOp, dominance);
  }

  static void corruptSelfResultPropertyUse(ModuleOp module) {
    auto func =
        module.lookupSymbol<func::FuncOp>("generic_self_result_property_use");
    if (!func)
      return;
    dependent_tensor::MakeOp makeOp = findFirstMake(func);
    if (!makeOp)
      return;
    setFirstPropertyValue(makeOp, makeOp.getResult());
  }

  static void corruptCycleLikeDimension(ModuleOp module) {
    auto func =
        module.lookupSymbol<func::FuncOp>("refinement_cycle_like_dimension");
    if (!func)
      return;
    dependent_tensor::MakeOp makeOp = findFirstMake(func);
    if (!makeOp)
      return;

    Value lateIndex;
    func.walk([&](dependent_tensor::DimOp dimOp) {
      if (!lateIndex)
        lateIndex = dimOp.getResult();
    });
    if (lateIndex)
      setFirstPropertyValue(makeOp, lateIndex);
  }

  static void corruptIsolatedCapture(ModuleOp module) {
    auto source =
        module.lookupSymbol<func::FuncOp>("refinement_isolated_capture_source");
    auto victim =
        module.lookupSymbol<func::FuncOp>("refinement_isolated_capture_victim");
    if (!source || !victim || source.getNumArguments() == 0)
      return;
    dependent_tensor::MakeOp makeOp = findFirstMake(victim);
    if (!makeOp)
      return;
    setFirstPropertyValue(makeOp, source.getArgument(0));
  }

  static void corruptFuncBoundaryIsolatedCapture(ModuleOp module) {
    auto source = module.lookupSymbol<func::FuncOp>(
        "refinement_func_boundary_isolated_capture_source");
    auto victim = module.lookupSymbol<func::FuncOp>(
        "refinement_func_boundary_isolated_capture_victim");
    if (!source || !victim || source.getNumArguments() == 0)
      return;

    auto &refinements = victim.getProperties().dependentTypeArgRefinements;
    if (refinements.empty() || refinements.front().dimValues.empty())
      return;
    refinements.front().dimValues.front().set(source.getArgument(0));
    reattachPropertyOperands(victim);
  }

  static void corruptScfForBoundaryDominance(ModuleOp module) {
    auto func =
        module.lookupSymbol<func::FuncOp>("refinement_bad_scf_for_body_dim");
    if (!func)
      return;
    scf::ForOp forOp;
    func.walk([&](scf::ForOp op) {
      if (!forOp)
        forOp = op;
    });
    if (!forOp || forOp.getInitArgs().empty())
      return;

    Value bodyDim;
    for (Operation &op : *forOp.getBody()) {
      for (Value result : op.getResults()) {
        if (result.getType().isIndex()) {
          bodyDim = result;
          break;
        }
      }
      if (bodyDim)
        break;
    }
    if (!bodyDim)
      return;
    setFirstPropertyValue(forOp, bodyDim);
  }
};

struct TestDependentTensorCorruptGenericPropertyUsePass
    : public PassWrapper<TestDependentTensorCorruptGenericPropertyUsePass,
                         OperationPass<ModuleOp>> {
  MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(
      TestDependentTensorCorruptGenericPropertyUsePass)

  StringRef getArgument() const final {
    return "test-dependent-tensor-corrupt-generic-property-uses";
  }
  StringRef getDescription() const final {
    return "Corrupt property SSA uses so the generic verifier checks them";
  }

  void runOnOperation() override {
    ModuleOp module = getOperation();
    corruptDominance(module);
    corruptIsolatedCapture(module);
  }

  static void corruptDominance(ModuleOp module) {
    auto func = module.lookupSymbol<func::FuncOp>(
        "generic_property_dominance_verifier");
    if (!func)
      return;
    dependent_tensor::MakeOp makeOp =
        TestDependentTensorCorruptRefinementsPass::findFirstMake(func);
    if (!makeOp)
      return;

    Value lateIndex;
    for (Operation &op : func.getBody().front())
      for (Value result : op.getResults())
        if (result.getType().isIndex())
          lateIndex = result;
    if (lateIndex)
      TestDependentTensorCorruptRefinementsPass::setFirstPropertyValue(
          makeOp, lateIndex);
  }

  static void corruptIsolatedCapture(ModuleOp module) {
    auto source = module.lookupSymbol<func::FuncOp>(
        "generic_property_isolated_capture_verifier_source");
    auto victim = module.lookupSymbol<func::FuncOp>(
        "generic_property_isolated_capture_verifier_victim");
    if (!source || !victim || source.getNumArguments() == 0)
      return;
    dependent_tensor::MakeOp makeOp =
        TestDependentTensorCorruptRefinementsPass::findFirstMake(victim);
    if (!makeOp)
      return;
    TestDependentTensorCorruptRefinementsPass::setFirstPropertyValue(
        makeOp, source.getArgument(0));
  }
};

struct TestDependentTensorCorruptPropertyOperandAttachmentPass
    : public PassWrapper<
          TestDependentTensorCorruptPropertyOperandAttachmentPass,
          OperationPass<func::FuncOp>> {
  MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(
      TestDependentTensorCorruptPropertyOperandAttachmentPass)

  StringRef getArgument() const final {
    return "test-dependent-tensor-corrupt-property-operand-attachment";
  }
  StringRef getDescription() const final {
    return "Detach an embedded property operand to test attachment "
           "verification";
  }

  void runOnOperation() override {
    if (getOperation().getName() != "stale_property_operand_attachment")
      return;

    SmallVector<BlockArgument> indexArgs;
    for (BlockArgument arg : getOperation().getArguments())
      if (arg.getType().isIndex())
        indexArgs.push_back(arg);
    if (indexArgs.size() < 2)
      return signalPassFailure();

    bool replaced = false;
    getOperation()->walk([&](Operation *op) {
      walkDependentTensorPropertyUses(
          op, [&](PropertyOperand &propertyOperand) {
            if (!replaced && propertyOperand.get() == indexArgs[0]) {
              propertyOperand.detach();
              replaced = true;
            }
          });
    });
    if (!replaced)
      return signalPassFailure();
  }
};
} // namespace

namespace mlir {
namespace test {
void registerDependentTensorTestPasses() {
  PassRegistration<TestDependentTensorEqualityPass>();
  PassRegistration<TestDependentTensorCloneLocalProducerPass>();
  PassRegistration<TestDependentTensorCloneFuncBoundaryPass>();
  PassRegistration<TestDependentTensorReplaceDimValuePass>();
  PassRegistration<TestDependentTensorRewriterReplaceOpPass>();
  PassRegistration<TestDependentTensorDialectConversionRemapPass>();
  PassRegistration<TestDependentTensorInlineCalleePass>();
  PassRegistration<TestDependentTensorReplaceDimValueExceptPass>();
  PassRegistration<TestDependentTensorRewriterReplaceDimValueExceptPass>();
  PassRegistration<TestDependentTensorReplaceDimValueIfPass>();
  PassRegistration<TestDependentTensorReplaceDimValueSSAIfPass>();
  PassRegistration<TestDependentTensorReplaceOpUsesPass>();
  PassRegistration<TestDependentTensorEraseScfForResultPass>();
  PassRegistration<TestDependentTensorEraseFunctionSignaturePass>();
  PassRegistration<TestDependentTensorReplaceOpUsesNoRefreshPass>();
  PassRegistration<TestDependentTensorRefreshPropertyUsesPass>();
  PassRegistration<TestDependentTensorReplaceFirstBlockArgPass>();
  PassRegistration<TestDependentTensorCheckPropertyUsesPass>();
  PassRegistration<TestDependentTensorDceLocalDimsPass>();
  PassRegistration<TestDependentTensorEraseLiveEntryBlockPass>();
  PassRegistration<TestDependentTensorCorruptRefinementsPass>();
  PassRegistration<TestDependentTensorCorruptGenericPropertyUsePass>();
  PassRegistration<TestDependentTensorCorruptPropertyOperandAttachmentPass>();
}
} // namespace test
} // namespace mlir
