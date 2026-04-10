# Claude Workflows — Global Rules

이 파일은 플러그인 설치 시 자동 적용된다.

## 테스트 전략 자동 발전

### 버그 수정 시 (reactive)

1. **관점 분석**: 기존 테스트가 이 버그를 왜 잡지 못했는지, 어떤 테스트 관점이 누락되었는지 분석
2. **프로젝트 전략 업데이트**: 누락된 관점이 프로젝트 CLAUDE.md의 테스트 관점 목록에 없으면 추가. 있지만 커버리지가 부족하면 항목 보강. 추가 배경 한 줄 기록.
3. **동일 패턴 보강**: 버그와 같은 패턴을 공유하는 모듈에 해당 관점 테스트 보강. 프로젝트 전반 보강은 별도 요청 시에만.
4. **전략 기록**: 새 관점이 발견되면 `~/.bunnie-workflows/strategy/testing/perspectives.md`에 기록.

### 기능 구현 완료 시 (proactive)

기능이 완료되면 프로젝트 CLAUDE.md의 테스트 관점 목록을 참조하여 누락된 테스트가 없는지 확인:
- 새 API 엔드포인트 → contract + boundary 테스트 확인
- 새 이벤트/메시지 consumer → idempotency 테스트 확인
- 새 에러 핸들링 → error path 테스트 확인
- 데이터 직렬화 경계 → boundary 테스트 확인

### 프로젝트 초기화

프로젝트에 CLAUDE.md 테스트 관점 목록이 아직 없으면, 기본 관점(strategy/testing/perspectives.md)과 발견된 관점(~/.bunnie-workflows/strategy/testing/perspectives.md)을 참조하여 초기화를 제안.

## 설계 관점 자동 발전

설계 문서 기반으로 구현을 진행한 후, 설계→구현 갭이 발견되면:
1. 갭 유형을 분석 (타입 누락, 에러 흐름 미정의 등)
2. `~/.bunnie-workflows/strategy/design/perspectives.md`에 기록
3. 다음 설계 문서 생성 시 축적된 관점이 자동 반영

## 프로젝트 초기화 패턴 발전

프로젝트 초기화 후 발견되는 패턴:
1. 추가로 필요했던 의존성, 변경이 필요했던 설정값, 버전 호환성 문제를 기록
2. `~/.bunnie-workflows/strategy/init/`에 기록
3. 다음 프로젝트 초기화 시 반영

## 전략 동기화

발견된 관점/패턴은 `~/.bunnie-workflows/strategy/`에 기록된다. 같은 머신의 모든 프로젝트가 이 디렉토리를 공유하므로 자동 전파. 플러그인 레포에 반영하려면 `/bunnie-workflows:sync`로 PR을 생성한다.
