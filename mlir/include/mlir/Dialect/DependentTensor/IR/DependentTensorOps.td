//===- DependentTensorOps.td - DependentTensor ops -----------*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef MLIR_DIALECT_DEPENDENTTENSOR_IR_DEPENDENTTENSOROPS_TD
#define MLIR_DIALECT_DEPENDENTTENSOR_IR_DEPENDENTTENSOROPS_TD

include "mlir/Dialect/DependentTensor/IR/DependentTensorDialect.td"
include "mlir/Interfaces/SideEffectInterfaces.td"
include "mlir/IR/DependentTensorInterfaces.td"
include "mlir/IR/OpAsmInterface.td"
include "mlir/IR/OpBase.td"

class DependentTensor_Op<string mnemonic, list<Trait> traits = []>
    : Op<DependentTensor_Dialect, mnemonic, traits>;

def MakeOp : DependentTensor_Op<"make", [
    Pure, DeclareOpInterfaceMethods<PropertySSAUseOpInterface,
      ["walkPropertySSAUses"]>,
    DeclareOpInterfaceMethods<DependentTensorPropertyOpInterface,
      ["getDependentTensorResultSemantics",
       "walkDependentTensorPropertyUses"]>]> {
  let summary = "construct a property-native dependent tensor value";
  let description = [{
    `dependent_tensor.make` constructs a tensor value whose dependency semantics
    are carried by the defining operation. Each result dimension is represented
    by a dependent SSA value stored in operation properties.
  }];

  let arguments = (ins
    DependentTensorValueSemanticsProp:$result_semantics
  );
  let results = (outs AnyRankedTensor:$result);
  let builders = [
    OpBuilder<(ins "RankedTensorType":$resultType, "ValueRange":$dimValues)>
  ];
  let extraClassDeclaration = [{
    SmallVector<Value, 4> getDimValues();
  }];
  let hasCustomAssemblyFormat = 1;
  let hasVerifier = 1;
}

def DimOp : DependentTensor_Op<"dim", [
    Pure]> {
  let summary = "query a dependent tensor dimension";
  let description = [{
    `dependent_tensor.dim` mirrors `tensor.dim` for tensors with dependent
    dimension semantics. The result is an index value, while the owning tensor
    value keeps its dependent dimension SSA values in operation properties.
  }];

  let arguments = (ins
    AnyRankedTensor:$source,
    Index:$dimension
  );
  let results = (outs Index:$result);
  let hasCustomAssemblyFormat = 1;
  let hasVerifier = 1;
  let hasFolder = 1;
}

def ExtractOp : DependentTensor_Op<"extract", [Pure]> {
  let summary = "extract an element from a dependent tensor";
  let description = [{
    `dependent_tensor.extract` is the scalar read primitive used by tests to
    write tensor kernels structurally instead of hiding them behind named
    dependent tensor ops.
  }];

  let arguments = (ins
    AnyRankedTensor:$source,
    Variadic<Index>:$indices
  );
  let results = (outs AnyType:$result);
  let hasCustomAssemblyFormat = 1;
  let hasVerifier = 1;
}

def InsertOp : DependentTensor_Op<"insert", [
    Pure,
    DeclareOpInterfaceMethods<PropertySSAUseOpInterface,
      ["walkPropertySSAUses"]>,
    DeclareOpInterfaceMethods<DependentTensorPropertyOpInterface,
      ["getDependentTensorResultSemantics",
       "walkDependentTensorPropertyUses"]>]> {
  let summary = "insert an element into a dependent tensor";
  let description = [{
    `dependent_tensor.insert` mirrors `tensor.insert`. Its result semantics are
    inherited from the destination tensor semantics.
  }];

  let arguments = (ins
    AnyType:$scalar,
    AnyRankedTensor:$dest,
    Variadic<Index>:$indices
  );
  let results = (outs AnyRankedTensor:$result);
  let builders = [
    OpBuilder<(ins "Value":$scalar, "Value":$dest, "ValueRange":$indices)>
  ];
  let hasCustomAssemblyFormat = 1;
  let hasVerifier = 1;
}

#endif // MLIR_DIALECT_DEPENDENTTENSOR_IR_DEPENDENTTENSOROPS_TD
