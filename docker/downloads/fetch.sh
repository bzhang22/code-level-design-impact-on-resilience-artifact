#!/bin/bash
# Fetch the third-party source archives needed to build the LLFI toolchain image.
# Run this on the HOST (which has a modern TLS stack) before `docker build`.
#
# These are standard, publicly released sources of third-party tools (the LLVM
# project and the LLFI fault injector); they are not part of the authors' work
# and are downloaded here only so the Docker build is self-contained. They are
# intentionally not committed to this repository to keep it small.
set -eu
cd "$(dirname "$0")"

fetch() {  # url  outfile
  if [ -s "$2" ]; then echo "already present: $2"; return; fi
  echo "downloading $2 ..."
  if command -v curl >/dev/null 2>&1; then curl -fL "$1" -o "$2";
  elif command -v wget >/dev/null 2>&1; then wget -O "$2" "$1";
  else echo "need curl or wget"; exit 1; fi
}

fetch "https://releases.llvm.org/3.4/llvm-3.4.src.tar.gz"  llvm-3.4.src.tar.gz
fetch "https://releases.llvm.org/3.4/clang-3.4.src.tar.gz" clang-3.4.src.tar.gz
# LLFI (LLVM 3.4 branch), the standard open-source fault injector used in the study.
fetch "https://codeload.github.com/DependableSystemsLab/LLFI/zip/refs/heads/master" LLFI-master.zip

echo
echo "Fetched:"
ls -la *.tar.gz *.zip 2>/dev/null
echo
echo "If any download fails (mirrors move), place the three archives here manually:"
echo "  llvm-3.4.src.tar.gz  clang-3.4.src.tar.gz  LLFI-master.zip"
echo "then run: docker build -t anonymous-sdc-artifact ."
