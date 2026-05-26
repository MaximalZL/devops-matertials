# Официальный Python 3.8 в slim-варианте - проект использует старый стек (Flask 1.1.x), а slim уменьшает размер образа
FROM python:3.8-slim

# Не создавать .pyc внутри контейнера - меньше служебных кеш-файлов Python (если не отключить, то Python при считывании .py файлов будет создавать кеш и при последующих запусках будет использовать этот кеш)
ENV PYTHONDONTWRITEBYTECODE=1
# Логи Python без буферизации - сообщения сразу видны в `docker logs`
ENV PYTHONUNBUFFERED=1
# Не хранить pip-кэш - итоговый образ меньше
ENV PIP_NO_CACHE_DIR=1
# Точка входа Flask CLI - команды `flask initdb`, `flask translate compile`, `flask run` знают, какое приложение запускать
ENV FLASK_APP=todoism
# Режим production для Flask CLI - не включается dev-поведение
ENV FLASK_ENV=production
# Явно отключить debug - исключаем случайное включение debug
ENV FLASK_DEBUG=0
# Выбор класса конфигурации приложения из `todoism.settings`- приложение загрузит `ProductionConfig` через FLASK_CONFIG
ENV FLASK_CONFIG=production
# Слушать все сетевые интерфейсы контейнера - иначе сервис будет доступен только внутри контейнера, без доступа с хоста
ENV FLASK_RUN_HOST=0.0.0.0
# Порт приложения по умолчанию - Flask по умолчанию работает на 5000
ENV FLASK_RUN_PORT=5000

# Рабочая директория внутри контейнера
WORKDIR /app

# Сначала копируем только список зависимостей - если меняется код, но не зависимости, слой с установкой пакетов берется из кэша.
COPY requirements.txt ./
# Обновляем pip и ставим зависимости проекта - это минимально необходимый набор для запуска приложения в контейнере
RUN pip install --upgrade pip \
    && pip install -r requirements.txt

# Копируем исходный код приложения
COPY . .

# Компилируем файлы локализации (.po -> .mo) на этапе сборки - контейнер запускается уже с готовыми переводами
RUN flask translate compile

# Создаем непривилегированного пользователя и передаем ему права на /app - запуск не от root снижает риск при компрометации контейнера
# Дополнительно это нужно для записи SQLite файла базы в /app/data.db
RUN useradd --create-home --shell /usr/sbin/nologin appuser \
    && chown -R appuser:appuser /app
USER appuser

# Документируем порт сервиса - `EXPOSE` не открывает порт сам по себе, но явно показывает
EXPOSE 5000

# Базовая проверка работоспособности контейнера
HEALTHCHECK --interval=30s --timeout=3s --start-period=20s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:5000/', timeout=2)" || exit 1

# При старте контейнера инициализируем БД и запускаем сервер Flask
CMD ["sh", "-c", "flask initdb && flask run"]
