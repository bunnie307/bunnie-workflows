---
name: test-audit
description: 프로젝트의 테스트 커버리지를 7개 관점에서 감사하고, 누락된 영역을 보고한다.
---

# /test-audit — 테스트 커버리지 감사

프로젝트의 테스트를 7개 관점에서 분석하여 누락된 영역을 식별한다.

## 프로세스

### Step 1: 현황 파악

```bash
# 테스트 파일 목록
find . -name "*.spec.ts" -o -name "*.test.ts" | grep -v node_modules | sort

# 테스트 수
npx jest --listTests 2>/dev/null | wc -l

# 소스 파일 대비 테스트 비율
SRC=$(find apps/ libs/ -name "*.ts" -not -name "*.spec.ts" -not -name "*.test.ts" | grep -v node_modules | wc -l)
TEST=$(find . -name "*.spec.ts" -o -name "*.test.ts" | grep -v node_modules | wc -l)
echo "Source: $SRC, Tests: $TEST, Ratio: $(echo "scale=1; $TEST * 100 / $SRC" | bc)%"
```

### Step 2: 관점별 분석

프로젝트 CLAUDE.md의 테스트 관점 목록을 읽는다. 없으면 perspectives.md 기본 7관점 사용.

각 관점에 대해:
- 해당 관점의 테스트가 존재하는가?
- 커버리지는 충분한가? (모든 모듈/엔드포인트를 커버하는가?)
- 누락된 영역은?

### Step 3: 갭 보고서

| 관점 | 커버리지 | 누락 | 위험도 |
|------|----------|------|--------|
| Unit | 80% (16/20 usecases) | enrich-token-metadata, ... | 낮음 |
| Contract | 90% (18/20 endpoints) | GET /tokens/:addr/holders | 중간 |
| Boundary | 70% | ... | 높음 |
| ... | | | |

### Step 4: 보강 제안

위험도 높음 순서로 구체적 보강 작업 제안:
1. [파일명] — [누락된 테스트 설명]
2. ...

사용자에게 보강 진행 여부를 확인한 후 실행.
