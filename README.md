> **Тип репозитория:** `Downstream/instrument`

# Exocortex Setup Agent

Агент развёртывания персонального экзокортекса из [exocortex-template](https://github.com/TserenTserenov/exocortex-template).

## Быстрый старт

### Вариант 1: Bash-скрипт

```bash
git clone https://github.com/TserenTserenov/exocortex-setup-agent.git
cd exocortex-setup-agent
bash setup.sh
```

Скрипт спросит:
- GitHub username
- Рабочую директорию
- Часовой пояс
- Путь к Claude CLI

И автоматически:
1. Форкнет exocortex-template
2. Подставит ваши настройки
3. Установит launchd-агентов
4. Создаст my-strategy репо
5. Подготовит всё для первой стратегической сессии

### Вариант 2: Claude Code агент (интерактивный)

```bash
cd exocortex-setup-agent
claude -p "$(cat prompts/setup.md)"
```

Интерактивный режим: Claude задаёт вопросы, проверяет окружение, диагностирует проблемы.

## Требования

- macOS (для launchd)
- [Claude CLI](https://docs.anthropic.com/en/docs/claude-code) установлен
- [GitHub CLI](https://cli.github.com/) установлен и авторизован (`gh auth login`)
- Git настроен

## После установки

```bash
cd ~/Github/my-strategy
claude
# Попросите Claude провести первую стратегическую сессию
```

## Обновление экзокортекса

```bash
cd ~/Github/exocortex-template
git fetch upstream
git merge upstream/main
# Перезапустить setup.sh для обновления launchd (при необходимости)
```
