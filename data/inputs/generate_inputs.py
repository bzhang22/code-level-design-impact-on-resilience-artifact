#!/usr/bin/env python3
import argparse
import random


def gen_ints(rng, size):
    return [rng.randint(1, 999999) for _ in range(size)]


def gen_search(rng, size, alphabet, m):
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
        s = rng.uniform(1.0, 100.0)
        k = rng.uniform(1.0, 100.0)
        r = rng.uniform(0.01, 0.10)
        dq = 0.0
        v = rng.uniform(0.05, 0.60)
        t = rng.uniform(0.1, 2.0)
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
    else:
        raise SystemExit("unknown mode")

    with open(args.out, "w") as fh:
        fh.write(body)
    print("wrote %s (mode=%s size=%d seed=%d)" % (args.out, args.mode, args.size, args.seed))


if __name__ == "__main__":
    main()
