### Tasks

#### Task 1

В директории Gitlab проекта создать .md файл с описанием:

для чего нужна практика CI/CD.
что такое TTM. Как связаны CI/CD и TTM.
перечислить все этапы CI/CD
описать на каком шаге заканчивается CI и на каком начинается CD
обьяснить чем отличется Continuous delivery и Continuous deployment
В директории Gitlab проекта создать .md файл с описанием GitLab и его компонентов

#### Task 2

Предварительные условия

- Виртуальная машина с Debian (из недели 1)
- Установленные Docker, Git
- Учётная запись на GitLab.com
- Проект на GitLab с Dockerfile и приложением (из недели 3)

Пошаговое задание

Настройка GitLab Runner

Установите и зарегистрируйте GitLab Runner

1. Установите gitlab-runner:

bash
curl -L https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh | sudo bash
sudo apt install -y gitlab-runner


2. Убедитесь, что Docker установлен и запущен:

bash
sudo systemctl status docker # должен быть active (running)
sudo usermod -aG docker gitlab-runner # добавьте runner в группу docker
sudo systemctl restart gitlab-runner


3. Получите токен регистрации:
- Зайдите в ваш проект на GitLab → Settings → CI/CD → Runners
- Скопируйте Project registration token

4. Зарегистрируйте runner:

bash
sudo gitlab-runner register \
--non-interactive \
--url "https://gitlab.com/" \
--registration-token "<ваш-token>" \
--executor "docker" \
--docker-image "docker:20.10.16" \
--description "local-docker-runner" \
--tag-list "docker" \
--run-untagged="true"


После регистрации проверьте в интерфейсе GitLab: runner должен появиться в разделе Runners с галочкой ✅.

2. Создание CI/CD-пайплайна

2.2 Напишите `.gitlab-ci.yml` для сборки, публикации и развёртывания

В корне вашего проекта создайте файл `.gitlab-ci.yml` со следующим содержанием:

yaml
stages:
- build
- deploy

variables:
DOCKER_TLS_CERTDIR: "/certs"
IMAGE_NAME: $CI_REGISTRY_IMAGE:$CI_COMMIT_SHORT_SHA

before_script:
- echo "Вход в GitLab Registry"
- docker login -u $CI_REGISTRY_USER -p $CI_JOB_TOKEN $CI_REGISTRY

build-image:
stage: build
image: docker:20.10.16
script:
- echo "Сборка образа: $IMAGE_NAME"
- docker build -t $IMAGE_NAME .
- echo "Публикация образа"
- docker push $IMAGE_NAME
- docker tag $IMAGE_NAME $CI_REGISTRY_IMAGE:latest
- docker push $CI_REGISTRY_IMAGE:latest
rules:
- if: '$CI_COMMIT_BRANCH == "main"'

deploy-to-docker:
stage: deploy
image: docker:20.10.16
script:
- echo "Остановка и удаление старого контейнера (если есть)"
- docker stop myapp || true
- docker rm myapp || true
- echo "Запуск нового контейнера из образа: $IMAGE_NAME"
- docker run -d --name myapp -p 8080:8080 $IMAGE_NAME
rules:
- if: '$CI_COMMIT_BRANCH == "main"'
tags:
- docker


Важно:
> - Образ публикуется с тегом `short SHA` и `latest`.
> - На стадиях build и deploy runner выполняет команды на своей ВМ — то есть там, где установлен `gitlab-runner`.
> - Порт `8080` должен совпадать с портом, на котором слушает ваше приложение.


3. Проверка работы

1. Закоммитьте и запушьте изменения:

bash
git add .gitlab-ci.yml
git commit -m "Add CI/CD pipeline"
git push origin main


2. Откройте CI/CD → Pipelines в GitLab и дождитесь успешного выполнения.

3. На вашей Debian-ВМ проверьте:

bash
docker ps
# Должен быть контейнер myapp
curl http://localhost:8080
# Должен вернуться ответ вашего приложения

Структура репозитория

your-project/
├── app.py (или index.js и т.п.)
├── Dockerfile
├── .dockerignore
├── .gitlab-ci.yml
└── README.md
В README.md укажите:
- Как настроить runner
- Как работает пайплайн
- Как проверить развёртывание

Критерии сдачи

- [ ] На ВМ установлен и зарегистрирован gitlab-runner с executor docker
- [ ] Runner активен в интерфейсе GitLab (зелёная галочка)
- [ ] В репозитории есть файл .gitlab-ci.yml
- [ ] Пайплайн состоит из двух стадий: build и deploy
- [ ] Образ собирается и публикуется в GitLab Container Registry
- [ ] После успешного пайплайна приложение запущено в Docker на ВМ (контейнер myapp)
- [ ] Приложение доступно по http://localhost:8080
- [ ] Предоставлены скриншоты:
- Страницы Runners в GitLab (активный runner)
- Успешного пайплайна в GitLab CI/CD
- Результата команды docker ps на ВМ
- Ответа curl http://localhost:8080

---
Советы

- Если runner не запускает job — проверьте теги: в .gitlab-ci.yml указан tags: [docker], и runner должен иметь такой же тег или run-untagged: true.
- Для отладки: посмотрите логи runner — sudo gitlab-runner --debug run
- Не храните чувствительные данные в .gitlab-ci.yml — используйте CI/CD Variables в GitLab UI.

#### Task 3

Задание:
1. Добавьте в ваше приложение (из недели 3) простой unit-тест:
- Для Python: используйте pytest или unittest
2. В .gitlab-ci.yml добавьте стадию test **до** build:

yaml
test:
stage: test
image: python:3.11 # или node:18
script:
- pip install -r requirements.txt
- pytest tests/
3. Убедитесь, что при падении тестов — сборка не запускается.

Критерии сдачи:
- В репозитории есть папка tests/
- Пайплайн содержит стадию test
- При ошибке в тесте пайплайн прерывается (используйте rules или порядок стадий)

#### Task 4

Задание:
1. Настройте cache в .gitlab-ci.yml:

yaml
cache:
key: "$CI_COMMIT_REF_SLUG"
paths:
- .cache/pip
- venv/

2. Используйте кэш в стадиях `test` и `build`:

yaml
before_script:
- python -m venv venv
- source venv/bin/activate
- pip install --cache-dir .cache/pip -r requirements.txt
3. Убедитесь, что на втором запуске пайплайна зависимости устанавливаются быстрее.

Критерии сдачи:
- В .gitlab-ci.yml настроен cache
- Кэш используется в нескольких стадиях
- В логах пайплайна видно: «Restoring cache...» и «Saving cache...»

#### Task 5

Цель:
Научиться разворачивать приложение в разные окружения в зависимости от ветки (main → prod, dev → dev).

Задание:
1. В .gitlab-ci.yml настройте две стадии деплоя:

yaml
deploy-dev:
stage: deploy
script:
- kubectl config use-context dev-context # или локальный minikube
- helm upgrade --install myapp-dev ./charts/myapp -n dev --set image.tag=$CI_COMMIT_SHORT_SHA
rules:
- if: '$CI_COMMIT_BRANCH == "dev"'

deploy-prod:
stage: deploy
script:
- kubectl config use-context prod-context # или тот же minikube, но другой namespace
- helm upgrade --install myapp-prod ./charts/myapp -n prod --set image.tag=$CI_COMMIT_SHORT_SHA
rules:
- if: '$CI_COMMIT_BRANCH == "main"'
2. Создайте два namespace: dev и prod, и соответствующие imagePullSecrets в каждом.

Критерии сдачи:
- При пуше в dev → деплой в namespace dev
- При пуше в main → деплой в namespace prod
- Оба окружения работают независимо

#### Task 6

Цель:
Создать автоматизированный пайплайн в GitLab CI/CD, который:
1. Собирает Docker-образ из исходного кода,
2. Публикует его в GitLab Container Registry,
3. Развертывает приложение в локальном Kubernetes-кластере (minikube) с помощью собственного Helm-чарта.

Предварительные условия

- Виртуальная машина с Debian
- Установленные:
- Docker
- kubectl
- minikube (запущен, Ingress включён)
- Helm
- В GitLab:
- Проект с приложением и Dockerfile (неделя 3)
- Helm-чарт в папке charts/myapp (неделя 4)
- На ВМ настроен и работает GitLab Runner с executor docker (из Задания 2)

Пошаговое задание

1️⃣ Подготовка Helm-чарта

Убедитесь, что в вашем репозитории есть структура:

your-project/
├── app/
│ ├── app.py (или index.js и т.п.)
│ └── Dockerfile
├── charts/
│ └── myapp/
│ ├── Chart.yaml
│ ├── values.yaml
│ └── templates/
│ ├── deployment.yaml
│ ├── service.yaml
│ └── ingress.yaml
└── .gitlab-ci.yml


В `values.yaml` чарта должны быть параметры:
yaml
image:
repository: "" # будет подставляться из CI
tag: "latest"

imagePullSecrets:
- name: registry-auth

service:
type: ClusterIP
port: 80

container:
port: 8080

ingress:
enabled: true
host: myapp.local


---

2️⃣ Настройка Kubernetes-доступа для Runner

Важно: Runner должен иметь доступ к `kubectl` и `~/.kube/config`.

1. На ВМ (где установлен runner), скопируйте kubeconfig:

bash
mkdir -p /home/gitlab-runner/.kube
cp /root/.kube/config /home/gitlab-runner/.kube/config # или из-под вашего пользователя
chown -R gitlab-runner:gitlab-runner /home/gitlab-runner/.kube
Также необходимо скопировать директорию minikube и сменить права

2. Убедитесь, что `gitlab-runner` может управлять кластером:

bash
sudo -u gitlab-runner kubectl get nodes


3. Создайте namespace и секрет один раз (вне пайплайна):

bash
kubectl create namespace ci-demo
kubectl create secret docker-registry registry-auth \
--docker-server=registry.gitlab.com \
--docker-username=<ваш-логин> \
--docker-password=<ваш-токен> \
-n ci-demo

---

3️⃣ Написание `.gitlab-ci.yml`

Создайте файл `.gitlab-ci.yml` в корне репозитория:

yaml
stages:
- build
- deploy

variables:
IMAGE_TAG: $CI_REGISTRY_IMAGE:$CI_COMMIT_SHORT_SHA
KUBE_NAMESPACE: ci-demo

before_script:
- echo "Авторизация в GitLab Registry"
- docker login -u $CI_REGISTRY_USER -p $CI_JOB_TOKEN $CI_REGISTRY

build-image:
stage: build
image: docker:20.10.16
services:
- docker:20.10.16-dind
script:
- echo "Сборка образа: $IMAGE_TAG"
- docker build -t $IMAGE_TAG .
- docker push $IMAGE_TAG
- docker tag $IMAGE_TAG $CI_REGISTRY_IMAGE:latest
- docker push $CI_REGISTRY_IMAGE:latest
rules:
- if: '$CI_COMMIT_BRANCH == "main"'

deploy-helm:
stage: deploy
image: alpine/k8s:latest # содержит kubectl, helm, docker
script:
- echo "Добавление Helm-чарта из локальной директории"
- helm upgrade --install myapp-release ./charts/myapp \
--namespace $KUBE_NAMESPACE \
--create-namespace \
--set image.repository=$CI_REGISTRY_IMAGE \
--set image.tag=$CI_COMMIT_SHORT_SHA \
--set imagePullSecrets[0].name=registry-auth
- echo "Проверка статуса релиза"
- helm status myapp-release --namespace $KUBE_NAMESPACE
- echo "Приложение доступно по: http://myapp.local"
rules:
- if: '$CI_COMMIT_BRANCH == "main"'
tags:
- docker # должен совпадать с тегом вашего runner


Используется образ `alpine/k8s`, который содержит `helm`, `kubectl`, `docker` — это избавляет от необходимости устанавливать их вручную.

---

4️⃣ Проверка работы

1. Закоммитьте и запушьте изменения:

bash
git add .
git commit -m "Add CI/CD with Helm deployment"
git push origin main


2. Откройте CI/CD → Pipelines в GitLab и дождитесь успешного выполнения.

3. На вашей ВМ проверьте:

bash
kubectl get pods -n ci-demo
helm list -n ci-demo
minikube ip # например, 192.168.49.2
echo "$(minikube ip) myapp.local" | sudo tee -a /etc/hosts
curl http://myapp.local


Должен вернуться ответ вашего приложения.

---

Структура репозитория


your-project/
├── app/ # исходный код и Dockerfile
├── charts/myapp/ # Helm-чарт
├── .gitlab-ci.yml
└── README.md
В README.md опишите:
- Как работает пайплайн
- Как настроить runner и kubectl
- Как проверить развёртывание

---

Критерии сдачи

- [ ] В репозитории есть Helm-чарт в папке charts/myapp
- [ ] В репозитории есть файл .gitlab-ci.yml
- [ ] Пайплайн состоит из двух стадий: build и deploy
- [ ] Образ собирается и публикуется в GitLab Container Registry
- [ ] Приложение развёрнуто через Helm в namespace ci-demo
- [ ] Приложение доступно по http://myapp.local
- [ ] В helm upgrade используются --set для передачи образа и тега
- [ ] Предоставлены скриншоты:
- Успешного пайплайна в GitLab
- Результата helm list -n ci-demo
- Результата kubectl get pods -n ci-demo
- Ответа curl http://myapp.local

---

Советы

- Если возникает ошибка cannot connect to the Kubernetes cluster, проверьте права на /home/gitlab-runner/.kube/config.
- Для отладки: добавьте --dry-run --debug к helm upgrade в пайплайн.
- Не храните токены в репозитории — используйте CI/CD Variables в GitLab UI для чувствительных данных (если они понадобятся позже).

#### Task 7

https://labex.io/ru/learn/jenkins