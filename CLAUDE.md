# Claude Workflows — Global Rules

이 파일은 모든 프로젝트에 적용되는 글로벌 워크플로우 규칙이다.
`~/.claude/CLAUDE.md`로 심볼릭 링크하여 사용.

## 테스트 전략 자동 발전

### 버그 수정 시 (reactive)

1. **관점 분석**: 기존 테스트가 이 버그를 왜 잡지 못했는지, 어떤 테스트 관점이 누락되었는지 분석
2. **프로젝트 전략 업데이트**: 누락된 관점이 프로젝트 CLAUDE.md의 테스트 관점 목록에 없으면 추가. 있지만 커버리지가 부족하면 항목 보강. 추가 배경 한 줄 기록.
3. **동일 패턴 보강**: 버그와 같은 패턴을 공유하는 모듈에 해당 관점 테스트 보강. 프로젝트 전반 보강은 별도 요청 시에만.
4. **플러그인 동기화**: 새 관점이 발견되면 `claude-workflows/strategy/perspectives.md`에 추가하고 플러그인 레포에 커밋/푸시.

### 기능 구현 완료 시 (proactive)

기능이 완료되면 프로젝트 CLAUDE.md의 테스트 관점 목록을 참조하여 누락된 테스트가 없는지 확인:
- 새 API 엔드포인트 → contract + boundary 테스트 확인
- 새 이벤트/메시지 consumer → idempotency 테스트 확인
- 새 에러 핸들링 → error path 테스트 확인
- 데이터 직렬화 경계 → boundary 테스트 확인

### 프로젝트 초기화

프로젝트에 CLAUDE.md 테스트 관점 목록이 아직 없으면, `claude-workflows/strategy/perspectives.md`의 기본 관점을 참조하여 초기화를 제안.

## 플러그인 동기화 규칙

워크플로우 개선 사항이 발견되면:
1. 해당 스킬 파일 또는 전략 파일을 로컬 플러그인 디렉토리에서 업데이트
2. `cd <plugin-repo> && git add -A && git commit -m "evolve: <설명>" && git push`
3. 플러그인 레포 경로: 환경변수 `CLAUDE_WORKFLOWS_DIR` 또는 기본값 `~/workspace/github/bunnie198/claude-workflows`
