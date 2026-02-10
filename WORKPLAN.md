# WORKPLAN: Exocortex Setup Agent

> РП #17 — Template-репо экзокортекса: fork & deploy агент
> Бюджет: 3h | Дедлайн: 15 фев 2026

## Сделано

| # | Шаг | Дата | Репо |
|---|-----|------|------|
| 1 | Создан GitHub-репо `exocortex-template` (public, Format) | 10 фев | exocortex-template |
| 2 | Шаблонизирован CLAUDE.md (универсальные протоколы Open/Work/Close) | 10 фев | exocortex-template |
| 3 | Шаблонизирована memory/ (7 файлов, Layer 1-3) | 10 фев | exocortex-template |
| 4 | Шаблонизирован strategist-agent/ (8 промптов, скрипты, launchd, install.sh) | 10 фев | exocortex-template |
| 5 | Шаблонизирован my-strategy/ (CLAUDE.md, docs, WORKPLAN) | 10 фев | exocortex-template |
| 6 | Создан .claude/settings.local.json (permissions) | 10 фев | exocortex-template |
| 7 | Создан GitHub-репо `exocortex-setup-agent` (public, Downstream/instrument) | 10 фев | exocortex-setup-agent |
| 8 | Написан setup.sh (fork → configure → install, 7 шагов) | 10 фев | exocortex-setup-agent |
| 9 | Написан prompts/setup.md (интерактивный Claude-агент) | 10 фев | exocortex-setup-agent |
| 10 | Обновлён REPOSITORY-REGISTRY.md (+2 репо, граф зависимостей) | 10 фев | ecosystem-development |
| 11 | Убран ecosystem-governance/ из template (не личный проект) | 10 фев | exocortex-template |
| 12 | Добавлена ONTOLOGY.md в оба репо | 10 фев | оба |
| 13 | Написан PROCESSES.md (2 сценария: развёртывание + обновление) | 10 фев | exocortex-setup-agent |
| 14 | Написан WORKPLAN.md | 10 фев | exocortex-setup-agent |

## Осталось

| # | Шаг | Приоритет | Оценка |
|---|-----|-----------|--------|
| A | Тестирование setup.sh на чистой среде (другой GitHub-аккаунт или sandbox) | high | 30 мин |
| B | Скрипт update.sh для Сценария 2 (обновление из upstream) | high | 30 мин |
| C | Добавить проверку окружения в setup.sh (Claude CLI, gh, git) | medium | 15 мин |
| D | CLAUDE.md для exocortex-setup-agent (инструкции агенту) | medium | 15 мин |
| E | Обработка ошибок в setup.sh (rollback при сбое) | low | 30 мин |
| F | Миграция репо в организацию (когда будет готово) | deferred | — |
| G | Документация для пользователей (подробный гайд) | deferred | — |

## Риски

| Риск | Митигация |
|------|----------|
| Конфликты при merge upstream после подстановки переменных | Документировано в PROCESSES.md, пользователь разрешает вручную |
| setup.sh не работает на другой версии macOS | Тест (шаг A) |
| Пользователь перезаписывает MEMORY.md при обновлении | Сценарий 2 явно указывает «НЕ перезаписывать MEMORY.md» |
