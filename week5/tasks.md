### Tasks

#### Task 1

В директории Observability проекта создать .md файл с описанием что таке Observability и для чего он нужен. Также написать основные инструменты, которые применяются для улучшения Observability

#### Task 2

1. Установите Docker (если ещё не установлен):
```bash
sudo apt update && sudo apt install -y docker.io
sudo usermod -aG docker $USER
```
2. Создайте `docker-compose.yml` для запуска:
- `prom/prometheus`
- `grafana/grafana`
- `prom/node-exporter`

Пример структуры:
```yaml
version: '3'
services:
prometheus:
image: prom/prometheus:latest
ports:
- "9090:9090"
volumes:
- ./prometheus.yml:/etc/prometheus/prometheus.yml
command:
- '--config.file=/etc/prometheus/prometheus.yml'
- '--storage.tsdb.path=/prometheus'
- '--web.console.libraries=/etc/prometheus/console_libraries'
- '--web.console.templates=/etc/prometheus/consoles'

grafana:
image: grafana/grafana:latest
ports:
- "3000:3000"
environment:
- GF_SECURITY_ADMIN_PASSWORD=admin

node-exporter:
image: prom/node-exporter:latest
ports:
- "9100:9100"
```

3. Запустите: `docker-compose up -d`

> Результат: все три сервиса работают, доступны по:
> Prometheus: http://localhost:9090
> Grafana: http://localhost:3000 (логин/пароль: admin/admin)
> Node Exporter: http://localhost:9100/metrics

#### Task 3

1. Создайте `prometheus.yml`:
```yaml
global:
scrape_interval: 15s

scrape_configs:
- job_name: 'node'
static_configs:
- targets: ['host.docker.internal:9100'] # если Docker Desktop
# ИЛИ, если в Linux:
# targets: ['node-exporter:9100'] + добавить в сеть Compose
- job_name: 'prometheus'
static_configs:
- targets: ['localhost:9090']
```

В Linux: замените `host.docker.internal` на имя сервиса `node-exporter` и убедитесь, что все сервисы в одной сети Docker Compose.

2. Добавьте второй экземпляр node-exporter (например, на другой порт 9101) — чтобы моделировать несколько хостов.

3. Проверьте в Prometheus:
- Targets → все должны быть UP
- Выполните запрос: `up{job="node"}` → должно вернуть 1 для каждого хоста

> Результат: Prometheus собирает метрики с 2+ хостов.

#### Task 4

1. В Grafana:
- Добавьте источник данных Prometheus (`http://prometheus:9090` или `host.docker.internal:9090`)
- Создайте новый дашборд

2. Добавьте панели:
- CPU usage (%)
- Memory usage (%)
- Disk I/O
- Network traffic

3. Настройте переменную:
- Имя: `instance`
- Тип: Query
- Запрос: `label_values(node_uname_info, instance)`
- Используйте её в панелях: `rate(node_cpu_seconds_total{instance=~"$instance",mode="idle"}[1m])`

Результат: дашборд с динамическим выбором хоста через выпадающий список.

#### Task 5

1. В `prometheus.yml` добавьте секцию:
```yaml
rule_files:
- "alert_rules.yml"
```

2. Создайте `alert_rules.yml`:
```yaml
groups:
- name: host-alerts
rules:
- alert: HostDown
expr: up == 0
for: 1m
labels:
severity: critical
annotations:
summary: "Хост {{ $labels.instance }} недоступен"
description: "Job {{ $labels.job }} на {{ $labels.instance }} не отвечает более 1 минуты."

- alert: HighLatency
expr: rate(node_network_receive_bytes_total[1m]) < 100
for: 2m
labels:
severity: warning
annotations:
summary: "Низкая сетевая активность на {{ $labels.instance }}"
```

3. Перезапустите Prometheus.
4. Проверьте:
- В Prometheus → Alerts → правила отображаются
- Имитируйте падение хоста (остановите node-exporter) → алерт должен перейти в **Pending → Firing**

> Результат: алерты работают, описания корректны.

#### Task 6

Доступные инструменты

- Виртуальная машина с Debian
- Docker и docker-compose
- Уже развёрнутый стек Prometheus + Grafana (из основного задания недели 6)
- Приложение из недели 3, запущенное в контейнере

---

Пошаговое задание

### 1️⃣ Обновите `docker-compose.yml`

Добавьте в ваш существующий `docker-compose.yml` сервисы Loki и Promtail:

```yaml
loki:
image: grafana/loki:latest
ports:
- "3100:3100"
command: -config.file=/etc/loki/local-config.yaml

promtail:
image: grafana/promtail:latest
volumes:
- /var/log:/var/log:ro
- ./promtail-config.yml:/etc/promtail/config.yml:ro
command: -config.file=/etc/promtail/config.yml
```

> Убедитесь, что все сервисы (`prometheus`, `grafana`, `loki`, `promtail`, `node-exporter`) находятся в одной Docker-сети.

---

### 2️⃣ Настройте Promtail

Создайте файл `promtail-config.yml`:

```yaml
server:
http_listen_port: 9080
grpc_listen_port: 0

positions:
filename: /tmp/positions.yaml

clients:
- url: http://loki:3100/loki/api/v1/push

scrape_configs:
- job_name: system
static_configs:
- targets:
- localhost
labels:
job: varlogs
__path__: /var/log/*.log

- job_name: app
static_configs:
- targets:
- localhost
labels:
job: myapp
__path__: /var/lib/docker/containers/*/*-json.log
```

> ⚠️ Важно: путь `/var/lib/docker/containers/*/*-json.log` позволяет собирать логи всех Docker-контейнеров.
> Убедитесь, что Docker использует json-file драйвер логирования (по умолчанию — да).

Если у вас ограниченные права, можно логировать в файл и монтировать его:

```yaml
# Альтернатива: логи приложения в ./app.log
# В приложении: перенаправьте stdout/stderr в ./app.log
# В promtail-config.yml:
# __path__: /mnt/app.log
# И добавьте volume: ./app.log:/mnt/app.log:ro
```

---

### 3️⃣ Настройте Grafana

1. Откройте Grafana (`http://localhost:3000`)
2. Добавьте новый источник данных (Data Source):
- Тип: Loki
- URL: `http://loki:3100`
3. Сохраните.

---

### 4️⃣ Создайте дашборд с логами

1. В Grafana создайте новый дашборд → Add panel → Logs
2. В строке запроса введите:
```
{job="myapp"}
```
или
```
{job="varlogs"}
```
3. Убедитесь, что логи отображаются в реальном времени.
4. (Опционально) добавьте фильтрацию по уровню (`|~ "error"`), временным меткам, или объедините с графиками из Prometheus на одном дашборде.

---

### 5️⃣ Проверка

1. Запустите ваше приложение в Docker (оно должно писать логи в stdout/stderr).
2. Выполните несколько запросов к приложению.
3. В Grafana → Explore → Loki → `{job="myapp"}` — вы должны видеть логи контейнера.
4. Проверьте системные логи: `{job="varlogs"}` — должны отображаться записи из `/var/log/`.

---

Что сдать

- Обновлённый `docker-compose.yml`
- Файл `promtail-config.yml`
- Скриншоты:
- Grafana → Data Sources → Loki (успешное подключение)
- Grafana → Explore → логи приложения (`{job="myapp"}`)
- Grafana → Explore → системные логи (`{job="varlogs"}`)

---

Критерии сдачи

- [ ] В `docker-compose.yml` добавлены сервисы `loki` и `promtail`
- [ ] Promtail настроен на сбор:
- логов Docker-контейнеров **или** логов приложения из файла
- системных логов из `/var/log/`
- [ ] Loki добавлен как источник данных в Grafana
- [ ] Логи отображаются в реальном времени в интерфейсе Grafana
- [ ] Всё работает на вашей локальной Debian-ВМ