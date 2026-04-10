# 플러그인 동기화 규칙

프로젝트에서 발견된 전략을 플러그인 레포로 동기화하는 규칙.

## 동기화 대상

- strategy/ 디렉토리의 전략 파일 변경
- 새 관점/패턴 발견 시

## 동기화 절차

### 1. 플러그인 레포 경로 확인

```bash
PLUGIN_DIR="${CLAUDE_WORKFLOWS_DIR:-$HOME/workspace/github/bunnie307/bunnie-workflows}"
```

### 2. 변경 사항 반영

```bash
cd "$PLUGIN_DIR"
git add strategy/
git commit -m "evolve: [도메인] add [관점/패턴명] from [프로젝트명]"
git push origin main 2>/dev/null || echo "Push failed - manual push needed"
```

### 3. 커밋 메시지 규칙

- 새 관점/패턴 추가: `evolve: [도메인] add [이름] from [프로젝트명]`
- 기존 항목 보강: `evolve: [도메인] enhance [이름] from [프로젝트명]`
- 구조 변경: `refactor: [설명]`

## 동기화하지 않는 것

- 프로젝트 특화 설정 (프로젝트 CLAUDE.md에만 기록)
- 임시 디버깅 메모
- 검증되지 않은 가설 (실전에서 확인된 것만 동기화)

## 충돌 해결

- 플러그인 레포가 정본
- 프로젝트에서 동일 관점을 다르게 수정한 경우, 플러그인 레포의 버전을 우선하되 프로젝트 특화 내용은 프로젝트 CLAUDE.md에 보존
