# Как запустить

Главный запуск:

```bash
ansible-playbook -i inventory.ini site.yml
```

Отдельные playbooks:

```bash
ansible-playbook -i inventory.ini setup_base.yml
ansible-playbook -i inventory.ini install_docker.yml
ansible-playbook -i inventory.ini deploy_node_exporter.yml
```

## Требования
- Debian 12-13 или другая Debian-based система
- установленный Ansible
- текущий пользователь должен иметь sudo без запроса пароля
- для установки и запуска Docker должна быть доступна коллекция community.docker
- на целевой машине должен быть установлен python3 (обычно устанавливается вместе с ansible)

## Немного про каждую роль

### `roles/base`

- устанавливает `htop`, `curl`, `git`, `unzip`, `nginx`, `ufw`
- открывает порт `8080` в UFW
- открывает порт `22` в UFW
- создает пользователей `dev` и `monitoring`
- генерирует SSH-ключи для этих пользователей
- разворачивает `motd`
- настраивает Nginx на порту `8080`
- создает cron-задачу для `monitoring`

### `roles/docker`

- добавляет официальный Docker GPG-ключ и репозиторий
- устанавливает `docker-ce`, `docker-ce-cli`, `containerd.io`
- добавляет пользователя `dev` в группу `docker`
- запускает и включает сервис `docker`
- запускает контейнер `hello-world`

### `roles/node_exporter`

- скачивает Node Exporter
- распаковывает его в `/opt/node_exporter`
- создает ссылку `/usr/local/bin/node_exporter`
- создает systemd-юнит
- запускает сервис на порту `9100`
- проверяет доступность метрик

## Ручная проверка

После применения ролей можно проверить результат так:

```bash
curl http://<ip_виртуальной_машины>:8080
su - dev -c 'docker run --rm hello-world'
curl http://<ip_виртуальной_машины>:9100/metrics
systemctl status node_exporter
```
