---
name: bw-project-init
description: 검증된 스택 번들로 프로젝트를 초기화하고, 초기화 과정에서 발견된 패턴을 축적한다.
---

# /project-init — 프로젝트 초기화

새 프로젝트를 검증된 기술 스택 번들로 초기화한다.

**유형:** 진화 스킬 (core/evolution-engine.md 참조)

## 입력

프로젝트 디렉토리와 원하는 스택 설명. 예: "NestJS MSA + Prisma + Kafka 기반 API 서비스" 또는 "NestJS 모놀리틱 + Prisma"

## 프로세스

### Step 1: DETECT — 프로젝트 상태 감지

- 현재 디렉토리에 기존 파일이 있는지 확인 (package.json, tsconfig 등)
- 기존 파일이 있으면 사용자에게 경고하고 계속할지 확인
- 사용자가 설명한 스택 요구사항을 파악

### Step 2: ANALYZE — 번들 매칭

사용 가능한 번들을 두 소스에서 읽는다 (예: strategy/init/nestjs-msa-prisma-kafka.md):
1. 기본 번들: strategy/init/*.md (플러그인 내장)
2. 발견된 패턴: ~/.bunnie-workflows/strategy/init/*.md (실전에서 축적)

아키텍처 유형을 먼저 확인:
- MSA (마이크로서비스): 서비스별 독립 배포, 이벤트 기반 통신
- Monolith (모놀리틱): 단일 서비스, 모듈로 도메인 분리, 빠른 시작

요구사항에 가장 가까운 번들을 찾는다.
- 정확히 일치하는 번들이 있으면 사용
- 없으면 가장 가까운 번들을 기반으로 조정 필요 사항을 사용자에게 알림

### Step 3: EXTRACT — 버전 최신화 검토 + 스택 확인

**버전 최신화 검토:**

번들에 기록된 의존성 버전과 현재 npm registry의 최신 안정 버전을 비교한다:

```bash
npm view [패키지명] version
```

각 의존성에 대해:
- 번들 버전과 최신 안정 버전을 나란히 표시
- 메이저 버전 차이가 있으면 경고 (breaking changes 가능)
- 마이너/패치 차이만 있으면 최신 버전 사용 권장

사용자에게 버전 선택지를 제시:
- A) 번들 버전 유지 (검증된 조합)
- B) 최신 안정 버전으로 업데이트 (권장, 단 호환성 확인 필요)
- C) 패키지별 개별 선택

**스택 구성 확인:**

확정된 버전으로 최종 구성을 보여주고 확인:
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

### Step 5: RECORD — 자동 트리거 기반 번들 갱신

```bash
mkdir -p ~/.bunnie-workflows/strategy/init
```

RECORD는 3가지 자동 트리거로 동작한다:

**트리거 1: npm install 성공 후 버전 캡처**

의존성 설치가 성공하면 `package-lock.json`에서 실제 해석된 버전을 읽고, 번들 스냅샷과 비교한다. 차이가 있으면 사용자 공간의 번들 스냅샷을 자동 갱신:

```bash
# package-lock.json에서 실제 설치된 버전 추출
node -e "const lock = require('./package-lock.json'); Object.entries(lock.packages).filter(([k]) => k.startsWith('node_modules/')).forEach(([k,v]) => console.log(k.replace('node_modules/',''), v.version))"
```

`~/.bunnie-workflows/strategy/init/[번들명].md`의 의존성 버전을 실제 사용된 버전으로 갱신:

```markdown
## 의존성 (업데이트: YYYY-MM-DD)
### Prisma
- prisma: ^6.8.0    ← 6.6.0에서 업데이트, [프로젝트명]에서 검증
```

**트리거 2: 추가 의존성 설치 감지**

프로젝트 초기화 직후 세션에서 `npm install [패키지]`가 실행되면, 번들에 없던 의존성인지 확인한다. 없던 것이면 사용자에게 질문:

```
"[패키지명]이 번들에 없는 의존성입니다. 번들에 추가할까요?"
A) 이 번들의 기본 의존성으로 추가
B) 이 프로젝트에서만 사용 (번들 갱신 안 함)
```

A를 선택하면 `~/.bunnie-workflows/strategy/init/[번들명].md`에 추가.

**트리거 3: 설정 파일 변경 감지**

번들에서 생성한 설정 파일(tsconfig.json, prisma/schema.prisma 등)이 변경되면, 번들 기본값과 diff를 비교한다. 의미 있는 변경이면 사용자에게 질문:

```
"tsconfig.json이 번들 기본값과 다릅니다. 번들 기본값을 업데이트할까요?"
A) 번들 기본값 업데이트
B) 이 프로젝트에서만 사용
```

**호환성 문제 기록:**

최신 버전으로 올렸더니 문제가 발생한 경우, 경고 정보를 기록:

```markdown
## 프로젝트 발견 패턴

> 유래: YYYY-MM-DD [프로젝트명]에서 prisma 7.x는 @nestjs/common 11.x와 비호환 확인. 6.x 유지 권장.
```

다음 프로젝트 초기화 시 Step 3에서 이 경고가 표시된다.

### Step 6: PROPAGATE — 전파

`~/.bunnie-workflows/strategy/init/`은 같은 머신의 모든 프로젝트가 공유.

- 업데이트된 버전 스냅샷 → 다음 프로젝트에서 최신 검증 버전이 기본값
- 호환성 경고 → 다음 프로젝트에서 위험한 업그레이드 시 경고 표시
- 추가 의존성 발견 → 다음 프로젝트에서 번들 제안에 포함

### 보고

사용자에게 결과 보고:
- 생성된 파일 목록
- 설치된 의존성
- 적용된 번들명
- 조정 사항이 있었다면 해당 내용
