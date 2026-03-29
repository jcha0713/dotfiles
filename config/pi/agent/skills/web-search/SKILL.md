---
name: web-search
description: Manually trigger a web search using SearXNG. Use when the user wants to search the web for information.
disable-model-invocation: true
---

# Web Search

Trigger a web search manually using the SearXNG instance.

## When triggered

When this skill is invoked via `/skill:web-search` or the skills menu:

1. Ask the user what they want to search for (if not provided)
2. Use the `web_search` tool to perform the search
3. Present the results to the user

## Tool usage

Use the `web_search` tool with:

- `query`: The search query
- `limit` (optional): Number of results (default: 10)

## Example

User: "/skill:web-search"
→ Ask: "What would you like to search for?"
→ Call web_search tool with their query
→ Display results
