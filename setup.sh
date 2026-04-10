#!/bin/bash
set -e

echo "=== Claude Workflows Plugin Setup ==="
echo ""
echo "이 플러그인은 Claude Code 마켓플레이스를 통해 설치합니다."
echo ""
echo "Claude Code에서 실행:"
echo "  /plugin marketplace add bunnie198/claude-workflows"
echo "  /plugin install claude-workflows"
echo ""
echo "또는 로컬 개발 모드 (이 디렉토리를 직접 참조):"
echo "  /plugin install --path $(cd "$(dirname "$0")" && pwd)"
echo ""
echo "=== Setup complete ==="
