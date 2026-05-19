//===- DependentTensorInterfaces.td - Dependent tensor properties ---------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef MLIR_IR_DEPENDENTTENSORINTERFACES
#define MLIR_IR_DEPENDENTTENSORINTERFACES

include "mlir/IR/OpBase.td"
include "mlir/IR/PropertySSAUseInterfaces.td"

def DependentTensorValueSemanticsProp
    : Property<"::mlir::DependentTensorValueSemantics",
               "dependent tensor value semantics"> {
  // Value-bearing properties are contextual and intentionally not serializable
  // through attributes/bytecode in this prototype. Custom assembly owns parsing
  // and printing of the SSA references.
  let convertToAttribute = [{
    (void)$_storage;
    return ::mlir::ArrayAttr::get($_ctxt, {});
  }];
  let convertFromAttribute = [{
    $_storage = {};
    return ::mlir::success();
  }];
  let readFromMlirBytecode = [{
    $_storage = {};
  }];
  let writeToMlirBytecode = [{
    (void)$_storage;
  }];
  let hashProperty = "::mlir::hash_value($_storage)";
}

def DependentTensorDimValueSemanticsProp
    : Property<"::mlir::DependentTensorDimValueSemantics",
               "dependent tensor dimension value assertion"> {
  // Value-bearing properties are contextual and intentionally not serializable
  // through attributes/bytecode in this prototype. Custom assembly owns parsing
  // and printing of the SSA references.
  let convertToAttribute = [{
    (void)$_storage;
    return ::mlir::ArrayAttr::get($_ctxt, {});
  }];
  let convertFromAttribute = [{
    $_storage = {};
    return ::mlir::success();
  }];
  let readFromMlirBytecode = [{
    $_storage = {};
  }];
  let writeToMlirBytecode = [{
    (void)$_storage;
  }];
  let hashProperty = "::mlir::hash_value($_storage)";
}

def DependentTensorPropertyOpInterface
    : OpInterface<"DependentTensorPropertyOpInterface"> {
  let cppNamespace = "::mlir";
  let methods = [
    InterfaceMethod<"Get dependent tensor semantics for an op result.",
      "::mlir::FailureOr<::mlir::DependentTensorValueSemantics>",
      "getDependentTensorResultSemantics",
      (ins "unsigned":$resultNumber), [{}],
      /*defaultImplementation=*/[{
        return ::mlir::failure();
      }]
    >,
    InterfaceMethod<"Get dependent tensor semantics for a region block argument.",
      "::mlir::FailureOr<::mlir::DependentTensorValueSemantics>",
      "getDependentTensorBlockArgumentSemantics",
      (ins "unsigned":$regionNumber, "unsigned":$blockNumber,
           "unsigned":$argumentNumber), [{}],
      /*defaultImplementation=*/[{
        return ::mlir::failure();
      }]
    >,
    InterfaceMethod<"Walk embedded SSA operands stored in dependent tensor properties.",
      "void", "walkDependentTensorPropertyUses",
      (ins "::llvm::function_ref<void(::mlir::PropertyOperand &)>":$callback), [{}]>
  ];
}

#endif // MLIR_IR_DEPENDENTTENSORINTERFACES
