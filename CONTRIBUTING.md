# 플러그인 개발 가이드

bunnie-workflows 플러그인 자체를 개발할 때의 규칙.

## 스킬 유형

- **진화 스킬**: 실전에서 발견된 패턴을 strategy 파일에 축적하는 스킬. core/evolution-engine.md의 6단계 프로세스(DETECT→ANALYZE→EXTRACT→APPLY→RECORD→PROPAGATE)를 따른다. 현재 테스트 도메인(test-evolve)에서만 검증됨.
- **정적 스킬**: 정해진 절차를 따르는 스킬. Evolution Core를 참조하지 않는다.

진화 메커니즘은 테스트 전략에서만 검증되었다. 새 스킬이 진화 스킬인지 정적 스킬인지는 도메인 특성에 따라 판단. 모든 스킬이 진화해야 한다고 가정하지 않는다.

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

## 디렉토리 구조

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
  scripts/                 # 개발 도구
    validate-structure.sh  # 구조 검증 스크립트
```
