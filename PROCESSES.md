# Сценарии: Exocortex Setup Agent

## Сценарий 1: Развёртывание экзокортекса (первичная установка)

> Владелец: пользователь + setup-agent. Результат: работающий экзокортекс с автоматическим стратегом.

### Вход

- Пользователь с macOS, установленными Claude CLI и GitHub CLI
- Шаблон FMT-exocortex в upstream

### Действия

```
Пользователь                    Setup Agent                     GitHub
    │                               │                              │
    │  1. git clone setup-agent     │                              │
    │──────────────────────────────►│                              │
    │                               │                              │
    │  2. bash setup.sh             │                              │
    │──────────────────────────────►│                              │
    │                               │                              │
    │  3. Запрос параметров         │                              │
    │◄──────────────────────────────│                              │
    │  (username, workspace,        │                              │
    │   timezone, claude path)      │                              │
    │                               │                              │
    │  4. Ввод параметров           │                              │
    │──────────────────────────────►│                              │
    │                               │  5. gh repo fork template    │
    │                               │─────────────────────────────►│
    │                               │                              │
    │                               │  6. Подстановка переменных   │
    │                               │  (sed по всем файлам)        │
    │                               │                              │
    │                               │  7. Копирование:             │
    │                               │  - CLAUDE.md → workspace/    │
    │                               │  - memory/ → ~/.claude/      │
    │                               │  - settings.local.json       │
    │                               │                              │
    │                               │  8. Установка launchd        │
    │                               │  (strategist plist → load)   │
    │                               │                              │
    │                               │  9. Создание DS-strategy     │
    │                               │─────────────────────────────►│
    │                               │  (gh repo create --private)  │
    │                               │                              │
    │  10. "Setup Complete!"        │                              │
    │◄──────────────────────────────│                              │
    │                               │                              │
    │  11. cd DS-strategy && claude │                              │
    │  → первая стратегическая      │                              │
    │    сессия                     │                              │
```

### Выход

| Артефакт | Расположение |
|----------|-------------|
| Fork FMT-exocortex | `{WORKSPACE_DIR}/FMT-exocortex/` |
| CLAUDE.md (сконфигурированный) | `{WORKSPACE_DIR}/CLAUDE.md` |
| Оперативная память | `~/.claude/projects/.../memory/` |
| Claude permissions | `{WORKSPACE_DIR}/.claude/settings.local.json` |
| LaunchAgents (2 шт.) | `~/Library/LaunchAgents/com.strategist.*.plist` |
| DS-strategy (private GitHub repo) | `{WORKSPACE_DIR}/DS-strategy/` |

### Проверка успешности

- [ ] `ls {WORKSPACE_DIR}/FMT-exocortex/` — структура на месте
- [ ] `ls {WORKSPACE_DIR}/CLAUDE.md` — файл существует
- [ ] `launchctl list | grep strategist` — агенты загружены
- [ ] `gh repo view {GITHUB_USER}/DS-strategy` — репо создано
- [ ] Нет `{{...}}` placeholder-ов в файлах: `grep -r '{{' {WORKSPACE_DIR}/FMT-exocortex/`

---

## Сценарий 2: Обновление экзокортекса из upstream

> Владелец: пользователь. Результат: обновлённые промпты, протоколы и скрипты без потери личных данных.

### Вход

- Развёрнутый экзокортекс (после Сценария 1)
- Обновления в upstream (TserenTserenov/FMT-exocortex)

### Действия

```
Пользователь                       Git                          Upstream
    │                               │                              │
    │  1. cd FMT-exocortex     │                              │
    │──────────────────────────────►│                              │
    │                               │                              │
    │  2. git fetch upstream        │                              │
    │──────────────────────────────►│─────────────────────────────►│
    │                               │◄─────────────────────────────│
    │                               │  (новые коммиты)             │
    │                               │                              │
    │  3. git merge upstream/main   │                              │
    │──────────────────────────────►│                              │
    │                               │  Автоматический merge:       │
    │                               │  - промпты (platform-space)  │
    │                               │  - скрипты (platform-space)  │
    │                               │  - протоколы                 │
    │                               │                              │
    │  4. Если конфликты:           │                              │
    │     разрешить вручную         │                              │
    │                               │                              │
    │  5. Переустановить launchd    │                              │
    │     (при изменении plist)     │                              │
    │  bash DS-strategist/       │                              │
    │       install.sh              │                              │
    │                               │                              │
    │  6. Обновить CLAUDE.md        │                              │
    │     в workspace (при          │                              │
    │     изменении CLAUDE.md)      │                              │
    │  cp CLAUDE.md {WORKSPACE}/    │                              │
    │                               │                              │
    │  7. Обновить memory/          │                              │
    │     (кроме MEMORY.md)         │                              │
    │  cp memory/*.md ~/.claude/    │                              │
    │     projects/.../memory/      │                              │
    │  (НЕ перезаписывать           │                              │
    │   MEMORY.md!)                 │                              │
```

### Что обновляется (Platform-space)

| Компонент | Путь | Действие при обновлении |
|-----------|------|------------------------|
| Промпты стратега | `DS-strategist/prompts/*.md` | Автоматически (git merge) |
| Скрипты | `DS-strategist/scripts/*.sh` | Автоматически (git merge) |
| LaunchD plist | `DS-strategist/scripts/launchd/*.plist` | Переустановить (`install.sh`) |
| CLAUDE.md (шаблон) | `CLAUDE.md` | Скопировать в workspace root |
| Memory шаблоны | `memory/*.md` (кроме MEMORY.md) | Скопировать в ~/.claude/ |
| Settings | `.claude/settings.local.json` | Скопировать в workspace |

### Что НЕ обновляется (User-space)

| Данные | Почему |
|--------|--------|
| `memory/MEMORY.md` (содержимое) | Личные РП и навигация пользователя |
| `DS-strategy/current/` | Текущие планы пользователя |
| `DS-strategy/docs/` | Стратегия и неудовлетворённости |
| `DS-strategy/archive/` | История планов |

### Проверка успешности

- [ ] `git log --oneline -3` — видны коммиты из upstream
- [ ] `grep -r '{{' .` — нет новых незаменённых placeholder-ов
- [ ] `launchctl list | grep strategist` — агенты перезагружены (если обновлялись)
- [ ] Личные данные в MEMORY.md не затронуты

---

## Внутренний процесс: Подстановка переменных

> Владелец: setup.sh. Используется в Сценарии 1.

### Вход

- 6 переменных от пользователя
- Файлы с placeholder-ами: `*.md`, `*.json`, `*.sh`, `*.plist`

### Действие

```bash
find "$TEMPLATE_DIR" -type f \( -name "*.md" -o -name "*.json" \
    -o -name "*.sh" -o -name "*.plist" \) | while read file; do
    sed -i '' \
        -e "s|{{GITHUB_USER}}|$GITHUB_USER|g" \
        -e "s|{{WORKSPACE_DIR}}|$WORKSPACE_DIR|g" \
        -e "s|{{CLAUDE_PATH}}|$CLAUDE_PATH|g" \
        -e "s|{{TIMEZONE_HOUR}}|$TIMEZONE_HOUR|g" \
        -e "s|{{TIMEZONE_DESC}}|$TIMEZONE_DESC|g" \
        -e "s|{{HOME_DIR}}|$HOME_DIR|g" \
        "$file"
done
```

### Выход

Все placeholder-ы `{{...}}` заменены на конкретные значения пользователя.

### Ограничение

После подстановки обновления из upstream могут создавать конфликты в файлах, где placeholder-ы были заменены на конкретные значения. Это ожидаемое поведение — git merge покажет конфликт, пользователь разрешает вручную.
