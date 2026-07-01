# Experiment mapping

This file ties every main result in the paper to the code, the raw result file,
and the command that reproduces it. Reviewers should not have to guess which
directory or CSV a number comes from.

Two conventions used throughout:

- **base** = the original / more-vulnerable implementation; **variant** = the
  same computation with one coding insight applied.
- Every raw count lives in `results/raw_summary/*.csv` (schema:
  `algorithm,impl,SDC,Crash,Benign,Hang,Total,DI_total_cycle,totalindex,status`).
  `scripts/aggregate_results.py` joins these with
  `data/benchmark_metadata/mapping.csv` to produce `results/processed/summary.csv`.

## The six coding insights (Section V, controlled pairs)

| Insight | Name | Source (base / variant) | Raw CSV rows | SDC% base→variant | z |
|--:|---|---|---|--:|--:|
| 1 | Exact predicate over truthy flag (verdict encoding) | `src/controlled_pairs/verdict_encoding/{base,variant}.cpp` | `FI_characterization_pool.csv`: `sm_01_naive`, `sm_02_naive_earlyexit` | 14.3 → 1.1 | 11.1 |
| 2 | Compute fixed values outside the loop (hoist) | `src/controlled_pairs/loop_invariant/{base,variant}.cpp` | `FI_ctrl.csv`: `ctrl_h_base`, `ctrl_h_prime` | 35.2 → 30.4 | 2.3 |
| 3 | Prefer a branch for value-preserving selection | `src/controlled_pairs/branch_selection/{base,variant}.cpp` | `FI_ctrl.csv`: `ctrl_b_prime` (branchless), `ctrl_b_base` (branch) | 12.1 → 6.2 | 4.6 |
| 4 | Write output state only when it changes | `src/controlled_pairs/conditional_write/{base,variant}.cpp` | `FI_round3.csv`: `cw_base`, `cw_prime` | 37.0 → 21.9 | 7.4 |
| 5 | Bounded lookup over wide arithmetic (table) | `src/controlled_pairs/bounded_lookup/{base,variant}.cpp` | `FI_ctrl.csv`: `ctrl_t_base`, `ctrl_t_prime` | 32.8 → 26.1 | 3.3 |
| 6 | Wide accumulator masking discarded bits | `src/controlled_pairs/masked_accumulator/{base,variant}.cpp` | `FI_round4.csv`: `hm_base`, `hm_prime` | 25.2 → 21.0 | 2.2 |

Replication of insights 1/2/3/5 on a second program (Section V, "Replication and
Scope") is in `results/raw_summary/FI_rep.csv` (`rep_v/h/b/t_{base,prime}`).

Regenerate this table:
```bash
python3 scripts/aggregate_results.py --input results/raw_summary --output results/processed
python3 scripts/generate_tables.py   --summary results/processed/summary.csv --output results/tables
cat results/tables/controlled_pairs.csv
```

## Case studies (paper Table V)

| Paper row | Insight | Source (base / variant) | Raw CSV rows | SDC% base→variant | DI base→variant |
|---|---|---|---|--:|---|
| Running maximum | 3 branch | `src/applications/running_maximum/` | `FI_evalbig.csv`: `ev_peak_base`, `ev_peak_res` | 8.5 → 1.7 | 7.4→6.7e8 |
| DNA motif search | 1 verdict | `src/applications/dna_motif_search/` | `FI_evalbig.csv`: `ev_dna_base`, `ev_dna_res` | 1.4 → 0.2 | 1.6→1.6e9 |
| String search | 1 verdict | `src/applications/string_search/` | `FI_evalbig.csv`: `b1_base`, `b1_res` | 2.9 → 1.5 | 1.1→1.2e9 |
| Dijkstra | 1 verdict | `src/applications/dijkstra/` | `FI_dj.csv`: `dj_flag`, `dj_inline` (N=5000) | 4.2 → 2.2 | 2.2→2.0e8 |
| Histogram | 5 table | `src/applications/histogram/` | `FI_evalbig.csv`: `b2_base`, `b2_res` | 30.3 → 20.7 | 7.5→7.5e8 |
| Transform sum | 5 table | `src/applications/transform_sum/` | `FI_evalbig.csv`: `ev_lut_base`, `ev_lut_res` | 30.5 → 24.4 | 7.5→7.3e8 |
| Weighted map | 2 hoist | `src/applications/weighted_map/` | `FI_evalbig.csv`: `ev_hoist_base`, `ev_hoist_res` | 32.7 → 29.0 | 7.5→7.1e8 |
| Threshold sum | 2 hoist | `src/applications/threshold_sum/` | `FI_evalbig.csv`: `b3_base`, `b3_res` | 23.1 → 21.7 | 7.8→7.4e8 |
| Record scan | stacked 1+2+5 | `src/applications/record_scan/` | `FI_stack.csv`: `rs_v0`, `rs_v3` | 17.2 → 14.8 | 2.3→2.3e8 |

The floating-point scope boundary discussed in Section VI (Blackscholes, not a
significant change) is `src/applications/blackscholes/`, rows `bs_base` /
`bs_branchless` in `FI_evalbig.csv` (17.1 vs 15.9, not significant).

Regenerate Table V:
```bash
python3 scripts/generate_tables.py --summary results/processed/summary.csv --output results/tables
cat results/tables/table5_applications.csv
```

## Characterization study (paper Table I and the SDC scatter)

The pool of 179 implementations across 10 algorithms is in
`results/raw_summary/FI_characterization_pool.csv`. Table I aggregates it by
algorithm (implementation count, median DI, SDC% range); the scatter shows the
within-algorithm SDC spread at controlled work.

## Reproducing with fresh injection

To re-run the injection for one experiment (needs the LLFI Docker image):
```bash
# one controlled pair, e.g. verdict encoding, 5000 injections, seed 2026
./scripts/run_controlled_pairs.sh --program verdict_encoding \
    --num-injections 5000 --seed 2026 --output-dir results/reproduced/verdict

# one application, e.g. running maximum
./scripts/run_applications.sh --program running_maximum \
    --num-injections 1000 --seed 2026 --output-dir results/reproduced/rmax

# then aggregate + tabulate the reproduced counts
python3 scripts/aggregate_results.py --input results/reproduced/verdict --output results/processed
```
A seeded re-run reproduces itself exactly; it agrees with the paper within the
sampling margin (~±3.1 pp at n=1000), and the base→variant direction is stable.
Absolute SDC% also depends on input size (`--size` / `--input`); see
`docs/fault_injection_protocol.md`.
