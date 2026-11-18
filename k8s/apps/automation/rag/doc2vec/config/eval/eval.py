#!/usr/bin/env python3
"""Measure doc2vec retrieval quality against Qdrant: recall@k and MRR."""
import argparse, json, os, time, urllib.request

QDRANT = os.getenv("QDRANT_URL", "http://qdrant.automation.svc.cluster.local:6333")
EMBED = os.getenv("EMBED_URL", "http://qwen3-embedding.automation.svc.cluster.local:8080/v1")
MODEL = os.getenv("EMBED_MODEL", "qwen3-embedding")
INSTRUCT = "Instruct: Given a question, retrieve documentation passages that answer it\nQuery: "
K_VALUES = (1, 4, 10)
# Same values as the doc2vec MCP server
CANDIDATE_DEPTH = 50
RRF_K = 60


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


def fuse(lists):
    """Reciprocal Rank Fusion, keyed on chunk and URL like the MCP server."""
    scores = {}
    for points in lists:
        for index, point in enumerate(points, 1):
            key = (point["payload"].get("chunk_id", point["id"]), point["payload"]["url"])
            scores[key] = scores.get(key, 0) + 1 / (RRF_K + index)
    return [(url, score) for (_, url), score in sorted(scores.items(), key=lambda item: -item[1])]


def one_per_page(results):
    seen, kept = set(), []
    for url, score in results:
        if norm(url) not in seen:
            seen.add(norm(url))
            kept.append((url, score))
    return kept


def search(case, query, limit, hybrid, per_page):
    product, version = case["product_name"], case.get("version", "latest")
    must = [
        {"key": "product_name", "match": {"value": product}},
        {"key": "version", "match": {"value": version}},
    ]
    depth = CANDIDATE_DEPTH if hybrid or per_page else limit
    common = {"limit": depth, "filter": {"must": must}, "with_payload": ["url", "chunk_id"]}
    endpoint = f"{QDRANT}/collections/{product}_{version}/points/query"
    dense = post(endpoint, {"query": embed(query), **common})["result"]["points"]
    if hybrid:
        keyword_query = {"query": {"text": query, "model": "qdrant/bm25"}, "using": "bm25"}
        keyword = post(endpoint, {**keyword_query, **common})["result"]["points"]
        results = fuse([dense, keyword])
    else:
        results = [(p["payload"]["url"], p["score"]) for p in dense]
    if per_page:
        results = one_per_page(results)
    return [(norm(url), score) for url, score in results[:limit]]


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("cases")
    parser.add_argument("--no-instruct", action="store_true", help="embed the bare question")
    parser.add_argument("--hybrid", action="store_true", help="fuse vector and BM25 results")
    parser.add_argument("--per-page", action="store_true", help="keep the best chunk of each page")
    args = parser.parse_args()
    cases = [json.loads(line) for line in open(args.cases) if line.strip()]

    ranks, started = [], time.time()
    for case in cases:
        query = case["query"] if args.no_instruct else INSTRUCT + case["query"]
        results = search(case, query, max(K_VALUES), args.hybrid, args.per_page)
        relevant = {norm(url) for url in case["relevant_urls"]}
        rank = next((i for i, (url, _) in enumerate(results, 1) if url in relevant), None)
        ranks.append(rank)
        top_url, top_score = results[0]
        print(f"{'miss' if rank is None else f'#{rank:<3}'} {case['id']:<24} top={top_score:.3f} {top_url.split('/latest/')[-1]}")

    print(
        f"\ncases={len(cases)} seconds={time.time() - started:.1f} instruct={not args.no_instruct}"
        f" hybrid={args.hybrid} per_page={args.per_page}"
    )
    for k in K_VALUES:
        print(f"recall@{k:<2} {sum(r is not None and r <= k for r in ranks) / len(ranks):.3f}")
    print(f"MRR       {sum(1 / r for r in ranks if r) / len(ranks):.3f}")


if __name__ == "__main__":
    main()
