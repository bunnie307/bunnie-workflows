# 전략 동기화 규칙

발견된 전략의 저장과 전파 규칙.

## 저장 경로

발견된 전략은 사용자 공간에 저장한다:

```
~/.bunnie-workflows/strategy/
  testing/
    perspectives.md       # 실전에서 발견된 테스트 관점
  ...
```

디렉토리가 없으면 생성한다:

```bash
mkdir -p ~/.bunnie-workflows/strategy/testing
```

## 읽기 규칙

전략을 참조할 때는 두 소스를 합친다:

1. **기본 전략**: 플러그인의 `strategy/[domain]/*.md` (불변, 플러그인 업데이트로만 변경)
2. **발견된 전략**: `~/.bunnie-workflows/strategy/[domain]/*.md` (실전에서 축적)

## 쓰기 규칙

새 관점/패턴이 발견되면:

1. `~/.bunnie-workflows/strategy/[domain]/` 에 추가 (core/strategy-schema.md 형식)
2. 프로젝트 CLAUDE.md의 관련 섹션도 업데이트

플러그인의 `strategy/` 디렉토리는 직접 수정하지 않는다.

## 프로젝트 간 전파

`~/.bunnie-workflows/strategy/`는 같은 머신의 모든 프로젝트가 공유한다. 한 프로젝트에서 발견한 관점은 다른 프로젝트에서 즉시 사용 가능.

## 기록하지 않는 것

- 프로젝트 특화 설정 (프로젝트 CLAUDE.md에만 기록)
- 임시 디버깅 메모
- 검증되지 않은 가설 (실전에서 확인된 것만 기록)

## 플러그인 개발자용: base 승격

플러그인 개발자는 주기적으로 `~/.bunnie-workflows/strategy/`에 축적된 검증된 관점을 플러그인의 base 전략(`strategy/`)에 승격시킬 수 있다:

```bash
# 발견된 관점 확인
cat ~/.bunnie-workflows/strategy/testing/perspectives.md

# 검증된 관점을 플러그인 base에 반영
# (플러그인 레포에서 직접 편집 후 커밋/푸시)
```

승격된 관점은 다음 플러그인 업데이트 시 모든 사용자에게 배포된다.
