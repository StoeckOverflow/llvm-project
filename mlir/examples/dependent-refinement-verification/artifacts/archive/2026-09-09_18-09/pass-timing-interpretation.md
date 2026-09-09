# Pass Timing Interpretation

- baseline `dimensions-128`: total `24.3 ms`
- dependent `dimensions-128`: total `17.7 ms`
- `root` contains everything
- `Pipeline Collection : ['func.func']` contains the nested `func.func` pipeline. 

`Parser`
Dependent is slower here in the raw example: `5.7 ms` vs baseline `3.9 ms`.
That makes sense: dependent input has extra `#types` / `#memref` refinement syntax and property operands. The baseline has plain memref IR.

`SCFToControlFlowPass`
Baseline: `1.5 ms`; dependent: `1.3 ms`.
Almost the same. Both lower similar loop nests from `scf.for` to CFG. Small differences are noise plus slightly different operation forms around memory access.

`ArithToLLVMConversionPass`
Baseline: `2.7 ms`; dependent: `2.4 ms`.
Almost the same. Both lower constants/index arithmetic. The dependent route has fewer descriptor-related arithmetic/materialization patterns by the time this matters.

`FinalizeMemRefToLLVMConversionPass`
Baseline only: `3.5 ms`.
Big standard MLIR memref descriptor lowering. It lowers memrefs through descriptor structs: allocated/aligned ptr, offset, sizes, strides. This creates the `llvm.insertvalue` / `llvm.extractvalue` traffic.

`LowerDependentMemRefToLLVMPass`
Dependent only: `3.5 ms`.
This replaces the standard memref descriptor path with the prototype's refinement-aware lowering. It computes addresses from refinement metadata and lowers carriers as bare LLVM pointers. That is why descriptor ops stay at `0`.

`ConvertFuncToLLVMPass`
Baseline: `4.0 ms`; dependent: `0.9 ms`.
This pass converts MLIR function/method signatures, calls, and returns to LLVM dialect ABI form. Once the baseline route has lowered ordinary memrefs into descriptor-shaped LLVM values, the function/method signatures still have to be converted around those descriptor-shaped ABI values: allocated pointer, aligned pointer, offset, sizes, and strides. That gives `ConvertFuncToLLVMPass` more aggregate signature material and value plumbing to rewrite.

In the dependent route, `LowerDependentMemRefToLLVMPass` has already avoided the descriptor abstraction and represents refined memrefs as bare LLVM pointers plus separately available index values from the original function/method signature and refinement metadata. By the time `ConvertFuncToLLVMPass` runs, there is much less signature-level ABI structure left to legalize: mostly pointer/index/scalar values instead of descriptor aggregates. This is why the dependent route is much cheaper in this pass.

`ConvertControlFlowToLLVMPass`
Baseline: `3.1 ms`; dependent: `0.8 ms`.
Baseline CFG carries/uses more descriptor-shaped values and therefore has more LLVM dialect structure to convert. Dependent has simpler pointer/index/scalar values.

`ReconcileUnrealizedCastsPass`
Baseline: `1.5 ms`; dependent: `0.8 ms`.
Baseline has more type-conversion glue from standard lowering. Dependent has less descriptor conversion residue.

`DataLayoutAnalysis`
Basically zero in both: `0.1 ms` vs `0.0 ms`.
Not meaningful here.

`Output`
Baseline: `3.2 ms`; dependent: `1.6 ms`.
Baseline emits larger LLVM-dialect IR because of descriptors. Dependent emits less IR, so printing to `/dev/null` still costs less.

`Rest`
Tiny miscellaneous overhead: `0.8 ms` vs `0.7 ms`.
