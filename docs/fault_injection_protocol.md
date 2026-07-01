# Fault-injection protocol

## Tool and fault model

Injection uses **LLFI** on **LLVM/clang 3.4**. Each injected run flips **one
bit** in the destination register (the output value) of **one dynamically
executed LLVM IR instruction**, chosen uniformly among executed instructions.
Instruction types with no meaningful output-value target are excluded
(`ret`, `alloca`, `call`, `phi`). This is the single-bit-flip model described
in the paper.

Programs are compiled to IR at **`-O0`** (`clang++ -std=c++11 -O0
-fno-exceptions -fno-rtti`). `-O0` is deliberate: higher optimisation levels
normalise away some of the source-level distinctions under study. See the paper
for the discussion of what this does and does not let us claim.

## Per-run outcome classification

Each run is compared against the fault-free **golden** output:

| Outcome | Condition |
|---|---|
| **Benign** | terminates normally, output == golden |
| **SDC** | terminates normally, output != golden |
| **Crash** | LLFI error file reports a crash (e.g. SIGSEGV, nonzero exit) |
| **Hang** | does not finish within the timeout (default 8 s) |

`SDC probability = SDC / Total`. In the paper, Crash and Hang are reported
together as Crash/Hang. `scripts/fault_inject.sh` implements exactly this
classification and writes one CSV line per program.

## Injection count and confidence

The campaign uses **1000 injections per program** (5000 for Dijkstra, where the
gap under test is small). At n=1000 the single-proportion 95% margin of error is
about **±3.1 percentage points** (worst case p=0.5). `aggregate_results.py`
reports a per-row 95% half-width; `generate_tables.py` reports the
two-proportion z-statistic for each base/variant pair (|z| ≥ 1.96 is significant
at α=0.05).

## Seeds and reproducibility (please read)

LLFI can fix its injection-site RNG with `fi_random_seed` (see
`configs/fault_model/llfi_input.yaml`). **The campaign reported in the paper
left this unset**, using LLFI's default randomisation. Consequences:

- The paper's SDC probabilities are **statistical estimates**, good to the
  sampling margin above — they are not a deterministic fingerprint.
- The reproduction scripts here **do set `fi_random_seed`** (default 2026), so a
  reviewer's re-run is reproducible run-to-run. It will **not** match the paper
  bit-for-bit, but should agree within the margin, and the **base→variant
  direction and ordering are stable**.
- The input each program reads is produced by
  `data/inputs/generate_inputs.py` with a separate, fixed **input seed**
  (default 42), so base and variant of a pair always see the same input and the
  comparison is fair and portable across machines.

## Input size vs. absolute SDC%

Absolute SDC% depends on input size (a larger dynamic footprint dilutes the
per-instruction contribution). The `run_*` scripts use moderate default input
sizes so a pair finishes quickly and clearly shows the effect; the larger inputs
that reproduce the paper's exact dynamic instruction counts are noted in
`docs/experiment_mapping.md` and can be set with `--size` / `--input`. The
base-vs-variant comparison — the paper's actual claim — is stable across sizes.

## Known injector quirks (already handled)

- gcc-4.8's demangler returns NULL on some C++11 mangled names and can crash
  LLFI's instrument pass; `fault_inject.sh` renames only the names `c++filt`
  cannot demangle before instrumenting.
- A fault can send a program into an infinite loop; the timeout classifies such
  runs as Hang. Two of the case-study kernels cap their iteration counts so a
  corrupted loop bound cannot wedge the run indefinitely.
