### Helm

#### Task 1

Предварительные условия

- У вас уже есть:
- Виртуальная машина с Debian (из недели 1)
- Установленные Docker, kubectl, minikube
- Приложение с Dockerfile (из недели 3), образ которого залит в GitLab Container Registry

> Если образ ещё не в registry — соберите и запушьте его:
> docker build -t registry.gitlab.com/<ваш-логин>/myapp .
> docker login registry.gitlab.com
> docker push registry.gitlab.com/<ваш-логин>/myapp

---

## Пошаговое задание

#### 1.1 Установите Helm
bash
sudo apt update && sudo apt install -y helm
helm version


#### 1.2 Запустите minikube и включите модуль Ingress
minikube start --driver=docker
minikube addons enable ingress
kubectl get pods -n ingress-nginx # убедитесь, что контроллер запущен


#### 1.3 Создайте namespace и секрет для доступа к registry
kubectl create namespace helm-demo

# Создайте imagePullSecret для GitLab Container Registry
kubectl create secret docker-registry registry-auth \
--docker-server=registry.gitlab.com \
--docker-username=<ваш-gitlab-логин> \
--docker-password=<ваш-gitlab-token> \
--docker-email=<ваш-email> \
-n helm-demo>

Важно: используйте Personal Access Token с правами `read_registry`, а не пароль!

---

### 2. Создание Helm-чарта

#### 2.1 Сгенерируйте структуру чарта
bash
helm create demo-chart
cd demo-chart

#### 2.2 Удалите ненужные файлы
Удалите `templates/tests/` и всё, что не относится к вашему приложению (ServiceAccount, HPA и т.д.).

#### 2.3 Обновите `values.yaml`
Замените содержимое `values.yaml` на параметризованные значения, например:# values.yaml
replicaCount: 1

image:
repository: registry.gitlab.com/<ваш-логин>/myapp
tag: "latest"
pullPolicy: IfNotPresent

imagePullSecrets:
- name: registry-auth

podLabels:
app: myapp

service:
type: ClusterIP
port: 80

container:
port: 8080

ingress:
enabled: true
host: myapp.local
port: 80

#### 2.4 Обновите шаблоны в templates/

##### templates/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
name: {{ include "demo-chart.fullname" . }}
namespace: {{ .Release.Namespace }}
labels: {{- include "demo-chart.labels" . | nindent 4 }}
spec:
replicas: {{ .Values.replicaCount }}
selector:
matchLabels: {{- include "demo-chart.selectorLabels" . | nindent 6 }}
template:
metadata:
labels: {{- include "demo-chart.selectorLabels" . | nindent 8 }}
{{- range $key, $value := .Values.podLabels }}
{{ $key }}: {{ $value | quote }}
{{- end }}
spec:
{{- if .Values.imagePullSecrets }}
imagePullSecrets:
{{- toYaml .Values.imagePullSecrets | nindent 8 }}
{{- end }}
containers:
- name: {{ .Chart.Name }}
image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
imagePullPolicy: {{ .Values.image.pullPolicy }}
ports:
- containerPort: {{ .Values.container.port }}
livenessProbe:
httpGet:
path: /health
port: {{ .Values.container.port }}
initialDelaySeconds: 5
readinessProbe:
httpGet:
path: /health
port: {{ .Values.container.port }}
initialDelaySeconds: 2


##### `templates/service.yaml`
apiVersion: v1
kind: Service
metadata:
name: {{ include "demo-chart.fullname" . }}
namespace: {{ .Release.Namespace }}
labels: {{- include "demo-chart.labels" . | nindent 4 }}
spec:
type: {{ .Values.service.type }}
ports:
- port: {{ .Values.service.port }}
targetPort: {{ .Values.container.port }}
protocol: TCP
name: http
selector: {{- include "demo-chart.selectorLabels" . | nindent 4 }}


##### `templates/ingress.yaml`
{{- if .Values.ingress.enabled }}
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
name: {{ include "demo-chart.fullname" . }}
namespace: {{ .Release.Namespace }}
labels: {{- include "demo-chart.labels" . | nindent 4 }}
spec:
ingressClassName: nginx
rules:
- host: {{ .Values.ingress.host }}
http:
paths:
- path: /
pathType: Prefix
backend:
service:
name: {{ include "demo-chart.fullname" . }}
port:
number: {{ .Values.service.port }}
{{- end }}
##

### 3. Тестирование и развёртывание

#### 3.1 Протестируйте чарт локально (dry-run)
bash
helm install demo-release ./demo-chart \
--namespace helm-demo \
--create-namespace \
--dry-run --debug


#### 3.2 Разверните чарт
bash
helm install demo-release ./demo-chart --namespace helm-demo


#### 3.3 Проверьте доступность
bash
# Убедитесь, что поды работают
kubectl get pods -n helm-demo

# Получите IP minikube
minikube ip # например, 192.168.49.2

# Добавьте в /etc/hosts
echo "$(minikube ip) myapp.local" | sudo tee -a /etc/hosts

# Проверьте
curl http://myapp.local


> Приложение должно отвечать по `http://myapp.local` (порт 80)

---

### 4. Публикация в GitLab

1. Создайте репозиторий на GitLab: `devops-week6-helm`
2. Загрузите всю папку `demo-chart`:

bash
git init
git add .
git commit -m "Helm chart for demo app"
git remote add origin https://gitlab.com/<ваш-логин>/devops-week6-helm.git
git push -u origin main

---

## Критерии сдачи

- [ ] В GitLab загружен репозиторий с Helm-чартом (`demo-chart/`)
- [ ] Чарт параметризован через `values.yaml`
- [ ] В `values.yaml` задаются:
- метки для Pod (`podLabels`)
- `imagePullSecrets`
- тип сервиса (`service.type`)
- порт приложения в контейнере (`container.port`)
- порт сервиса (`service.port`)
- входящий порт Ingress (через `ingress.port`, хотя в Ingress он фиксирован — но можно использовать для будущей гибкости)
- [ ] Приложение развёрнуто в namespace `helm-demo` через `helm install`
- [ ] Приложение доступно по `http://myapp.local` (порт 80)
- [ ] Используется `imagePullSecret` для доступа к GitLab Container Registry

---

## Советы

- Для отладки: `helm get manifest demo-release -n helm-demo`
- Для обновления: измените `values.yaml` и выполните `helm upgrade demo-release ./demo-chart -n helm-demo`
- Для отката: `helm rollback demo-release 1 -n helm-demo`