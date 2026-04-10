# bunnie-workflows

Claude Code 플러그인 — 자기 발전형 개발 워크플로우 자동화.

## 설치

```bash
# marketplace 등록
/plugin marketplace add bunnie307/bunnie-workflows

# 플러그인 설치
/plugin install bunnie-workflows
```

## 구조

```
bunnie-workflows/
  core/                    # Evolution Core (공통 지침 문서)
    evolution-engine.md    # 진화 스킬의 6단계 프로세스
    strategy-schema.md     # strategy 파일 형식 규격
    sync-rules.md          # 프로젝트 간 동기화 규칙
  strategy/                # 도메인별 축적된 전략
    testing/               # 테스트 도메인
      perspectives.md      # 테스트 관점 목록
  skills/                  # 스킬 (진화 + 정적)
  templates/               # 프로젝트/스킬/전략 템플릿
```

## 스킬

| 스킬 | 유형 | 실행 | 설명 |
|------|------|------|------|
| **test-evolve** | 진화 | `/bunnie-workflows:test-evolve` | 버그 → 관점 분석 → 전략 진화 |
| **test-audit** | 정적 | `/bunnie-workflows:test-audit` | 관점별 테스트 커버리지 감사 |
| **project-init** | 진화 | `/bunnie-workflows:project-init` | 검증된 스택 번들로 프로젝트 초기화 |
| **design-spec** | 진화 | `/bunnie-workflows:design-spec` | 에이전트 실행 가능한 설계 문서 생성 |
| **sync** | 정적 | `/bunnie-workflows:sync` | 발견된 전략을 플러그인 레포에 PR 동기화 |

## 스킬 유형

- **진화 스킬**: 실전에서 발견된 패턴을 strategy 파일에 축적. core/evolution-engine.md의 6단계 프로세스(DETECT→ANALYZE→EXTRACT→APPLY→RECORD→PROPAGATE)를 따른다.
- **정적 스킬**: 정해진 절차를 따르는 스킬. Evolution Core 불필요.

## 동작 원리

1. 버그 수정 시 `test-evolve` 스킬이 누락된 테스트 관점을 분석
2. 프로젝트 CLAUDE.md에 해당 관점을 추가하고 테스트 보강
3. 새 관점이 발견되면 `strategy/testing/perspectives.md`에 유래(provenance)와 함께 축적
4. 플러그인 업데이트로 다른 프로젝트/PC에서도 축적된 관점 활용

## 테스트 관점 (기본 7개)

1. **Unit** — 비즈니스 로직
2. **Integration** — 모듈 간 동작
3. **Contract** — API 소비자와의 계약
4. **Boundary** — 타입 변환 경계
5. **E2E** — 최종 사용자 관점
6. **Error Path** — 에러 응답
7. **Idempotency** — 중복/경합

프로젝트에서 새 관점이 발견되면 자동으로 8, 9, ... 번째 관점이 추가됩니다.

## 새 스킬 추가

1. `templates/skill-template.md`에서 진화 또는 정적 템플릿을 복사
2. `skills/[name]/SKILL.md`에 저장
3. 진화 스킬이면 `strategy/[domain]/` 디렉토리에 전략 파일도 생성 (`templates/strategy-template.md` 참조)

## 신규 프로젝트 적용

`templates/project-claude.md`를 프로젝트 CLAUDE.md에 복사하거나, 플러그인 설치 후 CLAUDE.md에 테스트 관점 섹션이 없으면 자동으로 초기화를 제안합니다.
