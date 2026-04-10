---
name: test-evolve
description: 버그 수정 후 테스트 전략을 자동 발전시키는 진화 스킬. 누락된 테스트 관점을 분석하고, 전략을 업데이트하고, 동일 패턴 모듈에 테스트를 보강한다.
---

# /test-evolve — 테스트 전략 자동 발전

버그 수정 후 실행. 또는 기존 테스트로 잡히지 않는 문제를 발견했을 때 실행.

**유형:** 진화 스킬 (core/evolution-engine.md 참조)

## 입력

사용자가 설명하는 버그/문제 상황. 또는 최근 `fix:` 커밋의 diff.

## 프로세스

이 스킬은 core/evolution-engine.md의 6단계 프로세스를 테스트 도메인에 맞게 구체화한 것이다.

### Step 1: DETECT — 문제 감지

트리거 이벤트를 식별한다:
- 사용자가 버그/문제를 설명한 경우
- 최근 `fix:` 커밋이 있는 경우 → diff를 분석
- 테스트 실패가 보고된 경우

### Step 2: ANALYZE — 관점 분석

아래 질문에 답한다:
- 이 버그의 근본 원인은 무엇인가?
- 기존 테스트 중 이 버그를 잡을 수 있었던 테스트가 있는가? 왜 못 잡았는가?
- 어떤 테스트 관점이 누락되었는가? (strategy/testing/perspectives.md 참조)
- 기존 관점에 속하지만 커버리지가 부족했는가, 아니면 완전히 새로운 관점인가?

분석 결과를 사용자에게 보고한다.

### Step 3: EXTRACT — 패턴 추출

발견된 테스트 관점/패턴을 구조화한다:
- 관점 이름과 한 줄 설명
- 구체적 확인 항목 목록
- 유래 정보: 프로젝트명, 날짜, 구체적 버그 설명

### Step 4: APPLY — 테스트 보강

버그와 같은 패턴을 공유하는 모듈을 찾아 해당 관점의 테스트를 보강:
- 범위: 버그 발생 모듈 + 같은 패턴의 다른 모듈 (프로젝트 전반은 사용자 요청 시)
- 테스트 팩토리가 있으면 재사용, 없으면 생성 제안
- 각 테스트는 TDD 패턴 (테스트 작성 → 실패 확인 → 구현/수정 → 통과 확인)

### Step 5: RECORD — 전략 기록

프로젝트의 CLAUDE.md를 확인하고 업데이트:
- 테스트 관점 목록이 없으면 기본 관점(strategy/testing/perspectives.md) + 발견된 관점(~/.bunnie-workflows/strategy/testing/perspectives.md) 기반으로 초기화
- 누락된 관점이면 해당 관점을 프로젝트 CLAUDE.md에 추가 (구체적 항목 + 추가 배경)
- 기존 관점이지만 부족하면 항목 보강

사용자 공간에 새 관점 기록:

```bash
mkdir -p ~/.bunnie-workflows/strategy/testing
```

`~/.bunnie-workflows/strategy/testing/perspectives.md`에 새 관점 추가:
- core/strategy-schema.md의 형식을 따른다
- 유래 정보를 반드시 포함한다
- 파일이 없으면 생성한다

### Step 6: PROPAGATE — 전파

`~/.bunnie-workflows/strategy/`는 같은 머신의 모든 프로젝트가 공유한다. 별도의 동기화 작업 없이, 한 프로젝트에서 기록한 관점은 다른 프로젝트에서 즉시 사용 가능.

- 동일 패턴의 다른 모듈 보강 (프로젝트 전반은 사용자 요청 시)

### 보고

사용자에게 결과 보고:
- 분석된 관점
- 업데이트된 항목
- 추가된 테스트 수
- 기록 위치 (~/.bunnie-workflows/strategy/testing/perspectives.md)
