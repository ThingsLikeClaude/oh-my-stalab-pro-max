#!/usr/bin/env bash
set -euo pipefail

# oh-my-stalab-pro-max installer
# Global install to ~/.claude/ — file-level merge, never overwrites custom files

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${HOME}/.claude"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  oh-my-stalab-pro-max installer"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 1. Check prerequisites
echo "[1/4] Checking prerequisites..."

# Check oh-my-stalab Harness (global)
MISSING_AGENTS=()
for agent in code-architect tdd-guide code-reviewer build-error-resolver code-simplifier; do
  if [ ! -f "$CLAUDE_DIR/agents/$agent.md" ]; then
    MISSING_AGENTS+=("$agent")
  fi
done

if [ ${#MISSING_AGENTS[@]} -gt 0 ]; then
  echo ""
  echo "  ERROR: oh-my-stalab-harness not installed."
  echo "  Missing agents: ${MISSING_AGENTS[*]}"
  echo ""
  echo "  Install harness first:"
  echo "    git clone https://github.com/ThingsLikeClaude/oh-my-stalab-harness.git"
  echo "    cd oh-my-stalab-harness && bash install.sh"
  echo ""
  read -p "  Continue anyway? (y/N) " -n 1 -r
  echo ""
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
  fi
else
  echo "  oh-my-stalab-harness: OK"
fi

# Check bkit plugin
if [ -d "$CLAUDE_DIR/plugins/marketplaces/bkit-marketplace" ] || [ -d "$HOME/.bkit" ]; then
  echo "  bkit plugin: OK"
else
  echo ""
  echo "  WARNING: bkit plugin not detected."
  echo "  Install: claude plugin add bkit"
  echo "  Or: https://github.com/popup-studio-ai/bkit-claude-code"
  echo ""
  read -p "  Continue anyway? (y/N) " -n 1 -r
  echo ""
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
  fi
fi

# 2. Detect OS
IS_WINDOWS=false
if [[ "$(uname -s)" == MINGW* ]] || [[ "$(uname -s)" == MSYS* ]]; then
  IS_WINDOWS=true
fi

# 3. File-level merge into ~/.claude/
echo ""
echo "[2/4] Installing to $CLAUDE_DIR (file-level merge)..."

INSTALLED=0
SKIPPED=0
CONFLICTS=()

install_file() {
  local src="$1" dst="$2"

  mkdir -p "$(dirname "$dst")"

  if [ ! -e "$dst" ]; then
    if [ "$IS_WINDOWS" = true ]; then
      cp "$src" "$dst"
    else
      ln -sf "$src" "$dst"
    fi
    INSTALLED=$((INSTALLED + 1))
    return
  fi

  # File exists — compare hashes
  local src_hash dst_hash
  src_hash=$(sha256sum "$src" 2>/dev/null | cut -d' ' -f1 || shasum -a 256 "$src" | cut -d' ' -f1)
  dst_hash=$(sha256sum "$dst" 2>/dev/null | cut -d' ' -f1 || shasum -a 256 "$dst" | cut -d' ' -f1)

  if [ "$src_hash" = "$dst_hash" ]; then
    SKIPPED=$((SKIPPED + 1))
    return
  fi

  # Conflict — backup then install
  local rel_path="${dst#$CLAUDE_DIR/}"
  CONFLICTS+=("$rel_path")
  cp "$dst" "$dst.backup-$(date +%Y%m%d-%H%M%S)"

  if [ "$IS_WINDOWS" = true ]; then
    cp "$src" "$dst"
  else
    ln -sf "$src" "$dst"
  fi
  INSTALLED=$((INSTALLED + 1))
}

# Install agents
for f in "$REPO_DIR"/agents/*.md; do
  [ -f "$f" ] || continue
  install_file "$f" "$CLAUDE_DIR/agents/$(basename "$f")"
done

# Install commands
for f in "$REPO_DIR"/commands/*.md; do
  [ -f "$f" ] || continue
  install_file "$f" "$CLAUDE_DIR/commands/$(basename "$f")"
done

# Install rules
for f in "$REPO_DIR"/rules/*.md; do
  [ -f "$f" ] || continue
  install_file "$f" "$CLAUDE_DIR/rules/$(basename "$f")"
done

echo "  Installed: $INSTALLED files"
echo "  Skipped (identical): $SKIPPED files"

if [ ${#CONFLICTS[@]} -gt 0 ]; then
  echo ""
  echo "  CONFLICTS (originals backed up with .backup-* suffix):"
  for c in "${CONFLICTS[@]}"; do
    echo "    ~/.claude/$c"
  done
fi

# 4. Summary
echo ""
echo "[3/4] Installed components:"
echo "  ~/.claude/agents/pm-agent.md"
echo "  ~/.claude/agents/test-designer.md"
echo "  ~/.claude/agents/verification-orchestrator.md"
echo "  ~/.claude/commands/oms-pro-max.md"
echo "  ~/.claude/rules/response-language.md"

echo ""
echo "[4/4] Note: CLAUDE.md is NOT auto-installed globally."
echo "  Pro-max pipeline rules live in the command itself."
echo "  .pipeline/ is created per-project when you run /oms-pro-max."

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Installation complete!"
echo ""
echo "  Installed: $INSTALLED | Skipped: $SKIPPED | Conflicts: ${#CONFLICTS[@]}"
echo ""
echo "  Usage (in any project):"
echo "    /oms-pro-max \"feature description\""
echo ""
if [ "$IS_WINDOWS" = false ]; then
  echo "  Update: git pull (symlinks auto-reflect)"
fi
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
