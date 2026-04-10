---
name: project-init
description: 검증된 스택 번들로 프로젝트를 초기화하고, 초기화 과정에서 발견된 패턴을 축적한다.
---

# /project-init — 프로젝트 초기화

새 프로젝트를 검증된 기술 스택 번들로 초기화한다.

**유형:** 진화 스킬 (core/evolution-engine.md 참조)

## 입력

프로젝트 디렉토리와 원하는 스택 설명. 예: "NestJS + Prisma + Kafka 기반 API 서비스"

## 프로세스

### Step 1: DETECT — 프로젝트 상태 감지

- 현재 디렉토리에 기존 파일이 있는지 확인 (package.json, tsconfig 등)
- 기존 파일이 있으면 사용자에게 경고하고 계속할지 확인
- 사용자가 설명한 스택 요구사항을 파악

### Step 2: ANALYZE — 번들 매칭

사용 가능한 번들을 두 소스에서 읽는다 (예: strategy/init/nestjs-prisma-kafka.md):
1. 기본 번들: strategy/init/*.md (플러그인 내장)
2. 발견된 패턴: ~/.bunnie-workflows/strategy/init/*.md (실전에서 축적)

요구사항에 가장 가까운 번들을 찾는다.
- 정확히 일치하는 번들이 있으면 사용
- 없으면 가장 가까운 번들을 기반으로 조정 필요 사항을 사용자에게 알림

### Step 3: EXTRACT — 스택 구성 확인

선택된 번들의 내용을 사용자에게 보여주고 확인:
- 의존성 목록과 버전
- 디렉토리 구조
- 아키텍처 규칙

추가/제거할 의존성이 있으면 조정.

### Step 4: APPLY — 프로젝트 생성

확정된 스택으로 프로젝트를 초기화:
- package.json 생성 (의존성 + 스크립트)
- 디렉토리 구조 생성
- 설정 파일 생성 (tsconfig, prisma schema 등)
- CLAUDE.md 생성 (아키텍처 규칙 + 테스트 관점)
- 의존성 설치

### Step 5: RECORD — 초기화 패턴 기록

프로젝트 초기화 후 첫 1주 이내에 발견되는 패턴을 기록:
- 번들에 없었지만 추가로 필요했던 의존성
- 변경이 필요했던 설정값
- 번들의 버전이 오래되어 업데이트가 필요했던 경우

발견된 패턴을 `~/.bunnie-workflows/strategy/init/` 에 기록:

```bash
mkdir -p ~/.bunnie-workflows/strategy/init
```

해당 번들 파일의 "프로젝트 발견 패턴" 섹션에 추가:
```markdown
> 유래: YYYY-MM-DD [프로젝트명]에서 [발견 내용]
```

### Step 6: PROPAGATE — 전파

`~/.bunnie-workflows/strategy/init/`은 같은 머신의 모든 프로젝트가 공유. 다음 프로젝트 초기화 시 발견된 패턴이 자동 반영.

### 보고

사용자에게 결과 보고:
- 생성된 파일 목록
- 설치된 의존성
- 적용된 번들명
- 조정 사항이 있었다면 해당 내용
