---
name: grok-use
description: |-
    Call Grok Build via headless `grok -p` for codebase exploration or
    implementing an already-written plan (not open-ended design)
user-invocable: false
---

Use Grok only for these two jobs:

1. **Explore code** — map the repo, find symbols/files, trace flows, report how something works
2. **Implement an existing plan** — execute a design/PR plan/checklist that already exists; do not invent the plan

Do **not** delegate open-ended design, product choices, or "figure out what to build" to Grok. Write or refine the plan yourself first, then hand Grok the plan (or path to it) plus any constraints.

Grok does **not** provide MCP tools for this integration. Call the `grok` CLI with Bash.

## Fixed flags

Always use:

| Flag | Reason |
|------|--------|
| `--always-approve` | Unattended tool approval |
| `--output-format json` | Parse `text` + `sessionId` |

Do **not** pass `--sandbox` (full access). Do **not** add model/tools/rules/other flags unless the user explicitly requested them.

Use a large Bash timeout (at least **3600000** ms) for real tasks.

## New session

```bash
grok -p '<prompt>' --always-approve --output-format json
```

For multi-line prompts or special characters, write the prompt **verbatim** to a file and use:

```bash
grok --prompt-file /path/to/prompt.txt --always-approve --output-format json
```

Successful JSON includes:

- `text` — Grok's final response (show this to the user / use as the result)
- `sessionId` — **keep this**; required for every follow-up

Example parse:

```bash
RESULT=$(grok -p '...' --always-approve --output-format json)
echo "$RESULT" | jq -r '.text'
echo "$RESULT" | jq -r '.sessionId'
```

## Continue a session (no separate reply tool)

There is **no** separate reply API. To continue, pass the previous `sessionId`:

```bash
grok -p '<continued prompt>' --resume '<sessionId>' --always-approve --output-format json
```

Or with a prompt file:

```bash
grok --prompt-file /path/to/prompt.txt --resume '<sessionId>' --always-approve --output-format json
```

* Omitting `--resume` starts a **new** session and drops prior context.
* `--session-id` is **not** resume — it only names a brand-new UUID. Use `--resume` / `-r`.

## Rules

* **MUST NOT** modify the prompt: no expanding, refining, or adding requirements. Transparent forward only.
* **MUST** use `--output-format json` so `sessionId` is available.
* **MUST** use `--always-approve`.
* **MUST** preserve and reuse `sessionId` for continuations.
* Grok already loads `CLAUDE.md` / `AGENTS.md` (and related project rules). Do not paste those files into the prompt; do not restate content Grok will read itself.
* For implementation: include the plan content or absolute path in the prompt; prefer one clear task over micro-stepping without analysis.
* For exploration: ask a concrete question (area, symbol, behavior) rather than an unbounded tour.

## Errors

Non-zero exit or JSON `{"type":"error","message":"..."}`: surface the full error. Do not silently retry.
