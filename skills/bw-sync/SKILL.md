---
name: bw-sync
description: 발견된 전략을 플러그인 레포에 PR로 동기화한다.
---

# /sync — 전략 동기화

실전에서 발견되어 `~/.bunnie-workflows/strategy/`에 축적된 관점/패턴을 플러그인 레포에 PR로 제출한다.

**유형:** 정적 스킬

## 프로세스

### Step 1: 발견된 전략 확인

`~/.bunnie-workflows/strategy/` 디렉토리를 읽는다.

```bash
find ~/.bunnie-workflows/strategy -name "*.md" 2>/dev/null
```

파일이 없으면 "동기화할 내용이 없습니다"로 종료.

### Step 2: base 전략과 diff

플러그인의 base 전략(`strategy/`)과 발견된 전략(`~/.bunnie-workflows/strategy/`)을 비교한다.

각 도메인별로:
- 발견된 전략 파일의 항목을 순회
- 각 항목의 `> 유래:` 줄을 기준으로 base에 이미 존재하는지 확인
- base에 없는 항목만 새 항목으로 분류

새 항목이 없으면 "모든 발견된 관점이 이미 base에 반영되어 있습니다"로 종료.

### Step 3: 사용자 확인

새 항목 목록을 보여주고 PR 생성 여부를 확인한다:

```
동기화할 새 관점 N건:

[도메인] [관점명]
  > 유래: ...

[도메인] [관점명]
  > 유래: ...

PR을 생성할까요?
```

사용자가 거부하면 종료.

### Step 4: 플러그인 레포 클론

`.claude-plugin/plugin.json`의 `repository` 필드에서 레포 URL을 읽는다.

```bash
REPO_URL=$(cat .claude-plugin/plugin.json | grep -o '"repository": *"[^"]*"' | sed 's/"repository": *"//;s/"//')
WORK_DIR=$(mktemp -d)
gh repo clone "$REPO_URL" "$WORK_DIR"
cd "$WORK_DIR"
```

### Step 5: 브랜치 생성 및 변경 적용

```bash
BRANCH="evolve/sync-$(date +%Y%m%d-%H%M%S)"
git checkout -b "$BRANCH"
```

새 항목을 해당 도메인의 base 전략 파일에 추가한다:
- `strategy/[domain]/*.md` 파일 끝에 새 항목을 append
- "## 프로젝트 발견" 섹션이 없으면 생성 후 그 아래에 추가
- core/strategy-schema.md의 형식을 따른다

```bash
git add strategy/
git commit -m "evolve: add discovered perspectives from $(whoami)"
git push origin "$BRANCH"
```

### Step 6: PR 생성

```bash
gh pr create \
  --title "evolve: add [N]건의 발견된 관점" \
  --body "$(cat <<'EOF'
## 발견된 관점

[각 새 항목을 나열: 관점명, 구체적 항목, 유래 정보]

---
Synced from `~/.bunnie-workflows/strategy/` by `/sync` skill.
EOF
)"
```

PR URL을 사용자에게 보고한다.

### Step 7: 정리

```bash
rm -rf "$WORK_DIR"
```

### 보고

사용자에게 결과 보고:
- 동기화된 관점 수
- PR URL
- 리뷰 후 merge하면 다음 플러그인 업데이트에 반영됨을 안내
