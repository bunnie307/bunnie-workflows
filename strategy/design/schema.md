# 설계 문서 스키마

모든 설계 문서는 이 스키마를 따른다. `docs/design/[feature-name]/` 디렉토리에 생성.

## 파일 구조

### 필수
- **README.md** — 요약, 선행조건, 미결사항, 에이전트 참조 가이드
- **context.md** — 기존 코드 재사용 정보, 참조 구현, 와이어링, 네이밍 규칙

### 기능 유형에 따라 포함
- **interfaces.md** — API 엔드포인트, 이벤트, 타입 정의 (API/이벤트가 있을 때)
- **data-model.md** — 스키마 변경, 마이그레이션 (DB 변경이 있을 때)
- **implementation.md** — phase별 구현 계획 + 흐름 + 파일 목록 (비즈니스 로직이 있을 때, 항상 권장)
- **tests.md** — 관점별 테스트 계획 (항상 권장, 구현보다 먼저 작성)

빈 파일은 만들지 않는다.

## 검증 규칙

문서 생성 후 아래 4가지만 기계적으로 검증한다:

1. **타입명 존재**: implementation.md에서 참조하는 모든 타입명이 interfaces.md에 정의되어 있는가
2. **에러코드 매칭**: implementation.md의 에러 흐름에서 사용하는 에러코드가 interfaces.md의 에러 응답에 정의되어 있는가
3. **파일경로 참조**: implementation.md의 모든 파일 경로가 context.md 또는 interfaces.md에서 참조되는가
4. **인라인 시그니처 일치**: implementation.md의 인라인 타입 시그니처가 interfaces.md의 정의와 일치하는가

검증 실패 시 자동 보강.

## 구체성 기준

"에이전트가 질문 없이 구현할 수 있는 수준"의 기준:

- **타입 정의**: 프로젝트 언어(TypeScript, Go 등)의 실제 코드로 작성. 자연어 설명 금지.
- **흐름**: 함수명과 인라인 타입 시그니처를 명시. `UseCase.execute(input: CancelOrderInput { orderId: string, reason: CancelReason }): CancelOrderOutput { cancelledAt: Date }` 수준.
- **에러**: enum 값 + HTTP 상태코드. "에러 반환" 이 아니라 "ErrorCode.ORDER_NOT_FOUND, 404".
- **테스트**: 입력값과 기대 결과를 구체적으로.
- **파일 경로**: 프로젝트 CLAUDE.md의 아키텍처 규칙에 맞는 정확한 경로. "적절한 위치" 금지.

모호성 금지 표현: "적절히", "필요에 따라", "등등", "일반적으로". 이런 표현이 있으면 구체화한다.

## 각 파일의 형식

### README.md
```markdown
# [기능명]

## 요약
[한 줄 목적]

## 선행조건
- [의존하는 설계 문서 또는 구현, 없으면 "없음"]

## 미결사항
- [결정되지 않은 것, 없으면 "없음"]

## 에이전트 참조 가이드
| 구현 단계 | 참조 문서 |
|-----------|-----------|
| 시작 전 | context.md (참조 구현 파일 읽기) |
| 데이터 모델 | data-model.md |
| 구현 (phase별) | implementation.md + interfaces.md |
| 와이어링 | context.md |
| 테스트 | tests.md + interfaces.md |
```

### context.md
```markdown
# 구현 컨텍스트

## 참조 구현
- UseCase 패턴: `[기존 유사 UseCase 경로]`
- Controller 패턴: `[기존 유사 Controller 경로]`
- 테스트 패턴: `[기존 유사 테스트 경로]`

## 재사용 (새로 만들지 않는다)
- 기본 예외: `[경로]`
- 페이지네이션: `[경로]`
- 인증 가드: `[경로]`
- 응답 래퍼: `[경로]`

## 와이어링
- 모듈 등록: `[모듈 파일 경로]`의 providers 배열에 추가
- Import 경로: `[공유 라이브러리 import 경로]`
- 이벤트/토픽 등록: `[토픽 정의 파일 경로]`

## 네이밍 규칙 (코드베이스에서 감지)
- UseCase 메서드: `execute(input: XxxInput): Promise<XxxOutput>`
- Repository 메서드: `[프로젝트에서 사용하는 패턴]`
- 에러 메시지 형식: `[프로젝트에서 사용하는 형식]`
```

### interfaces.md
```markdown
# 인터페이스 정의

## API 엔드포인트
### [METHOD] [PATH]
- Request: [타입 코드블록]
- Response: [타입 코드블록]
- 에러: [에러코드 + HTTP 상태]

## 이벤트/메시지
### [TOPIC]
- Payload: [타입 코드블록]

## 내부 인터페이스
### [UseCase명]
- Input: [타입 코드블록]
- Output: [타입 코드블록]

## NEW vs EXTEND
- NEW: 새로 생성하는 타입에는 [NEW] 표기
- EXTEND: 기존 타입에 필드 추가 시 [EXTEND 경로] 표기와 추가 필드만 명시
```

### data-model.md
```markdown
# 데이터 모델

## 스키마 변경
[Prisma 스키마 코드블록]

## 마이그레이션
- 마이그레이션 필요 여부
- 기존 데이터 영향
```

### implementation.md
```markdown
# 구현 계획

## 구현 순서
테스트 → 타입/인터페이스 → 데이터 레이어 → 비즈니스 로직 → API 레이어 → 와이어링

## Phase 1: 타입 및 인터페이스
**파일:**
- `[경로]` — [역할] [CREATE/MODIFY]

**완료 조건:** `tsc --noEmit` 통과

## Phase 2: 데이터 레이어
**파일:**
- `[경로]` — [역할] [CREATE/MODIFY]

**흐름:**
1. [함수명(input: InputType { field: type }): OutputType 수준의 인라인 시그니처]
2. [다음 단계]

**에러 흐름:**
- 조건: [언제], 에러코드: ErrorCode.XXX, 응답: [HTTP 상태]

**완료 조건:** prisma generate 성공 + 유닛 테스트 통과

## Phase N: ...
(같은 구조 반복)
```

### tests.md
```markdown
# 테스트 계획

## 구현 순서
tests.md의 테스트는 해당 phase의 구현보다 먼저 작성한다 (TDD).

## Phase 1 테스트
- [ ] [테스트 항목]: 입력 [X], 기대 [Y]

## Phase 2 테스트
- [ ] [테스트 항목]: 입력 [X], 기대 [Y]

## 통합 테스트 (전체 구현 완료 후)
- [ ] [테스트 항목]: 입력 [X], 기대 [Y]
```
