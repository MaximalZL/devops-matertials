# DevOps Docs Repository

Учебный репозиторий с материалами, заданиями, конспектами и практическими файлами по DevOps: Linux, Git, Ansible, Docker, Kubernetes, CI/CD, Observability, SRE, GitOps и DevSecOps.

## Быстрая навигация

| Раздел | Тема | Материалы |
| --- | --- | --- |
| [Week 1](#week-1---фундамент-linux-git-скриптинг) | Linux, Git, скриптинг | [Tasks](week1/tasks.md) |
| [Week 2](#week-2---infrastructure-as-code-iac) | Infrastructure as Code, Ansible | [Tasks](week2/tasks.md), [Ansible Overview](week2/ansible-overview.md), [Run tasks](week2/run-tasks.md) |
| [Week 3](#week-3---контейнеризация-и-kubernetes-основы) | Docker, Kubernetes, Helm | [Docker tasks](week3/tasks-docker.md), [Kubernetes tasks](week3/tasks-kuber.md), [Helm tasks](week3/tasks-helm.md) |
| [Week 4](#week-4---cicd) | CI/CD | [Tasks](week4/tasks.md), [GitLab Overview](week4/gitlab-overview.md) |
| [Week 5](#week-5---observability) | Observability | [Tasks](week5/tasks.md) |
| [Week 6](#week-6---sre--gitops) | SRE, GitOps | [GitOps Cookbook](week6/docs/gitops+cookbook.pdf) |
| [Week 7](#week-7---devsecops) | DevSecOps | [Tasks](week7/tasks.md) |
| [Дополнительно](#дополнительно) | Разбор вопросов | [Questions](addition/questions.md) |

## Структура

```text
addition/
└── questions.md
week1/
├── git/
│   └── git.md
├── img/
│   └── screen_users_and_rights.jpg
├── linux-admin/
│   ├── bash.md
│   ├── debian-setup.md
│   ├── load-average.md
│   ├── linux-permissions.md
│   ├── linux-signals.md
│   ├── systemd.md
│   └── systemd/
│       ├── myapp-log.service
│       └── myapp-log.timer
├── scripts/
│   ├── log-date.sh
│   └── log_parser.sh
└── tasks.md
week2/
├── roles
│   ├── base/
│   │   ├── files
│   │   │    └── motd
│   │   ├── handlers
│   │   │    └── main.yml
│   │   ├── tasks
│   │   │    └── main.yml
│   │   ├── templates
│   │   │    └── nginx-8080.conf.j2
│   ├── docker/
│   │   └── tasks
│   │       └── main.yml
│   └── node_exporter/
│   │   ├── handlers
│   │   │    └── main.yml
│   │   ├── tasks
│   │   │    └── main.yml
│   │   └── templates
│   │        └── node_exporter.service.j2
├── img
│   ├── task2.png
│   ├── task3.png
│   ├── task4-1.png
│   ├── task4-2.png
│   ├── task5-1.png
│   ├── task5-2.png
│   ├── task6-1.png
│   └── task6-2.png
├── ansible-overview.md
├── base.yml
├── docker.yml
├── inventory.ini
├── node_exporter.yml
├── site.yml
├── run-tasks.md
└── tasks.md
week3/
├── docker
│   ├── gin-master/
│   │   └── ...
│   ├── todoism/
│   │   ├── ...
│   │   └── Dockerfile
│   └── dockerfile_overview.md
├── docs
│   ├── Helm.pdf
│   ├── Kubernetes лучшие практики. Раскрой потенциал главного инструмента в отрасли.pdf
│   ├── Kubernetes_для_DevOps_развертывание__запуск_и_масш.pdf
│   ├── Гадзурас+Эммануил+-+Docker+Compose+для+разработчика+-+2023.pdf
│   ├── Лукша Kubernetes в действии 2019.pdf
│   └── Осваиваем_Kubernetes._Оркестрация_контейнерных_арх.pdf
├── kubernetes
│   └── kubernetes-overview.md
├── tasks-docker.md
├── tasks-helm.md
└── tasks-kuber.md
week4/
├── docs
│   └── CICD_Pipeline_Using_Jenkins_Unleashed_Solutions_While_Setting_Up.pdf
├── gitlab-overview.md
└── tasks.md
week5/
└── tasks.md
week6/
└── docs
    └── gitops+cookbook.pdf
week7/
└── tasks.md
```

## Переход к материалам

### Linux Admin

- [Bash](week1/linux-admin/bash.md)
- [Debian setup](week1/linux-admin/debian-setup.md)
- [Load-average](week1/linux-admin/load-average.md)
- [Linux permissions](week1/linux-admin/linux-permissions.md)
- [Linux signals](week1/linux-admin/linux-signals.md)
- [Systemd](week1/linux-admin/systemd.md)

### Git

- [Git](week1/git/git.md)

### Systemd Files

- [myapp-log.service](week1/linux-admin/systemd/myapp-log.service)
- [myapp-log.timer](week1/linux-admin/systemd/myapp-log.timer)

### Scripts

- [log-date.sh](week1/scripts/log-date.sh)
- [log_parser.sh](week1/scripts/log_parser.sh)

### Ansible

- [Ansible Overview](week2/ansible-overview.md)
- [How run tasks week2](week2/run-tasks.md)

### Docker

- [Docker Overview](week3/docker/dockerfile_overview.md)

## Week 1 - Фундамент: Linux, Git, скриптинг

- [Tasks](week1/tasks.md)

## Week 2 - Infrastructure as Code (IaC)

- [Tasks](week2/tasks.md)
- [Ansible Overview](week2/ansible-overview.md)
- [How run tasks week2](week2/run-tasks.md)

## Week 3 - Контейнеризация и Kubernetes (основы)

### Docker

- [Основы Docker](https://habr.com/ru/companies/ruvds/articles/438796/)
- [Multi-stage buildings](https://habr.com/ru/articles/349802/?ysclid=mfuryrf5ew657198764)
- [Building best practices](https://docs.docker.com/build/building/best-practices/)
- [20 лучших практик по работе с Dockerfile](https://habr.com/ru/companies/domclick/articles/546922/?ysclid=mfurx0m7fl978009042)
- [Docker](https://labex.io/ru/learn/docker)
- [Docker Overview](week3/docker/dockerfile_overview.md)
- [Гадзурас Эммануил - Docker Compose для разработчика - 2023](week3/docs/Гадзурас+Эммануил+-+Docker+Compose+для+разработчика+-+2023.pdf)
- [Tasks Docker](week3/tasks-docker.md)

### Kubernetes

- [Kubernetes для начинающих](https://labex.io/ru/courses/kubernetes-for-beginners)
- [Шпаргалка](https://kubernetes.io/ru/docs/reference/kubectl/cheatsheet/)
- [Kubernetes_для_DevOps_развертывание__запуск_и_масш](week3/docs/Kubernetes_для_DevOps_развертывание__запуск_и_масш.pdf)
- [Лукша Kubernetes в действии 2019](week3/docs/Лукша%20Kubernetes%20в%20действии%202019.pdf)
- [Осваиваем_Kubernetes._Оркестрация_контейнерных_арх](week3/docs/Осваиваем_Kubernetes._Оркестрация_контейнерных_арх.pdf)
- [Kubernetes лучшие практики. Раскрой потенциал главного инструмента в отрасли](week3/docs/Kubernetes%20лучшие%20практики.%20Раскрой%20потенциал%20главного%20инструмента%20в%20отрасли.pdf)
- [Kubernetes](https://labex.io/ru/learn/kubernetes)
- [Kubernetes Overview](week3/kubernetes/kubernetes-overview.md)
- [Tasks Kubernetes](week3/tasks-kuber.md)

### Kubernetes Video Materials

- [01. Вводный вебинар. Зачем нужен Kubernetes？ Вечерняя школа С](https://disk.yandex.ru/i/ZBaI_eHGdDuTNg)
- [02. Что такое Docker？ Вечерняя школа Слёрма по Kubernetes](https://disk.yandex.ru/i/_hZHGJgYcb_9Ug)
- [04. Введение в Kubernetes, Pod, Replicaset. Вечерняя школа Слёрма по K](https://disk.yandex.ru/i/OnNL0ZqGxzlk3w)
- [05. Kubernetes： Deployment, Probes, Resources. Вечерняя школа Слёрма по Kuberne](https://disk.yandex.ru/i/IYQ5Ty_SZ4oxuQ)
- [06. Kubernetes- Ingress, Service, PV, PVC, ConfigMap, Secret. Вечерняя школа Слёрма по Kubernetes](https://disk.yandex.ru/i/9x3CLTx3toIo9Q)
- [07. Компоненты кластера Kubernetes. Вечерняя школа Слёрма по](https://disk.yandex.ru/i/b4Z1cO2WtSx7AQ)
- [08. Сеть Kubernetes, отказоустойчивый сетап кластера. Вечерн](https://disk.yandex.ru/i/2G-yR6LRIjzYnQ)
- [09. Kubespray. Установка кластера. Вечерняя школа Слёрма по Kubernetes](https://disk.yandex.ru/i/TyBO7udGovIx1g)
- [10. Продвинутые абстракции Kubernetes： Daemonset, Statefulset. Вечерняя](https://disk.yandex.ru/d/uI9kN6OraoTiZA)
- [11. Продвинутые абстракции Kubernetes： Job, CronJob, RBAC. Вечерняя ш](https://disk.yandex.ru/d/XGKAAaidVvlznA)
- [12. DNS в Kubernetes. Способы публикации приложений. Вечерняя ш](https://disk.yandex.ru/i/vFja27fxQDX3Fw)
- [13. Helm. Темплейтирование приложений Kubernetes. Вечерняя шко](https://disk.yandex.ru/i/wtLvvGyBz4yqxw)
- [14. Подключение СХД Ceph в Kubernetes с помощью CSI. Вечерняя шко](https://disk.yandex.ru/i/S8RcMAay5hTFvA)
- [15. Как сломать Кубернетес？ Disaster Recovery. Вечерняя школа Сл](https://disk.yandex.ru/i/VPYDE7Ul4__qSQ)
- [16. Обновление Kubernetes. Вечерняя школа Слёрма по Kubernetes](https://disk.yandex.ru/i/-eNEBz74MW3xKg)
- [17. Траблшутинг кластера. Решения проблем при эксплуата](https://disk.yandex.ru/d/d5_E8vElM8CzZg)
- [18. Мониторинг кластера Kubernetes. Вечерняя школа Слёрма по](https://disk.yandex.ru/d/Q7saCsPgfebhuw)
- [19. Логирование в Kubernetes. Сбор и анализ логов. Вечерняя шк](https://disk.yandex.ru/d/RyIv7i8UKr-RJQ)
- [20. Требования к разработке приложения в Kubernetes. Вечерня](https://disk.yandex.ru/i/-VWxnagjH-h50Q)
- [21. Докеризация приложения и CI⧸CD в Kubernetes. Вечерняя школа](https://disk.yandex.ru/i/xMiido5ZhBOg_g)
- [22. Observability — принципы и техники наблюдения за системой](https://disk.yandex.ru/i/Yob_kSlkKcq_Ew)
- [49 - Build и push container images в AWS ECR, используя Kaniko и GitLab CI. AWS IRSA](https://disk.yandex.ru/i/936mEHhad6fDkQ)

### Helm

- [Quickstart Guide](https://helm.sh/ru/docs/intro/quickstart/)
- [Using Helm](https://helm.sh/ru/docs/intro/using_helm/)
- [Практическое руководство](https://habr.com/ru/articles/769046/)
- [Helm](week3/docs/Helm.pdf)
- [Tasks Helm](week3/tasks-helm.md)

## Week 4 - CI/CD

- [Tasks](week4/tasks.md)
- [GitLab Overview](week4/gitlab-overview.md)
- [Введение в GitLab CI](https://habr.com/ru/companies/softmart/articles/309380/?ysclid=mfuso68pga189645905)
- [Шпаргалка по написанию Gitlab Pipelines](https://www.dmosk.ru/miniinstruktions.php?mini=gitlab-pipeline)
- [CICD_Pipeline_Using_Jenkins_Unleashed_Solutions_While_Setting_Up](week4/docs/CICD_Pipeline_Using_Jenkins_Unleashed_Solutions_While_Setting_Up.pdf)

## Week 5 - Observability

- [Tasks](week5/tasks.md)
- [Полное руководство по Prometheus в 2019 году](https://habr.com/ru/companies/slurm/articles/455290/)
- [Система визуализации и мониторинга. Grafana + Prometheus](https://habr.com/ru/articles/757494/)
- [Введение в мониторинг серверов с помощью Prometheus и Grafana](https://habr.com/ru/articles/652185/)
- [Для чего нужен Observability Engineering](https://habr.com/ru/companies/slurm/articles/713196/)

## Week 6 - SRE + GitOps

- [Станет ли GitOps новым прорывом в DevOps?](https://www.atlassian.com/ru/git/tutorials/gitops)
- [Что такое GitOps? Краткий обзор методологии и знакомство с ArgoCD](https://selectel.ru/blog/gitops-argocd/)
- [Gitops Cookbook](week6/docs/gitops+cookbook.pdf)
- [Ребята из Google не знали о DevOps и просто придумали то же колесо сами](https://slurm.io/blog/tpost/h6ijdoo7c1-rebyata-iz-google-ne-znali-o-devops-i-pr)
- [Что такое SRE и почему инженеры по доступности](https://education.yandex.ru/journal/chto-takoe-sre)
- [Кто такой SRE-инженер](https://education.vk.company/news/kto-takoj-sre-inzhener)
- [Вводная лекция о теории SRE](https://disk.yandex.ru/i/XVgyIyxPxqM4fA)

## Week 7 - DevSecOps

- [Tasks](week7/tasks.md)
- [Что такое DevSecOps](https://practicum.yandex.ru/blog/pro-devsecops-koncepciya-principy/)
- [Инструменты DevSecOps](https://www.atlassian.com/ru/devops/devops-tools/devsecops-tools)
- [DevSecOps: безопасность в CI/CD](https://slurm.io/blog/devsecops-bezopasnost-v-ci-cd)
- [SonarQube. Проверяем код на качество](https://habr.com/ru/articles/259149/)
- [Trivy](https://dockerhosting.ru/blog/trivy-polnoe-rukovodstvo-po-skanirovaniyu-uyazvimostej-docker-obrazov-v-2025-godu/)
- [Зачем нам Kyverno?](https://habr.com/ru/articles/761476/)
- [Усиление безопасности Kubernetes с помощью Kyverno, RuntimeClass и контейнеров Kata](https://habr.com/ru/companies/otus/articles/737814/)

### Дополнительные инструменты DevSecOps

- Статическимй анализ кода (SAST): SonarQube, PVS Studio, ESLint, Bandit
- Динамическое сканирование (DAST): PT BlackBox, Bright DAST
- Анализ зависимостей (SBOM): CodeScoring, Trivy, Grype, OWASP dependency check, Syft
- Безопасность Kubernetes и контейнеров: Trivy, Clair, Anchore, kube-bench, kube-audit, OPA, Kyverno
- Управление секретами: Hashi Vault

## Дополнительно

- [Разбор вопросов](addition/questions.md)