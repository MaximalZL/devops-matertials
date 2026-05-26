### Tasks

#### Task 1

В директории DevSecOps проекта создать .md файл с описанием что таке DevSecOps и для чего он нужен. Также написать основные инструменты, которые применяются для DevSecOps

#### Task 2

Пошаговое задание

### 1️⃣ Установите Trivy на вашу Debian-ВМ
bash
# Установка через официальный способ
sudo apt-get install wget apt-transport-https gnupg lsb-release -y
wget -qO - https://aquasecurity.github.io/trivy-repo/debian/$(lsb_release -cs)/public.key | sudo apt-key add -
echo deb https://aquasecurity.github.io/trivy-repo/debian $(lsb_release -cs) main | sudo tee -a /etc/apt/sources.list.d/trivy.list
sudo apt-get update
sudo apt-get install trivy -y


Проверьте: `trivy --version`

---

### 2️⃣ Обновите `.gitlab-ci.yml`

Добавьте стадию `security` перед `build` или после `test`.

#### 2.1 Сканирование файлов зависимостей

yaml
scan-dependencies:
stage: security
image: aquasec/trivy:latest
script:
- trivy fs --security-checks vuln --exit-code 1 --severity CRITICAL,HIGH .
rules:
- if: '$CI_COMMIT_BRANCH == "main"'
tags:
- docker


> Это проверит `requirements.txt`, `package.json` и другие файлы в корне проекта.

#### 2.2 Сканирование Docker-образа (после сборки)

yaml
scan-image:
stage: security
image: aquasec/trivy:latest
services:
- docker:dind
before_script:
- docker login -u $CI_REGISTRY_USER -p $CI_JOB_TOKEN $CI_REGISTRY
- docker pull $CI_REGISTRY_IMAGE:$CI_COMMIT_SHORT_SHA
script:
- trivy image --exit-code 1 --severity CRITICAL,HIGH $CI_REGISTRY_IMAGE:$CI_COMMIT_SHORT_SHA
rules:
- if: '$CI_COMMIT_BRANCH == "main"'
tags:
- docker


> Образ должен уже существовать в registry — выполняется после стадии `build`.

#### 2.3 Сканирование Kubernetes-манифестов (опционально)

Если у вас есть папка `k8s/` или `charts/`:

yaml
lint-k8s:
stage: security
image: gcr.io/stackrox-io/kube-linter:latest
script:
- kube-linter lint k8s/ --config kube-linter-config.yaml || true
rules:
- if: '$CI_COMMIT_BRANCH == "main"'
allow_failure: true # чтобы не ломать пайплайн на первом этапе


Или через Trivy:

yaml
scan-configs:
image: aquasec/trivy:latest
script:
- trivy config --exit-code 1 --severity CRITICAL,HIGH k8s/
---

### 3️⃣ (Опционально) Настройте политику "fail on critical"

- В продакшен-ветке (main) пайплайн должен падать, если найдены CRITICAL/HIGH уязвимости.
- Для medium и low — можно использовать allow_failure: true или просто логировать.

---

### 4️⃣ Проверка

1. Закоммитьте изменения в .gitlab-ci.yml.
2. Запушьте в main.
3. Убедитесь, что в пайплайне появилась стадия security.
4. Попробуйте намеренно добавить уязвимую зависимость (например, старую версию requests в Python) — пайплайн должен упасть.

---

## Что сдать

- Обновлённый .gitlab-ci.yml с этапом сканирования.
- (Опционально) конфигурационные файлы: kube-linter-config.yaml, .trivyignore (если исключаете ложные срабатывания).
- Скриншоты:
- Успешного сканирования (если уязвимостей нет),
- Проваленного сканирования при наличии уязвимости,
- Отчёта Trivy в логах GitLab CI.

---

## Критерии сдачи

- [ ] В пайплайне есть стадия security.
- [ ] Выполняется сканирование зависимостей (trivy fs).
- [ ] Выполняется сканирование Docker-образа (trivy image).
- [ ] При обнаружении CRITICAL/HIGH уязвимости — пайплайн останавливается.
- [ ] Всё работает на вашем локальном GitLab Runner.
- [ ] Результаты сканирования видны в логах CI.

---

## Полезные ссылки

- Trivy Docs: https://aquasecurity.github.io/trivy/
- kube-linter: https://github.com/stackrox/kube-linter
- Checkov (альтернатива): https://www.checkov.io/