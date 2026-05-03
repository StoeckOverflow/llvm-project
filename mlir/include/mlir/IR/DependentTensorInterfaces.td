//===- DependentTensorInterfaces.td - Dependent tensor owner interfaces ---===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef MLIR_IR_DEPENDENTTENSORINTERFACES
#define MLIR_IR_DEPENDENTTENSORINTERFACES

include "mlir/IR/OpBase.td"

def DependentTensorDistinctAttrProp
    : Property<"::mlir::DistinctAttr", "distinct attribute"> {
  let convertToAttribute = [{
    return $_storage;
  }];
  let convertFromAttribute = [{
    auto attr = ::llvm::dyn_cast<::mlir::DistinctAttr>($_attr);
    if (!attr)
      return $_diag() << "expected distinct attribute";
    $_storage = attr;
    return ::mlir::success();
  }];
  let parser = [{
    ::mlir::Attribute attr;
    if (::mlir::failed($_parser.parseAttribute(attr)))
      return ::mlir::failure();
    auto distinct = ::llvm::dyn_cast<::mlir::DistinctAttr>(attr);
    if (!distinct)
      return ::mlir::failure();
    $_storage = distinct;
  }];
  let optionalParser = [{
    ::mlir::Attribute attr;
    auto result = $_parser.parseOptionalAttribute(attr);
    if (!result.has_value())
      return std::nullopt;
    if (::mlir::failed(*result))
      return ::mlir::failure();
    auto distinct = ::llvm::dyn_cast<::mlir::DistinctAttr>(attr);
    if (!distinct)
      return ::mlir::failure();
    $_storage = distinct;
    return ::mlir::success();
  }];
  let printer = "$_printer.printAttribute($_storage)";
  let readFromMlirBytecode = [{
    ::mlir::Attribute attr;
    if (::mlir::failed($_reader.readAttribute(attr)))
      return ::mlir::failure();
    auto distinct = ::llvm::dyn_cast<::mlir::DistinctAttr>(attr);
    if (!distinct)
      return ::mlir::failure();
    $_storage = distinct;
  }];
  let writeToMlirBytecode = [{
    $_writer.writeAttribute($_storage);
  }];
  let hashProperty = "::llvm::hash_value($_storage.getAsOpaquePointer())";
}

def DependentTensorArrayAttrProp
    : Property<"::mlir::ArrayAttr", "array attribute"> {
  let convertToAttribute = [{
    return $_storage;
  }];
  let convertFromAttribute = [{
    auto attr = ::llvm::dyn_cast<::mlir::ArrayAttr>($_attr);
    if (!attr)
      return $_diag() << "expected array attribute";
    $_storage = attr;
    return ::mlir::success();
  }];
  let parser = [{
    ::mlir::Attribute attr;
    if (::mlir::failed($_parser.parseAttribute(attr)))
      return ::mlir::failure();
    auto arrayAttr = ::llvm::dyn_cast<::mlir::ArrayAttr>(attr);
    if (!arrayAttr)
      return ::mlir::failure();
    $_storage = arrayAttr;
  }];
  let optionalParser = [{
    ::mlir::Attribute attr;
    auto result = $_parser.parseOptionalAttribute(attr);
    if (!result.has_value())
      return std::nullopt;
    if (::mlir::failed(*result))
      return ::mlir::failure();
    auto arrayAttr = ::llvm::dyn_cast<::mlir::ArrayAttr>(attr);
    if (!arrayAttr)
      return ::mlir::failure();
    $_storage = arrayAttr;
    return ::mlir::success();
  }];
  let printer = "$_printer.printAttribute($_storage)";
  let readFromMlirBytecode = [{
    ::mlir::Attribute attr;
    if (::mlir::failed($_reader.readAttribute(attr)))
      return ::mlir::failure();
    auto arrayAttr = ::llvm::dyn_cast<::mlir::ArrayAttr>(attr);
    if (!arrayAttr)
      return ::mlir::failure();
    $_storage = arrayAttr;
  }];
  let writeToMlirBytecode = [{
    $_writer.writeAttribute($_storage);
  }];
  let hashProperty = "::llvm::hash_value($_storage.getAsOpaquePointer())";
}

class DependentTensorOwnerInterface<string name>
    : OpInterface<name> {
  let cppNamespace = "::mlir";
  let methods = [
    InterfaceMethod<"Get the symbolic owner tag for dependent tensor anchors.",
      "::mlir::DistinctAttr", "getDependentTensorOwnerTagValue", (ins), [{}],
      /*defaultImplementation=*/[{
        auto tag = cast<ConcreteOp>(this->getOperation())
                       .getProperties()
                       .dependentTensorOwnerTag;
        return tag ? *tag : ::mlir::DistinctAttr();
      }]
    >,
    InterfaceMethod<"Set the symbolic owner tag for dependent tensor anchors.",
      "void", "setDependentTensorOwnerTagValue",
      (ins "::mlir::DistinctAttr":$tag), [{}],
      /*defaultImplementation=*/[{
        cast<ConcreteOp>(this->getOperation())
            .getProperties()
            .dependentTensorOwnerTag =
                tag ? std::optional<::mlir::DistinctAttr>(tag) : std::nullopt;
      }]
    >,
    InterfaceMethod<"Get the durable slot payload for dependent tensor anchors.",
      "::mlir::ArrayAttr", "getDependentTensorAnchorSlotsValue", (ins), [{}],
      /*defaultImplementation=*/[{
        auto slots = cast<ConcreteOp>(this->getOperation())
                         .getProperties()
                         .dependentTensorAnchorSlots;
        return slots ? *slots : ::mlir::ArrayAttr();
      }]
    >,
    InterfaceMethod<"Set the durable slot payload for dependent tensor anchors.",
      "void", "setDependentTensorAnchorSlotsValue",
      (ins "::mlir::ArrayAttr":$slots), [{}],
      /*defaultImplementation=*/[{
        cast<ConcreteOp>(this->getOperation())
            .getProperties()
            .dependentTensorAnchorSlots =
                slots ? std::optional<::mlir::ArrayAttr>(slots) : std::nullopt;
      }]
    >,
    InterfaceMethod<"Get the next owner-local dependent tensor slot id.",
      "uint32_t", "getDependentTensorNextSlotValue", (ins), [{}],
      /*defaultImplementation=*/[{
        return static_cast<uint32_t>(cast<ConcreteOp>(this->getOperation())
                                         .getProperties()
                                         .dependentTensorNextSlot);
      }]
    >,
    InterfaceMethod<"Set the next owner-local dependent tensor slot id.",
      "void", "setDependentTensorNextSlotValue", (ins "uint32_t":$nextSlot), [{}],
      /*defaultImplementation=*/[{
        cast<ConcreteOp>(this->getOperation())
            .getProperties()
            .dependentTensorNextSlot = static_cast<int32_t>(nextSlot);
      }]
    >
  ];
}

def DependentTensorScopeOwnerOpInterface
    : DependentTensorOwnerInterface<"DependentTensorScopeOwnerOpInterface">;

def DependentTensorResultOwnerOpInterface
    : DependentTensorOwnerInterface<"DependentTensorResultOwnerOpInterface">;

#endif // MLIR_IR_DEPENDENTTENSORINTERFACES
