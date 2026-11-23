#!/bin/bash
set -eu
HERE="$(cd "$(dirname "$0")/.." && pwd)"
cd "$HERE"
echo "== 1/3 aggregate raw counts -> results/processed/summary.csv =="
python3 scripts/aggregate_results.py --input results/raw_summary --output results/processed
echo
echo "== 2/3 regenerate tables -> results/tables/ =="
python3 scripts/generate_tables.py --summary results/processed/summary.csv --output results/tables
echo
echo "== 3/3 regenerate figures -> results/figures/ =="
python3 scripts/generate_figures.py --summary results/processed/summary.csv --output results/figures
echo
echo "== paper Table V (Case Studies), regenerated from included data =="
python3 - <<'PY'
import csv
rows = list(csv.DictReader(open("results/tables/table5_applications.csv")))
print("  %-18s %-22s %8s %8s %7s" % ("program", "mechanism(#)", "SDC_b%", "SDC_v%", "z"))
for r in rows:
    print("  %-18s %-22s %8s %8s %7.1f" % (
        r["program"], "%s(#%s)" % (r["mechanism"], r["insight"]),
        r["sdc_base_pct"], r["sdc_variant_pct"], float(r["z"])))
PY
echo
echo "Done. See results/tables/ (csv+tex) and results/figures/ (png+pdf)."
echo "Compare against paper Table V and Section V; docs/expected_outputs.md lists the target numbers."
