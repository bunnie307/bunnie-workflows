---
name: design-spec
description: 에이전트가 일관되게 구현할 수 있는 수준의 설계 문서를 생성하고, 설계→구현 갭에서 발견된 관점을 축적한다.
---

# /design-spec — 설계 문서 생성

에이전트가 질문 없이 구현할 수 있는 수준의 설계 문서를 생성한다.

**유형:** 진화 스킬 (core/evolution-engine.md 참조)

## 입력

기능 요구사항 설명. 예: "주문 취소 API, 취소 사유 기록, 환불 이벤트 발행"

## 프로세스

### Step 1: DETECT — 컨텍스트 감지

- 프로젝트 CLAUDE.md에서 아키텍처 규칙 읽기
- 기존 코드에서 유사 기능 패턴 분석:
  - 참조할 수 있는 기존 UseCase, Controller, 테스트 파일 경로
  - import 경로와 DI 등록 패턴
  - 네이밍 규칙 (메서드명, 에러코드 형식 등)
  - 재사용해야 하는 공유 코드 (예외 클래스, DTO, 가드, 인터셉터)
- 기존 설계 문서 확인 (docs/design/)
- 기능 유형 판별: API 기능 / 이벤트 consumer / 배치 작업 / 기타

**중요:** DETECT에서 분석한 내용은 context.md에 기록한다. 이 정보가 문서에 없으면 구현 에이전트가 패턴을 추측해야 한다.

### Step 2: ANALYZE — 설계 관점 검토

설계 관점을 두 소스에서 읽는다:
1. 기본 관점: strategy/design/perspectives.md (플러그인 내장)
2. 발견된 관점: ~/.bunnie-workflows/strategy/design/perspectives.md (실전에서 축적)

각 관점에 대해 이번 기능에 해당하는지 확인.

### Step 3: EXTRACT — 요구사항 구체화

사용자에게 한 번에 하나씩 질문하여 요구사항을 구체화:
- 어떤 API/이벤트가 필요한가?
- 스키마 변경이 있는가?
- 에러 케이스는?
- (설계 관점에서 누락된 부분이 있으면 추가 질문)

모호한 부분이 없을 때까지 반복.

### Step 4: APPLY — 문서 생성

`docs/design/[feature-name]/` 디렉토리에 문서를 생성한다.
strategy/design/schema.md의 스키마와 검증 규칙을 따른다.

**필수:**
- README.md (요약, 선행조건, 미결사항, 에이전트 참조 가이드)
- context.md (참조 구현, 재사용 코드, 와이어링, 네이밍 규칙)

**기능 유형에 따라 포함:**
- interfaces.md (API/이벤트가 있을 때, NEW/EXTEND 구분 포함)
- data-model.md (DB 변경이 있을 때)
- implementation.md (phase별 구현 계획 + 흐름 + 파일 목록 + 인라인 타입 시그니처)
- tests.md (phase별 테스트 계획, 구현보다 먼저 작성)

빈 파일은 만들지 않는다. 검증 실패 시 자동 보강.

### 보고

사용자에게 결과 보고:
- 생성된 문서 목록
- 검증 결과
- 에이전트 참조 가이드

### 설계→구현 갭 기록

이 스킬이 직접 하지 않는다. 구현 중에 설계 갭이 발견되면 CLAUDE.md의 "설계→구현 갭 발견 시" 글로벌 규칙이 자동으로 `~/.bunnie-workflows/strategy/design/perspectives.md`에 기록한다. 다음 설계 문서 생성 시 Step 2에서 축적된 관점이 자동 반영.
