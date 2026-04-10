#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== Claude Workflows Setup ==="

# 1. 글로벌 CLAUDE.md 심볼릭 링크
mkdir -p ~/.claude
if [ -f ~/.claude/CLAUDE.md ] && [ ! -L ~/.claude/CLAUDE.md ]; then
  echo "기존 ~/.claude/CLAUDE.md 발견. 백업: ~/.claude/CLAUDE.md.backup"
  cp ~/.claude/CLAUDE.md ~/.claude/CLAUDE.md.backup
fi
ln -sf "$SCRIPT_DIR/CLAUDE.md" ~/.claude/CLAUDE.md
echo "✓ ~/.claude/CLAUDE.md → $SCRIPT_DIR/CLAUDE.md"

# 2. 환경변수 설정 안내
echo ""
echo "셸 프로필에 추가하세요:"
echo "  export CLAUDE_WORKFLOWS_DIR=\"$SCRIPT_DIR\""
echo ""

# 3. 스킬 등록 안내
echo "Claude Code에서 스킬을 사용하려면:"
echo "  /skills 에서 $SCRIPT_DIR/skills/ 경로 등록"
echo ""

echo "=== Setup complete ==="
