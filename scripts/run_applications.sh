#!/bin/bash
set -u
HERE="$(cd "$(dirname "$0")/.." && pwd)"
PROG=all; WHICH=both; N=1000; SEED=2026; ISEED=42; SIZE=""; INPUT=""; OUTDIR="$HERE/results/reproduced"
while [ $# -gt 0 ]; do
  case "$1" in
    --program) PROG="$2"; shift 2;;
    --variant) WHICH="$2"; shift 2;;
    --num-injections) N="$2"; shift 2;;
    --seed) SEED="$2"; shift 2;;
    --input-seed) ISEED="$2"; shift 2;;
    --size) SIZE="$2"; shift 2;;
    --input) INPUT="$2"; shift 2;;
    --output-dir) OUTDIR="$2"; shift 2;;
    *) echo "unknown option: $1"; exit 2;;
  esac
done
LLFI_ROOT="${LLFI_ROOT:-/root/ws/llfi}"
[ -x "$LLFI_ROOT/bin/instrument" ] || { echo "ERROR: run inside the LLFI container (LLFI not at $LLFI_ROOT)."; exit 1; }
mkdir -p "$OUTDIR"
GEN="$HERE/data/inputs/generate_inputs.py"

ALL="running_maximum dna_motif_search string_search dijkstra histogram transform_sum weighted_map threshold_sum record_scan blackscholes"
[ "$PROG" = all ] && LIST="$ALL" || LIST="$PROG"

gen_input() {
  local p="$1" out="$2" sz="$SIZE"
  case "$p" in
    dna_motif_search) python3 "$GEN" --mode dna    --size "${sz:-2000000}" --pattern-len 8 --seed "$ISEED" --out "$out";;
    string_search)    python3 "$GEN" --mode search --size "${sz:-2000000}" --alphabet 4 --pattern-len 8 --seed "$ISEED" --out "$out";;
    dijkstra)         python3 "$GEN" --mode dijkstra --nodes 100 --seed "$ISEED" --out "$out";;
    blackscholes)     python3 "$GEN" --mode blackscholes --size "${sz:-500000}" --seed "$ISEED" --out "$out";;
    *)                python3 "$GEN" --mode ints   --size "${sz:-2000000}" --seed "$ISEED" --out "$out";;
  esac
}

for p in $LIST; do
  d="$HERE/src/applications/$p"
  [ -d "$d" ] || { echo "no such program: $p"; continue; }
  if [ -n "$INPUT" ]; then inp="$INPUT"; else
    inp="$(mktemp)"; echo "[$p] generating input (seed $ISEED)..."; gen_input "$p" "$inp"; fi
  out="$OUTDIR/${p}.csv"
  echo "algorithm,impl,SDC,Crash,Benign,Hang,Total,DI_total_cycle,totalindex,status" > "$out"
  for v in base variant; do
    { [ "$WHICH" = both ] || [ "$WHICH" = "$v" ]; } || continue
    echo "[$p/$v] injecting $N faults (seed $SEED)..."
    bash "$HERE/scripts/fault_inject.sh" "$d/$v.cpp" "$inp" "$N" "$SEED" "$out"
  done
  [ -n "$INPUT" ] || rm -f "$inp"
  echo "[$p] -> $out"
done
echo "Done. Aggregate with: python3 scripts/aggregate_results.py --input $OUTDIR --output results/processed"
