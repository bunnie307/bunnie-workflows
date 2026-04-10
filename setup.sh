#!/bin/bash
set -e

PLUGIN_DIR="$(cd "$(dirname "$0")" && pwd)"
GLOBAL_RULES="$PLUGIN_DIR/global-rules.md"
TARGET="$HOME/.claude/CLAUDE.md"

echo "=== bunnie-workflows Setup ==="
echo ""

# 글로벌 규칙 설치
if [ -f "$GLOBAL_RULES" ]; then
  mkdir -p "$HOME/.claude"

  if [ -L "$TARGET" ]; then
    current=$(readlink "$TARGET")
    if [ "$current" = "$GLOBAL_RULES" ]; then
      echo "✓ 글로벌 규칙 이미 링크됨: $TARGET -> $GLOBAL_RULES"
    else
      echo "! $TARGET 이 다른 파일을 가리키고 있음: $current"
      echo "  덮어쓰려면: ln -sf \"$GLOBAL_RULES\" \"$TARGET\""
    fi
  elif [ -f "$TARGET" ]; then
    echo "! $TARGET 이 이미 존재함 (심볼릭 링크가 아님)"
    echo "  백업 후 링크하려면:"
    echo "    mv \"$TARGET\" \"$TARGET.bak\""
    echo "    ln -s \"$GLOBAL_RULES\" \"$TARGET\""
  else
    ln -s "$GLOBAL_RULES" "$TARGET"
    echo "✓ 글로벌 규칙 링크 완료: $TARGET -> $GLOBAL_RULES"
  fi
else
  echo "✗ global-rules.md 를 찾을 수 없음"
  exit 1
fi

echo ""
echo "=== Setup complete ==="
