#!/usr/bin/env bash
set -euo pipefail

export PATH="$HOME/.local/share/pnpm:$HOME/.nvm/versions/node/$(node --version 2>/dev/null || echo 'current')/bin:/usr/local/bin:/usr/bin:/bin:./node_modules/.bin:$PATH"

INPUT=$(cat)

# toolCalls配列の最初のエントリから取得
TOOL_NAME=$(echo "$INPUT" | jq -r '.toolCalls[0].name // empty')
TOOL_ARGS=$(echo "$INPUT" | jq -r '.toolCalls[0].args // empty')

if [ -z "$TOOL_NAME" ]; then
  exit 0
fi

# Block --no-verify
if [ "$TOOL_NAME" = "bash" ]; then
  COMMAND=$(echo "$TOOL_ARGS" | jq -r '.command // empty' 2>/dev/null || echo "$TOOL_ARGS")
  if echo "$COMMAND" | grep -q -- "--no-verify"; then
    jq -n '{
      permissionDecision: "deny",
      permissionDecisionReason: "--no-verify is prohibited. Fix the code to pass pre-commit hooks."
    }'
    exit 0
  fi
fi

# Block edits to protected config files
if [ "$TOOL_NAME" = "edit" ] || [ "$TOOL_NAME" = "create" ]; then
  FILE=$(echo "$TOOL_ARGS" | jq -r '.path // empty' 2>/dev/null || echo "")
  PROTECTED=".oxlintrc.json .oxfmtrc.json lefthook.yml"
  for p in $PROTECTED; do
    case "$FILE" in
      *"$p"*)
        jq -n --arg f "$FILE" '{
          permissionDecision: "deny",
          permissionDecisionReason: ("BLOCKED: " + $f + " is a protected config file. Fix the code, not the linter config.")
        }'
        exit 0
        ;;
    esac
  done
fi
