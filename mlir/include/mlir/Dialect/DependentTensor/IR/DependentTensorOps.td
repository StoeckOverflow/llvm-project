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
include "mlir/IR/OpAsmInterface.td"
include "mlir/IR/OpBase.td"

class DependentTensor_Op<string mnemonic, list<Trait> traits = []>
    : Op<DependentTensor_Dialect, mnemonic, traits>;

def MakeOp : DependentTensor_Op<"make", [Pure]> {
  let summary = "construct a property-native dependent tensor value";
  let description = [{
    `dependent_tensor.make` constructs a tensor value whose dependency semantics
    are carried by the defining operation rather than the tensor type. In v1,
    the number of seed operands must match the tensor rank and every result
    dimension is dependent.
  }];

  let arguments = (ins
    Variadic<Index>:$seeds,
    ArrayProp<StringProp>:$dim_names,
    DefaultValuedProp<ArrayProp<I32Prop>,
      "::llvm::ArrayRef<int32_t>{}", "::llvm::SmallVector<int32_t>{}">:$dependency_map
  );
  let results = (outs AnyRankedTensor:$result);
  let hasCustomAssemblyFormat = 1;
  let hasVerifier = 1;
}

def MatmulOp : DependentTensor_Op<"matmul", [Pure]> {
  let summary = "matrix multiply with dependent tensor semantics";
  let description = [{
    `dependent_tensor.matmul` verifies matmul-compatible dependency semantics
    using the dialect query layer instead of type-contained dependent shape
    information.
  }];

  let arguments = (ins AnyRankedTensor:$lhs, AnyRankedTensor:$rhs);
  let results = (outs AnyRankedTensor:$result);
  let assemblyFormat = "$lhs `,` $rhs attr-dict `:` type($lhs) `,` type($rhs) `->` type($result)";
  let hasVerifier = 1;
}

def GemmOp : DependentTensor_Op<"gemm", [Pure]> {
  let summary = "matrix multiply-accumulate with explicit dependent schema";
  let description = [{
    `dependent_tensor.gemm` verifies a named contraction schema against
    property-native dependent tensor semantics recovered from its operands.
  }];

  let arguments = (ins
    AnyRankedTensor:$lhs,
    AnyRankedTensor:$rhs,
    AnyRankedTensor:$acc,
    ArrayProp<StringProp>:$dim_names,
    ArrayProp<I32Prop>:$lhs_dims,
    ArrayProp<I32Prop>:$rhs_dims,
    ArrayProp<I32Prop>:$acc_dims,
    ArrayProp<I32Prop>:$result_dims
  );
  let results = (outs AnyRankedTensor:$result);
  let hasCustomAssemblyFormat = 1;
  let hasVerifier = 1;
}

#endif // MLIR_DIALECT_DEPENDENTTENSOR_IR_DEPENDENTTENSOROPS_TD
