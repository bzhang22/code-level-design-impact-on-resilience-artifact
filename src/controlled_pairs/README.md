# Controlled pairs

Each subdirectory is one controlled single-difference experiment from Section V:
`base.cpp` and `variant.cpp` compute the **same output** and differ in **one**
source-level choice — the coding insight. Both read the same `numbers.txt`, so a
difference in SDC probability isolates that one choice.

| Directory | Insight | base → variant | SDC% (base→variant), z |
|---|---|---|---|
| `verdict_encoding` | 1 | truthy flag → exact-count predicate | 14.3 → 1.1, z=11.1 |
| `loop_invariant` | 2 | recompute in loop → hoist out of loop | 35.2 → 30.4, z=2.3 |
| `branch_selection` | 3 | branchless arithmetic max → branch max | 12.1 → 6.2, z=4.6 |
| `conditional_write` | 4 | write both slots every step → write only on swap | 37.0 → 21.9, z=7.4 |
| `bounded_lookup` | 5 | wide `(r*r)%97` chain → 256-entry table | 32.8 → 26.1, z=3.3 |
| `masked_accumulator` | 6 | 8-bit accumulator → 64-bit, masked at end | 25.2 → 21.0, z=2.2 |

Numbers and raw CSV locations: `docs/experiment_mapping.md`.

Note on `verdict_encoding`: `base.cpp`/`variant.cpp` are the two naive
substring searches (`sm_01`, `sm_02`) whose measured SDC is 14.3% vs 1.1% at
essentially identical dynamic instruction count (5.07e7 vs 5.03e7). The variant
uses an exact `j == m` predicate; on this input the inner loop rarely exits
early, so both effectively scan the full window, isolating the verdict
representation as the paper describes.
