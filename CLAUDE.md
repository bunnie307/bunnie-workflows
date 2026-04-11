# Claude Workflows — Global Rules

이 파일은 플러그인 설치 시 자동 적용된다.

## 자동 발전 규칙

이 플러그인의 진화 스킬(test-evolve, design-spec, project-init)은 실전에서 패턴을 발견하면 `~/.bunnie-workflows/strategy/`에 기록한다. 같은 머신의 모든 프로젝트가 이 디렉토리를 공유하므로 한 프로젝트의 학습이 다른 프로젝트에 자동 전파된다.

### 버그 수정 시

기존 테스트가 이 버그를 왜 잡지 못했는지 분석하고, 누락된 테스트 관점이 있으면:
1. 프로젝트 CLAUDE.md의 테스트 관점 목록에 추가
2. 동일 패턴의 다른 모듈에 테스트 보강
3. `~/.bunnie-workflows/strategy/testing/perspectives.md`에 기록

### 기능 구현 완료 시

프로젝트 CLAUDE.md의 테스트 관점 목록을 참조하여 누락된 테스트가 없는지 확인:
- 새 API 엔드포인트 → contract + boundary 테스트
- 새 이벤트/메시지 consumer → idempotency 테스트
- 새 에러 핸들링 → error path 테스트
- 데이터 직렬화 경계 → boundary 테스트

### 설계→구현 갭 발견 시

설계서에 없어서 구현 중 판단이 필요했던 부분이 있으면 `~/.bunnie-workflows/strategy/design/perspectives.md`에 기록.

### 프로젝트 초기화 후

번들에 없던 의존성 추가, 설정 변경, 버전 호환성 문제가 발생하면 `~/.bunnie-workflows/strategy/init/`에 기록.

## 프로젝트 초기화

프로젝트에 CLAUDE.md 테스트 관점 목록이 아직 없으면, 기본 관점과 발견된 관점을 참조하여 초기화를 제안.

## 전략 동기화

플러그인 레포에 반영하려면 `/bw-sync`로 PR을 생성한다.
