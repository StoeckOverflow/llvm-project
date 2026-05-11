//===- TestDependentTensorTransforms.cpp - DependentTensor test passes ----===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/DependentTensor/IR/DependentTensor.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Dialect/SCF/IR/SCF.h"
#include "mlir/IR/Builders.h"
#include "mlir/IR/BuiltinOps.h"
#include "mlir/IR/IRMapping.h"
#include "mlir/Pass/Pass.h"
#include "mlir/Interfaces/SideEffectInterfaces.h"

using namespace mlir;

namespace {
static constexpr StringLiteral kExpectSemanticsEqualAttr =
    "test.expect_semantics_equal";
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
  return SmallVector<int32_t>(attr.asArrayRef().begin(), attr.asArrayRef().end());
}

struct TestDependentTensorEqualityPass
    : public PassWrapper<TestDependentTensorEqualityPass,
                         OperationPass<func::FuncOp>> {
  MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(TestDependentTensorEqualityPass)

  StringRef getArgument() const final { return "test-dependent-tensor-equality"; }
  StringRef getDescription() const final {
    return "Exercise dependent_tensor semantic equality helpers";
  }

  void runOnOperation() override {
    func::FuncOp func = getOperation();
    auto ret = dyn_cast<func::ReturnOp>(func.getBody().front().getTerminator());
    if (!ret || ret.getNumOperands() < 2)
      return;

    Value lhs = ret.getOperand(0);
    Value rhs = ret.getOperand(1);

    if (func->hasAttr(kExpectSemanticsEqualAttr)) {
      auto expected = getRequiredBoolAttr(func, kExpectSemanticsEqualAttr);
      auto actual = dependent_tensor::haveEqualSemantics(lhs, rhs);
      if (failed(expected) || failed(actual))
        return signalPassFailure();
      if (*expected != *actual) {
        func.emitOpError() << "expected semantic equality to be "
                           << (*expected ? "true" : "false");
        return signalPassFailure();
      }
    }

    if (func->hasAttr(kExpectDimEqualAttr)) {
      auto expected = getRequiredBoolAttr(func, kExpectDimEqualAttr);
      auto pair = getDimPair(func);
      if (failed(expected) || failed(pair))
        return signalPassFailure();
      auto actual = dependent_tensor::haveEqualDimSemantics(
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

    Operation *root = getOperation();
    SmallVector<Operation *> propertyUsers =
        getDependentTensorPropertyUsers(indexResults.front(), root);
    if (propertyUsers.empty())
      return;

    indexResults.front().replaceAllUsesExcept(indexResults[1],
                                              propertyUsers.front());
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
    return "Exercise replaceUsesWithIf owner approximation for properties";
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
      return isa<dependent_tensor::MakeOp>(use.getOwner());
    });
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

struct TestDependentTensorCorruptSemanticsPass
    : public PassWrapper<TestDependentTensorCorruptSemanticsPass,
                         OperationPass<ModuleOp>> {
  MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(
      TestDependentTensorCorruptSemanticsPass)

  StringRef getArgument() const final {
    return "test-dependent-tensor-corrupt-semantics";
  }
  StringRef getDescription() const final {
    return "Inject invalid dependent tensor metadata for verifier tests";
  }

  void runOnOperation() override {
    ModuleOp module = getOperation();
    corruptDominance(module);
    corruptIsolatedCapture(module);
    corruptScfForBoundaryDominance(module);
  }

  static void setFirstPropertyValue(Operation *op, Value replacement) {
    bool replaced = false;
    walkDependentTensorPropertyValues(op, [&](Value &propertyValue) {
      if (!replaced) {
        propertyValue = replacement;
        replaced = true;
      }
    });
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
        "semantic_bad_dominance_property_owner");
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

  static void corruptIsolatedCapture(ModuleOp module) {
    auto source =
        module.lookupSymbol<func::FuncOp>("semantic_isolated_capture_source");
    auto victim =
        module.lookupSymbol<func::FuncOp>("semantic_isolated_capture_victim");
    if (!source || !victim || source.getNumArguments() == 0)
      return;
    dependent_tensor::MakeOp makeOp = findFirstMake(victim);
    if (!makeOp)
      return;
    setFirstPropertyValue(makeOp, source.getArgument(0));
  }

  static void corruptScfForBoundaryDominance(ModuleOp module) {
    auto func =
        module.lookupSymbol<func::FuncOp>("semantic_bad_scf_for_body_dim");
    if (!func)
      return;
    scf::ForOp forOp;
    func.walk([&](scf::ForOp op) {
      if (!forOp)
        forOp = op;
    });
    if (!forOp || forOp.getInitArgs().empty())
      return;

    dependent_tensor::MakeOp bodyMake;
    forOp.getBody()->walk([&](dependent_tensor::MakeOp op) {
      if (!bodyMake)
        bodyMake = op;
    });
    if (!bodyMake)
      return;
    forOp->setOperand(3, bodyMake.getResult());
  }
};
} // namespace

namespace mlir {
namespace test {
void registerDependentTensorTestPasses() {
  PassRegistration<TestDependentTensorEqualityPass>();
  PassRegistration<TestDependentTensorCloneLocalProducerPass>();
  PassRegistration<TestDependentTensorReplaceDimValuePass>();
  PassRegistration<TestDependentTensorReplaceDimValueExceptPass>();
  PassRegistration<TestDependentTensorReplaceDimValueIfPass>();
  PassRegistration<TestDependentTensorReplaceOpUsesPass>();
  PassRegistration<TestDependentTensorReplaceFirstBlockArgPass>();
  PassRegistration<TestDependentTensorCheckPropertyUsesPass>();
  PassRegistration<TestDependentTensorDceLocalDimsPass>();
  PassRegistration<TestDependentTensorCorruptSemanticsPass>();
}
} // namespace test
} // namespace mlir
