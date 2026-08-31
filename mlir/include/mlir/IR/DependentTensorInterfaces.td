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

def DependentTensorValueRefinementProp
    : Property<"::mlir::DependentTensorValueRefinement",
               "dependent tensor value refinements"> {
  // SSA-valued properties are contextual IR state. They are not serialized
  // through attributes or bytecode; custom assembly handles parsing and printing
  // of the embedded SSA references.
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

def DependentTensorTypeRefProp
    : Property<"::mlir::DependentTensorTypeRef",
               "dependent tensor type reference"> {
  // SSA-valued properties are contextual IR state. They are not serialized
  // through attributes or bytecode; custom assembly handles parsing and printing
  // of the embedded SSA references.
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

def DependentTensorLoopTypeRefProp
    : Property<"::mlir::DependentTensorLoopTypeRef",
               "dependent tensor loop operand/result type references"> {
  // SSA-valued properties are contextual IR state. They are not serialized
  // through attributes or bytecode; custom assembly handles parsing and printing
  // of the embedded SSA references.
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

def DependentTensorLoopTypeRefArrayProp
    : Property<"::llvm::SmallVector<::mlir::DependentTensorLoopTypeRef, 2>",
               "dependent tensor loop operand/result type reference array",
               "::llvm::ArrayRef<::mlir::DependentTensorLoopTypeRef>"> {
  // SSA-valued properties are contextual IR state. They are not serialized
  // through attributes or bytecode; custom assembly handles parsing and printing
  // of the embedded SSA references.
  let convertFromStorage = "$_storage";
  let assignToStorage = "$_storage.assign($_value.begin(), $_value.end())";
  let convertToAttribute = [{
    (void)$_storage;
    return ::mlir::ArrayAttr::get($_ctxt, {});
  }];
  let convertFromAttribute = [{
    $_storage.clear();
    return ::mlir::success();
  }];
  let readFromMlirBytecode = [{
    $_storage.clear();
  }];
  let writeToMlirBytecode = [{
    (void)$_storage;
  }];
  let hashProperty =
      "::llvm::hash_combine_range($_storage.begin(), $_storage.end())";
}

def DependentTensorDimValueRefinementProp
    : Property<"::mlir::DependentTensorDimValueRefinement",
               "dependent tensor dimension value assertion"> {
  // SSA-valued properties are contextual IR state. They are not serialized
  // through attributes or bytecode; custom assembly handles parsing and printing
  // of the embedded SSA references.
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

def DependentTypeValueRefinementProp
    : Property<"::mlir::DependentTypeValueRefinement",
               "dependent type value refinements"> {
  // SSA-valued properties are contextual IR state. They are not serialized
  // through attributes or bytecode; custom assembly handles parsing and printing
  // of the embedded SSA references.
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

def DependentMemRefValueRefinementProp
    : Property<"::mlir::DependentMemRefValueRefinement",
               "dependent memref value refinements"> {
  // SSA-valued properties are contextual IR state. They are not serialized
  // through attributes or bytecode; custom assembly handles parsing and printing
  // of the embedded SSA references.
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
    InterfaceMethod<"Get dependent tensor refinements for an op result.",
      "::mlir::FailureOr<::mlir::DependentTensorValueRefinement>",
      "getDependentTensorResultRefinement",
      (ins "unsigned":$resultNumber), [{}],
      /*defaultImplementation=*/[{
        return ::mlir::failure();
      }]
    >,
    InterfaceMethod<"Get dependent tensor refinements for a region block argument.",
      "::mlir::FailureOr<::mlir::DependentTensorValueRefinement>",
      "getDependentTensorBlockArgumentRefinement",
      (ins "unsigned":$regionNumber, "unsigned":$blockNumber,
           "unsigned":$argumentNumber), [{}],
      /*defaultImplementation=*/[{
        return ::mlir::failure();
      }]
    >,
    InterfaceMethod<"Get dependent tensor loop operand type reference.",
      "::mlir::FailureOr<::mlir::DependentTensorTypeRef>",
      "getDependentTensorLoopOperandTypeRef",
      (ins "unsigned":$operandNumber), [{}],
      /*defaultImplementation=*/[{
        return ::mlir::failure();
      }]
    >,
    InterfaceMethod<"Get dependent tensor loop result type reference.",
      "::mlir::FailureOr<::mlir::DependentTensorTypeRef>",
      "getDependentTensorLoopResultTypeRef",
      (ins "unsigned":$resultNumber), [{}],
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
