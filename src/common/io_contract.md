# I/O contract

Every program reads a single file named `numbers.txt` from its working
directory and prints a deterministic result (a value or a checksum) to stdout.
`scripts/fault_inject.sh` copies the chosen input to `numbers.txt` before each
run, captures stdout, and compares it against the fault-free golden output.

Input formats (produced by `data/inputs/generate_inputs.py`):

| Format | Layout of `numbers.txt` | Used by |
|---|---|---|
| `ints` | whitespace-separated integers in [1, 999999] | loop_invariant, branch_selection, bounded_lookup, masked_accumulator, conditional_write, histogram, transform_sum, weighted_map, threshold_sum, record_scan, running_maximum |
| `search` / `dna` | `m` then `m` pattern symbols then the text symbols | verdict_encoding, string_search, dna_motif_search |
| `dijkstra` | a `NUM_NODES × NUM_NODES` adjacency matrix (9999 = no edge) | dijkstra |
| `blackscholes` | `numOptions`, then one option tuple `s k r dq v t type ds dg` per line | blackscholes |

Determinism: all programs compute integer results or bit-level checksums of
their output, so the golden output is compiler-independent for every program
except `blackscholes` (floating point), which is the acknowledged
floating-point scope boundary in the paper.
