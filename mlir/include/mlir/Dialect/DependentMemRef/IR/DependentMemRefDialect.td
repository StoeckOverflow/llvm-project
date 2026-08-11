//===- DependentMemRefDialect.td - DependentMemRef dialect -*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef MLIR_DIALECT_DEPENDENTMEMREF_IR_DEPENDENTMEMREFDIALECT_TD
#define MLIR_DIALECT_DEPENDENTMEMREF_IR_DEPENDENTMEMREFDIALECT_TD

include "mlir/IR/OpBase.td"

def DependentMemRef_Dialect : Dialect {
  let name = "dependent_memref";
  let cppNamespace = "::mlir::dependent_memref";
  let summary = "Dependent memref dialect";
  let description = [{
    A small buffer dialect for carrying SSA-backed shape and layout refinements
    until they are lowered directly to LLVM pointer arithmetic.
  }];
}

#endif // MLIR_DIALECT_DEPENDENTMEMREF_IR_DEPENDENTMEMREFDIALECT_TD
