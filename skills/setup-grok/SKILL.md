---
name: setup-grok
description: Setup grok-agent plugin
disable-model-invocation: true
---

# grok-agent setup

## 1. Check the CLI

```bash
command -v grok
grok --version
```

If `grok` is missing, stop and tell the user to install Grok Build and ensure it is on `PATH`.

## 2. Smoke test

Load the `grok-use` skill and run:

```bash
grok -p 'Reply with exactly: Hello World' --always-approve --output-format json
```

Expect:

- exit code `0`
- JSON with `text` containing `Hello World` (or equivalent)
- a non-empty `sessionId`

If this fails (auth, network, binary error), stop and notify the user. Common fixes:

- `grok login` (browser or device code)
- or set `XAI_API_KEY` for headless auth

## 3. Project docs

No Codex-style config is required. Grok natively loads project rules such as `CLAUDE.md` and `AGENTS.md`. You do **not** need `project_doc_fallback_filenames` or edits under `~/.codex/`.

## 4. Done

Tell the user the plugin is ready. Delegate only:

- **explore code** or **implement an existing plan**
- background: agent `grok`
- foreground: skill `grok-use` + `grok -p`

Do not use Grok for open-ended design; plan first, then hand off implementation.
