#!/bin/bash
# ---------------------------------------------------------------------------
# verify_environment.sh -- report what is available and what each workflow needs.
# ---------------------------------------------------------------------------
HERE="$(cd "$(dirname "$0")/.." && pwd)"
echo "== environment check =="

ok=0
check() { if command -v "$1" >/dev/null 2>&1; then echo "  [ok]   $1  ($($1 --version 2>&1 | head -1))"; else echo "  [ --]  $1  not found"; fi; }
check python3
check g++
check clang++
check docker

echo
echo "== LLFI (fault injector) =="
LLFI_ROOT="${LLFI_ROOT:-/root/ws/llfi}"
if [ -x "$LLFI_ROOT/bin/instrument" ]; then
  echo "  [ok]   LLFI present at $LLFI_ROOT  (you are inside the container)"
else
  echo "  [ --]  LLFI not found at $LLFI_ROOT."
  echo "         Fault injection runs inside the Docker image; build it with:"
  echo "           bash docker/downloads/fetch.sh      # fetch LLVM/clang/LLFI sources"
  echo "           docker build -t anonymous-sdc-artifact ."
fi

echo
echo "== what each step needs =="
echo "  build.sh                    : a C++ compiler (g++/clang++)"
echo "  reproduce_main_results.sh   : python3  (matplotlib optional, for figures)"
echo "  run_quick_check.sh          : the LLFI Docker image"
echo "  run_controlled_pairs.sh /"
echo "  run_applications.sh         : the LLFI Docker image"

python3 -c "import matplotlib" 2>/dev/null \
  && echo "  matplotlib                  : installed (figures will render)" \
  || echo "  matplotlib                  : not installed (figures fall back to CSV; pip install matplotlib)"
