# WORKPLAN: Exocortex Setup Agent

> РП #17 — Template-репо экзокортекса: fork & deploy агент
> Бюджет: 3h | Дедлайн: 15 фев 2026

## Сделано

| # | Шаг | Дата | Репо |
|---|-----|------|------|
| 1 | Создан GitHub-репо `FMT-exocortex-template` (public, Format) | 10 фев | FMT-exocortex-template |
| 2 | Шаблонизирован CLAUDE.md (универсальные протоколы Open/Work/Close) | 10 фев | FMT-exocortex-template |
| 3 | Шаблонизирована memory/ (7 файлов, Layer 1-3) | 10 фев | FMT-exocortex-template |
| 4 | Шаблонизирован DS-strategist-agent/ (8 промптов, скрипты, launchd, install.sh) | 10 фев | FMT-exocortex-template |
| 5 | Шаблонизирован DS-my-strategy/ (CLAUDE.md, docs, WORKPLAN) | 10 фев | FMT-exocortex-template |
| 6 | Создан .claude/settings.local.json (permissions) | 10 фев | FMT-exocortex-template |
| 7 | Создан GitHub-репо `DS-exocortex-setup-agent` (public, Downstream/instrument) | 10 фев | DS-exocortex-setup-agent |
| 8 | Написан setup.sh (fork → configure → install, 7 шагов) | 10 фев | DS-exocortex-setup-agent |
| 9 | Написан prompts/setup.md (интерактивный Claude-агент) | 10 фев | DS-exocortex-setup-agent |
| 10 | Обновлён REPOSITORY-REGISTRY.md (+2 репо, граф зависимостей) | 10 фев | DS-ecosystem-development |
| 11 | Убран ecosystem-governance/ из template (не личный проект) | 10 фев | FMT-exocortex-template |
| 12 | Добавлена ONTOLOGY.md в оба репо | 10 фев | оба |
| 13 | Написан PROCESSES.md (2 сценария: развёртывание + обновление) | 10 фев | DS-exocortex-setup-agent |
| 14 | Написан WORKPLAN.md | 10 фев | DS-exocortex-setup-agent |

| 15 | template-sync.sh — авторские репо → шаблон (14 файлов, placeholders, strip, hash-idempotent) | 13 фев | DS-exocortex-setup-agent |
| 16 | validate-template.sh — 5 проверок генеративности | 13 фев | DS-exocortex-setup-agent |
| 17 | GH Actions CI (validate-template.yml) | 13 фев | FMT-exocortex-template |
| 18 | Scheduler интеграция (template-sync в scheduler Синхронизатора) | 13 фев | DS-synchronizer |
| 19 | update.sh — fetch upstream + merge + reinstall platform-space (--check, --dry-run) | 13 фев | DS-exocortex-setup-agent |
| 20 | CLAUDE.md агента (4 теста генеративности, запрещённый контент, плейсхолдеры) | 13 фев | DS-exocortex-setup-agent |
| 21 | setup.sh: поддержка {{CLAUDE_PROJECT_SLUG}} | 13 фев | DS-exocortex-setup-agent |

## Осталось

| # | Шаг | Приоритет | Оценка |
|---|-----|-----------|--------|
| A | **Тестирование:** прогнать setup.sh на чистой среде (другой аккаунт / sandbox), проверить placeholder-ы, launchd, DS-strategy | high | 45 мин |
| C | Добавить проверку окружения в setup.sh (Claude CLI, gh, git) | medium | 15 мин |
| E | Обработка ошибок в setup.sh (rollback при сбое) | low | 30 мин |
| F | Миграция репо в организацию (когда будет готово) | deferred | — |
| G | Документация для пользователей (подробный гайд) | deferred | — |

## Риски

| Риск | Митигация |
|------|----------|
| Конфликты при merge upstream после подстановки переменных | Документировано в PROCESSES.md. Решение: config.local.yaml (в .gitignore) вместо sed в git-tracked файлах |
| setup.sh не работает на другой версии macOS | Тест (шаг A) |
| Пользователь перезаписывает MEMORY.md при обновлении | update.sh явно пропускает MEMORY.md |
