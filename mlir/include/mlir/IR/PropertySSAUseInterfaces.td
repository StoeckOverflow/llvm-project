//===- PropertySSAUseInterfaces.td - Property SSA references -*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef MLIR_IR_PROPERTYSSAUSEINTERFACES
#define MLIR_IR_PROPERTYSSAUSEINTERFACES

include "mlir/IR/OpBase.td"

def PropertySSAUseOpInterface : OpInterface<"PropertySSAUseOpInterface"> {
  let cppNamespace = "::mlir";
  let description = [{
    Interface for operations whose properties contain SSA Value references.

    These references are second-class SSA edges: they are not OpOperands and do
    not participate in native use-lists, but generic IR infrastructure can use
    this interface to update, remap, query, and verify the Value slots.
  }];
  let methods = [
    InterfaceMethod<"Walk mutable SSA Value slots stored in op properties.",
      "void", "walkPropertySSAValues",
      (ins "::llvm::function_ref<void(::mlir::Value &)>":$callback), [{}]>
  ];
}

#endif // MLIR_IR_PROPERTYSSAUSEINTERFACES
