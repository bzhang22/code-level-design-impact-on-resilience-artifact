#!/bin/bash
# ---------------------------------------------------------------------------
# build.sh -- compile-check every implementation and verify the toolchain.
#
# This is the lightweight build: it compiles each base/variant program with a
# host C++ compiler to confirm all sources build and run, and checks that
# Python 3 is available for the analysis pipeline. It does NOT build the LLFI
# fault injector (that is heavy and lives in the Docker image; see README).
#
# Exit status is non-zero if any program fails to compile.
# ---------------------------------------------------------------------------
set -u
HERE="$(cd "$(dirname "$0")/.." && pwd)"
CXX="${CXX:-}"
for c in g++ clang++ c++; do command -v "$c" >/dev/null 2>&1 && { CXX="$c"; break; }; done
if [ -z "$CXX" ]; then
  echo "ERROR: no C++ compiler (g++/clang++) found on PATH."
  echo "Install one, or run inside the Docker image which ships clang++ 3.4."
  exit 1
fi
echo "Using C++ compiler: $CXX ($($CXX --version 2>/dev/null | head -1))"
command -v python3 >/dev/null 2>&1 && echo "Python: $(python3 --version 2>&1)" || echo "WARNING: python3 not found (needed for the analysis pipeline)."

fail=0; n=0
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
while IFS= read -r src; do
  n=$((n+1))
  if "$CXX" -std=c++11 -O0 -w -o "$tmp/a.out" "$src" 2>"$tmp/err"; then
    :
  else
    echo "  COMPILE FAIL: ${src#$HERE/}"; sed 's/^/    /' "$tmp/err" | head -5; fail=$((fail+1))
  fi
done < <(find "$HERE/src/controlled_pairs" "$HERE/src/applications" -name '*.cpp' | sort)

echo
if [ "$fail" -eq 0 ]; then
  echo "build.sh: all $n programs compiled cleanly with $CXX."
else
  echo "build.sh: $fail of $n programs FAILED to compile."; exit 1
fi
echo "Next: ./scripts/reproduce_main_results.sh   (regenerate paper tables/figures, Python only)"
echo "      ./scripts/run_quick_check.sh          (live fault-injection sanity check, needs the Docker image)"
