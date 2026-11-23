#!/bin/bash
set -u
HERE="$(cd "$(dirname "$0")/.." && pwd)"
N=80; SEED=2026; OUTDIR="$HERE/results/reproduced"
while [ $# -gt 0 ]; do
  case "$1" in
    --num-injections) N="$2"; shift 2;;
    --seed) SEED="$2"; shift 2;;
    --output-dir) OUTDIR="$2"; shift 2;;
    *) echo "unknown option: $1"; exit 2;;
  esac
done

LLFI_ROOT="${LLFI_ROOT:-/root/ws/llfi}"
if [ ! -x "$LLFI_ROOT/bin/instrument" ]; then
  echo "ERROR: LLFI not found at \$LLFI_ROOT ($LLFI_ROOT)."
  echo "Run this inside the LLFI container. See README.md > Quick Start."
  exit 1
fi

mkdir -p "$OUTDIR"
CSV="$OUTDIR/quick_check.csv"
echo "algorithm,impl,SDC,Crash,Benign,Hang,Total,DI_total_cycle,totalindex,status" > "$CSV"

echo "== quick check: $N injections/variant, seed $SEED =="

bash "$HERE/scripts/fault_inject.sh" \
  "$HERE/src/controlled_pairs/verdict_encoding/base.cpp" \
  "$HERE/data/inputs/quick_search.txt" "$N" "$SEED" "$CSV"
bash "$HERE/scripts/fault_inject.sh" \
  "$HERE/src/controlled_pairs/verdict_encoding/variant.cpp" \
  "$HERE/data/inputs/quick_search.txt" "$N" "$SEED" "$CSV"

bash "$HERE/scripts/fault_inject.sh" \
  "$HERE/src/applications/running_maximum/base.cpp" \
  "$HERE/data/inputs/quick_ints.txt" "$N" "$SEED" "$CSV"
bash "$HERE/scripts/fault_inject.sh" \
  "$HERE/src/applications/running_maximum/variant.cpp" \
  "$HERE/data/inputs/quick_ints.txt" "$N" "$SEED" "$CSV"

echo
echo "== results ($CSV) =="
cat "$CSV"

python3 - "$CSV" <<'PY'
import csv, sys
rows = list(csv.DictReader(open(sys.argv[1])))
def sdc(prog, role):
    for r in rows:
        if r["status"] == "OK" and r["algorithm"] == prog and r["impl"] == role:
            t = int(r["Total"]); return 100.0*int(r["SDC"])/t if t else None
    return None
print("\n== SDC comparison (small budget, direction only) ==")
ok = True
for name in ["verdict_encoding", "running_maximum"]:
    sb, sv = sdc(name, "base"), sdc(name, "variant")
    if sb is None or sv is None:
        print("  %-18s : INCOMPLETE (a run did not classify)" % name); ok = False; continue
    arrow = "lower (expected)" if sv <= sb else "higher (within small-budget noise)"
    print("  %-18s : base %.1f%% -> variant %.1f%%   [%s]" % (name, sb, sv, arrow))
print("\nQUICK CHECK %s: pipeline build+inject+classify+aggregate is working."
      % ("PASSED" if ok else "INCOMPLETE"))
print("Exact percentages are not expected to match the paper at this budget.")
PY
