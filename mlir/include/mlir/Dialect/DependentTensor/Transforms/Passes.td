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

#endif // MLIR_DIALECT_DEPENDENTTENSOR_TRANSFORMS_PASSES_TD
