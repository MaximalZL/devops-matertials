### Docker

#### Task 1

В директории Docker проекта создать .md файл с описанием best practices по созданию Dockerfile

#### Task 2

Склонируйте репозиторий https://github.com/greyli/todoism

Для этого приложения напишите Dockerfile

[Посмотреть Dockerfile](week3/docker/todoism/Dockerfile)

#### Task 3

Склонируйте репозиторий https://github.com/gin-gonic/gin
В соответствии с инструкцией Your First Gin Application создайте WEB приложение

Для этого приложения напишите multi-stage Dockerfile:

- Stage 1: сборка
- Stage 2: запуск
- Используйте `.dockerignore`
- Добавьте `HEALTHCHECK`

Результат: `Dockerfile`, `app` (или аналог), команда `docker build -t myapp:demo .`, проверка `docker run -p 8080:8080 myapp:demo`.

#### Task 4

Цель: Научиться использовать Docker Compose для запуска многоконтейнерного приложения, включающего ваше веб-приложение и Nginx в роли reverse proxy

Требования к реализации

Создайте файл `docker-compose.yml`, который:

1. Запускает ваше приложение (из задания по Dockerfile на неделе 3):
- Использует образ, собранный из вашего `Dockerfile`.
- Контейнер не публикует порт наружу — приложение должно быть доступно только внутри Docker-сети.
- Приложение слушает на порту `8080` внутри контейнера.

2. Запускает Nginx из официального образа (`nginx:alpine` или `nginx:latest`):
- Порт `80` хоста пробрасывается на порт `80` контейнера (`80:80`).
- Используется volume для подключения кастомного конфигурационного файла Nginx (например, `./nginx/nginx.conf:/etc/nginx/nginx.conf`).
- Используется volume для сохранения логов Nginx (`./logs:/var/log/nginx`).

3. Настройте Nginx как reverse proxy:
- Весь HTTP-трафик, приходящий на `http://localhost` (порт 80), должен проксироваться на ваше приложение по адресу `http://<app-container>:8080`.
- Убедитесь, что используется внутреннее DNS-имя контейнера (например, `app`), а не `127.0.0.1`.

4. Сетевая изоляция:
- Приложение недоступно напрямую с хоста (порт 8080 не должен быть опубликован).
- Доступ возможен только через Nginx на порту 80.

Структура проекта

your-project/
├── app/
│ ├── app.py (или index.js и т.п.)
│ └── Dockerfile
├── nginx/
│ └── nginx.conf
├── logs/ # будет создан автоматически
└── docker-compose.yml


Пример содержимого `nginx.conf`:
```nginx
    events {
        worker_connections 1024;
    }

    http {
        upstream backend {
            server app:8080; # имя сервиса из docker-compose.yml
    }

server {
    listen 80;

    location / {
        proxy_pass http://backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }

        access_log /var/log/nginx/access.log;
        error_log /var/log/nginx/error.log;
    }
}

Ожидаемый результат

- После выполнения команды:
```bash
docker-compose up --build
```
- Приложение недоступно по `http://localhost:8080`
- Приложение доступно по `http://localhost` (порт 80)
- В папке `logs/` появляются файлы `access.log` и `error.log`
- В выводе `docker-compose ps` видно два контейнера: `app` и `nginx`

Подсказки

- Убедитесь, что в `docker-compose.yml` оба сервиса находятся в одной пользовательской сети (по умолчанию это так).
- Имя сервиса с приложением должно совпадать с именем в `upstream` (например, `app`).
- Не используйте `127.0.0.1` или `localhost` внутри Nginx для проксирования — это ссылается на сам контейнер Nginx, а не на соседний контейнер.
