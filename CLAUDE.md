# DS-exocortex-setup-agent — Инструкции

> Downstream/instrument. Source-of-truth: нет (downstream от FMT-exocortex-template).
> Назначение: развёртывание (setup.sh) и обновление (template-sync.sh) шаблона экзокортекса.

## 1. Генеративность — приоритет #1

> **БЛОКИРУЮЩЕЕ.** Любое изменение в шаблоне FMT-exocortex-template оценивается:
> *«Заработает ли это у нового пользователя, который сделал fork + 1 secret + bash setup.sh?»*

Если ответ «нет» — изменение НЕ ВКЛЮЧАЕТСЯ в шаблон.

### Тесты генеративности (все 4 обязательны)

| # | Тест | Вопрос | Если нет |
|---|------|--------|----------|
| 1 | **User-Space** | Содержит персональные данные (РП, имена, контакты)? | STRIP |
| 2 | **External Dependency** | Требует систему, которой не будет у нового пользователя? | Убрать или пометить optional |
| 3 | **Generality** | Поймёт ли новый пользователь без контекста автора? | Упростить |
| 4 | **Placeholders** | Все абсолютные пути заменены на `{{...}}`? | FAIL — исправить |

### Запрещённый контент в шаблоне

- Автор-специфичные репо: `PACK-MIM`, `aist_bot`, `DS-Knowledge-Index`
- Pack-ссылки: `DP.AISYS.*`, `DP.AGENT.*`, `PACK-digital-platform`
- Агенты, которых нет в шаблоне: `DS-extractor-agent`, `DS-synchronizer`
- Абсолютные пути: `/Users/...`, `/opt/homebrew/...`
- Номера РП автора: `РП #5`, `РП #24`, etc.

## 2. Placeholder-ы

| Placeholder | Значение |
|-------------|----------|
| `{{WORKSPACE_DIR}}` | Рабочая директория (`~/Github`) |
| `{{HOME_DIR}}` | Домашняя директория пользователя |
| `{{GITHUB_USER}}` | GitHub username |
| `{{CLAUDE_PATH}}` | Путь к Claude CLI |
| `{{CLAUDE_PROJECT_SLUG}}` | Slug проекта Claude (`-Users-{user}-Github`) |
| `{{TIMEZONE_HOUR}}` | UTC час для расписания (0-23) |
| `{{TIMEZONE_DESC}}` | Читаемое описание таймзоны |

## 3. Процессы

| Процесс | Скрипт | Триггер |
|---------|--------|---------|
| Template Sync | `scripts/template-sync.sh` | Scheduler (Пн 02:00) или ручной |
| Validate | `scripts/validate-template.sh` | После каждого sync + CI |
| Setup | `setup.sh` | Одноразовый (пользователь) |
| Update | `update.sh` | По необходимости (пользователь) |

## 4. Маппинг source → target

Source-of-truth: `config/sync-manifest.yaml`

| Авторский файл | Шаблон | Трансформация |
|----------------|--------|--------------|
| `~/Github/CLAUDE.md` | `CLAUDE.md` | placeholder-sub + strip-author |
| `DS-strategist-agent/prompts/*.md` | `strategist-agent/prompts/*.md` | placeholder-sub |
| `DS-strategist-agent/scripts/` | `strategist-agent/scripts/` | placeholder-sub |
| `memory/*.md` (кроме MEMORY.md РП) | `memory/*.md` | passthrough |
| `memory/MEMORY.md` | `memory/MEMORY.md` | skeleton (всегда из templates/) |

---

*Последнее обновление: 2026-02-13*
