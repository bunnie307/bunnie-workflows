# Claude Workflows — Global Rules

이 파일은 모든 프로젝트에 적용되는 글로벌 워크플로우 규칙이다.
`~/.claude/CLAUDE.md`로 심볼릭 링크하여 사용.

## 스킬 유형

이 플러그인에는 두 가지 유형의 스킬이 있다:

- **진화 스킬**: 실전에서 발견된 패턴을 strategy 파일에 축적하는 스킬. core/evolution-engine.md의 6단계 프로세스를 따른다. 현재 테스트 도메인(test-evolve)에서만 검증됨.
- **정적 스킬**: 정해진 절차를 따르는 스킬. Evolution Core를 참조하지 않는다.

**주의:** 진화 메커니즘은 테스트 전략에서만 검증되었다. 새 스킬이 진화 스킬인지 정적 스킬인지는 도메인 특성에 따라 판단. 모든 스킬이 진화해야 한다고 가정하지 않는다.

## 전략 자동 발전

### 문제 발견 시 (reactive)

1. **감지/분석**: core/evolution-engine.md의 DETECT→ANALYZE 단계 실행. 해당 도메인의 strategy 파일을 읽고 기존 전략의 갭을 분석
2. **추출/적용**: EXTRACT→APPLY 단계 실행. 발견된 패턴을 구조화하고 코드베이스에 적용
3. **기록**: RECORD 단계 실행. 해당 도메인 strategy 파일에 추가 (core/strategy-schema.md 형식)
4. **전파**: PROPAGATE 단계 실행. 새 관점/패턴 발견 시 플러그인 레포에 동기화 (core/sync-rules.md 절차)

### 기능 구현 완료 시 (proactive)

기능이 완료되면 관련 도메인의 strategy 파일을 참조하여 누락된 검증 확인:

**테스트 도메인** (strategy/testing/perspectives.md):
- 새 API 엔드포인트 → contract + boundary 테스트 확인
- 새 이벤트/메시지 consumer → idempotency 테스트 확인
- 새 에러 핸들링 → error path 테스트 확인
- 데이터 직렬화 경계 → boundary 테스트 확인

(향후 도메인이 추가되면 각 도메인의 strategy 파일에 구체적 트리거→액션 매핑을 유지)

### 프로젝트 초기화

프로젝트에 CLAUDE.md 테스트 관점 목록이 아직 없으면, strategy/testing/perspectives.md의 기본 관점을 참조하여 초기화를 제안.

## 스킬 추가

1. `templates/skill-template.md`에서 진화 또는 정적 템플릿을 복사
2. `skills/[name]/SKILL.md`에 저장
3. 진화 스킬이면 `strategy/[domain]/`에 전략 파일도 생성 (`templates/strategy-template.md` 참조)
4. `./scripts/validate-structure.sh`로 구조 무결성 확인

## 구조 검증

스킬 추가/수정 후 반드시 실행:

```bash
./scripts/validate-structure.sh
```

검증 항목: 필수 파일, 스킬 프론트매터, 경로 참조 무결성, settings.json 글롭 매칭, strategy 스키마, 진화 스킬↔strategy 연결.

## 플러그인 동기화 규칙

core/sync-rules.md를 따른다. 요약:

1. 해당 스킬 파일 또는 전략 파일을 로컬 플러그인 디렉토리에서 업데이트
2. `cd <plugin-repo> && git add -A && git commit -m "evolve: <도메인> <설명>" && git push`
3. 플러그인 레포 경로: 환경변수 `CLAUDE_WORKFLOWS_DIR` 또는 기본값 `~/workspace/github/bunnie307/bunnie-workflows`
