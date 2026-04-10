#!/bin/bash
# bunnie-workflows 플러그인 구조 검증
# 사용: ./scripts/validate-structure.sh

set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

ERRORS=0
WARNINGS=0
CHECKS=0

pass() { CHECKS=$((CHECKS+1)); echo "  ✓ $1"; }
fail() { CHECKS=$((CHECKS+1)); ERRORS=$((ERRORS+1)); echo "  ✗ $1"; }
hint() { echo "    → $1"; }
warn() { CHECKS=$((CHECKS+1)); WARNINGS=$((WARNINGS+1)); echo "  ! $1"; }

# ─── 1. 필수 파일 존재 ───

echo "== 필수 파일 =="
for f in \
  CLAUDE.md README.md settings.json \
  .claude-plugin/plugin.json \
  .claude-plugin/marketplace.json \
  core/evolution-engine.md \
  core/strategy-schema.md \
  core/sync-rules.md
do
  if [ -f "$f" ]; then
    pass "$f"
  else
    fail "$f 없음"
    hint "이 파일은 플러그인 동작에 필수입니다."
  fi
done

# ─── 2. 스킬 프론트매터 ───

echo ""
echo "== 스킬 프론트매터 =="
for skill_dir in skills/*/; do
  [ -d "$skill_dir" ] || continue
  skill_file="${skill_dir}SKILL.md"
  skill_name=$(basename "$skill_dir")

  if [ ! -f "$skill_file" ]; then
    fail "$skill_name: SKILL.md 없음"
    hint "templates/skill-template.md를 복사하여 $skill_file 을 생성하세요."
    continue
  fi

  # YAML frontmatter에 name, description 필드 확인
  if head -10 "$skill_file" | grep -q "^name:"; then
    pass "$skill_name: name 필드"
  else
    fail "$skill_name: name 필드 없음"
    hint "SKILL.md 상단 YAML frontmatter에 name: $skill_name 을 추가하세요."
  fi

  if head -10 "$skill_file" | grep -q "^description:"; then
    pass "$skill_name: description 필드"
  else
    fail "$skill_name: description 필드 없음"
    hint "SKILL.md 상단 YAML frontmatter에 description: 을 추가하세요."
  fi

  # 스킬 유형 선언 (진화 스킬 또는 정적 스킬)
  if grep -q "유형.*스킬" "$skill_file"; then
    pass "$skill_name: 유형 선언"
  else
    fail "$skill_name: 유형 선언 없음"
    hint "SKILL.md 본문에 **유형:** 진화 스킬 또는 **유형:** 정적 스킬 을 추가하세요."
  fi
done

# ─── 3. 내부 경로 참조 무결성 ───

echo ""
echo "== 경로 참조 무결성 =="

for f in \
  CLAUDE.md README.md \
  skills/*/SKILL.md
do
  [ -f "$f" ] || continue

  refs=$(grep -oE '(core|strategy)/[a-zA-Z0-9_/.~-]+\.md' "$f" 2>/dev/null \
    | grep -v '\[' \
    | sort -u || true)

  for ref in $refs; do
    if [ -f "$ref" ]; then
      pass "$f -> $ref"
    else
      fail "$f -> $ref (파일 없음)"
      hint "$ref 파일을 생성하거나, $f 에서 경로를 수정하세요."
    fi
  done
done

# ─── 4. settings.json 권한 글롭 매칭 ───

echo ""
echo "== settings.json 권한 글롭 =="

set -f
globs=$(grep -oE 'Read\([^)]+\)' settings.json | sed 's/Read(//;s/)//')
for glob_pattern in $globs; do
  base_dir=$(echo "$glob_pattern" | cut -d'/' -f1)

  if [ -d "$base_dir" ]; then
    file_count=$(find "$base_dir" -type f 2>/dev/null | wc -l | tr -d ' ')
    if [ "$file_count" -gt 0 ]; then
      pass "Read($glob_pattern) -> ${file_count}개 파일 (in $base_dir/)"
    else
      fail "Read($glob_pattern) -> $base_dir/ 에 파일 없음"
      hint "$base_dir/ 디렉토리에 파일을 추가하거나, settings.json 권한을 수정하세요."
    fi
  else
    fail "Read($glob_pattern) -> 디렉토리 '$base_dir' 없음"
    hint "$base_dir/ 디렉토리를 생성하세요."
  fi
done
set +f

# ─── 5. Strategy 파일 스키마 검증 ───
# perspectives.md, patterns.md 만 검증 (번들, schema 등은 별도 형식)

echo ""
echo "== Strategy 파일 스키마 =="

for f in $(find strategy -name "perspectives.md" -o -name "patterns.md" 2>/dev/null); do
  fname=$(echo "$f" | sed 's|strategy/||')

  grep -q "^## 기본" "$f" \
    && pass "$fname: '기본' 섹션" \
    || warn "$fname: '기본' 섹션 없음"

  grep -q "^## 프로젝트 발견" "$f" \
    && pass "$fname: '프로젝트 발견' 섹션" \
    || warn "$fname: '프로젝트 발견' 섹션 없음"

  provenance_count=$(grep -c "^> 유래:" "$f" 2>/dev/null || true)
  provenance_count=${provenance_count:-0}
  if [ "$provenance_count" -gt 0 ]; then
    pass "$fname: 유래(provenance) ${provenance_count}건"
  fi
done

# ─── 6. 진화 스킬 ↔ strategy 연결 ───

echo ""
echo "== 진화 스킬 strategy 연결 =="

for skill_dir in skills/*/; do
  [ -d "$skill_dir" ] || continue
  skill_file="${skill_dir}SKILL.md"
  skill_name=$(basename "$skill_dir")

  [ -f "$skill_file" ] || continue

  if grep -q "진화 스킬" "$skill_file"; then
    strategy_refs=$(grep -oE 'strategy/[a-zA-Z0-9_/.-]+\.md' "$skill_file" \
      | grep -v '\[' | sort -u || true)

    if [ -n "$strategy_refs" ]; then
      for ref in $strategy_refs; do
        if [ -f "$ref" ]; then
          pass "$skill_name(진화) -> $ref"
        else
          fail "$skill_name(진화) -> $ref (strategy 파일 없음)"
          hint "strategy 파일을 생성하세요. templates/strategy-template.md를 참조."
        fi
      done
    else
      warn "$skill_name: 진화 스킬인데 strategy 파일 참조 없음"
    fi
  fi
done

# ─── 결과 ───

echo ""
echo "================================"
echo "  $CHECKS 검사, $ERRORS 오류, $WARNINGS 경고"
if [ "$ERRORS" -eq 0 ]; then
  echo "  PASS"
else
  echo "  FAIL"
fi
echo "================================"
exit "$ERRORS"
