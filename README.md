# bunnie-workflows

Claude Code 플러그인 — 자기 발전형 테스트 전략 및 워크플로우 자동화.

## 설치

```bash
# marketplace 등록
/plugin marketplace add bunnie307/bunnie-workflows

# 플러그인 설치
/plugin install bunnie-workflows
```

## 스킬

| 스킬 | 실행 | 설명 |
|------|------|------|
| **test-evolve** | `/bunnie-workflows:test-evolve` | 버그 → 관점 분석 → 전략 진화 → 동기화 |
| **test-audit** | `/bunnie-workflows:test-audit` | 7관점 테스트 커버리지 감사 |

## 동작 원리

1. 버그 수정 시 `test-evolve` 스킬이 누락된 테스트 관점을 분석
2. 프로젝트 CLAUDE.md에 해당 관점을 추가하고 테스트 보강
3. 새 관점이 발견되면 `strategy/perspectives.md`에 자동 축적
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

## 신규 프로젝트 적용

`templates/project-claude.md`를 프로젝트 CLAUDE.md에 복사하거나, 플러그인 설치 후 CLAUDE.md에 테스트 관점 섹션이 없으면 자동으로 초기화를 제안합니다.
