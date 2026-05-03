# Dependent Tensor Anchors

This prototype adds surface syntax that looks like SSA-valued tensor dimensions:

```mlir
tensor<[%x, %y], f32>
```

Internally, the type does not store raw `Value` or raw `Operation *` in
`TypeStorage`. Instead, each dependent dimension stores an `AnchorKey`:

- `ownerKind : ScopeOwner | ResultOwner`
- `ownerTag : DistinctAttr`
- `slot : uint32_t`
- `generation : uint32_t`

`ownerTag` is a symbolic token for the owner operation. The owner operation
keeps mutable owner-local anchor state in operation properties, not in the type
itself. Resolution is:

```text
AnchorKey -> (ownerKind, ownerTag) lookup -> owner-local slot state -> live Value
```

Owner and user are intentionally different concepts:

- owner: the op that knows how to resolve the anchor
- user: the op or block argument whose type mentions the anchor

Examples:

- op result anchor owner: the defining operation
- block argument anchor owner: the enclosing op that owns the region

Why not store `Value` in `TypeStorage`?

- types stay uniqued and immutable
- no raw SSA objects are embedded in globally-uniqued storage
- stale references become detectable with `generation` and `alive`

Why no global mutable registry?

- owner lookup is symbolic through `ownerTag`
- verifier and printer may build transient local search state
- the semantic source of truth remains owner-local state
- reverse-use tracking is maintained as a local prototype registry for mutation
  checks, but it is not the semantic source of truth

Dominance is checked after resolution, using the resolved live `Value` and
stock `DominanceInfo`.

Intentional invariant breaks in this prototype:

- type well-formedness is contextual
- parser and printer become SSA-scope aware for this syntax
- some transforms require dependent-type-aware remapping

Preserved MLIR invariants:

- no raw `Value` in `TypeStorage`
- no generic type-contained SSA use-def integration in core MLIR
- ordinary SSA use-def lists remain unchanged

Currently supported in this prototype:

- block-argument anchors and SSA-result anchors
- mixed anchors in one type, for example `tensor<[%x, %y], f32>`
- owner-local mutation checks for erase, bulk block-arg erase, and unsafe moves
- dependent-type-aware remapping in the covered replacement and clone paths

Currently rejected or intentionally conservative:

- non-dominating anchors
- anchors crossing isolated-from-above boundaries
- erasing owners or anchor values that still have live dependent-type users
- unsafe structural moves of scope-owned anchor subjects
- broader structural rewrites that would require automatic path repair

Still requiring deeper core work later:

- broader structural rewrite repair beyond the currently supported remap paths
- less conservative handling of safe moves/reorders of scope-owned anchors
- richer dependent dimension expressions beyond constants and anchors
