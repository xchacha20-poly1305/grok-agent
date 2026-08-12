# grok-agent

Claude Code plugin that delegates **codebase exploration**, **implementing an already-written plan**, and **real-time search** (current events, X/Twitter, web) to [Grok Build](https://github.com/xai-org/grok-build) via headless `grok -p`.

This plugin does **not** use MCP. Continuations require a `sessionId` and `grok -p --resume <sessionId>`.

## Scope

| In scope | Out of scope |
|----------|----------------|
| Explore / map the codebase | Open-ended design or writing the plan |
| Implement an existing design/PR plan/checklist | Ambiguous "build something" without a plan |
| Real-time search (events, X/Twitter, web) | Pure conversation or review-only opinions |

The main agent should design and plan; use Grok to investigate the tree, execute a plan that already exists, or search for real-time information when your own results are insufficient.

## Prerequisites

- `grok` on your `PATH` (Grok Build CLI)
- Authenticated (`grok login` or `XAI_API_KEY`)

## Usage

```shell
claude plugin marketplace add https://github.com/xchacha20-poly1305/agent-plugins.git
claude plugin install grok-agent@anrong-plugins
claude "/grok-agent:setup-grok"
```

### Force Update

```shell
claude plugin marketplace update anrong-plugins
claude plugin remove grok-agent@anrong-plugins
claude plugin install grok-agent@anrong-plugins
```

## How it works

The main agent calls `grok -p` directly via the `grok-use` skill — no intermediate sub-agent. Use `run_in_background` for long-running tasks.

### New session

```bash
grok -p '<prompt>' --always-approve --output-format json
# keep .sessionId from the JSON
```

### Continue

```bash
grok -p '<prompt>' --resume '<sessionId>' --always-approve --output-format json
```

There is no separate reply tool. Omitting `--resume` starts a new session.

## Project rules

Grok loads `CLAUDE.md` / `AGENTS.md` (and related names) automatically. No Codex `config.toml` fallback is required.
