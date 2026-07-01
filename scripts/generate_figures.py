#!/usr/bin/env python3
"""
Regenerate the paper's main figures from results/processed/summary.csv.

Produces grouped bar charts of SDC probability, base versus variant, for
(a) the six controlled pairs and (b) the case-study applications, saved as
PNG and PDF under results/figures/. Error bars are the 95% confidence
half-widths already computed by aggregate_results.py.

matplotlib is the only third-party dependency in this artifact. If it is not
installed, the script still writes the plotted values as CSV and exits 0, so
the pipeline never hard-fails on a plotting library.

Usage:
  python3 scripts/generate_figures.py --summary results/processed/summary.csv \
                                      --output results/figures
"""
import argparse
import csv
import os


def load(summary_path):
    with open(summary_path, newline="") as fh:
        return list(csv.DictReader(fh))


def collect(rows, group, order):
    by = {}
    for r in rows:
        if r["group"] != group:
            continue
        by.setdefault(r["program"], {})[r["role"]] = r
    out = []
    for prog in order:
        if prog in by and "base" in by[prog] and "variant" in by[prog]:
            b, v = by[prog]["base"], by[prog]["variant"]
            out.append((prog,
                        float(b["sdc_probability_pct"]), float(b["ci95_halfwidth_pct"]),
                        float(v["sdc_probability_pct"]), float(v["ci95_halfwidth_pct"])))
    return out


def write_plotdata(data, path):
    with open(path, "w", newline="") as fh:
        w = csv.writer(fh)
        w.writerow(["program", "sdc_base_pct", "ci_base", "sdc_variant_pct", "ci_variant"])
        for row in data:
            w.writerow(row)


def make_chart(data, title, out_base):
    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt

    progs = [d[0] for d in data]
    base = [d[1] for d in data]
    base_ci = [d[2] for d in data]
    var = [d[3] for d in data]
    var_ci = [d[4] for d in data]
    x = range(len(progs))
    w = 0.38

    fig, ax = plt.subplots(figsize=(max(6, len(progs) * 0.9), 3.6))
    ax.bar([i - w / 2 for i in x], base, w, yerr=base_ci, capsize=3,
           label="base (original)", color="#c44e52")
    ax.bar([i + w / 2 for i in x], var, w, yerr=var_ci, capsize=3,
           label="variant (insight applied)", color="#4c72b0")
    ax.set_ylabel("SDC probability (%)")
    ax.set_title(title)
    ax.set_xticks(list(x))
    ax.set_xticklabels(progs, rotation=30, ha="right", fontsize=8)
    ax.legend(fontsize=8)
    ax.grid(axis="y", linestyle=":", alpha=0.5)
    fig.tight_layout()
    fig.savefig(out_base + ".png", dpi=150)
    fig.savefig(out_base + ".pdf")
    plt.close(fig)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--summary", default="results/processed/summary.csv")
    ap.add_argument("--output", default="results/figures")
    args = ap.parse_args()
    os.makedirs(args.output, exist_ok=True)
    rows = load(args.summary)

    controlled_order = ["verdict_encoding", "loop_invariant", "branch_selection",
                        "conditional_write", "bounded_lookup", "masked_accumulator"]
    apps_order = ["running_maximum", "dna_motif_search", "string_search", "dijkstra",
                  "histogram", "transform_sum", "weighted_map", "threshold_sum",
                  "record_scan", "blackscholes"]

    controlled = collect(rows, "controlled_pairs", controlled_order)
    apps = collect(rows, "applications", apps_order)

    write_plotdata(controlled, os.path.join(args.output, "controlled_pairs_plotdata.csv"))
    write_plotdata(apps, os.path.join(args.output, "applications_plotdata.csv"))

    try:
        make_chart(controlled, "Controlled pairs: SDC probability", os.path.join(args.output, "controlled_pairs"))
        make_chart(apps, "Case studies: SDC probability", os.path.join(args.output, "applications"))
        print("wrote figures (png+pdf) to %s" % args.output)
    except ImportError:
        print("matplotlib not installed; wrote *_plotdata.csv only. "
              "Install with 'pip install matplotlib' to render the charts.")


if __name__ == "__main__":
    main()
