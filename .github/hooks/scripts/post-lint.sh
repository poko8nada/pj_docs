#!/usr/bin/env bash
set -euo pipefail

export PATH="$HOME/.local/share/pnpm:$HOME/.nvm/versions/node/$(node --version 2>/dev/null || echo 'current')/bin:/usr/local/bin:/usr/bin:/bin:./node_modules/.bin:$PATH"

INPUT=$(cat)

TOOL_NAME=$(echo "$INPUT" | jq -r '.toolName // empty')

if [ "$TOOL_NAME" != "edit" ] && [ "$TOOL_NAME" != "create" ]; then
  exit 0
fi

FILE=$(echo "$INPUT" | jq -r '.toolArgs.path // empty' 2>/dev/null || echo "")

case "$FILE" in
  *.ts|*.tsx|*.js|*.jsx) ;;
  *) exit 0 ;;
esac

pnpm oxlint --fix "$FILE" >/dev/null 2>&1 || true
pnpm oxfmt "$FILE" >/dev/null 2>&1 || true
