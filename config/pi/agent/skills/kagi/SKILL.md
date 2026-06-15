---
name: kagi
description: Use the local kagi-cli for Kagi search, news, smallweb, quick answers, assistant, translate, and subscriber summarization. Trigger when asked to use Kagi or kagi-cli.
---

# Kagi CLI

Use the installed `kagi` command.

Authentication is managed by `kagi-cli` itself, usually via local `./.kagi.toml` created by:

```bash
kagi auth
```

Do not print or inspect `.kagi.toml`; it may contain a session token. This repo ignores `.kagi.toml` so it should not be committed.

## Preferred no-API-billing commands

These commands use public endpoints or the Kagi subscriber/session path rather than API credits:

```bash
kagi news
kagi smallweb
kagi search "query"
kagi quick "question"
kagi assistant "prompt"
kagi translate "text" --to Korean
kagi summarize --subscriber --url https://example.com
```

## API-billed commands

Avoid these unless the user explicitly asks to use Kagi API credits/billing:

```bash
kagi extract ...
kagi fastgpt ...
kagi enrich ...
kagi summarize ...      # without --subscriber
```

If auth fails, suggest running:

```bash
kagi auth status
kagi auth
```
