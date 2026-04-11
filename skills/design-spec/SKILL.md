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

**4a. Summary** — purpose, trigger, scope, prerequisites, open questions

**4b. Codebase Context** — populated entirely from Step 1 findings
- Reference implementations (actual file paths verified in the codebase)
- Reusable code (actual imports verified in the codebase)
- Wiring instructions (actual module files verified in the codebase)
- Naming conventions (extracted from actual code, not assumed)

**4c. Types Registry** — single source of truth
- Write ALL types as TypeScript interfaces/enums
- Mark each type as `NEW` or `EXTEND` (with file path for EXTEND)
- Include the Error Mapping table (ErrorCode → HTTP status → trigger condition)
- No natural language type descriptions. If you can't define it as code, the requirement is ambiguous — go back to Step 3.

**4d. Data Model** (if needed) — Prisma schema changes
- Show new models and modifications to existing models
- Specify migration strategy and backfill requirements

**4e. Implementation Units** — the core deliverable
- Decompose the feature into 2-6 units
- Each unit is a vertical slice: types + logic + test for one coherent piece
- Each unit has: depends_on, files, type context (copied from Registry), flow, error paths, acceptance criteria, tests
- Order units as a DAG: dependencies before dependents
- Each unit should modify at most 5 files. If more, split it.

**4f. Cross-Cutting Concerns** (if needed) — Kafka topics, transactions, auth, idempotency

**4g. Validation Checklist** — auto-verified (see below)

---

### Step 5: VALIDATE — Mechanical Verification

Run every check from the **Validation Checklist** defined in `strategy/design/schema.md`. The canonical checklist lives there — do not maintain a separate list here.

The checklist covers five categories:
1. **Type Integrity** — every type/field/ErrorCode used in units exists in the Types Registry
2. **Unit DAG Integrity** — `depends_on` references are valid, no cycles, topological order
3. **File Path Integrity** — [MODIFY] files exist, [CREATE] files don't, naming conventions match
4. **Codebase Context Integrity** — all referenced paths/imports actually exist in the codebase
5. **Completeness** — error paths, tests, event payloads, no vague language

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
