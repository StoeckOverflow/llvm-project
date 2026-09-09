# Dependent Verification Coverage

## Function Boundary `#types`

The `func.func` verifier checks dependent function metadata attached to
arguments and results.

For each dependent argument refinement, it verifies:

- the referenced argument index is in range
- no argument receives duplicate dependent refinement entries
- the argument is a ranked tensor or memref carrier
- the stored refinement index matches the argument index
- the refinement rank matches the memref rank
- the refinement contains one dimension SSA value per logical dimension
- explicit layout refinements contain one stride SSA value per logical dimension
- all dimension and stride values have `index` type
- non-flat carriers only use dependent dimensions for dynamic memref dimensions
- function-boundary dimension and stride values refer to entry block arguments

For function result refinements, the same shape/type/index/layout checks are
performed against the function result type. In this benchmark there are no
function result refinements, because the generated memref kernels return `void`.

In the archived dependent kernels, the exercised boundary checks are the three
argument refinements:

```mlir
%A : #memref<[a-dims, k-dims], f32, offset: 0, strides: [as-dims]>
%B : #memref<[k-dims, b-dims], f32, offset: 0, strides: [bs-dims]>
%C : #memref<[a-dims, b-dims], f32, offset: 0, strides: [cs-dims]>
```

## `func.return`

The function-region verifier checks that returned values agree with declared
function result refinements:

- if a function result has no dependent refinement, the returned value must not
  unexpectedly carry one
- if a function result has a dependent refinement, the returned value's inferred
  refinement must resolve successfully
- the returned refinement must match the declared result refinement exactly:
  carrier type, dimensions, offset, strides, and explicit-layout bit

This check is implemented for the prototype, but it has no direct cost in the
current verification benchmark beyond visiting the `return`, because the
benchmark kernels return no values.

## `func.call`

The call verifier checks agreement between a call site and the callee's function
boundary metadata:

- call operands are mapped to the callee's refined arguments
- operand refinements must match the callee's declared argument refinements
  after substituting callee entry block arguments with call operands
- call results with dependent callee result metadata must have resolvable
  dependent refinements

The current benchmark does not contain calls, so this verifier is not exercised
by the generated contraction kernels.

## `scf.for` And `affine.for`

Loop verifiers support dependent loop-carried type refs. When loop `#types` are
present, they check:

- loop-carried operand/result/yield refinement entries are in range
- loop operand and loop result refs are valid tensor or memref refs
- tensor refs have no layout metadata
- memref refs have matching rank, dimensions, and optional stride metadata
- loop init refinements match the operand type refs when they can be resolved
- yielded value refinements match the result type refs when they can be resolved

The current verification benchmark intentionally does not attach loop-carried
`#types` to the generated memref kernels. The loops are still verified by normal
SCF verification, but dependent loop-refinement checks are not the measured
feature here.

## `dependent_memref.cast`

Verifier checks:

- source and result are memrefs
- source and result element types match
- the result refinement is valid for the result memref
- rank, dimension count, optional stride count, and index-typed dimension/stride
  operands are consistent

This op is implemented but not present in the current generated verification
kernels.

## `dependent_memref.load`

Verifier checks:

- the source is a memref
- the number of load indices equals the logical refinement rank
- the result type matches the memref element type
- the source refinement is valid for the source memref
- dimension and stride operands in the `#memref` refinement are `index` typed
- non-flat carriers only refine dynamic memref dimensions

## `dependent_memref.store`

Verifier checks:

- the source is a memref
- the number of store indices equals the logical refinement rank
- the stored scalar type matches the memref element type
- the source refinement is valid for the source memref
- dimension and stride operands in the `#memref` refinement are `index` typed
- non-flat carriers only refine dynamic memref dimensions
