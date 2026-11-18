---
name: docs-search
description: Answer questions about third-party tools and products from the documentation indexed by doc2vec (currently agentgateway). Use whenever the user asks how to configure, use or troubleshoot one of those products, or asks to search the docs.
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
- `limit`: 15 for how-to questions, 6 for exact lookups. Docs sites repeat sections across pages, so results include duplicates.
- One topic per query; run several queries for multi-part questions.
- To pull a full page (e.g. a complete YAML example), re-query with `urlPathPrefix` set to that page's URL.

## Answering

- Treat snippets with the same body as one result, ignoring the `[Topic: ...]` line and headings. Use the highest-scoring copy and cite its URL.
- Base the answer on the best 8 distinct passages at most.
- Answer only from the returned snippets and cite their URLs.
- The "Distance" in results is a similarity score: higher is better, below ~0.4 is usually noise.
- If the snippets don't cover the question, say so instead of answering from memory.
