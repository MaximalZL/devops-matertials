# Systemd

## Кратко

`systemd` — это системный менеджер и система инициализации в Linux. Он запускается одним из первых после ядра, поднимает службы, управляет зависимостями между ними и контролирует их состояние.

Основная сущность в `systemd` — это unit (юнит). Чаще всего в администрировании встречаются:

- `service` — сервис
- `socket` — сокет-активация
- `timer` — запуск по расписанию
- `target` — логическая группа юнитов
- `mount` — точка монтирования

## Где хранятся манифесты (unit-файлы)

На практике чаще всего используются такие каталоги:

- `/etc/systemd/system` — локальные юниты и переопределения администратора
- `/run/systemd/system` — временные юниты, созданные во время работы системы
- `/usr/lib/systemd/system` или `/lib/systemd/system` — юниты, установленные пакетным менеджером

Для пользовательского режима также могут использоваться:

- `~/.config/systemd/user`
- `/etc/systemd/user`
- `/usr/lib/systemd/user`

Важно: если unit с одинаковым именем есть в нескольких местах, более высокий приоритет обычно у `/etc/systemd/system`.

## Основные команды

- `systemctl status nginx` — посмотреть состояние сервиса
- `systemctl start nginx` — запустить сервис
- `systemctl stop nginx` — остановить сервис
- `systemctl restart nginx` — перезапустить сервис
- `systemctl reload nginx` — перечитать конфигурацию без полного перезапуска
- `systemctl enable nginx` — включить автозапуск
- `systemctl disable nginx` — отключить автозапуск
- `systemctl daemon-reload` — перечитать unit-файлы после изменения манифеста
- `systemctl list-units --type=service` — показать активные сервисы
- `systemctl list-unit-files` — показать установленные unit-файлы
- `journalctl -u nginx` — посмотреть логи сервиса

## Минимальный жизненный цикл работы

1. Создать или изменить unit-файл.
2. Выполнить `systemctl daemon-reload`.
3. Запустить сервис: `systemctl start <name>`.
4. При необходимости включить автозапуск: `systemctl enable <name>`.
5. Проверить состояние: `systemctl status <name>`.

## Источники

- [Systemd за пять минут](https://habr.com/ru/companies/slurm/articles/255845/)
- [systemd.unit](https://www.freedesktop.org/software/systemd/man/latest/systemd.unit.html)
