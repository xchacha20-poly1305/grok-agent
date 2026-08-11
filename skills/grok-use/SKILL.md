---
name: grok-use
description: |-
    Delegate codebase exploration or implementing an already-written plan to
    Grok Build via headless `grok -p`. Use this instead of doing the work
    yourself when the task is exploration or plan execution.

    In scope:
    - Explore / map code: locate files, trace call paths, summarize modules,
      answer "how does X work?" with repo evidence
    - Implement an existing plan: execute a design doc, PR plan, checklist, or
      step list that already exists — do not invent architecture

    Out of scope (do these yourself, not via Grok):
    - Open-ended design, product decisions, or writing the plan itself
    - Ambiguous tasks with no plan and no clear exploration question
    - Pure conversation, review-only opinions, or broad "fix everything"
      without a concrete plan

    Grok natively reads CLAUDE.md and AGENTS.md — do not paste project rules
    into the prompt. For implementation, pass the plan (or its path) and
    constraints; let Grok execute rather than micro-stepping.

    There is no MCP and no separate reply tool. Continuations require the
    session ID from the previous run (`--resume <sessionId>`).
user-invocable: true
---

Load this skill when you want Grok to do codebase exploration or execute an existing plan. **You call `grok` directly via Bash — there is no intermediate agent.**

Do **not** delegate open-ended design, product choices, or "figure out what to build" to Grok. Write or refine the plan yourself first, then hand Grok the plan (or path to it) plus any constraints.

Grok does **not** provide MCP tools. Call the `grok` CLI with Bash.

## Fixed flags

Always use:

| Flag | Reason |
|------|--------|
| `--always-approve` | Unattended tool approval |
| `--output-format json` | Machine-readable result with `text` + `sessionId` |

Do **not** pass `--sandbox` (full access). Do **not** add model/tools/rules/other flags unless the user explicitly requested them.

Use a large Bash timeout (at least **3600000** ms) for real tasks. For tasks that will take a while, prefer `run_in_background: true` so you stay unblocked — you will be notified when the command finishes.

## Handle JSON output (required)

`--output-format json` prints one object after completion. It can be **very large** (`text`, optional `thought`, `usage` / cost fields, pretty-printed). Treat it as a dump, not something to load into the agent context.

**Rules:**

1. **Always** redirect stdout to a file. Never leave the full JSON in the shell tool result; never `cat` / Read the whole dump.
2. Use **`jq`** against that file for only the fields you need.
3. Put the response body in its own file when you need it (`jq -r '.text'`).

```bash
OUT="$(mktemp "${TMPDIR:-/tmp}/grok-out.XXXXXX")"
TEXT="$(mktemp "${TMPDIR:-/tmp}/grok-text.XXXXXX")"

grok -p '...' --always-approve --output-format json >"$OUT"
status=$?

# errors: {"type":"error","message":"..."} (exit non-zero)
if [[ $status -ne 0 ]] || jq -e '.type == "error"' "$OUT" >/dev/null 2>&1; then
  jq -r '.message // .' "$OUT" >&2
  exit "${status:-1}"
fi

SESSION_ID=$(jq -r '.sessionId' "$OUT")
STOP=$(jq -r '.stopReason // empty' "$OUT")
jq -r '.text' "$OUT" >"$TEXT"

# Use SESSION_ID for --resume; read "$TEXT" (not "$OUT") for the reply body.
echo "sessionId=$SESSION_ID stopReason=$STOP text=$TEXT"
```
Useful `jq` extractions (run against the file path, do not pipe the whole dump through the agent):

| Need | Command |
|------|---------|
| Resume id | `jq -r '.sessionId' "$OUT"` |
| Stop reason | `jq -r '.stopReason' "$OUT"` (`end_turn`, `max_tokens`, …) |
| Reply body | `jq -r '.text' "$OUT" >"$TEXT"` then Read `"$TEXT"` if needed |
| Error | `jq -r 'select(.type=="error") \| .message' "$OUT"` |

Success shape (fields may include more; do not depend on loading them all):

```json
{
  "text": "...",
  "stopReason": "end_turn",
  "sessionId": "...",
  "requestId": "..."
}
```

## New session

```bash
grok -p '<prompt>' --always-approve --output-format json >"$OUT"
```

For multi-line prompts or special characters, write the prompt **verbatim** to a file and use:

```bash
grok --prompt-file /path/to/prompt.txt --always-approve --output-format json >"$OUT"
```

Then extract with `jq` as above. Keep `sessionId` for every follow-up.

## Continue a session (no separate reply tool)

There is **no** separate reply API. To continue, pass the previous `sessionId`:

```bash
grok -p '<continued prompt>' --resume '<sessionId>' --always-approve --output-format json >"$OUT"
```

Or with a prompt file:

```bash
grok --prompt-file /path/to/prompt.txt --resume '<sessionId>' --always-approve --output-format json >"$OUT"
```

* Omitting `--resume` starts a **new** session and drops prior context.
* `--session-id` is **not** resume — it only names a brand-new UUID. Use `--resume` / `-r`.

## Rules

* **MUST NOT** modify the prompt: no expanding, refining, or adding requirements. Transparent forward only.
* **MUST** use `--output-format json` so `sessionId` is available.
* **MUST** redirect that JSON to a file and use `jq` for keys; **MUST NOT** Read/cat the full dump.
* **MUST** use `--always-approve`.
* **MUST** preserve and reuse `sessionId` for continuations.
* Grok already loads `CLAUDE.md` / `AGENTS.md` (and related project rules). Do not paste those files into the prompt; do not restate content Grok will read itself.
* For implementation: include the plan content or absolute path in the prompt; prefer one clear task over micro-stepping without analysis.
* For exploration: ask a concrete question (area, symbol, behavior) rather than an unbounded tour.

## Errors

Non-zero exit or JSON `{"type":"error","message":"..."}`: surface `message` via `jq`. Do not silently retry. Do not dump the entire error file into context if only `message` is needed.
