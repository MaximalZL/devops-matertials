# DevOps Homework Repository

## Структура

```text
week1/
├── linux-admin/
│   ├── debian-setup.md
│   ├── load-average.md
│   ├── linux-permissions.md
│   ├── linux-signals.md
│   ├── systemd.md
│   └── systemd/
│       ├── myapp-log.service
│       └── myapp-log.timer
├── scripts/
│    └── log-date.sh
└── README.md
```

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
