# Debian в VirtualBox: базовая настройка

## Установка

Debian удобно ставить в VirtualBox как минимальную систему без графического интерфейса. Такой вариант подходит для тренировки администрирования: система стартует в консоль, расходует меньше ресурсов и не отвлекает от работы с сервисами, пользователями и сетью.

После установки полезно проверить версию системы и имя хоста:

```bash
cat /etc/os-release
hostnamectl
```

## Обновление системы и базовые пакеты

Сразу после первого входа систему стоит обновить и поставить минимальный набор утилит администратора:

```bash
sudo apt update
sudo apt upgrade -y
sudo apt install -y git curl tcpdump htop stress openssl vim nano
```

Для быстрой проверки можно посмотреть версии установленных программ:

```bash
git --version
curl --version
tcpdump --version
htop --version
stress --version
openssl version
vim --version
nano --version
```

## Пользователи, группа и общая директория

Для совместной работы можно создать группу `devops` и двух пользователей `alice` и `bob`:

```bash
sudo groupadd devops
sudo useradd -m -s /bin/bash -G devops alice
sudo useradd -m -s /bin/bash -G devops bob
sudo passwd alice
sudo passwd bob
```

Проверка членства в группе:

```bash
id alice
id bob
getent group devops
```

Общую директорию удобно создать так:

```bash
sudo mkdir -p /shared
sudo chown root:devops /shared
sudo chmod 2770 /shared
```

Здесь `2770` означает, что владелец и группа могут читать, писать и заходить в каталог, остальные доступа не имеют, а бит `setgid` сохраняет группу `devops` для новых файлов внутри каталога.

Проверка прав:

```bash
ls -ld /shared
```

## Скрипт и запуск по timer в systemd

Скрипт для записи текущей даты лежит в `week1/scripts/log-date.sh`. Его можно установить так:

```bash
sudo cp week1/scripts/log-date.sh /usr/local/bin/log-date.sh
sudo chmod +x /usr/local/bin/log-date.sh
```

Манифесты `systemd` лежат в `week1/linux-admin/systemd/`:

```bash
sudo cp week1/linux-admin/systemd/myapp-log.service /etc/systemd/system/
sudo cp week1/linux-admin/systemd/myapp-log.timer /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now myapp-log.timer
```

Проверить работу сервиса и таймера можно так:

```bash
systemctl status myapp-log.timer
systemctl list-timers --all | grep myapp-log
journalctl -u myapp-log.service
tail -n 5 /var/log/myapp.log
```

## TLS: самоподписанный сертификат

Самоподписанный сертификат создается командой:

```bash
openssl req -x509 -newkey rsa:2048 -keyout key.pem -out cert.pem -days 365 -nodes
```

Проверить содержимое сертификата можно так:

```bash
openssl x509 -in cert.pem -text -noout
```

## SSH по ключу

Для локальной проверки входа по ключу можно использовать `ed25519`:

```bash
ssh-keygen -t ed25519 -C "local-debian"
```

Публичный ключ добавляется в `authorized_keys`:

```bash
mkdir -p ~/.ssh
chmod 700 ~/.ssh
cat ~/.ssh/id_ed25519.pub >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```

После этого вход проверяется командой:

```bash
ssh localhost
```

Если соединение не устанавливается, обычно помогает установка и запуск SSH-сервера:

```bash
sudo apt install -y openssh-server
sudo systemctl enable --now ssh
sudo systemctl status ssh
```

## Что показать на скриншотах

Для отчета достаточно показать:

- `id alice`
- `id bob`
- `getent group devops`
- `ls -ld /shared`

Дополнительно можно показать:

- `systemctl status myapp-log.timer`
- `journalctl -u myapp-log.service`
- `tail -n 5 /var/log/myapp.log`
