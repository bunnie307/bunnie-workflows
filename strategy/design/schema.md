# Design Document Schema

All design documents follow this schema.

## Core Principle: Implementation Units

The document is organized around **implementation units** — independently implementable vertical slices. An agent reads one unit at a time and implements it without loading the full document. Units form a DAG via `depends_on`, giving the agent a clear implementation order.

## Output Format

**기본: 단일 파일** — `docs/design/[feature-name].md`

**분리 조건:** unit이 6개 이상이거나 문서가 500줄을 넘으면 자동 분리:

```
docs/design/[feature-name]/
  index.md              # Summary + Codebase Context + Types Registry + Data Model + Cross-Cutting + Validation
  unit-1-[name].md      # Unit 1 (depends_on, files, type context, flow, error paths, tests)
  unit-2-[name].md      # Unit 2
  ...
```

각 unit 파일은 self-contained. type context가 Types Registry에서 복사되어 있으므로 에이전트는 index.md를 먼저 읽고, 구현할 unit 파일만 읽으면 된다.

## Document Structure (단일 파일 시)

```
# [Feature Name]

## Summary
## Codebase Context
## Types Registry
## Data Model
## Implementation Units
  ### Unit 1: [Name]
  ### Unit 2: [Name]
  ...
## Cross-Cutting Concerns
## Validation Checklist (auto-verified)
```

Every section below is required unless marked `(conditional)`.

---

## Section: Summary

```markdown
## Summary

**Purpose:** [One sentence — what does this feature do for the user]
**Trigger:** [What causes this feature to execute: HTTP request, Kafka message, cron, user action]
**Scope:** [What is IN scope and what is explicitly OUT of scope]

### Prerequisites
- [Dependency on other features/PRs, or "None"]

### Open Questions
- [Unresolved decisions. If none, write "None — all decisions are captured below"]
```

Why this exists: Agents need to know the boundary. Without explicit scope, they build adjacent features. Without prerequisites, they attempt to build on code that doesn't exist yet.

---

## Section: Codebase Context

```markdown
## Codebase Context

### Reference Implementations
Copy the patterns from these existing files:
- Controller pattern: `src/order/order.controller.ts`
- UseCase pattern: `src/order/use-cases/create-order.use-case.ts`
- Service pattern: `src/order/order.service.ts`
- Test pattern: `src/order/__tests__/create-order.use-case.spec.ts`

### Reuse (DO NOT recreate)
These already exist. Import them:
- Base exception: `import { BusinessException } from '@app/common/exceptions/business.exception'`
- Pagination: `import { PaginationDto } from '@app/common/dto/pagination.dto'`
- Auth guard: `import { JwtAuthGuard } from '@app/auth/guards/jwt-auth.guard'`
- Response wrapper: `import { ApiResponse } from '@app/common/dto/api-response.dto'`

### Wiring
- Module registration: Add to `providers` array in `src/order/order.module.ts`
- Module imports: Import `PrismaModule` from `@app/prisma`
- Topic registration: Add topic constant to `src/common/constants/kafka-topics.ts`

### Naming Conventions (detected from codebase)
- UseCase method: `execute(input: XxxInput): Promise<XxxOutput>`
- Repository method: `findById`, `findMany`, `create`, `update`, `delete`
- Error code format: `ErrorCode.ENTITY_ACTION_REASON` (e.g., `ErrorCode.ORDER_NOT_FOUND`)
- File naming: `kebab-case.use-case.ts`, `kebab-case.controller.ts`
- Test naming: `kebab-case.use-case.spec.ts`
```

Why this exists: This is the highest-value section. Without it, agents reinvent existing utilities, use wrong import paths, and break naming conventions. Every path must be verified against the actual codebase during generation.

---

## Section: Types Registry

Single source of truth for all types in this feature. Every type referenced anywhere in the document must be defined here.

```markdown
## Types Registry

### NEW Types

```typescript
// --- Request/Response ---

interface CreateOrderRequest {
  productId: string;
  quantity: number; // min: 1, max: 100
  shippingAddressId: string;
  couponCode?: string; // optional, validated against coupon service
}

interface CreateOrderResponse {
  orderId: string;
  totalAmount: number;
  estimatedDelivery: Date;
}

// --- UseCase I/O ---

interface CreateOrderInput {
  productId: string;
  quantity: number;
  shippingAddressId: string;
  couponCode: string | null;
  userId: string; // extracted from JWT by controller
}

interface CreateOrderOutput {
  orderId: string;
  totalAmount: number;
  estimatedDelivery: Date;
}

// --- Events ---

interface OrderCreatedEvent {
  orderId: string;
  userId: string;
  totalAmount: number;
  createdAt: Date;
}

// --- Enums ---

enum OrderStatus {
  PENDING = 'PENDING',
  CONFIRMED = 'CONFIRMED',
  CANCELLED = 'CANCELLED',
}

enum ErrorCode {
  PRODUCT_NOT_FOUND = 'PRODUCT_NOT_FOUND',
  PRODUCT_OUT_OF_STOCK = 'PRODUCT_OUT_OF_STOCK',
  INVALID_COUPON = 'INVALID_COUPON',
  SHIPPING_ADDRESS_NOT_FOUND = 'SHIPPING_ADDRESS_NOT_FOUND',
}
```

### EXTEND Types (add fields to existing types)

```typescript
// EXTEND: src/order/types/order.types.ts
// Add to existing Order interface:
interface Order {
  // ... existing fields ...
  cancelledAt?: Date;     // NEW FIELD
  cancelReason?: string;  // NEW FIELD
}
```

### Error Mapping

| ErrorCode | HTTP Status | When |
|-----------|-------------|------|
| PRODUCT_NOT_FOUND | 404 | productId doesn't match any active product |
| PRODUCT_OUT_OF_STOCK | 409 | product.stock < requested quantity |
| INVALID_COUPON | 422 | coupon expired, already used, or doesn't exist |
| SHIPPING_ADDRESS_NOT_FOUND | 404 | shippingAddressId not found for this user |
```

Why this exists: Problems #5 (hallucinated field names) happens because types are defined in one file and used in another. The registry is the single source. Implementation units inline relevant type excerpts from this registry — but the registry is the canonical version.

---

## Section: Data Model (conditional)

Include only when Prisma schema changes are needed.

```markdown
## Data Model

### Schema Changes

```prisma
// NEW model
model OrderCancellation {
  id        String   @id @default(cuid())
  orderId   String   @unique
  reason    String
  cancelledBy String
  cancelledAt DateTime @default(now())

  order     Order    @relation(fields: [orderId], references: [id])
}

// MODIFY: add relation to existing Order model
model Order {
  // ... existing fields ...
  cancellation OrderCancellation?  // ADD THIS LINE
}
```

### Migration Notes
- Non-breaking: new table only, no column changes to existing tables
- Backfill: not required
- Run: `npx prisma migrate dev --name add-order-cancellation`
```

---

## Section: Implementation Units

This is the core of the document. Each unit is a vertical slice that can be implemented independently.

### Unit Format

```markdown
### Unit [N]: [Descriptive Name]

**depends_on:** [Unit numbers this depends on, or "none"]
**files:**
- `src/order/dto/cancel-order.dto.ts` — CancelOrderRequest/Response DTOs [CREATE]
- `src/order/use-cases/cancel-order.use-case.ts` — cancellation business logic [CREATE]
- `src/order/order.controller.ts` — add DELETE /orders/:id endpoint [MODIFY]
- `src/order/order.module.ts` — register CancelOrderUseCase [MODIFY]

**type context** (excerpt from Types Registry for this unit):
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
```

**flow:**
1. `OrderController.cancel(@Param('id') orderId: string, @Body() dto: CancelOrderRequest, @CurrentUser() user: User): Promise<ApiResponse<CancelOrderResponse>>`
2. Controller extracts `userId` from `user`, constructs `CancelOrderInput`, calls `CancelOrderUseCase.execute(input)`
3. `CancelOrderUseCase.execute(input: CancelOrderInput): Promise<CancelOrderOutput>`
   - Call `this.prisma.order.findUnique({ where: { id: input.orderId } })`
   - If not found: throw `new BusinessException(ErrorCode.ORDER_NOT_FOUND, 404)`
   - If `order.userId !== input.userId`: throw `new BusinessException(ErrorCode.ORDER_ACCESS_DENIED, 403)`
   - If `order.status !== OrderStatus.PENDING`: throw `new BusinessException(ErrorCode.ORDER_NOT_CANCELLABLE, 409)`
   - Call `this.prisma.order.update({ where: { id: input.orderId }, data: { status: OrderStatus.CANCELLED, cancelledAt: new Date() } })`
   - Publish `OrderCancelledEvent` to topic `order.cancelled`
   - Return `{ cancelledAt: updatedOrder.cancelledAt }`

**error paths:**
| Condition | ErrorCode | HTTP | Test Input |
|-----------|-----------|------|------------|
| Order doesn't exist | ORDER_NOT_FOUND | 404 | `orderId: 'nonexistent-id'` |
| User doesn't own order | ORDER_ACCESS_DENIED | 403 | `userId: 'other-user'` |
| Order already shipped | ORDER_NOT_CANCELLABLE | 409 | `order.status: 'SHIPPED'` |

**acceptance criteria:**
- [ ] `DELETE /orders/:id` returns 200 with `cancelledAt` timestamp
- [ ] Order status changes to CANCELLED in database
- [ ] `OrderCancelledEvent` published to `order.cancelled` topic
- [ ] Returns 404 for nonexistent order
- [ ] Returns 403 when user doesn't own the order
- [ ] Returns 409 when order status is not PENDING

**tests:**
- [ ] Unit: CancelOrderUseCase — happy path: input `{ orderId: 'order-1', reason: 'CHANGED_MIND', userId: 'user-1' }`, mock order exists and is PENDING, expect `cancelledAt` to be defined
- [ ] Unit: CancelOrderUseCase — order not found: input `{ orderId: 'nonexistent' }`, expect `BusinessException` with `ORDER_NOT_FOUND`
- [ ] Unit: CancelOrderUseCase — access denied: input `{ userId: 'wrong-user' }`, mock order owned by different user, expect `BusinessException` with `ORDER_ACCESS_DENIED`
- [ ] Unit: CancelOrderUseCase — not cancellable: mock order with status SHIPPED, expect `BusinessException` with `ORDER_NOT_CANCELLABLE`
- [ ] Unit: CancelOrderUseCase — event published: verify `kafkaProducer.send` called with topic `order.cancelled` and correct payload
```

### Unit Ordering Rules

1. Units with `depends_on: none` come first
2. Data model units before business logic units
3. Type/DTO units before units that use them
4. Test files are created within each unit (not a separate phase)
5. The DAG must be acyclic — circular dependencies indicate a design problem

---

## Section: Cross-Cutting Concerns (conditional)

Include when the feature touches shared infrastructure.

```markdown
## Cross-Cutting Concerns

### Kafka Topics
| Topic | Producer | Consumer | Payload Type |
|-------|----------|----------|-------------|
| order.cancelled | CancelOrderUseCase | notification-service (external) | OrderCancelledEvent |
| order.cancelled | CancelOrderUseCase | billing-service (external) | OrderCancelledEvent |

### Database Transactions
- CancelOrderUseCase: order update + event publish must be atomic. Use `this.prisma.$transaction()` wrapping the update, then publish event outside transaction (at-least-once delivery).

### Auth/Permissions
- `DELETE /orders/:id` requires `JwtAuthGuard` + ownership check (user can only cancel own orders)

### Rate Limiting / Idempotency
- No rate limiting needed (destructive operation, single use)
- Idempotency: cancelling an already-cancelled order returns 409 (not 200), so not idempotent by design
```

---

## Section: Validation Checklist

This checklist is executed mechanically after document generation. Every item is a yes/no check.

```markdown
## Validation Checklist

### Type Integrity
- [ ] Every type name used in any implementation unit's flow/error paths exists in the Types Registry
- [ ] Every field name used in any implementation unit matches the Types Registry definition (same name, same type)
- [ ] Every ErrorCode used in error paths is defined in the Types Registry enum
- [ ] Every ErrorCode has a corresponding row in the Error Mapping table

### Unit DAG Integrity
- [ ] Every `depends_on` reference points to an existing unit number
- [ ] No circular dependencies in the unit DAG
- [ ] Units are listed in topological order (dependencies before dependents)

### File Path Integrity
- [ ] Every file path in implementation units matches the project's file naming convention
- [ ] Every [MODIFY] file exists in the current codebase (verified by grep/glob)
- [ ] Every [CREATE] file does NOT already exist in the current codebase
- [ ] No two units create the same file

### Codebase Context Integrity
- [ ] Every path in "Reference Implementations" exists in the codebase
- [ ] Every import in "Reuse" resolves to an existing module
- [ ] Module registration path in "Wiring" exists

### Completeness
- [ ] Every API endpoint has at least one error path defined
- [ ] Every UseCase has a unit test for happy path + each error path
- [ ] Every Kafka topic produced has a payload type in the Types Registry
- [ ] Every [EXTEND] type specifies the file path of the existing type
- [ ] No occurrence of vague language: "적절히", "필요에 따라", "등등", "일반적으로", "as needed", "appropriately", "etc."
```

---

## Concreteness Rules

The document must meet this standard: **an agent can implement without asking a single question.**

| Element | Required Level | Bad Example | Good Example |
|---------|---------------|-------------|--------------|
| Types | Actual TypeScript code | "order data" | `interface CreateOrderInput { productId: string; quantity: number; }` |
| Flow | Function signatures with inline types | "validate input" | `UseCase.execute(input: CancelOrderInput { orderId: string }): Promise<CancelOrderOutput>` |
| Errors | Enum value + HTTP status + trigger condition | "return error" | `ErrorCode.ORDER_NOT_FOUND, 404, when orderId has no matching record` |
| Tests | Concrete input + expected output | "test error case" | `input: { orderId: 'nonexistent' }, expect: BusinessException(ORDER_NOT_FOUND)` |
| File paths | Full path from project root | "in the order module" | `src/order/use-cases/cancel-order.use-case.ts` |
| Wiring | Exact array/property to modify | "register the service" | `Add CancelOrderUseCase to providers in src/order/order.module.ts` |
