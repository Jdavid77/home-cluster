---
name: docs-search
description: Answer questions about third-party tools and products from the documentation indexed by doc2vec (currently agentgateway and llmkube). Use whenever the user asks how to configure, use or troubleshoot one of those products, or asks to search the docs.
---

# Docs search (doc2vec)

Search the indexed docs with the `doc2vec_query_documentation` MCP tool (served by the MCP gateway, e.g. `mcp__test-mcp__doc2vec_query_documentation`). If the tool is deferred, load it with ToolSearch first.

## Picking the product

Docs are indexed with `product_name` = the product's lowercase name and `version` = `latest`, and productName + version select the collection. So:

- productName: the product the question is about, lowercase (e.g. `agentgateway`)
- version: `latest`

If the tool returns `Not Found`, that product isn't indexed. Say so and answer from other sources only if the user agrees; don't keep guessing names.

## Querying

- `queryText` for questions: `"Instruct: Given a question, retrieve documentation passages that answer it\nQuery: <question>"`. The embedding model (Qwen3-Embedding) retrieves noticeably worse without this prefix.
- For a bare field, CRD or term lookup, pass the term alone.
- `limit`: 6 for how-to questions, 4 for exact lookups. Results are reranked, so the right page is nearly always in the top 4 (eval: 100% at 4, 87% at 1). Docs sites repeat sections across pages, so results can include duplicates.
- One topic per query; run several queries for multi-part questions.
- If results are mostly general overview pages, search again with the product's own term for the feature (e.g. "failover" rather than "fall back when a provider fails").
- Search returns only the best chunk of each page. To read more of a page (e.g. a complete YAML example), call `doc2vec_get_chunks` with `filePath` set to the result's URL, plus the same `productName` and `version`. Use `startIndex` and `endIndex` (0-based) to limit long pages.

## Answering

- Treat snippets with the same body as one result, ignoring the `[Topic: ...]` line and headings. Use the highest-scoring copy and reference its URL.
- Base the answer on the best 6 distinct passages at most.
- Answer only from the returned snippets.
- Never put URLs in the body of the answer. Mark each claim with a plain-text numbered reference such as `[Link 1]`, reusing the number when citing the same page again.
- End with a `## References` section that lists each referenced page, one per line, as `[Link 1] [Page name](URL)`.
- Results come ordered by "Relevance" (the reranker's score); "Distance" is the vector similarity before reranking. Higher is better for both, but use them only to order results: unrelated passages can still score high, so judge relevance from the text. If results show only "Distance", reranking failed and the order is plain vector search.
- If the snippets don't cover the question, say so instead of answering from memory.
