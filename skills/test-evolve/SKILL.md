---
name: test-evolve
description: 버그 수정 후 테스트 전략을 자동 발전시키는 스킬. 누락된 테스트 관점을 분석하고, 전략을 업데이트하고, 동일 패턴 모듈에 테스트를 보강한다.
---

# /test-evolve — 테스트 전략 자동 발전

버그 수정 후 실행. 또는 기존 테스트로 잡히지 않는 문제를 발견했을 때 실행.

## 입력

사용자가 설명하는 버그/문제 상황. 또는 최근 `fix:` 커밋의 diff.

## 프로세스

### Step 1: 관점 분석

아래 질문에 답한다:
- 이 버그의 근본 원인은 무엇인가?
- 기존 테스트 중 이 버그를 잡을 수 있었던 테스트가 있는가? 왜 못 잡았는가?
- 어떤 테스트 관점이 누락되었는가? (perspectives.md 참조)
- 기존 관점에 속하지만 커버리지가 부족했는가, 아니면 완전히 새로운 관점인가?

분석 결과를 사용자에게 보고한다.

### Step 2: 프로젝트 전략 업데이트

프로젝트의 CLAUDE.md를 확인:
- 테스트 관점 목록이 없으면 perspectives.md 기반으로 초기화
- 누락된 관점이면 해당 관점을 프로젝트 CLAUDE.md에 추가 (구체적 항목 + 추가 배경)
- 기존 관점이지만 부족하면 항목 보강

### Step 3: 테스트 보강

버그와 같은 패턴을 공유하는 모듈을 찾아 해당 관점의 테스트를 보강:
- 범위: 버그 발생 모듈 + 같은 패턴의 다른 모듈 (프로젝트 전반은 사용자 요청 시)
- 테스트 팩토리가 있으면 재사용, 없으면 생성 제안
- 각 테스트는 TDD 패턴 (테스트 작성 → 실패 확인 → 구현/수정 → 통과 확인)

### Step 4: 플러그인 동기화

새 관점이 발견된 경우:
1. `bunnie-workflows/strategy/perspectives.md`에 새 관점 추가
2. 유래 정보 기록 (어느 프로젝트, 어떤 버그에서 발견)
3. 플러그인 레포에 커밋/푸시

```bash
PLUGIN_DIR="${CLAUDE_WORKFLOWS_DIR:-$HOME/workspace/github/bunnie307/bunnie-workflows}"
cd "$PLUGIN_DIR"
git add strategy/perspectives.md
git commit -m "evolve: add [관점명] perspective from [프로젝트명]"
git push origin main 2>/dev/null || echo "Push failed - manual push needed"
```

### Step 5: 보고

사용자에게 결과 보고:
- 분석된 관점
- 업데이트된 항목
- 추가된 테스트 수
- 플러그인 동기화 여부
