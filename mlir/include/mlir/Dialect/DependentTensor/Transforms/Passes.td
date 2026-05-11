//===- Passes.td - DependentTensor pass definitions -----------*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef MLIR_DIALECT_DEPENDENTTENSOR_TRANSFORMS_PASSES_TD
#define MLIR_DIALECT_DEPENDENTTENSOR_TRANSFORMS_PASSES_TD

include "mlir/Pass/PassBase.td"

def VerifyDependentTensorSemanticsPass
    : Pass<"verify-dependent-tensor-semantics", "ModuleOp"> {
  let summary = "Verify dependent_tensor metadata across functions and calls";
}

def DependentTensorCloneLocalProducerPass
    : Pass<"dependent-tensor-clone-local-producer", "mlir::func::FuncOp"> {
  let summary = "Clone local dependent_tensor producers in a function";
}

def DependentTensorReplaceDimValuePass
    : Pass<"dependent-tensor-replace-dim-value", "mlir::func::FuncOp"> {
  let summary = "Replace the first index dimension producer in a function";
}

def DependentTensorReplaceFirstBlockArgPass
    : Pass<"dependent-tensor-replace-first-block-arg", "mlir::func::FuncOp"> {
  let summary = "Replace the first index function argument with the second";
}

def DependentTensorReplaceOpUsesPass
    : Pass<"dependent-tensor-replace-op-uses", "mlir::func::FuncOp"> {
  let summary = "Replace op-local operands and dependent tensor property uses";
}

def DependentTensorCheckPropertyUsesPass
    : Pass<"dependent-tensor-check-property-uses", "mlir::func::FuncOp"> {
  let summary = "Check dependent tensor second-class use query helpers";
}

#endif // MLIR_DIALECT_DEPENDENTTENSOR_TRANSFORMS_PASSES_TD
