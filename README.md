# grok-agent

Claude Code plugin that delegates **codebase exploration**, **implementing an already-written plan**, and **real-time search** (current events, X/Twitter, web) to [Grok Build](https://github.com/xai-org/grok-build) via headless `grok -p`.

> [!WARNING]
> This plugin disabled build-in explore and general use agent.

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

### Install

Add marketplace if not added.

```shell
claude plugin marketplace add https://github.com/xchacha20-poly1305/agent-plugins.git
```

Then install.

```
claude plugin install grok-agent@anrong-plugins
claude "/grok-agent:setup-grok"
```

### Update

```shell
claude plugin update grok-agent@anrong-plugins
```

<details>
<summary>Force Update</summary>

```shell
claude plugin marketplace update anrong-plugins
claude plugin remove grok-agent@anrong-plugins
claude plugin install grok-agent@anrong-plugins
```

</details>

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

## Enforcement

A skill is advisory — the model can still reach for a built-in sub-agent out of habit. This plugin ships a `PreToolUse` hook that **denies** `Task`/`Agent` calls with `subagent_type` of `Explore` or `general-purpose`, and tells the agent to use `grok-use` instead.

To opt out, set `GROK_AGENT_ALLOW_SUBAGENTS=1` in your environment (or in `settings.json` under `env`).

## Project rules

Grok loads `CLAUDE.md` / `AGENTS.md` (and related names) automatically. No Codex `config.toml` fallback is required.
