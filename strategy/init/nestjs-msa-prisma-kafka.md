# NestJS MSA + Prisma + Kafka 스택 번들

MSA(마이크로서비스) 아키텍처 기반. 서비스별 독립 배포, Kafka를 통한 이벤트 기반 통신.

> 검증: 2026-04-10 chain-indexer, crypto-vai 프로젝트에서 사용

## 아키텍처 특성

- 서비스별 독립 앱 (apps/[service]/)
- 공유 라이브러리 (libs/)
- Kafka를 통한 서비스 간 비동기 통신
- 서비스별 독립 Prisma 스키마 가능

## 의존성

### 코어
- @nestjs/core: ^11.0.0
- @nestjs/common: ^11.0.0
- @nestjs/platform-express: ^11.0.0
- class-validator: ^0.14.1
- class-transformer: ^0.5.1
- rxjs: ^7.8.1

### Prisma
- prisma: ^6.6.0
- @prisma/client: ^6.6.0

### Kafka
- @nestjs/microservices: ^11.0.0
- kafkajs: ^2.2.4

## 디렉토리 구조

```
apps/
  [service-a]/
    src/
      dto/
      usecases/
      controllers/
      [service-a].module.ts
      main.ts
  [service-b]/
    src/
      ...
libs/
  common/src/          # 공유 유틸, 에러 처리, 인터셉터
  types/src/           # 공유 타입, Kafka 토픽 정의
prisma/
  schema.prisma        # 공유 스키마 (또는 서비스별 분리)
docker-compose.yml     # Kafka, PostgreSQL, Redis 등
```

## 아키텍처 규칙

- Controller → UseCase(execute()) → Service
- DTO 위치: apps/[service]/src/dto/
- 에러: AppException + ErrorCode enum (libs/common)
- DB: Prisma, UUID PK, cursor pagination (encodeCursor/decodeCursor)
- Kafka 토픽 정의: libs/types/src/kafka.ts
- 서비스 간 통신: Kafka 이벤트만 (직접 HTTP 호출 금지)

## 설정 파일

### tsconfig.json
- strict: true
- esModuleInterop: true
- target: ES2022
- paths: libs/* 매핑

### prisma/schema.prisma
- provider: postgresql
- UUID PK: `id String @id @default(uuid())`
- 타임스탬프: `createdAt DateTime @default(now())`, `updatedAt DateTime @updatedAt`

## 프로젝트 발견 패턴

<!-- 이 번들로 프로젝트를 시작한 후 발견된 패턴들 -->
