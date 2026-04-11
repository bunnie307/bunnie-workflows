---
name: design-spec
description: Generate design documents optimized for AI agent implementation. Produces structured, self-validating specs with implementation units that agents can execute one at a time without questions.
---

# /design-spec — Design Document Generation

Generate a design document that an AI agent can implement without asking a single question. The document is structured as independently implementable units with explicit ordering, inlined types, and concrete acceptance criteria.

**Type:** Evolution skill (lessons from design-to-implementation gaps are recorded and applied to future runs)

## Input

Feature requirements in any form. Examples:
- "주문 취소 API, 취소 사유 기록, 환불 이벤트 발행"
- A Notion page URL with requirements
- A verbal description of what needs to be built
- A GitHub issue link

## Process

### Step 1: SCAN — Codebase Discovery

Before designing anything, understand what already exists. This step prevents the agent from reimplementing existing code or breaking naming conventions.

**1a. Read project rules:**
```
Read the project's CLAUDE.md for architecture rules, conventions, and constraints.
```

**1b. Find reference implementations:**
```
Glob for existing patterns that match the feature type:

# For API features:
Glob: src/**/*.controller.ts — pick the most similar controller
Glob: src/**/*.use-case.ts — pick the most similar use case
Glob: src/**/*.service.ts — pick the most similar service
Glob: src/**/*.spec.ts — pick the most similar test

# For Kafka consumers:
Glob: src/**/*.consumer.ts
Glob: src/**/*.handler.ts

# For shared code:
Glob: src/common/**/* or src/shared/**/*
Grep: 'export class.*Exception' — find all exception classes
Grep: 'export class.*Guard' — find all guards
Grep: 'export class.*Dto' — find all DTOs
Grep: '@Module' — find all module registrations
```

Read the 2-3 most relevant files found. Extract:
- Exact import paths and aliases (e.g., `@app/`, `@libs/`)
- Method naming patterns
- Error handling patterns
- DI registration patterns
- Test setup patterns (which mocking library, how services are mocked)

**1c. Check existing design docs:**
```
Glob: docs/design/**/*
```
Identify prerequisites and potential conflicts with existing designs.

**1d. Detect Prisma schema:**
```
Read: prisma/schema.prisma (or detected schema path)
```
Understand existing models, relations, and enums that the new feature may reference or extend.

**IMPORTANT:** Every finding from this step MUST appear in the Codebase Context section of the output. If it's not written down, the implementing agent will have to rediscover it.

---

### Step 2: ANALYZE — Apply Design Perspectives

Read design perspectives from two sources:
1. **Built-in perspectives:** `strategy/design/perspectives.md` (this plugin)
2. **Project-discovered perspectives:** Check if the project's CLAUDE.md has a design perspectives section

For each perspective, evaluate:
- Does this feature have this concern? (yes/no)
- If yes, what specific detail is needed in the design document?

Record which perspectives apply. They become verification checks in Step 4.

Also check the **Lessons Log** at the bottom of perspectives.md. If any lesson matches this feature's pattern, proactively address it.

---

### Step 3: CLARIFY — Fill Knowledge Gaps

Based on Steps 1 and 2, identify what is still unknown. Ask the user targeted questions.

**Rules for questions:**
- Ask ALL questions at once, not one by one (minimize round trips)
- Group by category: API shape, data model, business rules, error handling
- For each question, state what you'll assume if the user doesn't answer
- Never ask questions that can be answered by reading the codebase (that's Step 1's job)

**Question categories to consider:**
- API contract: method, path, auth requirements, request/response shape
- Business rules: what conditions cause failure, what side effects occur
- Data: new tables/columns, or extending existing ones
- Events: what events to publish, what to consume, payload shape
- Scope boundaries: what is explicitly NOT part of this feature

If requirements are clear enough to proceed without questions, skip this step.

---

### Step 4: GENERATE — Produce the Design Document

기본은 단일 파일 `docs/design/[feature-name].md`. unit이 6개 이상이거나 500줄을 넘으면 `docs/design/[feature-name]/` 디렉토리로 분리 (schema.md 참조). `strategy/design/schema.md`의 형식을 따른다.

**Generation order (follow strictly):**

**4a. 개요 & 아키텍처 뷰** — purpose, trigger, scope, 서비스 맵(의존성 다이어그램), 서비스 간 계약, 공통 규칙

**4b. Codebase Context** — Step 1 결과를 기록
- Reference implementations (실제 코드베이스에서 검증된 경로)
- Reuse (DO NOT recreate 목록)
- Wiring (모듈 등록, import 경로)
- Naming conventions (코드베이스에서 추출)

**4c. Types Registry** — 전체 기능의 타입 정본
- 프로젝트 언어(TypeScript 등)의 실제 코드로 작성
- NEW / EXTEND 구분 (EXTEND는 기존 파일 경로 명시)
- Error Mapping 테이블 (ErrorCode → HTTP status → 조건)
- 자연어 타입 설명 금지. 코드로 정의 불가하면 요구사항이 모호한 것 → Step 3으로 복귀

**4d. Data Model** (conditional) — Prisma 스키마 변경, 마이그레이션 노트

**4e. Service Blocks** — 서비스(또는 모듈)별로 그룹핑
- 각 서비스 블록에 소유 범위, Publishes/Consumes 명시
- 블록 안에 implementation units 배치 (2-6개/서비스)
- 각 unit: depends_on, files, type context(Registry에서 복사), flow(인라인 시그니처), error paths, acceptance criteria, tests
- unit은 DAG 순서. 서비스 간 의존은 `[ServiceName].Unit N` 형태
- 각 unit 최대 5파일. 초과 시 분리

**4f. Cross-Cutting Concerns** (conditional) — Kafka topics, transactions, auth, idempotency

**4g. Validation Checklist** — schema.md의 검증 규칙 실행

---

### Step 5: VALIDATE — Mechanical Verification

Run every check from the **Validation Checklist** defined in `strategy/design/schema.md`. The canonical checklist lives there — do not maintain a separate list here.

The checklist covers five categories:
1. **Type Integrity** — type context가 Registry와 일치, ErrorCode가 Error Mapping에 존재
2. **Service/Unit DAG Integrity** — depends_on 유효, 순환 없음, 서비스 간 의존이 아키텍처 뷰와 일치
3. **File Path Integrity** — [MODIFY] 파일 존재, [CREATE] 파일 미존재, 네이밍 규칙 일치
4. **Codebase Context Integrity** — 참조 경로/import가 실제 존재
5. **Completeness** — error path, tests, event payload, 모호한 표현 없음

For file path and codebase context checks, use Glob/Grep to verify against the actual codebase — do not rely on memory.

**If any check fails:** fix the document and re-validate. Do not present a document with known validation failures.

---

### Step 6: REPORT — Present Results

Report to the user:

```
## Design Document Generated

**File:** `docs/design/[feature-name].md`

### Implementation Units ([N] units, [M] files total)
1. Unit 1: [Name] — [depends_on: none]
2. Unit 2: [Name] — [depends_on: Unit 1]
...

### Validation
- Type integrity: PASS
- Unit DAG: PASS
- File paths: PASS
- Codebase context: PASS
- Completeness: PASS

### Applied Perspectives
- [List which perspectives from perspectives.md were relevant]

### Agent Usage Guide
Implementing agent: read the design doc's implementation units in order.
For each unit:
1. Read the unit's type context and flow
2. Implement the files listed
3. Run the acceptance criteria checks
4. Move to the next unit
```

---

## Evolution Mechanism

### Gap recording: invoked after implementation reveals problems

If the user invokes `/design-spec` and mentions that a previous design document had gaps (e.g., "the cancel order design was missing X"), handle the gap FIRST before generating a new document:

1. **Record the gap.** Ask the user:
   - Which design document had the gap?
   - What was missing or wrong?
   - What did the implementing agent have to figure out on its own?

2. **Classify the gap.** Does it match an existing perspective in `strategy/design/perspectives.md`?
   - **If yes:** refine that perspective's check/red-flag criteria to catch this specific gap
   - **If no:** add a new perspective under "Project-Discovered Perspectives" with:
     - Discovery date
     - Incident description (what the agent did X because the design said/didn't say Y)
     - Prevention check (specific verification steps)
     - Red flag pattern

3. **Add a Lessons Log entry** at the bottom of `strategy/design/perspectives.md`:
   - Date, feature name, gap description, resolution

4. **Sync plugin:** commit and push the updated perspectives.md:
   ```
   cd <plugin-repo> && git add strategy/design/perspectives.md && git commit -m "evolve: [gap description]" && git push
   ```
   Plugin repo path: env `CLAUDE_WORKFLOWS_DIR` or default `~/workspace/github/bunnie307/bunnie-workflows`

5. **Then proceed** with the normal design generation process (Steps 1-6), which will now apply the newly recorded perspective.

### Proactive gap detection

At the start of every `/design-spec` invocation, before Step 1, check:
- Does the feature being designed have an existing design doc in `docs/design/`?
- If yes, ask: "이전 설계 문서로 구현하면서 발견된 갭이 있나요?" (Were there any gaps discovered while implementing from the previous design document?)
- If the user reports gaps, handle them per the process above before proceeding.

### Self-improvement cycle

```
Design doc generated (perspectives applied)
    → Agent implements from it
    → Gap discovered during implementation
    → User invokes /design-spec again, reports the gap
    → Perspective added/refined in perspectives.md
    → All future design documents apply the new perspective
    → That gap category never recurs
```

This creates a flywheel: each failure makes all future design documents better.
