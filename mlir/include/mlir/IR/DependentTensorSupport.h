#ifndef MLIR_IR_DEPENDENTTENSORSUPPORT_H
#define MLIR_IR_DEPENDENTTENSORSUPPORT_H

#include "mlir/IR/Block.h"
#include "mlir/IR/BuiltinTypes.h"
#include "mlir/IR/DependentTensorInterfaces.h"
#include "mlir/IR/Diagnostics.h"
#include "mlir/IR/IRMapping.h"
#include "mlir/IR/OpImplementation.h"
#include "mlir/IR/PropertySSAUseSupport.h"
#include "mlir/IR/Value.h"

namespace mlir {
class Operation;

/// Compatibility wrappers for the generic property SSA use layer. New generic
/// IR code should use PropertySSAUseSupport directly; dependent_tensor-specific
/// code may use these names when that reads more clearly.
void walkDependentTensorPropertyUses(
    Operation *op, function_ref<void(PropertyOperand &)> callback);
void remapDependentTensorPropertyValues(Operation *op, IRMapping &mapping);
void replaceDependentTensorPropertyValue(Operation *root, Value from, Value to);
void replaceDependentTensorPropertyValueIf(
    Operation *root, Value from, Value to,
    function_ref<bool(Operation *)> shouldReplaceOwner);
bool hasDependentTensorPropertyUses(Value value, Operation *root);
bool dependentTensorUseEmpty(Value value, Operation *root);
SmallVector<Operation *> getDependentTensorPropertyUsers(Value value,
                                                         Operation *root);
bool hasDependentTensorResultUses(Operation *op, Operation *root);
LogicalResult verifyNoDependentTensorPropertyUses(Value value, Operation *root,
                                                  Location loc);
void replaceUsesOfWithIncludingDependentTensorProperties(Operation *op,
                                                         Value from, Value to);

namespace dependent_tensor {
ParseResult
parseTensorSpec(OpAsmParser &parser,
                SmallVectorImpl<OpAsmParser::UnresolvedOperand> &dims,
                Type &elementType);
ParseResult
parseTensorSpec(OpAsmParser &parser, RankedTensorType valueType,
                SmallVectorImpl<OpAsmParser::UnresolvedOperand> &dims);
ParseResult
parseTensorSpecBody(OpAsmParser &parser,
                    SmallVectorImpl<OpAsmParser::UnresolvedOperand> &dims,
                    Type &elementType);
void printTensorSpec(OpAsmPrinter &printer, ValueRange dims, Type elementType);

struct PendingTypeRef {
  SMLoc loc;
  SmallVector<OpAsmParser::UnresolvedOperand, 4> dims;
  Type elementType;
};

struct PendingLoopTypeRef {
  unsigned iterArgIndex = 0;
  SMLoc iterLoc;
  PendingTypeRef input;
  PendingTypeRef output;
};

ParseResult
parseOptionalLoopTypeRefs(OpAsmParser &parser, StringRef keyword,
                          ArrayRef<OpAsmParser::Argument> regionArgs,
                          SmallVectorImpl<PendingLoopTypeRef> &pending);

ParseResult resolvePendingTypeRef(OpAsmParser &parser,
                                  const PendingTypeRef &pending, Type valueType,
                                  StringRef kind,
                                  DependentTensorTypeRef &typeRef);

ParseResult populateLoopTypeRefsFromInits(
    OpAsmParser &parser, TypeRange resultTypes, ValueRange initOperands,
    Block::BlockArgListType regionIterArgs, ValueRange yieldedValues,
    ArrayRef<PendingLoopTypeRef> pendingLoopRefs,
    function_ref<FailureOr<DependentTensorTypeRef>(Value)> getTypeRefFromValue,
    SmallVectorImpl<DependentTensorLoopTypeRef> &loopTypeRefs);

const DependentTensorLoopTypeRef *
findLoopTypeRef(ArrayRef<DependentTensorLoopTypeRef> typeRefs,
                unsigned valueIndex);

void buildLoopTypeRefLookup(
    ArrayRef<DependentTensorLoopTypeRef> typeRefs, unsigned numValues,
    SmallVectorImpl<const DependentTensorLoopTypeRef *> &lookup);
void buildLoopTypeRefPresence(ArrayRef<DependentTensorLoopTypeRef> typeRefs,
                              unsigned numValues,
                              SmallVectorImpl<bool> &presence);

bool isValueOwnedByOperation(Value value, Operation *op);
FailureOr<DependentTensorTypeRef> getTypeRefFromValueUnlessOwned(
    Value value, Operation *op,
    function_ref<FailureOr<DependentTensorTypeRef>(Value)> getTypeRefFromValue);

class ScopedLoopTypeRefPopulation {
public:
  explicit ScopedLoopTypeRefPopulation(Operation *op);
  ~ScopedLoopTypeRefPopulation();

  bool isRecursive() const { return !inserted; }

private:
  Operation *op = nullptr;
  bool inserted = false;
};

void inferMissingLoopTypeRefs(
    TypeRange resultTypes, ValueRange initOperands,
    Block::BlockArgListType regionIterArgs, ValueRange yieldedValues,
    function_ref<FailureOr<DependentTensorTypeRef>(Value)> getTypeRefFromValue,
    SmallVectorImpl<DependentTensorLoopTypeRef> &loopTypeRefs);

bool isTypeRefVisibleFrom(Operation *op, const DependentTensorTypeRef &typeRef);
void printTypeRef(OpAsmPrinter &printer, const DependentTensorTypeRef &typeRef,
                  Type elementType);
void printLoopTypeRefs(OpAsmPrinter &printer,
                       Block::BlockArgListType regionIterArgs,
                       TypeRange resultTypes,
                       ArrayRef<DependentTensorLoopTypeRef> typeRefs);
} // namespace dependent_tensor

namespace dependent_memref {
struct PendingMemRefSpec {
  SmallVector<OpAsmParser::UnresolvedOperand, 4> dims;
  SmallVector<OpAsmParser::UnresolvedOperand, 4> strides;
  Type elementType;
  int64_t offset = 0;
  bool hasExplicitLayout = false;
  SMLoc loc;
};

ParseResult parseMemRefSpec(OpAsmParser &parser, PendingMemRefSpec &spec);
ParseResult resolveMemRefSpec(OpAsmParser &parser, MemRefType type,
                              const PendingMemRefSpec &spec,
                              unsigned valueIndex,
                              DependentMemRefValueRefinement &refinement);
bool allowsFlatMemRefCarrier(MemRefType type,
                             const DependentMemRefValueRefinement &stored);
LogicalResult
verifyStoredRefinement(Operation *op, Value value,
                       const DependentMemRefValueRefinement &stored);
void printMemRefSpec(OpAsmPrinter &printer,
                     const DependentMemRefValueRefinement &refinement,
                     Type elementType);
void printMemRefSpec(OpAsmPrinter &printer,
                     const DependentTypeValueRefinement &refinement,
                     Type elementType);
} // namespace dependent_memref

} // namespace mlir

#endif // MLIR_IR_DEPENDENTTENSORSUPPORT_H
