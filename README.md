# DevOps Homework Repository

## Структура

```text
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
└── scripts/
    ├── log-date.sh
    └── log_parser.sh
week2/
└── ansible/
    └── ansible-overview.md
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

- [Ansible Overview](week2/ansible/ansible-overview.md)

## Week 1

### Task 1:

В директории Linux проекта создать .md файл с описанием SystemD: краткое опиcание, в каких директорях храняться манифесты, основные команды

В директории Linux проекта создать .md файл с описанием Load Average

В директории Linux проекта создать .md файл с описанием категорий прав на файл, основные команды на смену прав.

В директории Linux проекта создать .md файл с описанием что такое сигналы Linux их типы, указать основные сигналы

### Task 2:

2.1 Установите Debian из ISO-образа в VirtualBox.
- Выберите минимальную установку без GUI

2.2 После установки:
- Обновите систему
- Установите необходимые пакеты: `git`, `curl`, `tcpdump`, `htop`, `stress`, `openssl`, `vim`/`nano`

2.3 Пользователи и права
- Создайте группу `devops` и пользователей `alice` и `bob`.
- Настройте общую директорию `/shared` с правами: только участники группы могут читать/писать.
- Проверьте права с помощью `ls -l` и `id`.

2.4 Systemd и journald
- Напишите простой bash-скрипт, который записывает текущую дату в `/var/log/myapp.log`.
- Создайте systemd-юнит и таймер для запуска скрипта каждые 2 минуты.
- Проверьте логи через `journalctl -u <имя_юнита>`.

2;5 TLS и SSH
- Сгенерируйте самоподписанный сертификат:
    ```bash
    openssl req -x509 -newkey rsa:2048 -keyout key.pem -out cert.pem -days 365 -nodes
    ```
- Настройте SSH-доступ по ключу (даже если локально):
- Сгенерируйте ключ (`ssh-keygen`)
- Добавьте публичный ключ в `~/.ssh/authorized_keys`
- Протестируйте вход: `ssh localhost`

Результат:

- Скриншоты
    - созданы пользователи alice и bob
    - создана группа devops
    - права на общую директорию /shared

- Текст
    - bash-скрипт
    - манифест systemd-юнита

### Screenshots

![Пользователи, группа devops и права на shared](week1/img/screen_users_and_rights.jpg)

### Task 3

В директории Linux проекта создать .md файл с кратким описанием Bash, описать требования к файлу, чтоб он мог выполнится как скрипт

### Task 4

В директории `week1/scripts` добавлен bash-скрипт [log_parser.sh](week1/scripts/log_parser.sh).

Что делает скрипт:

- читает `/var/log/syslog`, а если его нет, то `/var/log/messages`
- выбирает строки за последние 10 минут
- ищет строки с `error`, `fail`, `critical` без учета регистра
- сохраняет найденные строки в файл `errors_$(date +%F).log`
- отправляет содержимое через POST на `https://httpbin.org/post`
- если лог-файл не найден, завершает работу с кодом `1`
- если отправка не удалась, делает до 3 попыток с паузой 10 секунд

Запуск:

```bash
chmod +x week1/scripts/log_parser.sh
./week1/scripts/log_parser.sh
```

Если удобнее, можно запустить и так:

```bash
bash week1/scripts/log_parser.sh
```

### Task 5

В директории Git проекта создан файл [git.md](week1/git/git.md) с кратким описанием Git и его основных команд.

### Task 6

1. Создайте публичный проект на [GitLab.com] https://gitlab.com/.
2. Инициализируйте локальный репозиторий в папке с вашими заданиями:
```bash
git init
git remote add origin https://gitlab.com/<ваш-логин>/devops-week1.git
```
3. Реализуйте упрощённый Git Flow:
- `main` — стабильная версия (изначально пустая)
- `develop` — основная ветка разработки
- `feature/log-parser` — ветка для скрипта из задания 4
4. Создайте Merge Request (MR) из `feature/log-parser` в `develop`.
- В описании MR укажите:
- Цель: «Добавление утилиты парсинга логов»
- Как запустить
- Пример вывода
5. Включите code review — даже если нет реального ревьюера, добавьте комментарий от себя:
_«[Self-review] Проверил обработку ошибок и совместимость с Debian 12»_

## Week 2

### Task 1

В директории Ansible проекта создать .md файл с описанием возможностей и компонентов Ansilbe, а также best practices по написанию playbook.
Развернуть 2 ВМ (Ansible + Linux для настройки)