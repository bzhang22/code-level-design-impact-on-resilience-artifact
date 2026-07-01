#!/usr/bin/env python3
"""
Deterministic, portable input generator for the replication package.

Every program in this artifact reads a file named ``numbers.txt`` from its
working directory. The exact byte content of an input does not affect the
*comparison* between a base and its variant (both always read the same file);
it only shifts the absolute SDC probabilities. We therefore ship a portable
generator rather than large fixed input files: any reviewer, on any platform,
gets byte-identical inputs for a given (mode, size, seed), because Python's
Mersenne Twister is stable across versions and operating systems.

Modes
-----
  ints         plain whitespace-separated integers in [1, 999999]
               (loop_invariant, branch_selection, bounded_lookup,
                masked_accumulator, conditional_write, histogram,
                transform_sum, weighted_map, threshold_sum, record_scan,
                running_maximum)
  search       m, then m pattern symbols, then the text (verdict_encoding,
               string_search); --alphabet controls the symbol set
  dna          search input over a 4-symbol alphabet (dna_motif_search)
  dijkstra     a NUM_NODES x NUM_NODES adjacency matrix (dijkstra)
  blackscholes numOptions followed by one option tuple per line (blackscholes)

Examples
--------
  python3 generate_inputs.py --mode ints   --size 200000 --seed 42 --out numbers.txt
  python3 generate_inputs.py --mode search --size 50000  --seed 42 --out numbers.txt
  python3 generate_inputs.py --mode dna    --size 400000 --seed 42 --out numbers.txt
"""
import argparse
import random


def gen_ints(rng, size):
    return [rng.randint(1, 999999) for _ in range(size)]


def gen_search(rng, size, alphabet, m):
    # Small alphabet so partial matches occur and the verdict is exercised on a
    # hot per-position path; the pattern rarely matches in full, which is the
    # regime where the verdict-encoding insight applies.
    pattern = [rng.randint(0, alphabet - 1) for _ in range(m)]
    text = [rng.randint(0, alphabet - 1) for _ in range(size)]
    return [m] + pattern + text


def gen_dijkstra(rng, num_nodes, none_val=9999, density=0.35, max_cost=50):
    rows = []
    for i in range(num_nodes):
        row = []
        for j in range(num_nodes):
            if i == j:
                row.append(0)
            elif rng.random() < density:
                row.append(rng.randint(1, max_cost))
            else:
                row.append(none_val)
        rows.append(" ".join(str(v) for v in row))
    return rows


def gen_blackscholes(rng, num_options):
    lines = [str(num_options)]
    for _ in range(num_options):
        s = rng.uniform(1.0, 100.0)      # spot price
        k = rng.uniform(1.0, 100.0)      # strike
        r = rng.uniform(0.01, 0.10)      # rate
        dq = 0.0                         # dividend (unused by the kernel)
        v = rng.uniform(0.05, 0.60)      # volatility
        t = rng.uniform(0.1, 2.0)        # time
        tp = "P" if rng.random() < 0.5 else "C"
        lines.append("%.6f %.6f %.6f %.6f %.6f %.6f %s 0 0" % (s, k, r, dq, v, t, tp))
    return lines


def main():
    ap = argparse.ArgumentParser(description="Deterministic input generator.")
    ap.add_argument("--mode", required=True,
                    choices=["ints", "search", "dna", "dijkstra", "blackscholes"])
    ap.add_argument("--size", type=int, default=200000,
                    help="number of text/int elements (ignored for dijkstra: use --nodes)")
    ap.add_argument("--seed", type=int, default=42)
    ap.add_argument("--out", default="numbers.txt")
    ap.add_argument("--alphabet", type=int, default=6,
                    help="symbol-set size for search mode")
    ap.add_argument("--pattern-len", type=int, default=8, help="pattern length for search/dna")
    ap.add_argument("--nodes", type=int, default=100, help="node count for dijkstra")
    args = ap.parse_args()

    rng = random.Random(args.seed)

    if args.mode == "ints":
        toks = gen_ints(rng, args.size)
        body = " ".join(str(t) for t in toks) + "\n"
    elif args.mode == "search":
        toks = gen_search(rng, args.size, args.alphabet, args.pattern_len)
        body = " ".join(str(t) for t in toks) + "\n"
    elif args.mode == "dna":
        toks = gen_search(rng, args.size, 4, args.pattern_len)
        body = " ".join(str(t) for t in toks) + "\n"
    elif args.mode == "dijkstra":
        body = "\n".join(gen_dijkstra(rng, args.nodes)) + "\n"
    elif args.mode == "blackscholes":
        body = "\n".join(gen_blackscholes(rng, args.size)) + "\n"
    else:  # unreachable
        raise SystemExit("unknown mode")

    with open(args.out, "w") as fh:
        fh.write(body)
    print("wrote %s (mode=%s size=%d seed=%d)" % (args.out, args.mode, args.size, args.seed))


if __name__ == "__main__":
    main()
