# Expected outputs

## Files produced

| Command | Produces |
|---|---|
| `scripts/build.sh` | compiles every program (no files; prints per-program OK) |
| `scripts/reproduce_main_results.sh` | `results/processed/summary.csv`, `results/tables/{controlled_pairs,table5_applications}.{csv,tex}`, `results/figures/{controlled_pairs,applications}.{png,pdf}` |
| `scripts/run_quick_check.sh` | `results/reproduced/quick_check.csv` |
| `scripts/run_controlled_pairs.sh` | `results/reproduced/<program>.csv` |
| `scripts/run_applications.sh` | `results/reproduced/<program>.csv` |

## Expected numbers (from the included data)

`reproduce_main_results.sh` recomputes these from `results/raw_summary/`. They
match the paper.

### Controlled pairs (Section V)

| program | SDC% base→variant | z | significant |
|---|--:|--:|:--:|
| verdict_encoding | 14.3 → 1.1 | 11.1 | yes |
| loop_invariant | 35.2 → 30.4 | 2.3 | yes |
| branch_selection | 12.1 → 6.2 | 4.6 | yes |
| conditional_write | 37.0 → 21.9 | 7.4 | yes |
| bounded_lookup | 32.8 → 26.1 | 3.3 | yes |
| masked_accumulator | 25.2 → 21.0 | 2.2 | yes |

### Case studies (Table V)

| program | SDC% base→variant | z | significant |
|---|--:|--:|:--:|
| running_maximum | 8.5 → 1.7 | 6.9 | yes |
| dna_motif_search | 1.4 → 0.2 | 3.0 | yes |
| string_search | 2.9 → 1.5 | 2.1 | yes |
| dijkstra (N=5000) | 4.2 → 2.2 | 5.8 | yes |
| histogram | 30.3 → 20.7 | 4.9 | yes |
| transform_sum | 30.5 → 24.4 | 3.1 | yes |
| weighted_map | 32.7 → 29.0 | 1.8 | no |
| threshold_sum | 23.1 → 21.7 | 0.8 | no |
| record_scan (stacked) | 17.2 → 14.8 | 1.5 | no |
| blackscholes (FP scope boundary) | 17.1 → 15.9 | 0.7 | no |

Across the nine Table V rows the mean relative SDC reduction is 38.3% (the
headline figure in the abstract). Several individual reductions are not
significant on their own at n=1000; the paper's claim is the aggregate effect
plus the significant controlled and case-study results, not that every row
clears significance.

## Expected quick-check behaviour

`run_quick_check.sh` runs a tiny budget (default 80 injections/variant), so the
percentages carry large sampling noise. It should:

- complete all four runs with `status=OK`;
- print `verdict_encoding: base X% -> variant Y%` and
  `running_maximum: base X% -> variant Y%`, usually with the variant lower;
- print `QUICK CHECK PASSED`.

Because of the small budget a single run may occasionally show the variant equal
to or above the base; that is sampling noise, not a failure of the pipeline. Use
`--num-injections 1000` for a stable direction.
