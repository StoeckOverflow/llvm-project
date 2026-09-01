#!/usr/bin/env python3
import argparse
import json
import os
import subprocess
import time
from pathlib import Path


BASELINE_PIPELINE = "builtin.module(one-shot-bufferize{bufferize-function-boundaries},func.func(convert-scf-to-cf,convert-arith-to-llvm),finalize-memref-to-llvm,convert-func-to-llvm,convert-cf-to-llvm,reconcile-unrealized-casts)"


def run(command):
    result = subprocess.run(
        command, check=True, text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE
    )
    return result.stdout


def measure_wall(command, timing_path=None):
    start = time.perf_counter()
    result = subprocess.run(
        command, check=True, text=True, stdout=subprocess.DEVNULL, stderr=subprocess.PIPE
    )
    elapsed_ms = (time.perf_counter() - start) * 1000.0
    payload = {"wall_ms": round(elapsed_ms, 3)}
    if timing_path is not None:
        timing_path.write_text(result.stderr)
        payload["timing_file"] = str(timing_path)
    return payload


def measure_mlir_opt(command, timing_path):
    return measure_wall([*command, "--mlir-timing"], timing_path)


def parse_key_values(output):
    parsed = {}
    for line in output.splitlines():
        if "=" not in line:
            continue
        key, value = line.split("=", 1)
        parsed[key.strip()] = value.strip()
    return parsed


def line_count(path):
    return len(path.read_text().splitlines())


def count_occurrences(path, needle):
    return path.read_text().count(needle)


def collect_ir_metrics(prefix, out_dir, stem=None):
    stem = stem or prefix
    llvm_mlir = out_dir / f"{stem}.llvm.mlir"
    llvm_ir = out_dir / f"{stem}.ll"
    llvm_opt_ir = out_dir / f"{stem}.opt.ll"
    metrics = {
        "llvm_dialect_lines": line_count(llvm_mlir),
        "llvm_ir_lines": line_count(llvm_ir),
        "llvm_dialect_insertvalue": count_occurrences(llvm_mlir, '"llvm.insertvalue"'),
        "llvm_dialect_extractvalue": count_occurrences(llvm_mlir, '"llvm.extractvalue"'),
        "llvm_ir_insertvalue": count_occurrences(llvm_ir, "insertvalue"),
        "llvm_ir_extractvalue": count_occurrences(llvm_ir, "extractvalue"),
        "llvm_dialect_struct_type": count_occurrences(llvm_mlir, "!llvm.struct"),
        "llvm_dialect_gep": count_occurrences(llvm_mlir, '"llvm.getelementptr"'),
        "llvm_dialect_load": count_occurrences(llvm_mlir, '"llvm.load"'),
        "llvm_dialect_store": count_occurrences(llvm_mlir, '"llvm.store"'),
    }
    if llvm_opt_ir.exists():
        metrics.update(
            {
                "llvm_opt_ir_lines": line_count(llvm_opt_ir),
                "llvm_opt_ir_insertvalue": count_occurrences(llvm_opt_ir, "insertvalue"),
                "llvm_opt_ir_extractvalue": count_occurrences(llvm_opt_ir, "extractvalue"),
                "llvm_opt_ir_struct_type": count_occurrences(
                    llvm_opt_ir, "{ ptr, ptr, i64, [2 x i64], [2 x i64] }"
                ),
            }
        )
    return metrics


def main():
    parser = argparse.ArgumentParser(
        description="Build and compare dependent-memref and standard memref matmul artifacts."
    )
    parser.add_argument("--n", type=int, default=128)
    parser.add_argument("--k", type=int)
    parser.add_argument("--m", type=int)
    parser.add_argument("--repeats", type=int, default=10)
    parser.add_argument("--out", type=Path)
    parser.add_argument("--skip-run", action="store_true")
    args = parser.parse_args()

    script_dir = Path(__file__).resolve().parent
    repo_root = Path(
        run(["git", "-C", str(script_dir), "rev-parse", "--show-toplevel"]).strip()
    )
    mlir_opt = Path(os.environ.get("MLIR_OPT", repo_root / "build/bin/mlir-opt"))
    llvm_opt = Path(os.environ.get("LLVM_OPT", repo_root / "build/bin/opt"))
    out_dir = args.out or script_dir / "artifacts"
    out_dir.mkdir(parents=True, exist_ok=True)
    k = args.k if args.k is not None else args.n
    m = args.m if args.m is not None else args.n

    common = [
        "--out",
        str(out_dir),
        "--n",
        str(args.n),
        "--k",
        str(k),
        "--m",
        str(m),
        "--repeats",
        str(args.repeats),
    ]
    if args.skip_run:
        common.append("--build-only")

    dependent_output = run([str(script_dir / "run-dependent.sh"), *common])
    baseline_output = run([str(script_dir / "run-baseline.sh"), *common])

    result = {
        "problem": {"n": args.n, "k": k, "m": m, "repeats": args.repeats},
        "dependent": collect_ir_metrics("dependent", out_dir),
        "baseline": collect_ir_metrics("baseline", out_dir),
        "structural_artifacts": {
            "baseline_strided": collect_ir_metrics(
                "baseline_strided",
                out_dir / "baseline-strided",
                "baseline_matmul_strided",
            ),
            "direct_strided": collect_ir_metrics(
                "direct_strided",
                out_dir / "direct-strided",
                "dependent_matmul_strided",
            ),
        },
    }
    result["dependent"]["mlir_opt"] = measure_mlir_opt(
        [
            str(mlir_opt),
            str(script_dir / "dependent-matmul.mlir"),
            "-convert-dependent-tensor-to-dependent-memref",
            "-lower-dependent-memref-to-llvm",
            "-reconcile-unrealized-casts",
        ],
        out_dir / "dependent.mlir-timing.txt",
    )
    result["baseline"]["mlir_opt"] = measure_mlir_opt(
        [
            str(mlir_opt),
            str(script_dir / "baseline-tensor-matmul.mlir"),
            f"-pass-pipeline={BASELINE_PIPELINE}",
        ],
        out_dir / "baseline.mlir-timing.txt",
    )
    result["dependent"]["llvm_opt"] = measure_wall(
        [
            str(llvm_opt),
            "-O3",
            "-S",
            str(out_dir / "dependent.ll"),
            "-o",
            str(out_dir / "dependent.opt.ll"),
        ]
    )
    result["baseline"]["llvm_opt"] = measure_wall(
        [
            str(llvm_opt),
            "-O3",
            "-S",
            str(out_dir / "baseline.ll"),
            "-o",
            str(out_dir / "baseline.opt.ll"),
        ]
    )

    if not args.skip_run:
        result["dependent"]["run"] = parse_key_values(dependent_output)
        result["baseline"]["run"] = parse_key_values(baseline_output)

    result["delta"] = {
        "llvm_dialect_lines": result["baseline"]["llvm_dialect_lines"]
        - result["dependent"]["llvm_dialect_lines"],
        "llvm_ir_lines": result["baseline"]["llvm_ir_lines"]
        - result["dependent"]["llvm_ir_lines"],
        "llvm_opt_ir_lines": result["baseline"]["llvm_opt_ir_lines"]
        - result["dependent"]["llvm_opt_ir_lines"],
        "llvm_dialect_insertvalue": result["baseline"]["llvm_dialect_insertvalue"]
        - result["dependent"]["llvm_dialect_insertvalue"],
        "llvm_dialect_extractvalue": result["baseline"]["llvm_dialect_extractvalue"]
        - result["dependent"]["llvm_dialect_extractvalue"],
        "llvm_opt_ir_insertvalue": result["baseline"]["llvm_opt_ir_insertvalue"]
        - result["dependent"]["llvm_opt_ir_insertvalue"],
        "llvm_opt_ir_extractvalue": result["baseline"]["llvm_opt_ir_extractvalue"]
        - result["dependent"]["llvm_opt_ir_extractvalue"],
    }

    report_path = out_dir / "results.json"
    report_path.write_text(json.dumps(result, indent=2, sort_keys=True) + "\n")

    print(f"wrote={report_path}")
    print(f"dependent_llvm_dialect_lines={result['dependent']['llvm_dialect_lines']}")
    print(f"baseline_llvm_dialect_lines={result['baseline']['llvm_dialect_lines']}")
    print(f"dependent_llvm_ir_lines={result['dependent']['llvm_ir_lines']}")
    print(f"baseline_llvm_ir_lines={result['baseline']['llvm_ir_lines']}")
    print(f"dependent_llvm_opt_ir_lines={result['dependent']['llvm_opt_ir_lines']}")
    print(f"baseline_llvm_opt_ir_lines={result['baseline']['llvm_opt_ir_lines']}")
    print(
        "dependent_descriptor_ops="
        f"{result['dependent']['llvm_dialect_insertvalue'] + result['dependent']['llvm_dialect_extractvalue']}"
    )
    print(
        "baseline_descriptor_ops="
        f"{result['baseline']['llvm_dialect_insertvalue'] + result['baseline']['llvm_dialect_extractvalue']}"
    )
    baseline_strided = result["structural_artifacts"]["baseline_strided"]
    print(
        "baseline_strided_llvm_dialect_lines="
        f"{baseline_strided['llvm_dialect_lines']}"
    )
    print(
        "baseline_strided_descriptor_ops="
        f"{baseline_strided['llvm_dialect_insertvalue'] + baseline_strided['llvm_dialect_extractvalue']}"
    )
    direct_strided = result["structural_artifacts"]["direct_strided"]
    print(
        "direct_strided_llvm_dialect_lines="
        f"{direct_strided['llvm_dialect_lines']}"
    )
    print(
        "direct_strided_descriptor_ops="
        f"{direct_strided['llvm_dialect_insertvalue'] + direct_strided['llvm_dialect_extractvalue']}"
    )
    if not args.skip_run:
        print(f"dependent_median_ns={result['dependent']['run']['median_ns']}")
        print(f"baseline_median_ns={result['baseline']['run']['median_ns']}")
    print(f"dependent_mlir_opt_wall_ms={result['dependent']['mlir_opt']['wall_ms']}")
    print(f"baseline_mlir_opt_wall_ms={result['baseline']['mlir_opt']['wall_ms']}")
    print(f"dependent_llvm_opt_wall_ms={result['dependent']['llvm_opt']['wall_ms']}")
    print(f"baseline_llvm_opt_wall_ms={result['baseline']['llvm_opt']['wall_ms']}")


if __name__ == "__main__":
    main()
