#!/usr/bin/env bash
# PreToolUse hook: block built-in subagents whose job the grok-use skill already covers.
# Escape hatch: set GROK_AGENT_ALLOW_SUBAGENTS=1 to disable this hook.
set -euo pipefail

if [[ "${GROK_AGENT_ALLOW_SUBAGENTS:-}" == "1" ]]; then
  exit 0
fi

input=$(cat)

subagent=$(printf '%s' "$input" | jq -r '.tool_input.subagent_type // empty')

# Subagent types that overlap with grok-use's in-scope work (exploration / search).
case "$subagent" in
  Explore | general-purpose) ;;
  *) exit 0 ;;
esac

reason="Blocked by the grok-agent plugin: the '${subagent}' subagent duplicates work the grok-use skill should handle. Invoke the grok-agent:grok-use skill and delegate to the grok CLI instead. If the user explicitly asked for a built-in subagent, tell them this hook blocked it and that GROK_AGENT_ALLOW_SUBAGENTS=1 disables it."

jq -n --arg reason "$reason" '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    permissionDecision: "deny",
    permissionDecisionReason: $reason
  }
}'
