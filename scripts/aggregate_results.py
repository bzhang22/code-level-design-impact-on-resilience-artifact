#!/usr/bin/env python3
import argparse
import csv
import math
import os


def load_mapping(path):
    with open(path, newline="") as fh:
        return list(csv.DictReader(fh))


def index_raw_csv(path):
    rows = {}
    with open(path, newline="") as fh:
        reader = csv.reader(fh)
        header = next(reader)
        col = {name: i for i, name in enumerate(header)}
        impl_i = col.get("impl", 1)
        di_i = col.get("DI_total_cycle", col.get("DI"))
        for r in reader:
            if not r or len(r) < 7:
                continue
            impl = r[impl_i]
            rows[impl] = {
                "SDC": r[col["SDC"]],
                "Crash": r[col["Crash"]],
                "Benign": r[col["Benign"]],
                "Hang": r[col["Hang"]],
                "Total": r[col["Total"]],
                "DI": r[di_i] if di_i is not None else "",
                "status": r[col.get("status", len(r) - 1)],
            }
    return rows


def to_int(x, default=0):
    try:
        return int(x)
    except (ValueError, TypeError):
        return default


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--input", default="results/raw_summary",
                    help="directory of raw campaign CSVs")
    ap.add_argument("--output", default="results/processed",
                    help="directory for summary.csv")
    ap.add_argument("--mapping", default="data/benchmark_metadata/mapping.csv")
    ap.add_argument("--seed-label", default="unseeded",
                    help="value recorded in the 'seed' column for these rows")
    args = ap.parse_args()

    mapping = load_mapping(args.mapping)

    raw_cache = {}
    def get_raw(csv_name):
        if csv_name not in raw_cache:
            raw_cache[csv_name] = index_raw_csv(os.path.join(args.input, csv_name))
        return raw_cache[csv_name]

    out_rows = []
    missing = []
    for m in mapping:
        raw = get_raw(m["raw_csv"])
        rec = raw.get(m["raw_impl"])
        if rec is None:
            missing.append((m["raw_csv"], m["raw_impl"]))
            continue
        sdc = to_int(rec["SDC"]); crash = to_int(rec["Crash"])
        benign = to_int(rec["Benign"]); hang = to_int(rec["Hang"])
        total = to_int(rec["Total"])
        if total <= 0:
            missing.append((m["raw_csv"], m["raw_impl"] + " (Total=0)"))
            continue
        p = sdc / total
        ci = 1.96 * math.sqrt(p * (1.0 - p) / total) * 100.0
        out_rows.append({
            "group": m["group"],
            "program": m["program"],
            "role": m["role"],
            "insight": m["insight_num"],
            "insight_name": m["insight_name"],
            "mechanism": m["mechanism"],
            "seed": args.seed_label,
            "num_injections": total,
            "benign_count": benign,
            "sdc_count": sdc,
            "crash_count": crash,
            "hang_count": hang,
            "sdc_probability_pct": round(p * 100.0, 4),
            "ci95_halfwidth_pct": round(ci, 4),
            "dynamic_instruction_count": to_int(rec["DI"]),
            "raw_csv": m["raw_csv"],
            "raw_impl": m["raw_impl"],
            "paper_ref": m["paper_ref"],
        })

    os.makedirs(args.output, exist_ok=True)
    out_path = os.path.join(args.output, "summary.csv")
    fields = ["group", "program", "role", "insight", "insight_name", "mechanism",
              "seed", "num_injections", "benign_count", "sdc_count", "crash_count",
              "hang_count", "sdc_probability_pct", "ci95_halfwidth_pct",
              "dynamic_instruction_count", "raw_csv", "raw_impl", "paper_ref"]
    with open(out_path, "w", newline="") as fh:
        w = csv.DictWriter(fh, fieldnames=fields)
        w.writeheader()
        w.writerows(out_rows)

    print("wrote %s (%d rows)" % (out_path, len(out_rows)))
    if missing:
        print("WARNING: %d mapped implementations not found in raw CSVs:" % len(missing))
        for c, i in missing:
            print("  %s :: %s" % (c, i))


if __name__ == "__main__":
    main()
