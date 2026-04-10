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
  [ -f "$f" ] && pass "$f" || fail "$f 없음"
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
    continue
  fi

  # YAML frontmatter에 name, description 필드 확인
  head -10 "$skill_file" | grep -q "^name:" \
    && pass "$skill_name: name 필드" \
    || fail "$skill_name: name 필드 없음"

  head -10 "$skill_file" | grep -q "^description:" \
    && pass "$skill_name: description 필드" \
    || fail "$skill_name: description 필드 없음"

  # 스킬 유형 선언 (진화 스킬 또는 정적 스킬)
  grep -q "유형.*스킬" "$skill_file" \
    && pass "$skill_name: 유형 선언" \
    || fail "$skill_name: 유형 선언 없음 (진화/정적 스킬 표기 필요)"
done

# ─── 3. 내부 경로 참조 무결성 ───

echo ""
echo "== 경로 참조 무결성 =="

# 검증 대상: core/, strategy/, templates/ 이외의 .md 파일에서 이들을 참조할 때
# 플레이스홀더([domain] 등)가 포함된 경로는 제외
for f in \
  CLAUDE.md README.md \
  skills/*/SKILL.md
do
  [ -f "$f" ] || continue

  # core/xxx.md, strategy/xxx/xxx.md 형태의 참조 추출
  # [domain] 같은 플레이스홀더가 포함된 경로는 제외
  refs=$(grep -oE '(core|strategy)/[a-zA-Z0-9_/.~-]+\.md' "$f" 2>/dev/null \
    | grep -v '\[' \
    | sort -u || true)

  for ref in $refs; do
    [ -f "$ref" ] \
      && pass "$f -> $ref" \
      || fail "$f -> $ref (파일 없음)"
  done
done

# ─── 4. settings.json 권한 글롭 매칭 ───

echo ""
echo "== settings.json 권한 글롭 =="

# settings.json에서 Read() 패턴 추출
# set -f로 bash glob 확장 방지 (core/* 가 실제 파일로 확장되는 것 방지)
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
    fi
  else
    fail "Read($glob_pattern) -> 디렉토리 '$base_dir' 없음"
  fi
done
set +f

# ─── 5. Strategy 파일 스키마 검증 ───

echo ""
echo "== Strategy 파일 스키마 =="

for f in $(find strategy -name "*.md" -not -path "./.git/*" 2>/dev/null); do
  fname=$(echo "$f" | sed 's|strategy/||')

  # 필수 섹션: "## 기본"
  grep -q "^## 기본" "$f" \
    && pass "$fname: '기본' 섹션" \
    || warn "$fname: '기본' 섹션 없음"

  # 필수 섹션: "## 프로젝트 발견" (없으면 경고만)
  grep -q "^## 프로젝트 발견" "$f" \
    && pass "$fname: '프로젝트 발견' 섹션" \
    || warn "$fname: '프로젝트 발견' 섹션 없음"

  # 유래 형식 존재 확인 (프로젝트 발견 항목이 있는 경우)
  provenance_count=$(grep -c "^> 유래:" "$f" 2>/dev/null || echo "0")
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

  # 진화 스킬인 경우 strategy 디렉토리가 존재하는지 확인
  if grep -q "진화 스킬" "$skill_file"; then
    # strategy 경로 참조 추출 (strategy/xxx/xxx.md)
    strategy_refs=$(grep -oE 'strategy/[a-zA-Z0-9_/.-]+\.md' "$skill_file" \
      | grep -v '\[' | sort -u || true)

    if [ -n "$strategy_refs" ]; then
      for ref in $strategy_refs; do
        [ -f "$ref" ] \
          && pass "$skill_name(진화) -> $ref" \
          || fail "$skill_name(진화) -> $ref (strategy 파일 없음)"
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
