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

    These references are second-class SSA edges: they are not OpOperands, but
    embedded PropertyOperands participate directly in the same physical use-list
    as native operands. Generic SSA infrastructure that needs semantic uses,
    including dominance verification, must walk `SSAUse`; native operand APIs
    intentionally remain operand-only views.
  }];
  let methods = [
    InterfaceMethod<"Walk embedded SSA operands stored in op properties.",
      "void", "walkPropertySSAUses",
      (ins "::llvm::function_ref<void(::mlir::PropertyOperand &)>":$callback), [{}]>,
    InterfaceMethod<"Update op properties after generic result erasure.",
      "::mlir::LogicalResult", "updatePropertiesForResultErasure",
      (ins "::mlir::Operation *":$oldOp,
           "const ::llvm::BitVector &":$eraseIndices), [{}],
      /*defaultImplementation=*/[{
        bool hasPropertyOperands = false;
        auto oldIface = ::llvm::cast<::mlir::PropertySSAUseOpInterface>(oldOp);
        oldIface.walkPropertySSAUses([&](::mlir::PropertyOperand &) {
          hasPropertyOperands = true;
        });
        if (hasPropertyOperands)
          return oldOp->emitError()
                 << "cannot erase operation results without op-specific "
                    "property SSA update support";
        return ::mlir::success();
      }]>
  ];
}

#endif // MLIR_IR_PROPERTYSSAUSEINTERFACES
