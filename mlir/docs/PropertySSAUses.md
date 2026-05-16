# Property SSA Uses

MLIR operation properties may store SSA `Value` handles. This is useful for
value-dependent metadata, such as dependent tensor refinements whose dynamic
dimensions are represented by SSA values. These references are real SSA edges
for dominance, replacement, cloning, erasure, and liveness, but they are not
native MLIR operands.

This document describes the current model and the APIs that property-aware
infrastructure should use.

## Native Uses and Property Uses

MLIR's native use-list model is unchanged:

* `Value::getUses()`, `Value::getUsers()`, and `Value::use_empty()` describe
  native operand uses.
* `Operation::use_empty()` describes native uses of operation results.
* Property-contained SSA values are not `OpOperand`s and are not included in
  those native queries.

Property SSA references are tracked separately with `PropertySSAUse` nodes.
They are second-class uses: explicit, opt-in SSA edges that preserve existing
operand semantics while still being visible to property-aware clients.

MLIR also exposes a staged unified use view through `SSAUse`. An `SSAUse` is a
non-owning wrapper over either an `OpOperand` or a `PropertySSAUse`; it does not
change the underlying storage or make properties ordinary operands. This gives
generic infrastructure one traversal surface for semantic SSA dependencies
while preserving native operand APIs as operand-only views.

The direct property-use APIs are:

* `Value::getPropertyUses()`
* `Value::getPropertyUsers()`
* `Value::property_use_empty()`
* `Operation::property_use_empty()`

The combined native-plus-property APIs are:

* `Value::getAllUses()`
* `Value::all_use_begin()` / `Value::all_use_end()`
* `Value::all_use_empty()`
* `Value::getAllUsers()`
* `Operation::walkSSAUses(function_ref<void(SSAUse)>)`
* `Operation::all_use_empty()`
* `allUseEmpty(Value, Operation *root = nullptr)`
* `getAllUsers(Value, Operation *root = nullptr)`
* `allResultsUseEmpty(Operation *, Operation *root = nullptr)`

Use the combined APIs when a transformation is asking whether a value or
operation result is semantically live.

## Why Property Uses Are Second-Class

Property references are kept separate from native operands for three reasons.

First, existing MLIR passes and dialects rely on `OpOperand` meaning "ordinary
operation operand" with stable operand numbering, mutation hooks, and parsing
semantics. Silently mixing property references into native use iteration would
change long-standing assumptions.

Second, property references often describe metadata about an operation boundary
or result rather than an executable operand of the operation. Treating them as
operands would overstate their operational meaning.

Third, the explicit API boundary makes migration tractable. Clients that care
about semantic liveness, dominance, or replacement can opt into the combined
queries without changing every native operand walk in MLIR at once.

## Registration and Mutation

Operations that store SSA values in properties expose the mutable property slots
through `PropertySSAUseOpInterface::walkPropertySSAValues`.

The infrastructure helpers are:

* `walkPropertySSAValues(Operation *, function_ref<void(Value &)>)`
* `registerPropertySSAUses(Operation *)`
* `refreshPropertySSAUses(Operation *)`
* `dropPropertySSAUses(Operation *)`
* `remapPropertySSAValues(Operation *, IRMapping &)`
* `replaceUsesOfWithIncludingPropertySSAUses(Operation *, Value from, Value to)`

Operation creation registers property uses. Operation destruction drops the
operation-owned property-use nodes. Direct property mutations that change stored
`Value`s must either update the relevant `PropertySSAUse` node or call
`refreshPropertySSAUses`.

## Replacement, Clone, and Remap

Property SSA uses participate in the core replacement paths:

* `Value::replaceAllUsesWith`
* `Value::replaceAllUsesExcept`
* `Value::replaceUsesWithIf`
* `RewriterBase::replaceOp`
* `RewriterBase::replaceAllUsesWith`
* `RewriterBase::replaceUsesWithIf`

`replaceUsesWithIf` keeps owner-approximation semantics. Its predicate receives
an `OpOperand &`, not a property-use slot, so property refs are rewritten for
owners that have selected native operand uses. Property-only owners are not
directly selectable by that predicate.

Clone and remap paths call `remapPropertySSAValues` so property-contained values
follow `IRMapping`. This includes operation and region cloning paths that route
through the shared IR clone support.

## Dominance and Isolation

Generic IR verification walks `Operation::walkSSAUses` and checks native
operands and owner-site property SSA uses through the same staged traversal.
Property-specific clients may still call `verifyPropertySSAUseDominance`.

The verifier enforces that:

* an owner-site property value dominates the owning operation, using MLIR
  `DominanceInfo`;
* a property value does not illegally cross an `IsolatedFromAbove` boundary.

Some property references describe operation boundary metadata for values defined
inside a region owned by the operation itself. Those are not ordinary owner-site
uses, so their stronger semantics remain dialect-specific. Dependent tensor
function boundary, result, and loop-carried metadata are verified by the
dependent tensor semantic verifier.

## Erasure and Liveness

Release-visible erasure guards reject several unsafe cases:

* `Operation::erase` rejects operation results with live property SSA users.
* `Block::eraseArgument` rejects erased arguments with live property SSA users.
* `Block::erase` rejects blocks whose arguments have live property SSA users.

`RewriterBase::eraseOp` and `RewriterBase::eraseBlock` use property-aware debug
assertions. Property-aware DCE should use `all_use_empty` or
`allResultsUseEmpty` rather than native-only `use_empty`.

The following generic paths are property-aware today:

* RAUW and selected replace APIs;
* operation/region clone and remap;
* generic verifier dominance/isolation;
* central erase paths listed above;
* `RewriterBase` replacement and erase checks;
* CSE dead-operation checks;
* `remove-dead-values`;
* dependent tensor semantic verification and local dimension DCE.

## Limitations

Native MLIR use-list APIs remain native-only. A pass that manually calls
`Value::use_empty()` or `Operation::use_empty()` to decide semantic liveness may
still ignore property SSA users unless it has been audited or routes through a
property-aware helper.

Property uses are not operands. They do not participate in operand numbering,
operand segment attributes, operand parsing, or `OpOperand` mutation callbacks.
Use `SSAUse::getKind()` to distinguish ordinary operands from property uses
when using the unified traversal.

Release-mode safety is improved in the shared erase paths, but it is not a
global replacement for verification. Transformations that directly mutate
properties must keep property-use nodes in sync. Dialect-specific metadata
semantics still need dialect-specific verification.

## Tests

The dependent tensor tests exercise the current infrastructure:

* `dependent-tensor-transforms.mlir` covers RAUW, `replaceAllUsesExcept`,
  `replaceUsesWithIf`, clone/remap, unified `SSAUse` queries, CSE,
  canonicalization, and property-aware local dimension DCE.
* `dependent-tensor-property-ssa-generic.mlir` covers direct
  `RewriterBase::replaceOp`, dialect conversion replacement, function-boundary
  cloning, `remove-dead-values`, and release-relevant block erasure guards.
* `dependent-tensor-property-ssa-ir-verifier-errors.mlir` covers generic IR
  verifier isolation diagnostics.
* `dependent-tensor-semantic-errors.mlir` covers dependent tensor semantic
  dominance, isolation, function boundary, and loop-carried metadata errors.

## Future Work

Property SSA uses should remain separate from native operands unless MLIR
intentionally grows a physically merged use-list abstraction. Useful future
work includes:

* auditing more dialect-specific passes that use raw `use_empty`;
* adding broader inliner and dialect-conversion coverage;
* auditing clients that should migrate from property-specific helpers to the
  unified `SSAUse` view;
* moving operation-owned `PropertySSAUse` nodes into trailing storage if the
  feature becomes widely used beyond value-dependent type metadata.
