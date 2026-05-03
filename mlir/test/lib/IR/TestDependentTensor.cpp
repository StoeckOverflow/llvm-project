#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/IR/DependentTensorSupport.h"
#include "mlir/Pass/Pass.h"

using namespace mlir;

namespace {
static Value findAnchorSeed(func::FuncOp func) {
  Block &entry = func.getBody().front();
  for (BlockArgument arg : entry.getArguments())
    if (arg.getType().isIndex())
      return arg;
  for (Operation &op : entry)
    for (Value result : op.getResults())
      if (result.getType().isIndex())
        return result;
  return Value();
}

static Value findReplacementSeed(func::FuncOp func, Value original) {
  Block &entry = func.getBody().front();
  for (Operation &op : entry)
    for (Value result : op.getResults())
      if (result.getType().isIndex() && result != original)
        return result;
  return Value();
}

struct TestDependentTensorEraseOwnerPass
    : public PassWrapper<TestDependentTensorEraseOwnerPass,
                         OperationPass<func::FuncOp>> {
  MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(
      TestDependentTensorEraseOwnerPass)

  StringRef getArgument() const final {
    return "test-dependent-tensor-erase-owner";
  }
  StringRef getDescription() const final {
    return "Exercise dependent tensor owner erase checks";
  }

  void runOnOperation() override {
    Block &entry = getOperation().getBody().front();
    Operation *target = nullptr;
    for (Operation &op : entry) {
      if (!op.hasTrait<OpTrait::IsTerminator>()) {
        target = &op;
        break;
      }
    }
    if (!target)
      return signalPassFailure();

    if (failed(checkDependentAnchorOwnerCanErase(
            target, [&]() { return target->emitOpError(); })))
      return;
    signalPassFailure();
  }
};

struct TestDependentTensorEraseBlockArgPass
    : public PassWrapper<TestDependentTensorEraseBlockArgPass,
                         OperationPass<func::FuncOp>> {
  MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(
      TestDependentTensorEraseBlockArgPass)

  StringRef getArgument() const final {
    return "test-dependent-tensor-erase-block-arg";
  }
  StringRef getDescription() const final {
    return "Exercise dependent tensor block argument erase checks";
  }

  void runOnOperation() override {
    func::FuncOp func = getOperation();
    Block &entry = func.getBody().front();
    if (entry.empty() || entry.getNumArguments() == 0)
      return signalPassFailure();
    BlockArgument arg = entry.getArgument(0);
    if (failed(checkDependentAnchorValueCanErase(
            arg, [&]() { return emitError(arg.getLoc()); })))
      return;
  }
};

struct TestDependentTensorRemoveAnchorPass
    : public PassWrapper<TestDependentTensorRemoveAnchorPass,
                         OperationPass<func::FuncOp>> {
  MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(
      TestDependentTensorRemoveAnchorPass)

  StringRef getArgument() const final {
    return "test-dependent-tensor-remove-anchor";
  }
  StringRef getDescription() const final {
    return "Remove the owner-local slot for the first dependent anchor seed";
  }

  void runOnOperation() override {
    Value seed = findAnchorSeed(getOperation());
    if (!seed || failed(removeDependentAnchorForValue(seed)))
      signalPassFailure();
  }
};

struct TestDependentTensorResetOwnerPropertiesPass
    : public PassWrapper<TestDependentTensorResetOwnerPropertiesPass,
                         OperationPass<func::FuncOp>> {
  MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(
      TestDependentTensorResetOwnerPropertiesPass)

  StringRef getArgument() const final {
    return "test-dependent-tensor-reset-owner-properties";
  }
  StringRef getDescription() const final {
    return "Clear the owner-local properties for the first dependent anchor "
           "seed";
  }

  void runOnOperation() override {
    func::FuncOp func = getOperation();
    Value seed = findAnchorSeed(func);
    if (!seed)
      return signalPassFailure();

    FailureOr<AnchorKey> key = createAnchorKeyForValue(seed);
    if (failed(key))
      return signalPassFailure();

    Operation *owner =
        findDependentAnchorOwner(func, key->ownerKind, key->ownerTag);
    if (!owner)
      return signalPassFailure();

    resetDependentTensorOwnerProperties(owner);
  }
};

struct TestDependentTensorMarkDeadPass
    : public PassWrapper<TestDependentTensorMarkDeadPass,
                         OperationPass<func::FuncOp>> {
  MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(
      TestDependentTensorMarkDeadPass)

  StringRef getArgument() const final {
    return "test-dependent-tensor-mark-dead";
  }
  StringRef getDescription() const final {
    return "Mark the first dependent anchor seed as dead";
  }

  void runOnOperation() override {
    Value seed = findAnchorSeed(getOperation());
    if (!seed || failed(markDependentAnchorDead(seed)))
      signalPassFailure();
  }
};

struct TestDependentTensorBumpGenerationPass
    : public PassWrapper<TestDependentTensorBumpGenerationPass,
                         OperationPass<func::FuncOp>> {
  MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(
      TestDependentTensorBumpGenerationPass)

  StringRef getArgument() const final {
    return "test-dependent-tensor-bump-generation";
  }
  StringRef getDescription() const final {
    return "Bump the generation of the first dependent anchor seed";
  }

  void runOnOperation() override {
    Value seed = findAnchorSeed(getOperation());
    if (!seed || failed(bumpDependentAnchorGeneration(seed)))
      signalPassFailure();
  }
};

struct TestDependentTensorBulkEraseBlockArgsPass
    : public PassWrapper<TestDependentTensorBulkEraseBlockArgsPass,
                         OperationPass<func::FuncOp>> {
  MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(
      TestDependentTensorBulkEraseBlockArgsPass)

  StringRef getArgument() const final {
    return "test-dependent-tensor-bulk-erase-block-args";
  }
  StringRef getDescription() const final {
    return "Exercise dependent tensor bulk block argument erase checks";
  }

  void runOnOperation() override {
    Block &entry = getOperation().getBody().front();
    if (entry.getNumArguments() == 0)
      return signalPassFailure();
    BlockArgument arg = entry.getArgument(0);
    if (failed(checkDependentAnchorValueCanErase(
            arg, [&]() { return emitError(arg.getLoc()); })))
      return;
    signalPassFailure();
  }
};

struct TestDependentTensorReplaceAnchorSeedPass
    : public PassWrapper<TestDependentTensorReplaceAnchorSeedPass,
                         OperationPass<func::FuncOp>> {
  MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(
      TestDependentTensorReplaceAnchorSeedPass)

  StringRef getArgument() const final {
    return "test-dependent-tensor-replace-anchor-seed";
  }
  StringRef getDescription() const final {
    return "Replace the first dependent anchor seed and remap anchored types";
  }

  void runOnOperation() override {
    func::FuncOp func = getOperation();
    Value seed = findAnchorSeed(func);
    Value replacement = findReplacementSeed(func, seed);
    if (!seed || !replacement)
      return;
    seed.replaceAllUsesWith(replacement);
  }
};

struct TestDependentTensorMoveAnchorSeedPass
    : public PassWrapper<TestDependentTensorMoveAnchorSeedPass,
                         OperationPass<func::FuncOp>> {
  MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(
      TestDependentTensorMoveAnchorSeedPass)

  StringRef getArgument() const final {
    return "test-dependent-tensor-move-anchor-seed";
  }
  StringRef getDescription() const final {
    return "Move a scope-owned anchor seed with live dependent references";
  }

  void runOnOperation() override {
    Block &entry = getOperation().getBody().front();
    Operation *anchorProducer = nullptr;
    for (Operation &op : entry) {
      if (llvm::any_of(op.getResults(),
                       [](Value result) { return result.getType().isIndex(); })) {
        anchorProducer = &op;
        break;
      }
    }

    if (!anchorProducer)
      return signalPassFailure();
    Value anchorSeed = anchorProducer->getResult(0);
    if (failed(checkDependentAnchorValueCanMove(
            anchorSeed, [&]() { return anchorProducer->emitOpError(); })))
      return;
    signalPassFailure();
  }
};

struct TestDependentTensorCloneLocalAnchorProducerPass
    : public PassWrapper<TestDependentTensorCloneLocalAnchorProducerPass,
                         OperationPass<func::FuncOp>> {
  MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(
      TestDependentTensorCloneLocalAnchorProducerPass)

  StringRef getArgument() const final {
    return "test-dependent-tensor-clone-local-anchor-producer";
  }
  StringRef getDescription() const final {
    return "Clone non-terminator ops in a function while preserving dependent "
           "tensor anchors";
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
      return signalPassFailure();

    IRMapping mapping;
    OpBuilder builder(getOperation().getContext());
    builder.setInsertionPoint(entry.getTerminator());
    for (Operation *op : toClone)
      builder.clone(*op, mapping);
  }
};
} // namespace

namespace mlir {
void registerDependentTensorTestPasses() {
  PassRegistration<TestDependentTensorEraseOwnerPass>();
  PassRegistration<TestDependentTensorEraseBlockArgPass>();
  PassRegistration<TestDependentTensorRemoveAnchorPass>();
  PassRegistration<TestDependentTensorResetOwnerPropertiesPass>();
  PassRegistration<TestDependentTensorMarkDeadPass>();
  PassRegistration<TestDependentTensorBumpGenerationPass>();
  PassRegistration<TestDependentTensorBulkEraseBlockArgsPass>();
  PassRegistration<TestDependentTensorReplaceAnchorSeedPass>();
  PassRegistration<TestDependentTensorMoveAnchorSeedPass>();
  PassRegistration<TestDependentTensorCloneLocalAnchorProducerPass>();
}
} // namespace mlir
