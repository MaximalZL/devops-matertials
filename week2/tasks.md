### Task 1

В директории Ansible проекта создать .md файл с описанием возможностей и компонентов Ansilbe, а также best practices по написанию playbook.
Развернуть 2 ВМ (Ansible + Linux для настройки)

### Task 2

2.1. В вашей Debian-VM (из недели 1):
- Установите Ansible через `apt`:
```bash
sudo apt update && sudo apt install -y ansible
```
- Проверьте версию: `ansible --version`


2.2 Настройте Ansible для работы с localhost без пароля:
- Добавьте в `/etc/ansible/hosts` группу `[local]` с `localhost ansible_connection=local`
- Или создайте свой `inventory.ini` в рабочей директории.

Результат: команда `ansible local -m ping` возвращает `SUCCESS`.

![task2-week2](week2/img/task2.png)

### Task 3

3.1 Настройте, чтобы Ansible могла управлять второй VM

![task3-week2](week2/img/task3.png)

### Task 4

Создайте плейбук `setup_base.yml`, который:

- Открывает 8080 порт в Firewall

- Создаёт двух пользователей: `dev` и `monitoring` (без пароля, с домашними каталогами)
- Создает SSH-ключи для этих пользователей
- Устанавливает пакеты: `htop`, `curl`, `git`, `unzip`, `nginx`,

- Создается файл конфигурации Nginx для работы на порту 8080
- Копирует файл `motd` в `/etc/motd` с приветственным сообщением
- Добавляет cron-задачу для `monitoring`: каждые 5 минут записывает дату в `/var/log/heartbeat.log`

Результат: плейбук запускается без ошибок, всё настроено. При обращении на порт 8080 отображается приветственная страничка Nginx
Протестируйте вручную.

![task4-1-week2](week2/img/task4-1.png)
![task4-2-week2](week2/img/task4-2.png)

### Task 5

Создайте плейбук `install_docker.yml`, который:

- Устанавливает Docker на Debian (по официальной инструкции через `apt`, но автоматизированно):
- Добавляет GPG-ключ Docker
- Добавляет репозиторий
- Устанавливает `docker-ce`, `docker-ce-cli`, `containerd.io`
- Добавляет пользователя `dev` в группу `docker`
- Запускает и включает службу `docker`
- Запускает тестовый контейнер `hello-world` через модуль `docker_container`

Подсказка: используйте модули `apt_key`, `apt_repository`, `apt`, `user`, `systemd`, `docker_container`.

Результат: `docker run hello-world` работает от пользователя `dev`.

![task5-1-week2](week2/img/task5-1.png)
![task5-2-week2](week2/img/task5-2.png)

### Task 6

Создайте плейбук `deploy_node_exporter.yml`, который:

- Скачивает актуальный релиз Node Exporter (например, `v1.8.0`) с GitHub через `get_url`
- Распаковывает архив в `/opt/node_exporter`
- Создаёт символическую ссылку `/usr/local/bin/node_exporter`
- Создаёт systemd-юнит для запуска Node Exporter на порту `9100`
- Запускает и включает службу
- Проверяет, что метрики доступны: `curl http://localhost:9100/metrics`

Результат: сервис работает, метрики отдаются.

![task6-1-week2](week2/img/task6-1.png)
![task6-2-week2](week2/img/task6-2.png)

### Task 7

7.1. Преобразуйте ваши плейбуки в роли:
- `roles/base` — пользователи, ПО, motd, cron
- `roles/docker` — установка Docker
- `roles/node_exporter` — установка и запуск экспортера

7.2. Создайте главный плейбук `site.yml`, который применяет все три роли к `local`.

7.3. Загрузите всё в GitLab:
- Создайте новый проект `devops-week2`
- Структура репозитория:
```
/roles
/base
/docker
/node_exporter
inventory.ini
site.yml
README.md
```

7.4. В `README.md` опишите:
- Как запустить: `ansible-playbook -i inventory.ini site.yml`
- Требования (Debian, sudo без пароля для текущего пользователя)
- Что делает каждая роль

Результат: репозиторий на GitLab.com с рабочей структурой ролей и инструкцией.