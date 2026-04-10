# 설계 문서 스키마

모든 설계 문서는 이 스키마를 따른다. `docs/design/[feature-name]/` 디렉토리에 생성.

## 파일 구조

### 필수
- **README.md** — 요약, 선행조건, 미결사항

### 기능 유형에 따라 포함
- **interfaces.md** — API 엔드포인트, 이벤트, 타입 정의 (API/이벤트가 있을 때)
- **data-model.md** — 스키마 변경, 마이그레이션 (DB 변경이 있을 때)
- **flows.md** — 정상/에러 흐름 (비즈니스 로직이 있을 때)
- **files.md** — 생성/수정 파일 목록 + 역할 (항상 권장)
- **tests.md** — 관점별 테스트 계획 (항상 권장)

단순 CRUD는 README.md + interfaces.md + files.md + tests.md로 충분할 수 있다.
복잡한 기능은 6개 파일 모두 필요할 수 있다. 빈 파일을 만들지 않는다.

## 검증 규칙

문서 생성 후 아래 3가지만 기계적으로 검증한다:

1. **타입명 존재**: flows.md에서 참조하는 모든 타입명이 interfaces.md에 정의되어 있는가
2. **에러코드 매칭**: flows.md의 에러 흐름에서 사용하는 에러코드가 interfaces.md의 에러 응답에 정의되어 있는가
3. **파일경로 참조**: files.md의 모든 경로가 다른 문서에서 최소 1회 참조되는가

검증 실패 시 자동 보강. 외부 일관성(다른 설계 문서와의 모순)은 검증하지 않는다.

## 구체성 기준

"에이전트가 질문 없이 구현할 수 있는 수준"의 기준:

- **타입 정의**: 프로젝트 언어(TypeScript, Go 등)의 실제 코드로 작성. 자연어 설명 금지.
- **흐름**: 함수명과 인터페이스를 명시. "데이터를 처리한다" 가 아니라 "OrderCancelUseCase.execute(input: CancelOrderInput): CancelOrderOutput" 수준.
- **에러**: enum 값 + HTTP 상태코드. "에러 반환" 이 아니라 "ErrorCode.ORDER_NOT_FOUND, 404".
- **테스트**: 입력값과 기대 결과를 구체적으로. "주문 취소를 테스트" 가 아니라 "입력: orderId='non-existent', 기대: ErrorCode.ORDER_NOT_FOUND 404".
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

### flows.md
```markdown
# 흐름

## 정상 흐름
1. [입력]
2. [처리 단계]
3. [출력]

## 에러 흐름
### [에러 상황]
- 조건: [언제 발생]
- 에러코드: [ErrorCode.XXX]
- 응답: [HTTP 상태 + 메시지]
```

### files.md
```markdown
# 파일 목록

## 생성
- `[경로]` — [역할]

## 수정
- `[경로]` — [변경 내용]
```

### tests.md
```markdown
# 테스트 계획

## [관점명] (strategy/testing/perspectives.md 참조)
- [ ] [테스트 항목]: 입력 [X], 기대 [Y]
- [ ] [테스트 항목]: 입력 [X], 기대 [Y]
```
