#!/usr/bin/env python3
import argparse
import csv
from pathlib import Path


def ranked_type(rank: int, kind: str) -> str:
    return f"{kind}<{'x'.join(['?'] * rank)}xf32>"


def tensor_ref(dims):
    return f"#tensor<[{', '.join(dims)}], f32>"


def memref_ref(dims, strides):
    return f"#memref<[{', '.join(dims)}], f32, offset: 0, strides: [{', '.join(strides)}]>"


def indent(text: str, spaces: int) -> str:
    pad = " " * spaces
    return "".join(pad + line if line else line for line in text.splitlines(True))


def contraction_dims(rank: int):
    a_dims = [f"%a{i}" for i in range(rank)]
    b_dims = [f"%b{i}" for i in range(rank)]
    k_dims = [f"%k{i}" for i in range(rank)]
    a_shape = a_dims + k_dims
    b_shape = k_dims + b_dims
    c_shape = a_dims + b_dims
    return a_dims, b_dims, k_dims, a_shape, b_shape, c_shape


def tensor_kernel(rank: int, idx: int) -> str:
    a_dims, b_dims, k_dims, a_shape, b_shape, c_shape = contraction_dims(rank)
    a_ty = ranked_type(2 * rank, "tensor")
    b_ty = ranked_type(2 * rank, "tensor")
    c_ty = ranked_type(2 * rank, "tensor")
    arg_lines = [f"    {dim} : index" for dim in a_dims + b_dims + k_dims]
    arg_lines += [f"    %A : {a_ty}", f"    %B : {b_ty}", f"    %C : {c_ty}"]

    header = [f"func.func @tensor_contraction_rank_{rank}_{idx}("]
    header.append(",\n".join(arg_lines) + f") -> {c_ty}")
    header.append("    #types[")
    header.append(f"      %A : {tensor_ref(a_shape)},")
    header.append(f"      %B : {tensor_ref(b_shape)},")
    header.append(f"      %C : {tensor_ref(c_shape)}")
    header.append(f"    ] -> {tensor_ref(c_shape)} {{")

    loop_bounds = a_dims + b_dims
    loop_names = [f"%ia{i}" for i in range(rank)] + [f"%ib{i}" for i in range(rank)]

    def emit_body(level: int, carried: str):
        if level == len(loop_bounds):
            a_ivs = loop_names[:rank]
            b_ivs = loop_names[rank:]
            k_ivs = [f"%ik{i}" for i in range(rank)]
            a_indices = a_ivs + k_ivs
            b_indices = k_ivs + b_ivs
            c_indices = a_ivs + b_ivs

            def emit_reduction(level: int, acc: str):
                if level == rank:
                    code = ""
                    code += f"%lhs = dependent_tensor.extract %A[{', '.join(a_indices)}] : f32\n"
                    code += f"%rhs = dependent_tensor.extract %B[{', '.join(b_indices)}] : f32\n"
                    code += "%mul = arith.mulf %lhs, %rhs : f32\n"
                    code += f"%next = arith.addf {acc}, %mul : f32\n"
                    return code, "%next"

                result = f"%sum{level}"
                iter_arg = f"%acc{level}"
                nested_code, nested_result = emit_reduction(level + 1, iter_arg)
                code = ""
                code += f"{result} = scf.for {k_ivs[level]} = %c0 to {k_dims[level]} step %c1 iter_args({iter_arg} = {acc}) -> (f32) {{\n"
                code += indent(nested_code, 2)
                code += f"  scf.yield {nested_result} : f32\n"
                code += "}\n"
                return code, result

            code, sum_value = emit_reduction(0, "%zero")
            code += f"%updated = dependent_tensor.insert {sum_value} into {carried}[{', '.join(c_indices)}] {tensor_ref(c_shape)} : f32 into {c_ty}\n"
            return code, "%updated"

        result = f"%C{level}"
        arg = f"%C_arg{level}"
        nested_code, nested_result = emit_body(level + 1, arg)
        code = ""
        code += f"{result} = scf.for {loop_names[level]} = %c0 to {loop_bounds[level]} step %c1 iter_args({arg} = {carried}) -> ({c_ty})\n"
        code += f"  #types[{arg} : {tensor_ref(c_shape)}] -> {tensor_ref(c_shape)} {{\n"
        code += indent(nested_code, 2)
        code += f"  scf.yield {nested_result} : {c_ty}\n"
        code += "}\n"
        return code, result

    body, final_c = emit_body(0, "%C")

    text = "\n".join(header) + "\n"
    text += "  %c0 = arith.constant 0 : index\n"
    text += "  %c1 = arith.constant 1 : index\n"
    text += "  %zero = arith.constant 0.0 : f32\n"
    text += indent(body, 2)
    text += f"  return {final_c} : {c_ty}\n"
    text += "}\n"
    return text


def memref_kernel(rank: int, idx: int) -> str:
    a_dims, b_dims, k_dims, a_shape, b_shape, c_shape = contraction_dims(rank)
    a_ty = ranked_type(2 * rank, "memref")
    b_ty = ranked_type(2 * rank, "memref")
    c_ty = ranked_type(2 * rank, "memref")
    a_strides = [f"%as{i}" for i in range(2 * rank)]
    b_strides = [f"%bs{i}" for i in range(2 * rank)]
    c_strides = [f"%cs{i}" for i in range(2 * rank)]

    arg_lines = [f"    {dim} : index" for dim in a_dims + b_dims + k_dims]
    arg_lines += [f"    {stride} : index" for stride in a_strides + b_strides + c_strides]
    arg_lines += [f"    %A : {a_ty}", f"    %B : {b_ty}", f"    %C : {c_ty}"]

    header = [f"func.func @memref_contraction_rank_{rank}_{idx}("]
    header.append(",\n".join(arg_lines) + ")")
    header.append("    #types[")
    header.append(f"      %A : {memref_ref(a_shape, a_strides)},")
    header.append(f"      %B : {memref_ref(b_shape, b_strides)},")
    header.append(f"      %C : {memref_ref(c_shape, c_strides)}")
    header.append("    ] {")

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
            code = " " * (2 * indent_level) + f"%lhs = dependent_memref.load %A[{', '.join(a_indices)}] {memref_ref(a_shape, a_strides)} : {a_ty}\n"
            code += " " * (2 * indent_level) + f"%rhs = dependent_memref.load %B[{', '.join(b_indices)}] {memref_ref(b_shape, b_strides)} : {b_ty}\n"
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
    body += " " * (2 * (level + 1)) + f"dependent_memref.store {sum_value}, %C[{', '.join(c_indices)}] {memref_ref(c_shape, c_strides)} : {c_ty}\n"
    for level in reversed(range(len(loop_bounds))):
        body += " " * (2 * (level + 1)) + "}\n"

    text = "\n".join(header) + "\n"
    text += "  %c0 = arith.constant 0 : index\n"
    text += "  %c1 = arith.constant 1 : index\n"
    text += "  %zero = arith.constant 0.0 : f32\n"
    text += body
    text += "  return\n}\n"
    return text


def metrics_for(route: str, rank: int, kernels: int, text: str):
    a_rank = 2 * rank
    b_rank = 2 * rank
    c_rank = 2 * rank
    if route == "tensor":
        refinement_sites_per_kernel = 4 + (2 * rank * 2) + 1
        logical_dim_refs_per_kernel = a_rank + b_rank + c_rank + c_rank
        logical_dim_refs_per_kernel += (2 * rank) * 2 * c_rank
        logical_dim_refs_per_kernel += c_rank
        refinement_value_refs_per_kernel = logical_dim_refs_per_kernel
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


def generate(out: Path, ranks, kernels: int):
    out.mkdir(parents=True, exist_ok=True)
    rows = []
    for rank in ranks:
        tensor_text = "\n".join(tensor_kernel(rank, i) for i in range(kernels))
        memref_text = "\n".join(memref_kernel(rank, i) for i in range(kernels))
        tensor_path = out / f"tensor-contraction-rank-{rank}.mlir"
        memref_path = out / f"memref-contraction-rank-{rank}.mlir"
        tensor_path.write_text(tensor_text)
        memref_path.write_text(memref_text)
        for route, path, text in [("tensor", tensor_path, tensor_text), ("memref", memref_path, memref_text)]:
            row = {"route": route, **metrics_for(route, rank, kernels, text)}
            row["path"] = str(path)
            rows.append(row)
    with (out / "manifest.csv").open("w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=rows[0].keys())
        writer.writeheader()
        writer.writerows(rows)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", type=Path, default=Path("artifacts/generated"))
    ap.add_argument("--ranks", type=int, nargs="+", default=[1, 2, 3, 4, 5, 6, 8])
    ap.add_argument("--kernels", type=int, default=24)
    args = ap.parse_args()
    generate(args.out, args.ranks, args.kernels)


if __name__ == "__main__":
    main()
