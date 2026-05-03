#include "mlir/Dialect/DependentTensor/IR/DependentTensor.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Pass/Pass.h"

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
        func.emitOpError()
            << "expected semantic equality to be " << (*expected ? "true" : "false");
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
} // namespace

namespace mlir {
void registerDependentTensorEqualityTestPasses() {
  PassRegistration<TestDependentTensorEqualityPass>();
}
} // namespace mlir
