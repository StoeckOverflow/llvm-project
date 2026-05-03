//===- DependentTensorDialect.td - DependentTensor dialect ---*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef MLIR_DIALECT_DEPENDENTTENSOR_IR_DEPENDENTTENSORDIALECT_TD
#define MLIR_DIALECT_DEPENDENTTENSOR_IR_DEPENDENTTENSORDIALECT_TD

include "mlir/IR/OpBase.td"

def DependentTensor_Dialect : Dialect {
  let name = "dependent_tensor";
  let cppNamespace = "::mlir::dependent_tensor";
}

#endif // MLIR_DIALECT_DEPENDENTTENSOR_IR_DEPENDENTTENSORDIALECT_TD
