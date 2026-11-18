#!/usr/bin/env python3
"""Measure doc2vec retrieval quality against Qdrant: recall@k and MRR."""
import argparse, json, os, time, urllib.request

QDRANT = os.getenv("QDRANT_URL", "http://qdrant.automation.svc.cluster.local:6333")
EMBED = os.getenv("EMBED_URL", "http://qwen3-embedding.automation.svc.cluster.local:8080/v1")
MODEL = os.getenv("EMBED_MODEL", "qwen3-embedding")
INSTRUCT = "Instruct: Given a question, retrieve documentation passages that answer it\nQuery: "
K_VALUES = (1, 4, 10)


def post(url, body):
    request = urllib.request.Request(
        url, json.dumps(body).encode(), {"Content-Type": "application/json"}
    )
    with urllib.request.urlopen(request, timeout=150) as response:
        return json.load(response)


def norm(url):
    return url.split("#")[0].rstrip("/").lower()


def embed(text):
    return post(f"{EMBED}/embeddings", {"model": MODEL, "input": text})["data"][0]["embedding"]


def search(case, query, limit):
    product, version = case["product_name"], case.get("version", "latest")
    must = [
        {"key": "product_name", "match": {"value": product}},
        {"key": "version", "match": {"value": version}},
    ]
    body = {"query": embed(query), "limit": limit, "filter": {"must": must}, "with_payload": ["url"]}
    points = post(f"{QDRANT}/collections/{product}_{version}/points/query", body)["result"]["points"]
    return [(norm(p["payload"]["url"]), p["score"]) for p in points]


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("cases")
    parser.add_argument("--no-instruct", action="store_true", help="embed the bare question")
    args = parser.parse_args()
    cases = [json.loads(line) for line in open(args.cases) if line.strip()]

    ranks, started = [], time.time()
    for case in cases:
        query = case["query"] if args.no_instruct else INSTRUCT + case["query"]
        results = search(case, query, max(K_VALUES))
        relevant = {norm(url) for url in case["relevant_urls"]}
        rank = next((i for i, (url, _) in enumerate(results, 1) if url in relevant), None)
        ranks.append(rank)
        top_url, top_score = results[0]
        print(f"{'miss' if rank is None else f'#{rank:<3}'} {case['id']:<24} top={top_score:.3f} {top_url.split('/latest/')[-1]}")

    print(f"\ncases={len(cases)} seconds={time.time() - started:.1f} instruct={not args.no_instruct}")
    for k in K_VALUES:
        print(f"recall@{k:<2} {sum(r is not None and r <= k for r in ranks) / len(ranks):.3f}")
    print(f"MRR       {sum(1 / r for r in ranks if r) / len(ranks):.3f}")


if __name__ == "__main__":
    main()
