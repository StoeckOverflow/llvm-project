#!/usr/bin/env python3
import argparse
import csv
from pathlib import Path


def ranked_type(rank: int, kind: str, layout: str | None = None) -> str:
    shape = 'x'.join(['?'] * rank)
    if layout is None:
        return f"{kind}<{shape}xf32>"
    return f"{kind}<{shape}xf32, {layout}>"


def dynamic_strided_layout(rank: int) -> str:
    return f"strided<[{', '.join(['?'] * rank)}], offset: ?>"


def memref_ref(dims, strides):
    return f"#memref<[{', '.join(dims)}], f32, offset: 0, strides: [{', '.join(strides)}]>"


def contraction_dims(rank: int):
    a_dims = [f"%a{i}" for i in range(rank)]
    b_dims = [f"%b{i}" for i in range(rank)]
    k_dims = [f"%k{i}" for i in range(rank)]
    a_shape = a_dims + k_dims
    b_shape = k_dims + b_dims
    c_shape = a_dims + b_dims
    return a_dims, b_dims, k_dims, a_shape, b_shape, c_shape


def emit_memref_body(rank: int, load_op: str, store_op: str, ref_suffix,
                     a_ty: str | None = None, b_ty: str | None = None,
                     c_ty: str | None = None) -> str:
    a_dims, b_dims, k_dims, a_shape, b_shape, c_shape = contraction_dims(rank)
    a_ty = a_ty or ranked_type(2 * rank, "memref")
    b_ty = b_ty or ranked_type(2 * rank, "memref")
    c_ty = c_ty or ranked_type(2 * rank, "memref")
    loop_bounds = a_dims + b_dims
    loop_names = [f"%ia{i}" for i in range(rank)] + [f"%ib{i}" for i in range(rank)]
    body = ""
    for level, (iv, bound) in enumerate(zip(loop_names, loop_bounds)):
        body += " " * (2 * (level + 1)) + f"scf.for {iv} = %c0 to {bound} step %c1 {{\n"

    a_ivs = loop_names[:rank]
    b_ivs = loop_names[rank:]
    k_ivs = [f"%ik{i}" for i in range(rank)]
    a_indices = a_ivs + k_ivs
    b_indices = k_ivs + b_ivs
    c_indices = a_ivs + b_ivs
    level = len(loop_bounds)

    def emit_reduction(level_index: int, acc: str, indent_level: int):
        if level_index == rank:
            a_ref = ref_suffix(a_shape, "a")
            b_ref = ref_suffix(b_shape, "b")
            code = " " * (2 * indent_level) + f"%lhs = {load_op} %A[{', '.join(a_indices)}]{a_ref} : {a_ty}\n"
            code += " " * (2 * indent_level) + f"%rhs = {load_op} %B[{', '.join(b_indices)}]{b_ref} : {b_ty}\n"
            code += " " * (2 * indent_level) + "%mul = arith.mulf %lhs, %rhs : f32\n"
            code += " " * (2 * indent_level) + f"%next = arith.addf {acc}, %mul : f32\n"
            return code, "%next"

        result = f"%sum{level_index}"
        iter_arg = f"%acc{level_index}"
        code = " " * (2 * indent_level) + f"{result} = scf.for {k_ivs[level_index]} = %c0 to {k_dims[level_index]} step %c1 iter_args({iter_arg} = {acc}) -> (f32) {{\n"
        nested_code, nested_result = emit_reduction(level_index + 1, iter_arg, indent_level + 1)
        code += nested_code
        code += " " * (2 * (indent_level + 1)) + f"scf.yield {nested_result} : f32\n"
        code += " " * (2 * indent_level) + "}\n"
        return code, result

    reduction, sum_value = emit_reduction(0, "%zero", level + 1)
    body += reduction
    c_ref = ref_suffix(c_shape, "c")
    body += " " * (2 * (level + 1)) + f"{store_op} {sum_value}, %C[{', '.join(c_indices)}]{c_ref} : {c_ty}\n"
    for level in reversed(range(len(loop_bounds))):
        body += " " * (2 * (level + 1)) + "}\n"
    return body


def reinterpret_cast(source: str, target: str, shape, strides,
                     target_type: str) -> str:
    return (
        f"  {target} = memref.reinterpret_cast {source} to "
        f"offset: [0], sizes: [{', '.join(shape)}], "
        f"strides: [{', '.join(strides)}] : memref<?xf32> to {target_type}\n"
    )


def baseline_memref_kernel(rank: int) -> str:
    a_dims, b_dims, k_dims, a_shape, b_shape, c_shape = contraction_dims(rank)
    layout = dynamic_strided_layout(2 * rank)
    a_ty = ranked_type(2 * rank, "memref", layout)
    b_ty = ranked_type(2 * rank, "memref", layout)
    c_ty = ranked_type(2 * rank, "memref", layout)
    a_strides = [f"%as{i}" for i in range(2 * rank)]
    b_strides = [f"%bs{i}" for i in range(2 * rank)]
    c_strides = [f"%cs{i}" for i in range(2 * rank)]
    arg_lines = [f"    {dim} : index" for dim in a_dims + b_dims + k_dims]
    arg_lines += [f"    {stride} : index" for stride in a_strides + b_strides + c_strides]
    arg_lines += [
        "    %A_flat : memref<?xf32>",
        "    %B_flat : memref<?xf32>",
        "    %C_flat : memref<?xf32>",
    ]

    text = f"func.func @baseline_memref_contraction_rank_{rank}(\n"
    text += ",\n".join(arg_lines) + ") {\n"
    text += "  %c0 = arith.constant 0 : index\n"
    text += "  %c1 = arith.constant 1 : index\n"
    text += "  %zero = arith.constant 0.0 : f32\n"
    text += reinterpret_cast("%A_flat", "%A", a_shape, a_strides, a_ty)
    text += reinterpret_cast("%B_flat", "%B", b_shape, b_strides, b_ty)
    text += reinterpret_cast("%C_flat", "%C", c_shape, c_strides, c_ty)
    text += emit_memref_body(rank, "memref.load", "memref.store",
                             lambda _shape, _name: "", a_ty, b_ty, c_ty)
    text += "  return\n}\n"
    return text


def memref_kernel(rank: int) -> str:
    a_dims, b_dims, k_dims, a_shape, b_shape, c_shape = contraction_dims(rank)
    a_ty = ranked_type(2 * rank, "memref")
    b_ty = ranked_type(2 * rank, "memref")
    c_ty = ranked_type(2 * rank, "memref")
    a_strides = [f"%as{i}" for i in range(2 * rank)]
    b_strides = [f"%bs{i}" for i in range(2 * rank)]
    c_strides = [f"%cs{i}" for i in range(2 * rank)]
    strides_by_name = {"a": a_strides, "b": b_strides, "c": c_strides}

    arg_lines = [f"    {dim} : index" for dim in a_dims + b_dims + k_dims]
    arg_lines += [f"    {stride} : index" for stride in a_strides + b_strides + c_strides]
    arg_lines += [f"    %A : {a_ty}", f"    %B : {b_ty}", f"    %C : {c_ty}"]

    header = [f"func.func @memref_contraction_rank_{rank}("]
    header.append(",\n".join(arg_lines) + ")")
    header.append("    #types[")
    header.append(f"      %A : {memref_ref(a_shape, a_strides)},")
    header.append(f"      %B : {memref_ref(b_shape, b_strides)},")
    header.append(f"      %C : {memref_ref(c_shape, c_strides)}")
    header.append("    ] {")

    def dependent_ref(shape, name):
        return " " + memref_ref(shape, strides_by_name[name])

    text = "\n".join(header) + "\n"
    text += "  %c0 = arith.constant 0 : index\n"
    text += "  %c1 = arith.constant 1 : index\n"
    text += "  %zero = arith.constant 0.0 : f32\n"
    text += emit_memref_body(rank, "dependent_memref.load", "dependent_memref.store", dependent_ref)
    text += "  return\n}\n"
    return text


def metrics_for(route: str, rank: int, kernels: int, text: str):
    a_rank = 2 * rank
    b_rank = 2 * rank
    c_rank = 2 * rank
    if route == "baseline_memref":
        refinement_sites_per_kernel = 0
        logical_dim_refs_per_kernel = 0
        refinement_value_refs_per_kernel = 0
    else:
        refinement_sites_per_kernel = 6
        logical_dim_refs_per_kernel = 2 * (a_rank + b_rank + c_rank)
        refinement_value_refs_per_kernel = 2 * logical_dim_refs_per_kernel
    return {
        "contraction_rank": rank,
        "rank": rank,
        "a_rank": a_rank,
        "b_rank": b_rank,
        "c_rank": c_rank,
        "max_carrier_rank": max(a_rank, b_rank, c_rank),
        "kernels": kernels,
        "path": "",
        "lines": text.count("\n"),
        "refinement_sites": kernels * refinement_sites_per_kernel,
        "logical_dim_refs": kernels * logical_dim_refs_per_kernel,
        "refinement_value_refs": kernels * refinement_value_refs_per_kernel,
    }


def generate(out: Path, ranks):
    out.mkdir(parents=True, exist_ok=True)
    rows = []
    kernels = 1
    for rank in ranks:
        baseline_text = baseline_memref_kernel(rank)
        memref_text = memref_kernel(rank)
        baseline_path = out / f"baseline-memref-contraction-rank-{rank}.mlir"
        memref_path = out / f"memref-contraction-rank-{rank}.mlir"
        baseline_path.write_text(baseline_text)
        memref_path.write_text(memref_text)
        for route, path, text in [
            ("baseline_memref", baseline_path, baseline_text),
            ("memref", memref_path, memref_text),
        ]:
            row = {"route": route, **metrics_for(route, rank, kernels, text)}
            row["path"] = str(path.resolve())
            rows.append(row)
    with (out / "manifest.csv").open("w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=rows[0].keys())
        writer.writeheader()
        writer.writerows(rows)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", type=Path, default=Path("artifacts/generated"))
    ap.add_argument("--ranks", type=int, nargs="+", default=[1, 2, 4, 8, 16, 24, 32])
    args = ap.parse_args()
    generate(args.out, args.ranks)


if __name__ == "__main__":
    main()
