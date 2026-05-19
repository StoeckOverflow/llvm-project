# DependentTensor Dialect Prototype

## 1. Core Idea

* `DependentTensor` models tensors whose shape semantics can depend on SSA
  values.
* A dynamic dimension is stored as metadata, but it is still a real SSA edge.
* Textual IR stays compact: dependent dimensions print inside `#tensor<...>`
  annotations instead of becoming ordinary operands.
* The key invariant is that property SSA edges are tracked by embedded
  `PropertyOperand`s, not by operation-owned sidecar registration objects.

## 2. Architecture

* DependentTensor dialect ops define the local tensor semantics.
* Dependent tensor property structs store ranks, value indices, and dimension
  SSA references.
* Property SSA-use infrastructure exposes embedded `PropertyOperand`s through
  `PropertySSAUseOpInterface`.
* Verification, rewrites, cloning, dominance, and liveness use the combined
  `SSAUse` view when semantic SSA edges matter.

## 3. Dialect Operations

* `dependent_tensor.make` creates a tensor value with dependent shape metadata.
* `dependent_tensor.dim` materializes one dependent dimension value.
* `dependent_tensor.extract` reads an element while preserving source
  semantics.
* `dependent_tensor.insert` writes an element and carries result semantics.

## 4. Boundary Operations

* `func.func` stores dependent tensor semantics for arguments and results.
* `func.call` maps callee boundary semantics onto caller operands and results.
* `scf.for` carries dependent tensor semantics across init operands, region
  block arguments, yielded values, and loop results.

## 5. Property Operand Infrastructure

* `PropertyOperand` is the property-side peer of `OpOperand`.
* It stores a `Value`, has `get`, `set`, `drop`, `attach`, and `detach`, and is
  valid in detached/null form during property construction.
* `SSAUse` wraps either an `OpOperand *` or a `PropertyOperand *`.
* `Value::getUses()` remains native-only.
* `Value::getPropertyUses()` returns embedded property operands.
* `Value::getAllUses()` returns the combined native-plus-property SSA view.

## 6. Physical Use-List Layout

* `OpOperand` and `PropertyOperand` link into the same physical per-`Value`
  use-list.
* Native iterators filter that list to ordinary operands.
* Property iterators filter that list to embedded property operands.
* All-use iterators expose both kinds without making property operands ordinary
  operation operands.
* There is no `Operation::propertySSAUses` vector and no sidecar
  `PropertySSAUse` node allocation.

## 7. Semantic Dataflow Example

```mlir
func.func @example(%m: index, %i: index) -> f32 {
  %t = dependent_tensor.make () #tensor<[%m], f32> : tensor<?xf32>
  %v = dependent_tensor.extract %t[%i] : tensor<?xf32>
  return %v : f32
}
```

* Native edges:
  * `%t -> dependent_tensor.extract`
  * `%i -> dependent_tensor.extract`
  * `%v -> return`
* Property edges:
  * `%m -> PropertyOperand` embedded in `%t`'s result semantics.
* Combined graph sketch:
  * `%m` defines the symbolic tensor dimension.
  * `%t` carries that dimension through metadata.
  * `%v` is produced by a native read from `%t`.
* Exact use-lists:
  * `%m.getUses()` is empty in this example.
  * `%m.getPropertyUses()` contains the `PropertyOperand` in
    `dependent_tensor.make`.
  * `%m.getAllUses()` contains that same property edge.

## 8. Replacement, Remapping, and Dominance

* RAUW updates embedded property operands.
* `replaceAllUsesWith`, `replaceAllUsesExcept`, and
  `replaceSSAUsesWithIf` handle property uses directly.
* `replaceUsesWithIf` intentionally remains native-operand-only.
* `IRMapping` and cloning remap property operands after native operands are
  remapped.
* Generic dominance verification walks `Operation::walkSSAUses`.
* `IsolatedFromAbove` rejects illegal property captures across isolated
  operation boundaries.

## 9. Edge Cases

* Native liveness APIs such as `use_empty()` intentionally miss property-only
  liveness.
* Property-aware liveness should use `all_use_empty`, `getAllUses`, or the
  dependent tensor helper APIs.
* Direct mutation must go through `PropertyOperand::set`.
* Property-use cycles and owner self-references are infrastructure-possible.
* `dropAllReferences()` drops property operands so cyclic property references
  can be broken during cleanup.
* Region boundary metadata is verified by the dependent tensor semantic
  verifier, because those references are not always ordinary owner-site uses.

## 10. Kernel Examples

* Matmul examples use property operands to carry `M`, `N`, and `K` shape
  relationships through tensor values.
* Conv2D im2col examples use property operands to preserve image, filter, and
  lowered matrix dimensions.
* These examples exercise semantic dataflow without changing native operand
  numbering or textual IR syntax.
