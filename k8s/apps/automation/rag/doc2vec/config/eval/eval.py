#!/usr/bin/env python3
"""Measure doc2vec retrieval quality against Qdrant: recall@k and MRR."""
import argparse, json, os, time, urllib.request

QDRANT = os.getenv("QDRANT_URL", "http://qdrant.automation.svc.cluster.local:6333")
EMBED = os.getenv("EMBED_URL", "http://qwen3-embedding.automation.svc.cluster.local:8080/v1")
MODEL = os.getenv("EMBED_MODEL", "qwen3-embedding")
# The llm gateway's rerank route; the key is the gateway key doc2vec uses (doc2vec-mcp-secret)
RERANK_URL = os.getenv("RERANK_URL", "http://llm.automation.svc.cluster.local/v1/rerank")
INSTRUCT = "Instruct: Given a question, retrieve documentation passages that answer it\nQuery: "
K_VALUES = (1, 4, 10)
# Same values as the doc2vec MCP server
CANDIDATE_DEPTH = 50
RRF_K = 60
RERANK_CANDIDATES = 40


def post(url, body, headers=None):
    request = urllib.request.Request(
        url, json.dumps(body).encode(), {"Content-Type": "application/json", **(headers or {})}
    )
    with urllib.request.urlopen(request, timeout=150) as response:
        return json.load(response)


def norm(url):
    return url.split("#")[0].rstrip("/").lower()


def embed(text):
    return post(f"{EMBED}/embeddings", {"model": MODEL, "input": text})["data"][0]["embedding"]


def fuse(lists):
    """Reciprocal Rank Fusion, keyed on chunk and URL like the MCP server."""
    scores, contents = {}, {}
    for points in lists:
        for index, point in enumerate(points, 1):
            key = (point["payload"].get("chunk_id", point["id"]), point["payload"]["url"])
            scores[key] = scores.get(key, 0) + 1 / (RRF_K + index)
            contents[key] = point["payload"].get("content", "")
    return [(url, score, contents[(chunk, url)]) for (chunk, url), score in sorted(scores.items(), key=lambda item: -item[1])]


def rerank(model, query, results):
    """Rerank the top candidates by their text, like the MCP server (RERANKER=openrouter)."""
    pool = results[:RERANK_CANDIDATES]
    body = post(
        RERANK_URL,
        {"model": model, "query": query, "documents": [content for _, _, content in pool], "top_n": len(pool)},
        {"Authorization": f"Bearer {os.environ['OPENROUTER_API_KEY']}"},
    )
    scores = {result["index"]: result["relevance_score"] for result in body["results"]}
    reranked = sorted(((url, scores[i], content) for i, (url, _, content) in enumerate(pool)), key=lambda item: -item[1])
    return reranked + results[RERANK_CANDIDATES:]


def one_per_page(results):
    seen, kept = set(), []
    for url, score, content in results:
        if norm(url) not in seen:
            seen.add(norm(url))
            kept.append((url, score, content))
    return kept


def search(case, query, limit, hybrid, per_page, rerank_model):
    product, version = case["product_name"], case.get("version", "latest")
    must = [
        {"key": "product_name", "match": {"value": product}},
        {"key": "version", "match": {"value": version}},
    ]
    depth = max(CANDIDATE_DEPTH if hybrid or per_page else limit, RERANK_CANDIDATES if rerank_model else 0)
    common = {"limit": depth, "filter": {"must": must}, "with_payload": ["url", "chunk_id", "content"]}
    endpoint = f"{QDRANT}/collections/{product}_{version}/points/query"
    dense = post(endpoint, {"query": embed(query), **common})["result"]["points"]
    if hybrid:
        keyword_query = {"query": {"text": query, "model": "qdrant/bm25"}, "using": "bm25"}
        keyword = post(endpoint, {**keyword_query, **common})["result"]["points"]
        results = fuse([dense, keyword])
    else:
        results = [(p["payload"]["url"], p["score"], p["payload"].get("content", "")) for p in dense]
    if rerank_model:
        results = rerank(rerank_model, query, results)
    if per_page:
        results = one_per_page(results)
    return [(norm(url), score) for url, score, _ in results[:limit]]


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("cases")
    parser.add_argument("--no-instruct", action="store_true", help="embed the bare question")
    parser.add_argument("--hybrid", action="store_true", help="fuse vector and BM25 results")
    parser.add_argument("--per-page", action="store_true", help="keep the best chunk of each page")
    parser.add_argument("--rerank", metavar="MODEL", help="rerank the top candidates through the llm gateway (needs OPENROUTER_API_KEY)")
    args = parser.parse_args()
    cases = [json.loads(line) for line in open(args.cases) if line.strip()]

    ranks, started = [], time.time()
    for case in cases:
        query = case["query"] if args.no_instruct else INSTRUCT + case["query"]
        results = search(case, query, max(K_VALUES), args.hybrid, args.per_page, args.rerank)
        relevant = {norm(url) for url in case["relevant_urls"]}
        rank = next((i for i, (url, _) in enumerate(results, 1) if url in relevant), None)
        ranks.append(rank)
        top_url, top_score = results[0]
        print(f"{'miss' if rank is None else f'#{rank:<3}'} {case['id']:<24} top={top_score:.3f} {top_url.split('/latest/')[-1]}")

    print(
        f"\ncases={len(cases)} seconds={time.time() - started:.1f} instruct={not args.no_instruct}"
        f" hybrid={args.hybrid} per_page={args.per_page} rerank={args.rerank}"
    )
    for k in K_VALUES:
        print(f"recall@{k:<2} {sum(r is not None and r <= k for r in ranks) / len(ranks):.3f}")
    print(f"MRR       {sum(1 / r for r in ranks if r) / len(ranks):.3f}")


if __name__ == "__main__":
    main()
