#!/usr/bin/env bash
set -euo pipefail

# oh-my-stalab-pro-max installer
# Copies pipeline-specific .claude/ files into the target project

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="${1:-.}"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  oh-my-stalab-pro-max installer"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check prerequisites
echo "[1/4] Checking prerequisites..."

# Check oh-my-stalab Harness (global)
MISSING_AGENTS=()
for agent in code-architect tdd-guide code-reviewer build-error-resolver code-simplifier; do
  if [ ! -f "$HOME/.claude/agents/$agent.md" ]; then
    MISSING_AGENTS+=("$agent")
  fi
done

if [ ${#MISSING_AGENTS[@]} -gt 0 ]; then
  echo "WARNING: oh-my-stalab Harness agents not found in ~/.claude/agents/:"
  for a in "${MISSING_AGENTS[@]}"; do echo "  - $a.md"; done
  echo ""
  echo "oh-my-stalab-pro-max requires oh-my-stalab Harness installed globally."
  echo "Install it first, then re-run this script."
  echo ""
  read -p "Continue anyway? (y/N) " -n 1 -r
  echo ""
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
  fi
fi

# Check bkit plugin
if [ -d "$HOME/.claude/plugins/marketplaces/bkit-marketplace" ]; then
  echo "  bkit plugin: OK"
elif [ -d "$HOME/.bkit" ]; then
  echo "  bkit plugin: OK (detected via .bkit/)"
else
  echo "WARNING: bkit plugin not detected."
  echo "Install with: claude plugin add bkit"
  echo "Or visit: https://github.com/popup-studio-ai/bkit-claude-code"
  echo ""
  read -p "Continue anyway? (y/N) " -n 1 -r
  echo ""
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
  fi
fi

# Create target directories
echo "[2/4] Creating directories..."
mkdir -p "$TARGET_DIR/.claude/agents"
mkdir -p "$TARGET_DIR/.claude/commands"
mkdir -p "$TARGET_DIR/.claude/rules"

# Link or copy files
echo "[3/4] Installing oh-my-stalab-pro-max files..."

IS_WINDOWS=false
if [[ "$(uname -s)" == MINGW* ]] || [[ "$(uname -s)" == MSYS* ]] || [[ -n "${WSLENV:-}" ]]; then
  IS_WINDOWS=true
fi

link_or_copy() {
  local src="$1" dst="$2"
  if [ "$IS_WINDOWS" = true ]; then
    cp "$src" "$dst"
  else
    ln -sf "$src" "$dst"
  fi
}

link_or_copy "$SCRIPT_DIR/agents/pm-agent.md" "$TARGET_DIR/.claude/agents/pm-agent.md"
link_or_copy "$SCRIPT_DIR/agents/test-designer.md" "$TARGET_DIR/.claude/agents/test-designer.md"
link_or_copy "$SCRIPT_DIR/agents/verification-orchestrator.md" "$TARGET_DIR/.claude/agents/verification-orchestrator.md"
link_or_copy "$SCRIPT_DIR/commands/oms-pro-max.md" "$TARGET_DIR/.claude/commands/oms-pro-max.md"
link_or_copy "$SCRIPT_DIR/rules/response-language.md" "$TARGET_DIR/.claude/rules/response-language.md"

# Handle CLAUDE.md
echo "[4/4] Setting up CLAUDE.md..."
if [ -f "$TARGET_DIR/CLAUDE.md" ]; then
  echo "  CLAUDE.md already exists. Appending oh-my-stalab-pro-max rules..."
  echo "" >> "$TARGET_DIR/CLAUDE.md"
  echo "# --- oh-my-stalab-pro-max rules (auto-appended) ---" >> "$TARGET_DIR/CLAUDE.md"
  echo "" >> "$TARGET_DIR/CLAUDE.md"
  cat "$SCRIPT_DIR/CLAUDE.md" >> "$TARGET_DIR/CLAUDE.md"
  echo "  Appended to existing CLAUDE.md. Review and deduplicate if needed."
else
  cp "$SCRIPT_DIR/CLAUDE.md" "$TARGET_DIR/CLAUDE.md"
  echo "  Created CLAUDE.md"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Installation complete!"
echo ""
echo "  Installed to: $TARGET_DIR"
echo ""
echo "  Files:"
echo "    .claude/agents/pm-agent.md"
echo "    .claude/agents/test-designer.md"
echo "    .claude/agents/verification-orchestrator.md"
echo "    .claude/commands/oms-pro-max.md"
echo "    .claude/rules/response-language.md"
echo "    CLAUDE.md"
echo ""
echo "  Usage:"
echo "    /oms-pro-max \"feature description\""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
