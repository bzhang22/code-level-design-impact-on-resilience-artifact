#!/bin/bash
# ---------------------------------------------------------------------------
# fault_inject.sh -- run ONE program end to end through LLFI and classify.
#
# Pipeline: compile to LLVM IR at -O0 -> demangle-safe rename -> LLFI
# instrument -> profile (dynamic instruction count) -> injectfault (N single
# bit flips) -> classify each run against the fault-free golden output ->
# append one CSV line.
#
# This is the per-program engine; run_quick_check.sh / run_controlled_pairs.sh
# / run_applications.sh call it. It is meant to run inside the LLFI container
# (see Dockerfile); LLVM/LLFI locations are taken from the environment so the
# script contains no absolute install path of its own.
#
# Usage:
#   fault_inject.sh <src.cpp> <input.txt> <num_injections> <seed> <out.csv> [timeout_s]
#
# Environment (with defaults matching the provided Docker image):
#   LLFI_ROOT   directory of the LLFI build            (default /root/ws/llfi)
#   CLANGXX     clang++ 3.4 built with RTTI            (default /root/ws/llvm-build/bin/clang++)
# ---------------------------------------------------------------------------
set -u
SRC="$1"; INPUT="$2"; N="${3:-1000}"; SEED="${4:-42}"; OUT="$5"; TIMEOUT="${6:-8}"
LLFI_ROOT="${LLFI_ROOT:-/root/ws/llfi}"
CLANGXX="${CLANGXX:-/root/ws/llvm-build/bin/clang++}"

name=$(basename "$SRC" .cpp)
group=$(basename "$(dirname "$SRC")")   # e.g. verdict_encoding, running_maximum
label="$group,$name"                    # two CSV fields: algorithm,impl
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
cp "$SRC" "$work/prog.cpp"
cp "$INPUT" "$work/numbers.txt"
cd "$work" || { echo "$label,,,,,,,,NOWDIR" >> "$OUT"; exit 1; }

# Injection configuration. fi_random_seed makes LLFI's choice of which dynamic
# instruction to corrupt reproducible run to run (the original campaign left it
# unset and used default randomisation; see docs/fault_injection_protocol.md).
cat > input.yaml <<YAML
defaultTimeOut: $TIMEOUT
compileOption:
    instSelMethod:
      - insttype:
          include:
            - all
          exclude:
            - ret
            - alloca
            - call
            - phi
    regSelMethod: regloc
    regloc: dstreg
runOption:
    - run:
        numOfRuns: $N
        fi_type: bitflip
        fi_random_seed: $SEED
YAML

emit() { echo "$1" >> "$OUT"; }

if ! "$CLANGXX" -std=c++11 -O0 -fno-exceptions -fno-rtti -w -emit-llvm -S -o prog.ll prog.cpp 2>clang.log; then
  emit "$label,,,,,,,,COMPILE_FAIL"; exit 1; fi

# gcc-4.8's __cxa_demangle returns NULL on some C++11 mangled names, which
# crashes LLFI's instrument pass. Rename only the names c++filt cannot demangle.
grep -oE '_Z[A-Za-z0-9_]+' prog.ll | sort -u | awk '{print length,$0}' | sort -rn | cut -d' ' -f2- > _n.txt
ri=0
while read -r nm; do
  [ -z "$nm" ] && continue
  if [ "$(echo "$nm" | c++filt)" = "$nm" ]; then
    ri=$((ri+1)); sed -i "s/@${nm}(/@NODEMANGLE${ri}(/g" prog.ll
  fi
done < _n.txt

if ! "$LLFI_ROOT/bin/instrument" --readable prog.ll >i.log 2>&1; then emit "$label,,,,,,,,INSTRUMENT_FAIL"; exit 1; fi
if ! "$LLFI_ROOT/bin/profile" ./llfi/prog-profiling.exe >p.log 2>&1; then emit "$label,,,,,,,,PROFILE_FAIL"; exit 1; fi
if ! "$LLFI_ROOT/bin/injectfault" ./llfi/prog-faultinjection.exe >f.log 2>&1; then emit "$label,,,,,,,,FI_FAIL"; exit 1; fi

G=llfi/baseline/golden_std_output
sdc=0; crash=0; benign=0; hang=0; total=0
for ff in llfi/std_output/std_outputfile-*; do
  [ -e "$ff" ] || continue
  total=$((total+1))
  tag=$(basename "$ff" | sed 's/^std_outputfile-//')
  ef="llfi/error_output/errorfile-$tag"
  if [ -f "$ef" ]; then
    if grep -qi hang "$ef"; then hang=$((hang+1)); else crash=$((crash+1)); fi
  elif diff -q "$ff" "$G" >/dev/null 2>&1; then benign=$((benign+1)); else sdc=$((sdc+1)); fi
done
di=$(grep -o 'total_cycle=[0-9]*' llfi.stat.prof.txt 2>/dev/null | cut -d= -f2)
ti=$(grep -o 'totalindex=[0-9]*' llfi.stat.totalindex.txt 2>/dev/null | cut -d= -f2)
emit "$label,$sdc,$crash,$benign,$hang,$total,$di,$ti,OK"
echo "[fault_inject] $label: SDC=$sdc Crash=$crash Benign=$benign Hang=$hang Total=$total DI=$di" 1>&2
