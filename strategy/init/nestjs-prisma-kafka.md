# NestJS + Prisma + Kafka 스택 번들

검증된 기술 스택 조합. 이 번들의 의존성과 설정은 실제 프로젝트에서 함께 동작함을 확인한 것이다.

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
  [service-name]/
    src/
      dto/
      usecases/
      controllers/
      [service-name].module.ts
      main.ts
libs/
  common/src/
  types/src/
prisma/
  schema.prisma
```

## 아키텍처 규칙

- Controller → UseCase(execute()) → Service
- DTO 위치: apps/[service]/src/dto/
- 에러: AppException + ErrorCode enum
- DB: Prisma, UUID PK, cursor pagination (encodeCursor/decodeCursor)
- Kafka 토픽 정의: libs/types/src/kafka.ts

## 설정 파일

### tsconfig.json
- strict: true
- esModuleInterop: true
- target: ES2022

### prisma/schema.prisma
- provider: postgresql
- UUID PK: `id String @id @default(uuid())`
- 타임스탬프: `createdAt DateTime @default(now())`, `updatedAt DateTime @updatedAt`

## 프로젝트 발견 패턴

<!-- 이 번들로 프로젝트를 시작한 후 발견된 패턴들 -->
<!-- 예: > 유래: YYYY-MM-DD [프로젝트명]에서 [발견 내용] -->
