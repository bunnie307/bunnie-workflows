# Design Document Schema

모든 설계 문서는 이 스키마를 따른다.

## Core Principle

두 가지 구조 원리를 결합한다:

1. **서비스 블록**: 사람이 서비스 단위로 아키텍처를 리뷰할 수 있도록 서비스별로 그룹핑
2. **Implementation Unit**: 에이전트가 독립적으로 구현할 수 있는 self-contained 단위. 서비스 블록 안에 위치하며 DAG로 순서화

## Output Format

**기본: 단일 파일** — `docs/design/[feature-name].md`

**분리 조건:** 서비스 블록이 3개 이상이거나 문서가 500줄을 넘으면 자동 분리:

```
docs/design/[feature-name]/
  index.md                    # 개요 + 아키텍처 뷰 + Types Registry + Data Model + Cross-Cutting + Validation
  service-[name].md           # 서비스 블록 (컨텍스트 + implementation units)
  service-[name].md           # ...
```

## Document Structure

```
# [Feature Name]

## 개요 & 아키텍처 뷰
## Codebase Context
## Types Registry
## Data Model
## Service: [ServiceA]
  ### Unit 1: [Name]
  ### Unit 2: [Name]
## Service: [ServiceB]
  ### Unit 3: [Name]
## Cross-Cutting Concerns
## Validation Checklist
```

모놀리틱 프로젝트에서는 "Service"를 "Module"로 대체한다.

---

## Section: 개요 & 아키텍처 뷰

```markdown
## 개요 & 아키텍처 뷰

**Purpose:** [기능이 사용자에게 하는 것 한 문장]
**Trigger:** [실행 트리거: HTTP 요청, Kafka 메시지, cron, 사용자 액션]
**Scope:** [IN scope / OUT of scope 명시]

### 서비스 맵

```
[ServiceA] --OrderCreatedEvent--> [ServiceB]
[ServiceA] --HTTP GET /products--> [ServiceC]
```

### 서비스 간 계약
| From | To | Type | Contract |
|------|-----|------|----------|
| OrderService | PaymentService | Kafka: order.created | OrderCreatedEvent |
| OrderService | ProductService | HTTP: GET /products/:id | ProductResponse |

### 공통 규칙
- [모든 서비스에 적용되는 규칙. 구체적으로: 어떤 에러 처리 패턴, 어떤 인증 방식]

### Prerequisites
- [선행 조건, 없으면 "None"]

### Open Questions
- [미결사항, 없으면 "None"]
```

---

## Section: Codebase Context

```markdown
## Codebase Context

### Reference Implementations
Copy the patterns from these existing files:
- Controller pattern: `src/order/order.controller.ts`
- UseCase pattern: `src/order/use-cases/create-order.use-case.ts`
- Test pattern: `src/order/__tests__/create-order.use-case.spec.ts`

### Reuse (DO NOT recreate)
These already exist. Import them:
- Base exception: `import { BusinessException } from '@app/common/exceptions/business.exception'`
- Pagination: `import { PaginationDto } from '@app/common/dto/pagination.dto'`
- Auth guard: `import { JwtAuthGuard } from '@app/auth/guards/jwt-auth.guard'`

### Wiring
- Module registration: Add to `providers` array in `src/order/order.module.ts`
- Topic registration: Add topic constant to `src/common/constants/kafka-topics.ts`

### Naming Conventions (detected from codebase)
- UseCase method: `execute(input: XxxInput): Promise<XxxOutput>`
- Error code format: `ErrorCode.ENTITY_ACTION_REASON`
- File naming: `kebab-case.use-case.ts`
```

모든 경로는 실제 코드베이스에서 검증된 것이어야 한다. 추측 금지.

---

## Section: Types Registry

전체 기능의 타입 정본. 모든 서비스 블록의 implementation unit이 이 registry를 참조한다.

```markdown
## Types Registry

### NEW Types

```typescript
interface CancelOrderInput {
  orderId: string;
  reason: CancelReason;
  userId: string;
}

interface CancelOrderOutput {
  cancelledAt: Date;
}

enum CancelReason {
  CHANGED_MIND = 'CHANGED_MIND',
  FOUND_CHEAPER = 'FOUND_CHEAPER',
  OTHER = 'OTHER',
}

enum ErrorCode {
  ORDER_NOT_FOUND = 'ORDER_NOT_FOUND',
  ORDER_ACCESS_DENIED = 'ORDER_ACCESS_DENIED',
  ORDER_NOT_CANCELLABLE = 'ORDER_NOT_CANCELLABLE',
}
```

### EXTEND Types

```typescript
// EXTEND: src/order/types/order.types.ts
interface Order {
  // ... existing fields ...
  cancelledAt?: Date;     // NEW FIELD
  cancelReason?: string;  // NEW FIELD
}
```

### Error Mapping

| ErrorCode | HTTP Status | When |
|-----------|-------------|------|
| ORDER_NOT_FOUND | 404 | orderId에 해당하는 주문 없음 |
| ORDER_ACCESS_DENIED | 403 | 요청 사용자가 주문 소유자 아님 |
| ORDER_NOT_CANCELLABLE | 409 | 주문 상태가 PENDING 아님 |
```

---

## Section: Data Model (conditional)

Prisma 스키마 변경이 필요할 때만 포함.

```markdown
## Data Model

### Schema Changes

```prisma
model OrderCancellation {
  id          String   @id @default(cuid())
  orderId     String   @unique
  reason      String
  cancelledBy String
  cancelledAt DateTime @default(now())
  order       Order    @relation(fields: [orderId], references: [id])
}
```

### Migration Notes
- Non-breaking: 새 테이블만, 기존 컬럼 변경 없음
- Run: `npx prisma migrate dev --name add-order-cancellation`
```

---

## Section: Service Blocks

각 서비스(또는 모놀리틱의 모듈)별로 하나의 블록. 블록 안에 implementation unit이 위치한다.

### Service Block Format

```markdown
## Service: OrderService

**소유 범위:** 주문 라이프사이클 (생성, 수정, 취소)
**Publishes:** OrderCancelled → Kafka: order.cancelled
**Consumes:** PaymentCompleted ← Kafka: payment.completed

### Unit 1: Cancel Order UseCase

**depends_on:** none
**files:**
- `src/order/dto/cancel-order.dto.ts` — DTO [CREATE]
- `src/order/use-cases/cancel-order.use-case.ts` — 비즈니스 로직 [CREATE]
- `src/order/order.controller.ts` — DELETE /orders/:id 추가 [MODIFY]
- `src/order/order.module.ts` — CancelOrderUseCase 등록 [MODIFY]

**type context** (Types Registry에서 발췌):
```typescript
interface CancelOrderInput {
  orderId: string;
  reason: CancelReason;
  userId: string;
}
interface CancelOrderOutput {
  cancelledAt: Date;
}
```

**flow:**
1. `OrderController.cancel(@Param('id') orderId, @Body() dto, @CurrentUser() user)`
2. Controller가 CancelOrderInput 구성, `CancelOrderUseCase.execute(input)` 호출
3. `CancelOrderUseCase.execute(input: CancelOrderInput): Promise<CancelOrderOutput>`
   - `this.prisma.order.findUnique({ where: { id: input.orderId } })`
   - not found → `throw BusinessException(ErrorCode.ORDER_NOT_FOUND, 404)`
   - `order.userId !== input.userId` → `throw BusinessException(ErrorCode.ORDER_ACCESS_DENIED, 403)`
   - `order.status !== PENDING` → `throw BusinessException(ErrorCode.ORDER_NOT_CANCELLABLE, 409)`
   - `this.prisma.order.update({ ... status: CANCELLED, cancelledAt: new Date() })`
   - Publish `OrderCancelledEvent` to `order.cancelled`
   - Return `{ cancelledAt }`

**error paths:**
| Condition | ErrorCode | HTTP | Test Input |
|-----------|-----------|------|------------|
| 주문 없음 | ORDER_NOT_FOUND | 404 | `orderId: 'nonexistent'` |
| 소유자 아님 | ORDER_ACCESS_DENIED | 403 | `userId: 'other-user'` |
| 취소 불가 상태 | ORDER_NOT_CANCELLABLE | 409 | `status: 'SHIPPED'` |

**acceptance criteria:**
- [ ] DELETE /orders/:id → 200 + cancelledAt
- [ ] DB에 status CANCELLED 저장
- [ ] OrderCancelledEvent 발행
- [ ] 404/403/409 에러 케이스 처리

**tests:**
- [ ] happy path: PENDING 주문 취소 → cancelledAt 반환
- [ ] order not found → ORDER_NOT_FOUND
- [ ] access denied → ORDER_ACCESS_DENIED
- [ ] not cancellable → ORDER_NOT_CANCELLABLE
- [ ] event published → kafkaProducer.send 호출 검증
```

### Unit Rules

1. 각 unit은 하나의 서비스 블록 안에 위치
2. 서비스 간 의존은 `depends_on`에 `[ServiceName].Unit N` 형태로 표기
3. 각 unit은 최대 5개 파일. 초과 시 분리.
4. type context는 Types Registry에서 해당 unit에 필요한 부분만 복사
5. DAG는 비순환이어야 함

---

## Section: Cross-Cutting Concerns (conditional)

```markdown
## Cross-Cutting Concerns

### Kafka Topics
| Topic | Producer | Consumer | Payload Type |
|-------|----------|----------|-------------|
| order.cancelled | OrderService | notification-service | OrderCancelledEvent |

### Database Transactions
- CancelOrderUseCase: order update는 트랜잭션, event publish는 트랜잭션 밖 (at-least-once)

### Auth/Permissions
- DELETE /orders/:id → JwtAuthGuard + 소유자 확인
```

---

## Section: Validation Checklist

문서 생성 후 기계적으로 검증한다. 모든 항목은 yes/no.

```markdown
## Validation Checklist

### Type Integrity
- [ ] 모든 unit의 flow/error에서 사용하는 타입명이 Types Registry에 존재
- [ ] 모든 unit의 인라인 type context가 Types Registry 정의와 일치
- [ ] 모든 ErrorCode가 Error Mapping 테이블에 존재

### Service/Unit DAG Integrity
- [ ] 모든 depends_on 참조가 실제 unit을 가리킴
- [ ] 순환 의존 없음
- [ ] 서비스 간 의존이 아키텍처 뷰의 서비스 맵과 일치

### File Path Integrity
- [ ] [MODIFY] 파일이 실제 존재 (Glob/Grep 검증)
- [ ] [CREATE] 파일이 아직 존재하지 않음
- [ ] 파일명이 프로젝트 네이밍 규칙과 일치

### Codebase Context Integrity
- [ ] Reference Implementations 경로가 실제 존재
- [ ] Reuse의 import 경로가 실제 resolve 가능
- [ ] Wiring의 모듈 경로가 실제 존재

### Completeness
- [ ] 모든 API 엔드포인트에 최소 1개 error path 정의
- [ ] 모든 UseCase에 happy path + error path 테스트 존재
- [ ] 모든 Kafka topic에 payload type 정의
- [ ] 모호한 표현 없음: "적절히", "필요에 따라", "등등", "as needed"
```

---

## Concreteness Rules

**에이전트가 질문 없이 구현할 수 있는 수준:**

| Element | Required Level | Bad | Good |
|---------|---------------|-----|------|
| Types | 프로젝트 언어 코드 | "order data" | `interface CancelOrderInput { orderId: string }` |
| Flow | 함수 시그니처 + 인라인 타입 | "validate input" | `UseCase.execute(input: CancelOrderInput)` |
| Errors | enum + HTTP + 조건 | "return error" | `ErrorCode.ORDER_NOT_FOUND, 404` |
| Tests | 구체적 입력 + 기대 결과 | "test error" | `input: { orderId: 'nonexistent' }, expect: ORDER_NOT_FOUND` |
| File paths | 프로젝트 루트 기준 전체 경로 | "in the module" | `src/order/use-cases/cancel-order.use-case.ts` |
| Wiring | 정확한 배열/속성 | "register it" | `providers in src/order/order.module.ts` |
