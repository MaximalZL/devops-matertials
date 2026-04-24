# Dockerfile Best Practices

## Чек-лист
- Используется `multi-stage build`
- Базовый образ минимальный и доверенный
- Нет `latest`; версия закреплена тегом и, по возможности, digest
- Есть `.dockerignore`
- Контейнер запускается не от `root` (`USER`)
- Секреты не передаются через `ARG`/`ENV`
- В CI есть lint + security scanning

## Практики по приоритету
| Практика | Зачем | Как делать |
|---|---|---|
| Multi-stage build | Уменьшает размер образа и поверхность атаки | Отдельный stage для сборки, в runtime копировать только артефакты |
| Минимальный base image | Меньше уязвимостей и быстрее pull | Выбирать slim/alpine/distroless/scratch под задачу |
| Пинning base image | Воспроизводимость сборок | `FROM image:tag@sha256:...` вместо плавающего `latest` |
| Логичный порядок слоев | Быстрее пересборки | Сначала lock-файлы и зависимости, потом исходники |
| Маленький build context | Меньше утечек и лишних инвалидирований кэша | Грамотный `.dockerignore` (`.git`, логи, артефакты, секреты) |
| Non-root runtime | Уменьшение риска получения повышенных прав | Создавать пользователя и задавать `USER` |
| Минимум пакетов | Меньше CVE (Common Vulnerabilities and Exposures - это публичный идентификатор уязвимости в формате CVE-ГОД-НОМЕР) и размер образа | Не ставить лишние утилиты; для apt использовать `--no-install-recommends` (ставить строго необходимые пакеты) |
| `COPY` предпочтительнее `ADD` | Прозрачнее поведение | `ADD` использовать только при необходимости URL/tar-распаковки |
| `HEALTHCHECK` | Быстрее детектируются "жив, но не работает" | Добавить HTTP/TCP probe с таймаутами и retry |
| CI-сборка и тесты | Раннее обнаружение проблем | Автосборка образа и smoke (проверка запускается или нет)/integration (проверка взаимодействия приложения) checks в pipeline |

## Дополнительные практики

### 1. BuildKit secrets вместо `ARG`/`ENV`
Секреты не должны оставаться в слоях образа и истории сборки.

```Dockerfile
RUN --mount=type=secret,id=npm_token \
    NPM_TOKEN=$(cat /run/secrets/npm_token) npm ci
```

### 2. Cache mounts и внешний кэш в CI
Ускоряют повторные сборки, особенно для пакетных менеджеров.

```Dockerfile
RUN --mount=type=cache,target=/root/.npm npm ci
```

Пример для CI buildx: `--cache-from ... --cache-to ...`.

### 3. Supply chain metadata: SBOM (Software Bill of Materials) и provenance
Полезно для аудита и контроля цепочки поставок.

```bash
docker buildx build --sbom=true --provenance=mode=max .
```

SBOM - список того, что внутри образа (пакеты, библиотеки, версии, зависимости).

Provenance - "паспорт" сборки (кто, где, чем и из какого исходника собрал образ).

Provenance можно посмотреть следующей командой:

```bash
docker buildx imagetools inspect <registry>/<repo>:<tag> --format "{{json .Provenance}}"
```

SBOM можно посмотреть так:

```bash
docker buildx imagetools inspect <registry>/<repo>:<tag> --format "{{json .SBOM}}"
```

Важно: `imagetools inspect` смотрит образы в реестре.

Запушить в реестр можно примерно такой командой:

```bash
docker buildx build -t <registry>/<repo>:<tag> --push --sbom=true --provenance=mode=max .
```

Если образ локально, то посмотреть метаданные так:

```bash
docker image inspect <image:tag>
```

SBOM без пуша в реестр так можно так:

```bash
docker buildx build --sbom=true --provenance=mode=max --output type=local,dest=out .
```

Если мы пушим docker.io registry, то команда будет примерно такой:

```bash
docker buildx build -t username/myapp:1.0 --push .
```

Если мы подняли какой-то свой, то указываем явно:

```bash
docker buildx build -t localhost:5000/myapp:1.0 --push .
```

### 4. Линт Dockerfile в CI (Hadolint)
Помогает автоматически находить типовые ошибки и антипаттерны.

```bash
docker run --rm -i hadolint/hadolint < Dockerfile
```

### 5. Метаданные образа через `LABEL`
Упрощает трассировку версии, репозитория, владельца и лицензии.

```Dockerfile
LABEL org.opencontainers.image.source="https://example.com/repo" \
      org.opencontainers.image.version="1.4.2"
```

## Антипаттерны
- `FROM something:latest` без контроля версии
- `COPY . .` в самом начале Dockerfile
- Секреты в `ENV`, `ARG` или прямо в файле
- Runtime от `root` без необходимости
- Установка "на всякий случай" дебаг-утилит в production-образ

## Пример Dockerfile
```Dockerfile
# syntax=docker/dockerfile:1
FROM node:20-alpine AS deps
WORKDIR /app
COPY package*.json ./
RUN --mount=type=cache,target=/root/.npm npm ci

FROM deps AS build
COPY . .
RUN npm run build

FROM gcr.io/distroless/nodejs20-debian12
WORKDIR /app
COPY --from=build /app/dist ./dist
USER 10001:10001
HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
  CMD ["/nodejs/bin/node","-e","fetch('http://127.0.0.1:3000/health').then(r=>process.exit(r.ok?0:1)).catch(()=>process.exit(1))"]
CMD ["dist/main.js"]
```