# NestJS Monolith + Prisma 스택 번들

모놀리틱 아키텍처 기반. 단일 서비스로 빠르게 시작, 필요 시 MSA로 분리 가능한 구조.

## 아키텍처 특성

- 단일 앱, 모듈로 도메인 분리
- 모듈 간 직접 의존 허용 (같은 프로세스)
- 메시지 큐 없음 (필요 시 BullMQ 추가)

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

### Dev
- typescript: ^5.7.0
- ts-node: ^10.9.0
- @types/node: ^22.0.0
- jest: ^29.7.0
- ts-jest: ^29.2.0
- @types/jest: ^29.5.0
- eslint: ^9.0.0
- @typescript-eslint/eslint-plugin: ^8.0.0
- @typescript-eslint/parser: ^8.0.0
- prettier: ^3.4.0

## 디렉토리 구조

```
src/
  modules/
    [domain-a]/
      dto/
      usecases/
      controllers/
      [domain-a].module.ts
    [domain-b]/
      ...
  common/
    exceptions/
    interceptors/
    guards/
  app.module.ts
  main.ts
prisma/
  schema.prisma
```

## 아키텍처 규칙

- Controller → UseCase(execute()) → Service
- DTO 위치: src/modules/[domain]/dto/
- 에러: AppException + ErrorCode enum (src/common/exceptions/)
- DB: Prisma, UUID PK, cursor pagination
- 모듈 간 의존: 인터페이스를 통해 (직접 서비스 import 지양)

## 설정 파일

### tsconfig.json
- strict: true
- esModuleInterop: true
- target: ES2022

### prisma/schema.prisma
- provider: postgresql
- UUID PK: `id String @id @default(uuid())`
- 타임스탬프: `createdAt DateTime @default(now())`, `updatedAt DateTime @updatedAt`

## MSA 전환 가이드

이 모놀리스를 MSA로 분리할 때:
1. 각 모듈을 독립 앱으로 추출 (src/modules/[domain] → apps/[domain])
2. 공유 코드를 libs/로 이동 (src/common → libs/common)
3. 모듈 간 직접 의존을 Kafka 이벤트로 교체
4. nestjs-msa-prisma-kafka.md 번들 참조

## 프로젝트 발견 패턴

<!-- 이 번들로 프로젝트를 시작한 후 발견된 패턴들 -->
