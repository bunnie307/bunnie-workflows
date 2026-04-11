# bunnie-workflows

Claude Code 플러그인 — 자기 발전형 개발 워크플로우 자동화.

## 설치

```bash
# marketplace 등록
/plugin marketplace add bunnie307/bunnie-workflows

# 플러그인 설치
/plugin install bunnie-workflows
```

## 빠른 시작

설치 후 프로젝트에서 바로 사용:

```bash
# 1. 테스트 커버리지 감사 — 현재 테스트 상태를 7관점에서 분석
/bw-test-audit

# 2. 버그 수정 후 — 누락된 테스트 관점을 분석하고 전략을 진화
/bw-test-evolve

# 3. 새 프로젝트 시작 — 검증된 스택 번들로 초기화
/bw-project-init

# 4. 기능 설계 — 에이전트가 구현할 수 있는 수준의 설계 문서 생성
/bw-design-spec
```

처음이라면 `/bw-test-audit`부터 실행해보세요. 프로젝트의 테스트 현황을 관점별로 보여줍니다.

## 구조

```
bunnie-workflows/
  core/                          # Evolution Core (공통 지침 문서)
    evolution-engine.md          # 진화 스킬의 6단계 프로세스
    strategy-schema.md           # strategy 파일 형식 규격
    sync-rules.md                # 전략 동기화 규칙
  strategy/                      # 도메인별 기본 전략
    testing/perspectives.md      # 테스트 관점
    design/perspectives.md       # 설계 관점
    design/schema.md             # 설계 문서 스키마
    init/nestjs-monolith-prisma.md   # 모놀리틱 스택 번들
    init/nestjs-msa-prisma-kafka.md  # MSA 스택 번들
  skills/                        # 스킬 (진화 + 정적)
  templates/                     # 프로젝트/스킬/전략 템플릿
  scripts/                       # 개발 도구
    validate-structure.sh        # 구조 검증 스크립트
```

## 스킬

| 스킬 | 유형 | 실행 | 설명 |
|------|------|------|------|
| **bw-test-evolve** | 진화 | `/bw-test-evolve` | 버그 → 관점 분석 → 전략 진화 |
| **bw-test-audit** | 정적 | `/bw-test-audit` | 관점별 테스트 커버리지 감사 |
| **bw-project-init** | 진화 | `/bw-project-init` | 검증된 스택 번들로 프로젝트 초기화 |
| **bw-design-spec** | 진화 | `/bw-design-spec` | 에이전트 실행 가능한 설계 문서 생성 |
| **bw-sync** | 정적 | `/bw-sync` | 발견된 전략을 플러그인 레포에 PR 동기화 |

## 스킬 유형

- **진화 스킬**: 실전에서 발견된 패턴을 strategy 파일에 축적. core/evolution-engine.md의 6단계 프로세스(DETECT→ANALYZE→EXTRACT→APPLY→RECORD→PROPAGATE)를 따른다.
- **정적 스킬**: 정해진 절차를 따르는 스킬. Evolution Core 불필요.

## 동작 원리

진화 스킬은 실전에서 패턴을 발견하고 축적한다:

1. 버그 수정, 설계→구현 갭, 초기화 문제 등을 스킬이 분석
2. 프로젝트 CLAUDE.md에 발견된 관점을 추가
3. `~/.bunnie-workflows/strategy/`에 유래(provenance)와 함께 기록
4. 같은 머신의 모든 프로젝트가 이 디렉토리를 공유하므로 자동 전파
5. `/bw-sync`로 플러그인 레포에 PR을 보내면 다른 사용자에게도 배포

## 테스트 관점 (기본 7개)

1. **Unit** — 비즈니스 로직
2. **Integration** — 모듈 간 동작
3. **Contract** — API 소비자와의 계약
4. **Boundary** — 타입 변환 경계
5. **E2E** — 최종 사용자 관점
6. **Error Path** — 에러 응답
7. **Idempotency** — 중복/경합

프로젝트에서 새 관점이 발견되면 자동으로 8, 9, ... 번째 관점이 추가됩니다.

## 개발

플러그인에 새 스킬을 추가하거나 구조를 변경하려면 [DEVELOPMENT.md](DEVELOPMENT.md)를 참조.
