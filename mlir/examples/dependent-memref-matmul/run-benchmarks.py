#!/usr/bin/env python3
import argparse
import json
import subprocess
from datetime import datetime, timezone
from pathlib import Path


DEFAULT_SIZES = [128, 256, 512]
PAPER_SIZES = [512, 1024, 2048, 4096]
LARGE_SIZE = 1024


def run(command):
    print("+ " + " ".join(str(arg) for arg in command), flush=True)
    subprocess.run(command, check=True)


def read_json(path):
    return json.loads(path.read_text())


def as_float(value):
    if value is None:
        return None
    return float(value)


def ratio(numerator, denominator):
    numerator = as_float(numerator)
    denominator = as_float(denominator)
    if numerator is None or denominator in (None, 0.0):
        return None
    return numerator / denominator


def run_median_ns(result, key):
    run_info = result[key].get("run")
    if not run_info:
        return None
    return as_float(run_info.get("median_ns"))


def summarize_size(size, result):
    dependent_ns = run_median_ns(result, "dependent")
    baseline_ns = run_median_ns(result, "baseline")
    return {
        "size": size,
        "problem": result["problem"],
        "dependent": {
            "median_ns": dependent_ns,
            "mlir_opt_wall_ms": result["dependent"]["mlir_opt"]["wall_ms"],
            "llvm_opt_wall_ms": result["dependent"]["llvm_opt"]["wall_ms"],
            "llvm_dialect_lines": result["dependent"]["llvm_dialect_lines"],
            "llvm_ir_lines": result["dependent"]["llvm_ir_lines"],
            "llvm_opt_ir_lines": result["dependent"]["llvm_opt_ir_lines"],
            "descriptor_ops": result["dependent"]["llvm_dialect_insertvalue"]
            + result["dependent"]["llvm_dialect_extractvalue"],
            "opt_descriptor_ops": result["dependent"]["llvm_opt_ir_insertvalue"]
            + result["dependent"]["llvm_opt_ir_extractvalue"],
        },
        "baseline": {
            "median_ns": baseline_ns,
            "mlir_opt_wall_ms": result["baseline"]["mlir_opt"]["wall_ms"],
            "llvm_opt_wall_ms": result["baseline"]["llvm_opt"]["wall_ms"],
            "llvm_dialect_lines": result["baseline"]["llvm_dialect_lines"],
            "llvm_ir_lines": result["baseline"]["llvm_ir_lines"],
            "llvm_opt_ir_lines": result["baseline"]["llvm_opt_ir_lines"],
            "descriptor_ops": result["baseline"]["llvm_dialect_insertvalue"]
            + result["baseline"]["llvm_dialect_extractvalue"],
            "opt_descriptor_ops": result["baseline"]["llvm_opt_ir_insertvalue"]
            + result["baseline"]["llvm_opt_ir_extractvalue"],
        },
        "ratios": {
            "runtime_baseline_over_dependent": ratio(baseline_ns, dependent_ns),
            "mlir_opt_baseline_over_dependent": ratio(
                result["baseline"]["mlir_opt"]["wall_ms"],
                result["dependent"]["mlir_opt"]["wall_ms"],
            ),
            "llvm_opt_baseline_over_dependent": ratio(
                result["baseline"]["llvm_opt"]["wall_ms"],
                result["dependent"]["llvm_opt"]["wall_ms"],
            ),
        },
    }


def fmt(value, precision=2):
    if value is None:
        return "n/a"
    if isinstance(value, float):
        return f"{value:.{precision}f}"
    return str(value)


def write_markdown(summary, path):
    lines = [
        "# Dependent MemRef Matmul Benchmark Summary",
        "",
        f"Generated: `{summary['generated_at']}`",
        f"Repeats: `{summary['repeats']}`",
        f"Sizes: `{', '.join(str(size) for size in summary['sizes'])}`",
        "",
        "| size | dep ns | base ns | base/dep | dep MLIR ms | base MLIR ms | dep opt lines | base opt lines | dep desc | base desc | base opt desc |",
        "| ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |",
    ]
    for entry in summary["runs"]:
        lines.append(
            "| {size} | {dep_ns} | {base_ns} | {runtime_ratio} | {dep_mlir} | "
            "{base_mlir} | {dep_lines} | {base_lines} | {dep_desc} | "
            "{base_desc} | {base_opt_desc} |".format(
                size=entry["size"],
                dep_ns=fmt(entry["dependent"]["median_ns"], 0),
                base_ns=fmt(entry["baseline"]["median_ns"], 0),
                runtime_ratio=fmt(entry["ratios"]["runtime_baseline_over_dependent"]),
                dep_mlir=fmt(entry["dependent"]["mlir_opt_wall_ms"]),
                base_mlir=fmt(entry["baseline"]["mlir_opt_wall_ms"]),
                dep_lines=entry["dependent"]["llvm_opt_ir_lines"],
                base_lines=entry["baseline"]["llvm_opt_ir_lines"],
                dep_desc=entry["dependent"]["descriptor_ops"],
                base_desc=entry["baseline"]["descriptor_ops"],
                base_opt_desc=entry["baseline"]["opt_descriptor_ops"],
            )
        )
    lines.extend(
        [
            "",
            "`base/dep` above is `baseline median ns / dependent median ns`; values",
            "larger than 1 mean the dependent executable was faster for that run.",
            "Descriptor counts are textual counts in the generated IR artifacts.",
            "",
        ]
    )
    path.write_text("\n".join(lines))


def main():
    parser = argparse.ArgumentParser(
        description="Run the dependent-memref matmul benchmark sweep."
    )
    parser.add_argument(
        "--sizes",
        type=int,
        nargs="+",
        default=DEFAULT_SIZES,
        help="Square matrix sizes to run. Defaults to 128 256 512.",
    )
    parser.add_argument(
        "--paper",
        action="store_true",
        help="Run the paper-oriented sweep: 512 1024 2048 4096.",
    )
    parser.add_argument(
        "--large",
        action="store_true",
        help="Also run the 1024x1024x1024 benchmark for non-paper sweeps.",
    )
    parser.add_argument(
        "--repeats",
        type=int,
        default=30,
        help="Kernel repetitions per size. Defaults to 30.",
    )
    parser.add_argument(
        "--out",
        type=Path,
        default=None,
        help="Output directory. Defaults to artifacts/benchmarks.",
    )
    parser.add_argument(
        "--skip-run",
        action="store_true",
        help="Collect code-size and compile-time metrics without executing kernels.",
    )
    args = parser.parse_args()

    script_dir = Path(__file__).resolve().parent
    out_dir = args.out or script_dir / "artifacts" / "benchmarks"
    sizes = list(PAPER_SIZES if args.paper else args.sizes)
    if args.large and not args.paper and LARGE_SIZE not in sizes:
        sizes.append(LARGE_SIZE)

    out_dir.mkdir(parents=True, exist_ok=True)
    runs = []
    for size in sizes:
        size_dir = out_dir / f"size-{size}"
        command = [
            str(script_dir / "compare.py"),
            "--n",
            str(size),
            "--k",
            str(size),
            "--m",
            str(size),
            "--repeats",
            str(args.repeats),
            "--out",
            str(size_dir),
        ]
        if args.skip_run:
            command.append("--skip-run")
        run(command)
        result = read_json(size_dir / "results.json")
        runs.append(summarize_size(size, result))

    summary = {
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "repeats": args.repeats,
        "sizes": sizes,
        "paper": args.paper,
        "skip_run": args.skip_run,
        "runs": runs,
    }
    summary_json = out_dir / "summary.json"
    summary_md = out_dir / "summary.md"
    summary_json.write_text(json.dumps(summary, indent=2, sort_keys=True) + "\n")
    write_markdown(summary, summary_md)

    print(f"wrote={summary_json}")
    print(f"wrote={summary_md}")


if __name__ == "__main__":
    main()
