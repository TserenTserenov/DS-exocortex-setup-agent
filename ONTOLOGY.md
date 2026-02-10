# Онтология: Exocortex Setup Agent

> Downstream от `exocortex-template/ONTOLOGY.md`

## Сущности

### Setup Agent

Инструмент развёртывания персонального экзокортекса из шаблона [exocortex-template](https://github.com/TserenTserenov/exocortex-template).

**Тип:** Downstream/instrument — не содержит шаблонов, только механизм доставки.

### Компоненты

| Компонент | Файл | Назначение |
|-----------|------|-----------|
| Bash-скрипт | `setup.sh` | Автоматическое развёртывание (fork → configure → install) |
| Claude-промпт | `prompts/setup.md` | Интерактивное развёртывание через Claude Code |

### Входные данные (от пользователя)

| Параметр | Описание | Значение по умолчанию |
|----------|----------|----------------------|
| `GITHUB_USER` | GitHub username | — (обязательно) |
| `WORKSPACE_DIR` | Рабочая директория | `~/Github` |
| `CLAUDE_PATH` | Путь к Claude CLI | `/opt/homebrew/bin/claude` |
| `TIMEZONE_HOUR` | Час запуска стратега (UTC) | `4` |
| `TIMEZONE_DESC` | Описание времени | `{TIMEZONE_HOUR}:00 UTC` |

### Выходные артефакты

| Артефакт | Путь | Описание |
|----------|------|---------|
| Fork exocortex-template | `{WORKSPACE_DIR}/exocortex-template/` | Сконфигурированный шаблон |
| CLAUDE.md | `{WORKSPACE_DIR}/CLAUDE.md` | Глобальные правила |
| Memory | `~/.claude/projects/.../memory/` | Оперативная память Claude |
| Settings | `{WORKSPACE_DIR}/.claude/settings.local.json` | Permissions |
| LaunchAgents | `~/Library/LaunchAgents/com.strategist.*.plist` | Расписание стратега |
| my-strategy | `{WORKSPACE_DIR}/my-strategy/` | Отдельный GitHub-репо (private) |

### Пространства

| Пространство | Описание |
|-------------|---------|
| **Platform-space** | Файлы из exocortex-template, обновляемые через upstream |
| **User-space** | Данные пользователя: MEMORY.md (содержимое), планы, стратегии |

### Зависимости

```
exocortex-template (Format, source-of-truth)
    │
    ▼
exocortex-setup-agent (Downstream/instrument)
    │
    ▼
Развёрнутый экзокортекс пользователя
```

### Требования к окружению

| Требование | Проверка |
|------------|---------|
| macOS | `uname -s` |
| Claude CLI | `which claude` |
| GitHub CLI | `which gh` |
| gh авторизован | `gh auth status` |
| Git настроен | `git config user.name` |
