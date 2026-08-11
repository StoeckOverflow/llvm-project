//===- DependentMemRefOps.td - DependentMemRef ops -----------*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef MLIR_DIALECT_DEPENDENTMEMREF_IR_DEPENDENTMEMREFOPS_TD
#define MLIR_DIALECT_DEPENDENTMEMREF_IR_DEPENDENTMEMREFOPS_TD

include "mlir/Dialect/DependentMemRef/IR/DependentMemRefDialect.td"
include "mlir/Dialect/MemRef/IR/MemRefBase.td"
include "mlir/IR/DependentTensorInterfaces.td"
include "mlir/IR/OpAsmInterface.td"
include "mlir/Interfaces/SideEffectInterfaces.td"

class DependentMemRef_Op<string mnemonic, list<Trait> traits = []>
    : Op<DependentMemRef_Dialect, mnemonic, traits>;

def DependentMemRef_AllocOp : DependentMemRef_Op<"alloc", [
    DeclareOpInterfaceMethods<PropertySSAUseOpInterface,
      ["walkPropertySSAUses"]>]> {
  let summary = "allocate a dependent memref";
  let arguments = (ins DependentMemRefValueRefinementProp:$result_refinement);
  let results = (outs AnyMemRef:$memref);
  let hasCustomAssemblyFormat = 1;
  let hasVerifier = 1;
}

def DependentMemRef_DeallocOp : DependentMemRef_Op<"dealloc"> {
  let summary = "deallocate a dependent memref";
  let arguments = (ins AnyMemRef:$memref);
  let hasCustomAssemblyFormat = 1;
}

def DependentMemRef_ReinterpretCastOp : DependentMemRef_Op<"reinterpret_cast", [
    DeclareOpInterfaceMethods<PropertySSAUseOpInterface,
      ["walkPropertySSAUses"]>]> {
  let summary = "attach dependent memref shape/layout metadata to a carrier";
  let arguments = (ins AnyMemRef:$source,
                       DependentMemRefValueRefinementProp:$result_refinement);
  let results = (outs AnyMemRef:$result);
  let hasCustomAssemblyFormat = 1;
  let hasVerifier = 1;
}

def DependentMemRef_CastOp : DependentMemRef_Op<"cast", [
    DeclareOpInterfaceMethods<PropertySSAUseOpInterface,
      ["walkPropertySSAUses"]>]> {
  let summary = "refinement-preserving dependent memref cast";
  let arguments = (ins AnyMemRef:$source,
                       DependentMemRefValueRefinementProp:$result_refinement);
  let results = (outs AnyMemRef:$result);
  let hasCustomAssemblyFormat = 1;
  let hasVerifier = 1;
}

def DependentMemRef_DimOp : DependentMemRef_Op<"dim", [Pure,
    DeclareOpInterfaceMethods<PropertySSAUseOpInterface,
      ["walkPropertySSAUses"]>]> {
  let summary = "query a dependent memref dimension";
  let arguments = (ins AnyMemRef:$source, Index:$dimension,
                       DependentMemRefValueRefinementProp:$source_refinement);
  let results = (outs Index:$result);
  let hasCustomAssemblyFormat = 1;
  let hasVerifier = 1;
  let hasFolder = 1;
}

def DependentMemRef_DimExactOp : DependentMemRef_Op<"dim_exact", [Pure,
    DeclareOpInterfaceMethods<PropertySSAUseOpInterface,
      ["walkPropertySSAUses"]>]> {
  let summary = "materialize a statically selected dependent memref dimension";
  let arguments = (ins AnyMemRef:$source, I32Attr:$axis,
                       DependentMemRefValueRefinementProp:$source_refinement);
  let results = (outs Index:$result);
  let hasCustomAssemblyFormat = 1;
  let hasVerifier = 1;
  let hasFolder = 1;
}

def DependentMemRef_LoadOp : DependentMemRef_Op<"load", [
    DeclareOpInterfaceMethods<PropertySSAUseOpInterface,
      ["walkPropertySSAUses"]>]> {
  let summary = "load from a dependent memref";
  let arguments = (ins AnyMemRef:$source, Variadic<Index>:$indices,
                       DependentMemRefValueRefinementProp:$source_refinement);
  let results = (outs AnyType:$result);
  let hasCustomAssemblyFormat = 1;
  let hasVerifier = 1;
}

def DependentMemRef_StoreOp : DependentMemRef_Op<"store", [
    DeclareOpInterfaceMethods<PropertySSAUseOpInterface,
      ["walkPropertySSAUses"]>]> {
  let summary = "store into a dependent memref";
  let arguments = (ins AnyType:$value, AnyMemRef:$source, Variadic<Index>:$indices,
                       DependentMemRefValueRefinementProp:$source_refinement);
  let hasCustomAssemblyFormat = 1;
  let hasVerifier = 1;
}

#endif // MLIR_DIALECT_DEPENDENTMEMREF_IR_DEPENDENTMEMREFOPS_TD
