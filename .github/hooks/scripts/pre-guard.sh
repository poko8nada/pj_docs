#!/bin/bash

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$HOME/.local/share/pnpm:./node_modules/.bin:$PATH"

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.toolName')
TOOL_ARGS=$(echo "$INPUT" | jq -r '.toolArgs')
PROTECTED=".oxlintrc.json .oxfmtrc.json lefthook.yml"

contains_protected() {
  local str="$1"
  for p in $PROTECTED; do
    if echo "$str" | grep -qF "$p"; then
      return 0
    fi
  done
  return 1
}

case "$TOOL_NAME" in
  bash)
    if echo "$TOOL_ARGS" | grep -qF -- "--no-verify"; then
      echo '{"permissionDecision":"deny","permissionDecisionReason":"--no-verify is prohibited. Fix the code to pass pre-commit hooks."}'
      exit 0
    fi
    if contains_protected "$TOOL_ARGS"; then
      echo '{"permissionDecision":"deny","permissionDecisionReason":"Modifying protected config files via bash is prohibited."}'
      exit 0
    fi
    ;;
  edit|create|apply_patch)
    if contains_protected "$TOOL_ARGS"; then
      echo '{"permissionDecision":"deny","permissionDecisionReason":"BLOCKED: Protected config file cannot be modified. Fix the code, not the linter config."}'
      exit 0
    fi
    ;;
esac
