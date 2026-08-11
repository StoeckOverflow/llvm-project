#!/usr/bin/env python3
import argparse
import json
import sys
from pathlib import Path


def import_pyplot():
    try:
        import matplotlib

        matplotlib.use("Agg")
        import matplotlib.pyplot as plt

        return plt
    except ImportError as error:
        print(
            "error: matplotlib is required to generate plots.\n"
            "Install it with: python3 -m pip install matplotlib",
            file=sys.stderr,
        )
        raise SystemExit(1) from error


def read_summary(path):
    return json.loads(path.read_text())


def value_at(entry, path):
    value = entry
    for key in path:
        if value is None:
            return None
        value = value.get(key)
    return value


def series(summary, path):
    values = []
    for entry in summary["runs"]:
        value = value_at(entry, path)
        values.append(None if value is None else float(value))
    return values


def sizes(summary):
    return [entry["size"] for entry in summary["runs"]]


def has_values(values):
    return any(value is not None for value in values)


def zero_none(values):
    return [0.0 if value is None else value for value in values]


def runtime_ms(summary, key):
    return [None if v is None else v / 1.0e6 for v in series(summary, [key, "median_ns"])]


def save_figure(fig, output_stem, formats):
    written = []
    for fmt in formats:
        path = output_stem.with_suffix(f".{fmt}")
        fig.savefig(path)
        written.append(path)
    return written


def plot_performance_stacked(plt, summary, output_dir, formats):
    from matplotlib.patches import Patch

    x_values = sizes(summary)
    positions = list(range(len(x_values)))
    width = 0.36

    dep_mlir = series(summary, ["dependent", "mlir_opt_wall_ms"])
    dep_llvm = series(summary, ["dependent", "llvm_opt_wall_ms"])
    dep_run = runtime_ms(summary, "dependent")
    base_mlir = series(summary, ["baseline", "mlir_opt_wall_ms"])
    base_llvm = series(summary, ["baseline", "llvm_opt_wall_ms"])
    base_run = runtime_ms(summary, "baseline")

    fig, ax = plt.subplots(figsize=(9.2, 6.4))
    fig.subplots_adjust(top=0.74)
    dep_x = [pos - width / 2 for pos in positions]
    base_x = [pos + width / 2 for pos in positions]

    colors = {
        "mlir": "#4C78A8",
        "llvm": "#F58518",
        "run": "#54A24B",
    }
    dep_mlir_z = zero_none(dep_mlir)
    dep_llvm_z = zero_none(dep_llvm)
    dep_run_z = zero_none(dep_run)
    base_mlir_z = zero_none(base_mlir)
    base_llvm_z = zero_none(base_llvm)
    base_run_z = zero_none(base_run)

    ax.bar(dep_x, dep_mlir_z, width, color=colors["mlir"], edgecolor="black", linewidth=0.4, label="MLIR lowering")
    ax.bar(dep_x, dep_llvm_z, width, bottom=dep_mlir_z, color=colors["llvm"], edgecolor="black", linewidth=0.4, label="LLVM opt -O3")
    ax.bar(
        dep_x,
        dep_run_z,
        width,
        bottom=[a + b for a, b in zip(dep_mlir_z, dep_llvm_z)],
        color=colors["run"],
        edgecolor="black",
        linewidth=0.4,
        label="kernel execution",
    )

    ax.bar(base_x, base_mlir_z, width, color=colors["mlir"], edgecolor="black", linewidth=0.4, hatch="//")
    ax.bar(base_x, base_llvm_z, width, bottom=base_mlir_z, color=colors["llvm"], edgecolor="black", linewidth=0.4, hatch="//")
    ax.bar(
        base_x,
        base_run_z,
        width,
        bottom=[a + b for a, b in zip(base_mlir_z, base_llvm_z)],
        color=colors["run"],
        edgecolor="black",
        linewidth=0.4,
        hatch="//",
    )

    fig.suptitle("Matmul Cost: Lowering, LLVM Optimization, Execution", y=0.98)
    ax.set_xlabel("matrix size")
    ax.set_ylabel("time (ms)")
    ax.set_xticks(positions, [str(size) for size in x_values])
    ax.grid(True, axis="y", linestyle=":", linewidth=0.7)

    phase_handles = [
        Patch(facecolor=colors["mlir"], edgecolor="black", linewidth=0.4, label="MLIR lowering"),
        Patch(facecolor=colors["llvm"], edgecolor="black", linewidth=0.4, label="LLVM opt -O3"),
        Patch(facecolor=colors["run"], edgecolor="black", linewidth=0.4, label="kernel execution"),
    ]
    approach_handles = [
        Patch(facecolor="white", edgecolor="black", linewidth=0.7, label="dependent: left, solid"),
        Patch(facecolor="white", edgecolor="black", linewidth=0.7, hatch="//", label="baseline: right, dashed"),
    ]
    fig.legend(
        handles=phase_handles, loc="upper center", bbox_to_anchor=(0.5, 0.925),
        ncol=3, frameon=False
    )
    fig.legend(
        handles=approach_handles, loc="upper center", bbox_to_anchor=(0.5, 0.865),
        ncol=2, frameon=False
    )
    return save_figure(fig, output_dir / "performance-stacked", formats)


def plot_llvm_line_count(plt, summary, output_dir, formats):
    x_values = sizes(summary)
    positions = list(range(len(x_values)))
    width = 0.36
    dep_lines = series(summary, ["dependent", "llvm_opt_ir_lines"])
    base_lines = series(summary, ["baseline", "llvm_opt_ir_lines"])

    fig, ax = plt.subplots(figsize=(8.8, 5.0), constrained_layout=True)
    ax.bar([pos - width / 2 for pos in positions], zero_none(dep_lines), width, label="dependent", color="#4C78A8")
    ax.bar([pos + width / 2 for pos in positions], zero_none(base_lines), width, label="baseline", color="#F58518")
    ax.set_title("Optimized LLVM IR Line Count", pad=18)
    ax.set_xlabel("matrix size")
    ax.set_ylabel("line count after opt -O3")
    ax.set_xticks(positions, [str(size) for size in x_values])
    max_line_count = max(zero_none(dep_lines) + zero_none(base_lines))
    ax.set_ylim(0, max_line_count * 1.24 if max_line_count else 1)
    ax.grid(True, axis="y", linestyle=":", linewidth=0.7)
    ax.legend(loc="upper center", bbox_to_anchor=(0.5, 1.0), ncol=2, frameon=False)
    return save_figure(fig, output_dir / "llvm-line-count", formats)


def plot_lines(plt, x_values, named_series, title, ylabel, output_stem, formats):
    filtered = [(name, values) for name, values in named_series if has_values(values)]
    if not filtered:
        print(f"skip {output_stem}: no values")
        return []

    fig, ax = plt.subplots(figsize=(7.2, 4.4), constrained_layout=True)
    for name, values in filtered:
        ax.plot(x_values, values, marker="o", linewidth=2, label=name)
    ax.set_title(title)
    ax.set_xlabel("matrix size")
    ax.set_ylabel(ylabel)
    ax.grid(True, which="both", axis="y", linestyle=":", linewidth=0.7)
    ax.legend(frameon=False)
    ax.set_xticks(x_values)
    return save_figure(fig, output_stem, formats)


def plot_grouped_bars(plt, x_values, named_series, title, ylabel, output_stem, formats):
    filtered = [(name, values) for name, values in named_series if has_values(values)]
    if not filtered:
        print(f"skip {output_stem}: no values")
        return []

    fig, ax = plt.subplots(figsize=(7.2, 4.4), constrained_layout=True)
    width = 0.8 / len(filtered)
    positions = list(range(len(x_values)))
    for i, (name, values) in enumerate(filtered):
        offsets = [pos - 0.4 + width / 2 + i * width for pos in positions]
        ax.bar(offsets, zero_none(values), width=width, label=name)
    ax.set_title(title)
    ax.set_xlabel("matrix size")
    ax.set_ylabel(ylabel)
    ax.grid(True, axis="y", linestyle=":", linewidth=0.7)
    ax.legend(frameon=False)
    ax.set_xticks(positions, [str(value) for value in x_values])
    return save_figure(fig, output_stem, formats)


def plot_debug_figures(plt, summary, output_dir, formats):
    x_values = sizes(summary)
    written = []
    written += plot_lines(
        plt,
        x_values,
        [("dependent", runtime_ms(summary, "dependent")), ("baseline", runtime_ms(summary, "baseline"))],
        "Matmul Runtime",
        "median runtime (ms)",
        output_dir / "debug-runtime",
        formats,
    )
    written += plot_lines(
        plt,
        x_values,
        [
            ("dependent", series(summary, ["dependent", "mlir_opt_wall_ms"])),
            ("baseline", series(summary, ["baseline", "mlir_opt_wall_ms"])),
        ],
        "MLIR Lowering Time",
        "wall time (ms)",
        output_dir / "debug-mlir-lowering-time",
        formats,
    )
    written += plot_lines(
        plt,
        x_values,
        [
            ("dependent", series(summary, ["dependent", "llvm_opt_wall_ms"])),
            ("baseline", series(summary, ["baseline", "llvm_opt_wall_ms"])),
        ],
        "LLVM opt -O3 Time",
        "wall time (ms)",
        output_dir / "debug-llvm-opt-time",
        formats,
    )
    written += plot_lines(
        plt,
        x_values,
        [
            ("dependent raw LLVM IR", series(summary, ["dependent", "llvm_ir_lines"])),
            ("baseline raw LLVM IR", series(summary, ["baseline", "llvm_ir_lines"])),
            ("dependent opt LLVM IR", series(summary, ["dependent", "llvm_opt_ir_lines"])),
            ("baseline opt LLVM IR", series(summary, ["baseline", "llvm_opt_ir_lines"])),
        ],
        "Generated LLVM IR Size",
        "line count",
        output_dir / "debug-llvm-ir-lines",
        formats,
    )
    written += plot_grouped_bars(
        plt,
        x_values,
        [
            ("dependent raw", series(summary, ["dependent", "descriptor_ops"])),
            ("baseline raw", series(summary, ["baseline", "descriptor_ops"])),
            ("dependent opt", series(summary, ["dependent", "opt_descriptor_ops"])),
            ("baseline opt", series(summary, ["baseline", "opt_descriptor_ops"])),
        ],
        "Descriptor Operation Counts",
        "textual op count",
        output_dir / "debug-descriptor-ops",
        formats,
    )
    return written


def write_index(written, output_dir, summary_path, include_debug):
    lines = [
        "# Dependent MemRef Matmul Plots",
        "",
        f"Input summary: `{summary_path}`",
        "",
        "Default paper-facing figures:",
        "",
    ]
    for path in written:
        if not path.name.startswith("debug-"):
            lines.append(f"- `{path.name}`")
    if include_debug:
        lines.extend(["", "Debug figures:", ""])
        for path in written:
            if path.name.startswith("debug-"):
                lines.append(f"- `{path.name}`")
    lines.append("")
    (output_dir / "README.md").write_text("\n".join(lines))


def main():
    parser = argparse.ArgumentParser(
        description="Generate paper-facing plots from run-benchmarks.py summary.json."
    )
    parser.add_argument("summary", type=Path, help="Benchmark summary.json file.")
    parser.add_argument(
        "--out",
        type=Path,
        default=None,
        help="Output directory. Defaults to <summary-dir>/plots.",
    )
    parser.add_argument(
        "--formats",
        nargs="+",
        default=["pdf", "png"],
        choices=["pdf", "png", "svg"],
        help="Plot formats to emit. Defaults to pdf png.",
    )
    parser.add_argument(
        "--debug-plots",
        action="store_true",
        help="Also emit detailed diagnostic plots for runtime, compile-time, lines, and descriptor counts.",
    )
    args = parser.parse_args()

    summary = read_summary(args.summary)
    output_dir = args.out or args.summary.parent / "plots"
    output_dir.mkdir(parents=True, exist_ok=True)
    plt = import_pyplot()

    written = []
    written += plot_performance_stacked(plt, summary, output_dir, args.formats)
    written += plot_llvm_line_count(plt, summary, output_dir, args.formats)
    if args.debug_plots:
        written += plot_debug_figures(plt, summary, output_dir, args.formats)

    write_index(written, output_dir, args.summary, args.debug_plots)
    for path in written:
        print(f"wrote={path}")
    print(f"wrote={output_dir / 'README.md'}")


if __name__ == "__main__":
    main()
