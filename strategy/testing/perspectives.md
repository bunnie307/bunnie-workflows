# 테스트 관점 목록

프로젝트 전반에서 축적된 테스트 관점. 새 프로젝트에서 CLAUDE.md 초기화 시 이 목록을 기본으로 사용.

## 기본 관점

### 1. Unit — 비즈니스 로직 검증
- 개별 함수/클래스의 입출력 검증
- 엣지 케이스: null, 빈 값, 존재하지 않는 리소스
- 외부 의존성은 mock

### 2. Integration — 모듈 간 동작 검증
- 실제 DB/큐/캐시와의 상호작용 검증
- 트랜잭션 롤백, 동시 접근 등

### 3. Contract — 소비자와의 계약 검증
- API 응답의 정확한 형식이 소비자의 기대와 일치하는지
- 모든 필드의 존재 여부, 타입, 네이밍
- 응답 래퍼/인터셉터 적용 후의 최종 형태
> 유래: 2026-04-10 chain-indexer에서 API 응답 래퍼 불일치 버그

### 4. Boundary — 타입 변환 경계 검증
- 시스템 경계에서의 직렬화/역직렬화 정확성
- 큰 숫자(BigInt), 소수점(Decimal), 바이너리(Bytes), 날짜(Date), null/undefined
- 정밀도 손실 없는지 검증
> 유래: 2026-04-10 chain-indexer에서 BigInt(undefined) 런타임 에러

### 5. E2E — 최종 사용자 관점 검증
- 전체 파이프라인을 관통하는 검증
- 실제 인프라(DB, 큐, 외부 서비스)와 함께 동작

### 6. Error Path — 에러 응답 검증
- 에러 응답 형식의 일관성 (4xx, 5xx)
- 에러 전파 경로가 올바른지
- 장애 상황에서 graceful degradation

### 7. Idempotency — 중복/경합 검증
- 같은 입력이 두 번 들어와도 결과가 동일한지
- 메시지 중복 수신, API 재요청 등
- 동시 요청 시 레이스 컨디션

## 프로젝트 발견

### 8. Error Classification — 에러의 HTTP 상태 코드 매핑 검증
- 사용자 입력 검증 실패 → 400 BadRequestException
- 리소스 미발견 → 404 NotFoundException
- 중복/충돌 → 409 ConflictException
- 인증 실패 → 401 UnauthorizedException
- 권한 부족 → 403 ForbiddenException
- 인프라 불가용 → 503 ServiceUnavailableException
- 도메인 에러 → VcalmError (status 필드로 매핑)
- generic `new Error()` 사용 금지 (500으로 매핑되어 클라이언트가 재시도 불가)
- 가드 테스트: `grep -rn "throw new Error(" --include="*.ts"` 결과가 프로덕션 코드에서 0건이어야 함
> 유래: 2026-04-11 vcalm, CreateWorkflowUsecase에서 입력 검증 실패(initialStep not found)가 generic Error로 던져져 500 반환. KeysController에서도 인프라 불가용이 generic Error로 500 반환. 두 건 모두 수정 후 관점 추가.

### 9. Consumer-Driven Contract — 소비자가 의존하는 API 엔드포인트 및 요청 형식 검증
- 프론트엔드 hook/client가 호출하는 모든 API 경로가 백엔드에 라우트로 등록되어 있는가?
- 프론트엔드가 사용하는 HTTP 메서드(GET/POST/PATCH/DELETE)가 해당 라우트에서 지원되는가?
- 기본 테스트 계정의 scope가 대시보드에서 사용하는 모든 엔드포인트를 커버하는가?
- monorepo에서 `.env` 경로가 모든 앱(API, Dashboard 등)에서 올바르게 로드되는가?
- 검증 방법: supertest로 각 경로에 요청 → 404가 아니면 통과 (401/403은 라우트 존재를 의미)
- 가드 테스트: 프론트엔드 hook에서 `apiClient.*` 호출을 추출하여 API 라우트 목록과 대조
- **요청 페이로드 정합성**: 프론트엔드 폼이 보내는 요청 바디가 API DTO의 class-validator 검증을 통과하는가?
  - 올바른 페이로드로 supertest 요청 → 400이 아니면 DTO 구조 일치 확인 (401/500은 허용)
  - 잘못된 필드명(proofFormat vs securingMechanism)이 forbidNonWhitelisted로 거부되는가?
  - 필수 필드 누락(did, verificationMethod)이 class-validator로 검출되는가?
  - AuthGuard가 ValidationPipe보다 먼저 실행되므로, 잘못된 페이로드는 plainToInstance + validate()로 정적 검증
> 유래: 2026-04-11 vcalm, 대시보드 hooks가 GET /entities 등 호출하지만 API에 리스트 엔드포인트 미구현 → 404. credential 발급 폼이 proofFormat을 보냈지만 API는 securingMechanism+cryptosuite 기대 → 400. Entity 생성 폼에 did 필드 누락 → 400. 키 생성 없이 발급 → 500.
