# 스킬 템플릿

새 스킬 작성 시 아래 템플릿 중 적합한 것을 복사하여 시작한다.

## 진화 스킬 템플릿

실전에서 발견된 패턴을 strategy 파일에 축적하는 스킬.
core/evolution-engine.md의 6단계 프로세스를 이 도메인에 맞게 구체화한다.

```markdown
---
name: [domain]-evolve
description: [도메인] 워크플로우에서 누락된 패턴을 분석하고 전략을 자동 발전시킨다.
---

# /[domain]-evolve — [도메인] 전략 자동 발전

[언제 이 스킬을 실행하는가?]

**유형:** 진화 스킬 (core/evolution-engine.md 참조)

## 입력

[어떤 입력을 받는가? diff, 에러 로그, 사용자 설명 등]

## 프로세스

이 스킬은 core/evolution-engine.md의 6단계 프로세스를 [도메인]에 맞게 구체화한 것이다.

### Step 1: DETECT — [도메인 특화 감지]
[이 도메인에서 어떤 이벤트가 트리거인가?]

### Step 2: ANALYZE — [도메인 특화 분석]
[기존 전략의 어떤 부분을 검토하는가? strategy/[domain]/*.md 참조]

### Step 3: EXTRACT — [도메인 특화 추출]
[발견된 패턴을 어떤 형태로 구조화하는가?]

### Step 4: APPLY — [도메인 특화 적용]
[발견된 패턴을 코드베이스에 어떻게 적용하는가? 이 단계가 핵심.]

### Step 5: RECORD — [도메인 특화 기록]
[strategy/[domain]/*.md와 프로젝트 CLAUDE.md를 어떻게 업데이트하는가?]

### Step 6: PROPAGATE — [도메인 특화 전파]
[core/sync-rules.md를 따라 플러그인 레포에 동기화]

### 보고
[사용자에게 어떤 결과를 보고하는가?]
```

## 정적 스킬 템플릿

정해진 절차를 따르는 스킬. Evolution Core를 참조하지 않는다.

```markdown
---
name: [domain]-[action]
description: [도메인]에서 [작업]을 수행한다.
---

# /[domain]-[action] — [설명]

[언제 이 스킬을 실행하는가?]

**유형:** 정적 스킬

## 프로세스

### Step 1: [단계명]
[구체적 절차]

### Step 2: [단계명]
[구체적 절차]

### Step N: 보고
[사용자에게 어떤 결과를 보고하는가?]
```
