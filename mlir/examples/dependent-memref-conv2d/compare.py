#!/usr/bin/env python3
import argparse
import json
import os
import subprocess
import time
from pathlib import Path

BASELINE_PIPELINE = "builtin.module(one-shot-bufferize{bufferize-function-boundaries},func.func(convert-scf-to-cf,convert-arith-to-llvm),finalize-memref-to-llvm,convert-func-to-llvm,convert-cf-to-llvm,reconcile-unrealized-casts)"
MEMREF_PIPELINE = "builtin.module(func.func(convert-scf-to-cf,convert-arith-to-llvm),finalize-memref-to-llvm,convert-func-to-llvm,convert-cf-to-llvm,reconcile-unrealized-casts)"
DEPENDENT_PIPELINE = "builtin.module(convert-dependent-tensor-to-dependent-memref,lower-dependent-memref-to-llvm,func.func(convert-scf-to-cf,convert-arith-to-llvm),reconcile-unrealized-casts)"
DIRECT_DEPENDENT_PIPELINE = "builtin.module(lower-dependent-memref-to-llvm,func.func(convert-scf-to-cf,convert-arith-to-llvm),reconcile-unrealized-casts)"


def run(command, **kwargs):
    return subprocess.run(command, check=True, text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, **kwargs)


def extract_mlir_timing(stderr):
    try:
        timing = json.loads(stderr)
    except json.JSONDecodeError:
        return {}
    total = next((entry for entry in timing if entry.get("name") == "Total"), None)
    payload = {"pass_timing": timing}
    if total and "wall" in total and "duration" in total["wall"]:
        payload["pass_timing_total_ms"] = round(total["wall"]["duration"] * 1000.0, 3)
    return payload


def extract_llvm_pass_timing(stderr):
    in_pass_report = False
    for line in stderr.splitlines():
        if "Pass execution timing report" in line:
            in_pass_report = True
            continue
        if in_pass_report and "Total Execution Time:" in line:
            fields = line.split()
            try:
                seconds = float(fields[3])
            except (IndexError, ValueError):
                return {}
            return {"pass_timing_total_ms": round(seconds * 1000.0, 3)}
    return {}


def measure_wall(command, timing_path=None, parse_timing=None):
    start = time.perf_counter()
    result = subprocess.run(command, check=True, text=True, stdout=subprocess.DEVNULL, stderr=subprocess.PIPE)
    payload = {"wall_ms": round((time.perf_counter() - start) * 1000.0, 3)}
    if timing_path is not None:
        timing_path.write_text(result.stderr)
        payload["timing_file"] = str(timing_path)
    if parse_timing is not None:
        payload.update(parse_timing(result.stderr))
    return payload


def measure_mlir_opt(command, timing_path):
    return measure_wall(
        [
            *command,
            "-mlir-disable-threading",
            "-mlir-timing",
            "-mlir-timing-display=list",
            "-mlir-output-format=json",
        ],
        timing_path,
        extract_mlir_timing,
    )


def measure_llvm_opt(command, timing_path):
    return measure_wall([*command, "-time-passes"], timing_path, extract_llvm_pass_timing)


def line_count(path):
    return len(path.read_text().splitlines())


def count_occurrences(path, needle):
    return path.read_text().count(needle)


def collect_metrics(out_dir, stem):
    llvm_mlir = out_dir / f"{stem}.llvm.mlir"
    llvm_ir = out_dir / f"{stem}.ll"
    llvm_opt_ir = out_dir / f"{stem}.opt.ll"
    return {
        "llvm_dialect_lines": line_count(llvm_mlir),
        "llvm_dialect_insertvalue": count_occurrences(llvm_mlir, '"llvm.insertvalue"'),
        "llvm_dialect_extractvalue": count_occurrences(llvm_mlir, '"llvm.extractvalue"'),
        "llvm_ir_lines": line_count(llvm_ir),
        "llvm_ir_insertvalue": count_occurrences(llvm_ir, "insertvalue"),
        "llvm_ir_extractvalue": count_occurrences(llvm_ir, "extractvalue"),
        "llvm_opt_ir_lines": line_count(llvm_opt_ir),
        "llvm_opt_ir_insertvalue": count_occurrences(llvm_opt_ir, "insertvalue"),
        "llvm_opt_ir_extractvalue": count_occurrences(llvm_opt_ir, "extractvalue"),
    }


def emit_route(mlir_opt, mlir_translate, llvm_opt, source, out_dir, stem, pipeline):
    out_dir.mkdir(parents=True, exist_ok=True)
    (out_dir / "input.mlir").write_text(source.read_text())
    if pipeline.startswith("-"):
        lower_cmd = [str(mlir_opt), str(source), *pipeline.split()]
    else:
        lower_cmd = [str(mlir_opt), str(source), f"-pass-pipeline={pipeline}"]
    llvm_mlir = run([*lower_cmd, "-mlir-print-op-generic"]).stdout
    (out_dir / f"{stem}.llvm.mlir").write_text(llvm_mlir)
    llvm_ir = run(lower_cmd).stdout
    translated = subprocess.run([str(mlir_translate), "-mlir-to-llvmir"], input=llvm_ir, check=True, text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE).stdout
    (out_dir / f"{stem}.ll").write_text(translated)
    metrics = {
        "llvm_opt": measure_llvm_opt(
            [
                str(llvm_opt),
                "-O3",
                "-S",
                str(out_dir / f"{stem}.ll"),
                "-o",
                str(out_dir / f"{stem}.opt.ll"),
            ],
            out_dir / f"{stem}.opt-timing.txt",
        )
    }
    metrics.update(collect_metrics(out_dir, stem))
    return metrics


def main():
    parser = argparse.ArgumentParser(description="Build Conv2D-shaped structural LLVM lowering artifacts.")
    parser.add_argument("--out", type=Path)
    args = parser.parse_args()

    script_dir = Path(__file__).resolve().parent
    repo_root = Path(run(["git", "-C", str(script_dir), "rev-parse", "--show-toplevel"]).stdout.strip())
    mlir_opt = Path(os.environ.get("MLIR_OPT", repo_root / "build/bin/mlir-opt"))
    mlir_translate = Path(os.environ.get("MLIR_TRANSLATE", repo_root / "build/bin/mlir-translate"))
    llvm_opt = Path(os.environ.get("LLVM_OPT", repo_root / "build/bin/opt"))
    out_dir = args.out or script_dir / "artifacts"
    out_dir.mkdir(parents=True, exist_ok=True)

    routes = {
        "baseline": ("baseline-conv2d.mlir", "baseline_conv2d_kernel", BASELINE_PIPELINE),
        "dependent": ("dependent-conv2d.mlir", "dependent_conv2d_kernel", DEPENDENT_PIPELINE),
        "baseline_strided": ("baseline-strided-conv2d.mlir", "baseline_conv2d_strided", MEMREF_PIPELINE),
        "direct_strided": ("dependent-strided-conv2d.mlir", "dependent_conv2d_strided", DIRECT_DEPENDENT_PIPELINE),
    }

    result = {"routes": {}}
    for name, (source_name, stem, pipeline) in routes.items():
        route_dir = out_dir / name.replace("_", "-")
        timing_path = route_dir / f"{stem}.mlir-timing.txt"
        source = script_dir / source_name
        if pipeline.startswith("-"):
            timing_cmd = [str(mlir_opt), str(source), *pipeline.split()]
        else:
            timing_cmd = [str(mlir_opt), str(source), f"-pass-pipeline={pipeline}"]
        metrics = emit_route(mlir_opt, mlir_translate, llvm_opt, source, route_dir, stem, pipeline)
        metrics["mlir_opt"] = measure_mlir_opt(timing_cmd, timing_path)
        result["routes"][name] = metrics

    report_path = out_dir / "results.json"
    report_path.write_text(json.dumps(result, indent=2, sort_keys=True) + "\n")
    print(f"wrote={report_path}")
    for name, metrics in result["routes"].items():
        descriptor_ops = metrics["llvm_dialect_insertvalue"] + metrics["llvm_dialect_extractvalue"]
        print(f"{name}_llvm_dialect_lines={metrics['llvm_dialect_lines']}")
        print(f"{name}_insertvalue={metrics['llvm_dialect_insertvalue']}")
        print(f"{name}_extractvalue={metrics['llvm_dialect_extractvalue']}")
        print(f"{name}_descriptor_ops={descriptor_ops}")


if __name__ == "__main__":
    main()
