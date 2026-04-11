# Design Perspectives

Design review lenses applied during document generation. Each perspective catches a category of design-to-implementation gap. When a gap is discovered during implementation, a new perspective (or refinement) is added here, and all future design documents benefit.

## How to Use

During Step 2 (ANALYZE) of the design-spec skill:
1. Read each perspective below
2. For each, ask: "Does this feature have this concern?"
3. If yes, verify the design document addresses it with the required specificity
4. If the document doesn't address it, add the missing detail before finalizing

---

## Core Perspectives

### 1. Error Specificity

**Problem it prevents:** Agent implements `throw new Error('something went wrong')` because the design said "return error on failure."

**Check:** For every flow step that can fail:
- Is there an explicit ErrorCode enum value?
- Is the HTTP status code specified?
- Is the trigger condition concrete enough to write an `if` statement from it?
- Is there a test case with specific input that triggers this error?

**Red flag:** Any error described in natural language without an ErrorCode.

---

### 2. Type Completeness

**Problem it prevents:** Agent guesses field names or types because the design described the shape in natural language or omitted optional fields.

**Check:**
- Are ALL request/response/event types written as TypeScript interfaces (not prose)?
- Are optional fields marked with `?` and their default behavior specified?
- Do DTO types (what the API receives) and Input types (what the UseCase receives) have an explicit mapping? (e.g., controller adds `userId` from JWT)
- Are array element types specified? (`items: string[]` not `items: array`)
- Are date fields explicitly typed as `Date` or `string` (ISO format)?

**Red flag:** The word "data" or "info" used as a type description instead of a concrete interface.

---

### 3. Boundary Conditions

**Problem it prevents:** Agent doesn't handle empty arrays, zero values, null inputs, or pagination edges because the design only described the happy path.

**Check:**
- What happens when a list input is empty? (e.g., `productIds: []`)
- What happens with zero/negative numeric inputs?
- What is the max length for string fields?
- For paginated endpoints: what does the response look like when there are zero results?
- For bulk operations: is there a batch size limit?

**Red flag:** Numeric or array inputs with no documented min/max constraints.

---

### 4. Existing Code Collision

**Problem it prevents:** Agent creates a new utility/helper/guard that already exists, or uses a different naming pattern than the codebase.

**Check:**
- Has the Codebase Context section been populated by actually scanning the codebase (not from memory)?
- Are ALL shared utilities listed in the "Reuse" section? (exception classes, DTOs, guards, interceptors, decorators)
- Does the file naming match existing conventions? (check 3+ existing files for pattern)
- Do method names match existing patterns? (check 3+ existing similar methods)
- Are import paths using the project's path aliases (e.g., `@app/` vs relative `../../`)?

**Red flag:** The "Reuse" section has fewer than 3 items. Every NestJS project has shared code.

---

### 5. Wiring Gaps

**Problem it prevents:** Agent implements the UseCase perfectly but forgets to register it in the module, add the route, or declare the Kafka topic.

**Check:**
- Is the NestJS module file specified (where to add `providers`, `controllers`, `imports`)?
- For new modules: are `exports` specified for cross-module consumption?
- For Kafka: is the topic constant defined and the consumer group specified?
- For Prisma: is `prisma generate` / `prisma migrate` mentioned as a prerequisite step?
- For guards/interceptors: are they applied at controller or route level?

**Red flag:** An implementation unit that creates a UseCase but has no [MODIFY] entry for a module file.

---

### 6. Event Contract Integrity

**Problem it prevents:** Producer publishes an event with fields the consumer doesn't expect, or consumer assumes fields that the producer doesn't include.

**Check:**
- Is the event payload type defined in the Types Registry?
- Does every produced event have at least one documented consumer (even if external)?
- For events consumed from external services: is the payload type verified against the producer's documentation?
- Is the serialization format specified? (JSON assumed, but date formats matter)
- Is the ordering guarantee documented? (per-partition key for Kafka)

**Red flag:** A Kafka topic appears in the flow but has no entry in Cross-Cutting Concerns.

---

### 7. Implementation Unit Independence

**Problem it prevents:** Agent tries to implement everything at once, hits type errors from undefined dependencies, and loses coherence after 4+ files.

**Check:**
- Can each unit be implemented and tested without loading other units into context?
- Does each unit's "type context" contain ALL types referenced in its flow (copied from the Registry)?
- Does each unit's acceptance criteria define a verifiable checkpoint? (`tsc --noEmit` passes, specific tests pass)
- Are `depends_on` relationships minimal? (a unit should depend on as few others as possible)
- Is the total number of files per unit <= 5? If more, split the unit.

**Red flag:** A unit that depends on more than 2 other units, or a unit that modifies more than 5 files.

---

### 8. Transaction Boundaries

**Problem it prevents:** Agent wraps everything in a single transaction (performance kill) or wraps nothing (data inconsistency), because the design didn't specify where atomicity is needed.

**Check:**
- For multi-step writes: which steps must be atomic?
- Is the transaction scope explicitly stated? (`prisma.$transaction([...])`)
- For event publishing after DB writes: is it inside or outside the transaction?
- For distributed operations: is the failure recovery strategy specified? (saga, compensation, retry)
- For read-after-write: are there race conditions to address?

**Red flag:** A flow with 2+ database writes and no mention of transaction boundaries.

---

## Project-Discovered Perspectives

<!-- 
When a design-to-implementation gap is discovered during actual coding:
1. Add a new perspective here with the format below
2. Date-stamp it
3. Reference the specific incident

Format:
### [N]. [Perspective Name]
**Discovered:** [YYYY-MM-DD]  
**Incident:** [What happened — the agent did X because the design said/didn't say Y]  
**Problem it prevents:** [One sentence]  
**Check:** [Specific verification steps]  
**Red flag:** [Pattern that indicates this problem]
-->

---

## Lessons Log

<!--
Append-only log of design failures and what was learned.
Each entry creates or refines a perspective above.

Format:
### [YYYY-MM-DD] [Short title]
**Feature:** [Which feature's design doc failed]
**Gap:** [What the design doc said vs what was actually needed]
**Resolution:** [How the perspective was added/updated]
-->
