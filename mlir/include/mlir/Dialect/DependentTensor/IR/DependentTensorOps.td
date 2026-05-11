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
      ["walkPropertySSAValues"]>,
    DeclareOpInterfaceMethods<DependentTensorPropertyOpInterface,
      ["getDependentTensorResultSemantics",
       "walkDependentTensorPropertyValues"]>]> {
  let summary = "construct a property-native dependent tensor value";
  let description = [{
    `dependent_tensor.make` constructs a tensor value whose dependency semantics
    are carried by the defining operation rather than the tensor type. In v1,
    the number of dimension operands must match the tensor rank and every
    result dimension is dependent.
  }];

  let arguments = (ins
    Variadic<Index>:$dim_values,
    DependentTensorValueSemanticsProp:$result_semantics
  );
  let results = (outs AnyRankedTensor:$result);
  let hasCustomAssemblyFormat = 1;
  let hasVerifier = 1;
}

def DimOp : DependentTensor_Op<"dim", [Pure]> {
  let summary = "query a dependent tensor dimension";
  let description = [{
    `dependent_tensor.dim` mirrors `tensor.dim` for the dependent tensor
    prototype. The result is an index value, while the owning tensor value keeps
    the dependent dimension SSA values in its creator/owner properties.
  }];

  let arguments = (ins
    AnyRankedTensor:$source,
    Index:$dimension
  );
  let results = (outs Index:$result);
  let hasCustomAssemblyFormat = 1;
  let hasVerifier = 1;
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
    Pure, AttrSizedOperandSegments,
    DeclareOpInterfaceMethods<PropertySSAUseOpInterface,
      ["walkPropertySSAValues"]>,
    DeclareOpInterfaceMethods<DependentTensorPropertyOpInterface,
      ["getDependentTensorResultSemantics",
       "walkDependentTensorPropertyValues"]>]> {
  let summary = "insert an element into a dependent tensor";
  let description = [{
    `dependent_tensor.insert` mirrors `tensor.insert`. Its result semantics are
    explicit value-bearing properties copied from the destination tensor
    semantics during parsing/building.
  }];

  let arguments = (ins
    AnyType:$scalar,
    AnyRankedTensor:$dest,
    Variadic<Index>:$indices,
    Variadic<Index>:$result_dim_values,
    DependentTensorValueSemanticsProp:$result_semantics
  );
  let results = (outs AnyRankedTensor:$result);
  let hasCustomAssemblyFormat = 1;
  let hasVerifier = 1;
}

#endif // MLIR_DIALECT_DEPENDENTTENSOR_IR_DEPENDENTTENSOROPS_TD
