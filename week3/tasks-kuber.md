### Kubernetes

#### Task 1

В директории Kubernetes проекта создать .md файл с описанием архитектуры и всех компонентов Control plane и Data plane Kubernetes

#### Task 2

Предварительные условия

- Виртуальная машина с Debian (из недели 1)
- Установленный Docker
- Учётная запись на GitLab.com
- Приложение и Dockerfile из задания по Docker (неделя 3)

Пошаговое задание

1. Подготовка доступа к GitLab Container Registry

Создайте персональный токен в GitLab
1. Зайдите в GitLab → Preferences → Access Tokens
2. Создайте токен со следующими параметрами:
- Name: gitlab-registry-token
- Expiration date: 01.04.2026
- Scopes:
read_registry
write_registry
3. Скопируйте токен и сохраните его в безопасном месте (он покажется один раз!).

> Этот токен будет использоваться как пароль для docker login и imagePullSecret.

2. Сборка и публикация образа
Соберите и запушьте образ в GitLab Container Registry

1. Соберите образ локально:

bash
docker build -t registry.gitlab.com/<ваш-логин>/devops-app:latest .

2. Авторизуйтесь в GitLab Container Registry:

bash
docker login registry.gitlab.com -u <ваш-логин> -p <токен-из-2.1>

3. Запушьте образ:

bash
docker push registry.gitlab.com/<ваш-логин>/devops-app:latest


> Убедитесь, что образ появился в GitLab:
> Project → Packages & Registries → Container Registry

3. Настройка локального Kubernetes-кластера

Установите `kubectl` и `minikube`
bash
# Установка kubectl
sudo apt update && sudo apt install -y curl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Установка minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Запуск кластера
minikube start --driver=docker

#### Создайте namespace и секрет
bash
# Создание namespace
kubectl create namespace devops

# Создание imagePullSecret
kubectl create secret docker-registry registry-auth \
--docker-server=registry.gitlab.com \
--docker-username=<ваш-логин> \
--docker-password=<токен-из-2.1> \
-n devops


> Секрет `registry-auth` даёт кластеру право скачивать приватные образы из GitLab.

4. Создание и применение манифестов

#### Создайте файлы манифестов

##### `deployment.yaml`
yaml
apiVersion: apps/v1
kind: Deployment
metadata:
name: devops-app
namespace: devops
labels:
app: devops-app
spec:
replicas: 1
selector:
matchLabels:
app: devops-app
template:
metadata:
labels:
app: devops-app
spec:
imagePullSecrets:
- name: registry-auth
containers:
- name: app
image: registry.gitlab.com/<ваш-логин>/devops-app:latest
imagePullPolicy: Always
ports:
- containerPort: 8080
livenessProbe:
httpGet:
path: /health
port: 8080
initialDelaySeconds: 5
readinessProbe:
httpGet:
path: /health
port: 8080
initialDelaySeconds: 2


##### `service.yaml`
yaml
apiVersion: v1
kind: Service
metadata:
name: devops-app-svc
namespace: devops
spec:
type: NodePort
ports:
- port: 80
targetPort: 8080
nodePort: 30080 # Фиксированный порт для предсказуемости
selector:
app: devops-app


> Использование `nodePort: 30080` упрощает проверку доступности.

#### Примените манифесты
bash
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml


#### Проверьте развертывание
bash
kubectl get deployments -n devops
kubectl get pods -n devops
kubectl get services -n devops


#### Проверьте доступность приложения
bash
curl http://$(minikube ip):30080


> Должен вернуться ответ вашего приложения (например, `{"status": "ok"}`).

## Публикация в GitLab

1. Создайте публичный репозиторий: `devops-week3-k8s`
2. Загрузите манифесты:


k8s/
├── deployment.yaml
└── service.yaml

3. В `README.md` укажите:
- Как собрать и запушить образ
- Как развернуть в minikube
- Как проверить доступность

---
Критерии сдачи

- [ ] Образ успешно запушен в GitLab Container Registry
- [ ] В репозитории на GitLab есть файлы:
- `k8s/deployment.yaml`
- `k8s/service.yaml`
- [ ] Приложение развернуто в namespace `devops` в minikube
- [ ] В `Deployment` используется образ из GitLab Container Registry
- [ ] Приложение доступно по адресу: `http://<minikube-ip>:30080`
- [ ] Предоставлены скриншоты следующих команд:

bash
kubectl get nodes -o wide
kubectl get deployments -n devops
kubectl get pods -n devops
kubectl get services -n devops
---

## Советы

- Если minikube ip не отвечает — убедитесь, что вы используете драйвер docker и нет конфликта сетей.
- Для отладки:
kubectl describe pod <pod-name> -n devops
kubectl logs <pod-name> -n devops
- Не храните токен в репозитории! Он должен быть только у вас.
