# Applications (case studies)

Each subdirectory is a larger program from the Case Studies (paper Table V):
`base.cpp` is the original implementation and `variant.cpp` applies one coding
insight while holding the algorithm and input fixed. `record_scan` stacks three
insights (1, 2, 5) on one kernel; `blackscholes` is the floating-point scope
boundary where the branch insight washes out (not significant).

| Directory | Insight | Table V SDC% (base→variant) |
|---|---|--:|
| `running_maximum` | 3 branch | 8.5 → 1.7 |
| `dna_motif_search` | 1 verdict | 1.4 → 0.2 |
| `string_search` | 1 verdict | 2.9 → 1.5 |
| `dijkstra` | 1 verdict | 4.2 → 2.2 |
| `histogram` | 5 table | 30.3 → 20.7 |
| `transform_sum` | 5 table | 30.5 → 24.4 |
| `weighted_map` | 2 hoist | 32.7 → 29.0 |
| `threshold_sum` | 2 hoist | 23.1 → 21.7 |
| `record_scan` | stacked 1+2+5 | 17.2 → 14.8 |
| `blackscholes` | 3 branch (n.s.) | 17.1 → 15.9 |

`dijkstra` (MiBench) and `blackscholes` (PARSEC) are adapted from published
benchmark suites; the others are kernels written to exercise a pattern at scale.
Input formats and reproduction commands: `src/common/io_contract.md` and
`docs/experiment_mapping.md`.
