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

## 2. Ensure `jq`

`grok-use` redirects headless JSON to a file and extracts fields with `jq`. Require it on this machine:

```bash
command -v jq && jq --version
```

If `jq` is missing, install it (pick what fits the host), then re-check:

```bash
# Debian/Ubuntu
sudo apt-get update && sudo apt-get install -y jq

# Fedora
sudo dnf install -y jq

# Arch
sudo pacman -S --noconfirm jq

# macOS (Homebrew)
brew install jq
```

If install is not possible (no package manager / no privileges), stop and tell the user to install `jq` and put it on `PATH`. Do not continue without it.

## 3. Smoke test

Load the `grok-use` skill and run (redirect JSON; parse with `jq` — do not Read the dump):

```bash
OUT="$(mktemp "${TMPDIR:-/tmp}/grok-out.XXXXXX")"
grok -p 'Reply with exactly: Hello World' --always-approve --output-format json >"$OUT"
status=$?
jq -r '.sessionId // empty' "$OUT"
jq -r '.text // empty' "$OUT"
jq -r 'if .type == "error" then .message else empty end' "$OUT"
exit "$status"
```

Expect:

- exit code `0`
- non-empty `sessionId` from `jq`
- `text` containing `Hello World` (or equivalent)
- no `type: error`

If this fails (auth, network, binary error), stop and notify the user. Common fixes:

- `grok login` (browser or device code)
- or set `XAI_API_KEY` for headless auth

## 4. Done

Tell the user the plugin is ready. Delegate only:

- **explore code** or **implement an existing plan**
- background: agent `grok`
- foreground: skill `grok-use` + `grok -p`

Do not use Grok for open-ended design; plan first, then hand off implementation.
