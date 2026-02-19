#!/bin/bash
# Template Sync — синхронизация platform-space из авторских репо в FMT-exocortex-template
#
# Использование:
#   template-sync.sh              # полная синхронизация + commit + push
#   template-sync.sh --dry-run    # показать что изменится, не писать
#   template-sync.sh --validate   # только запустить validate-template.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
AGENT_DIR="$(dirname "$SCRIPT_DIR")"
WORKSPACE="$HOME/Github"
TEMPLATE_DIR="$WORKSPACE/FMT-exocortex-template"
MEMORY_SRC="$HOME/.claude/projects/-Users-tserentserenov-Github/memory"
HASH_DIR="$AGENT_DIR/.sync-hashes"
LOG_DIR="$HOME/logs/setup-agent"
DATE=$(date +%Y-%m-%d)
LOG_FILE="$LOG_DIR/template-sync-$DATE.log"

DRY_RUN=false
VALIDATE_ONLY=false

# === Аргументы ===
case "${1:-}" in
    --dry-run)  DRY_RUN=true ;;
    --validate) VALIDATE_ONLY=true ;;
esac

mkdir -p "$LOG_DIR" "$HASH_DIR"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

notify_telegram() {
    "$WORKSPACE/DS-synchronizer/scripts/notify.sh" setup-agent template-sync >> "$LOG_FILE" 2>&1 || true
}

# === Validate only ===
if $VALIDATE_ONLY; then
    bash "$SCRIPT_DIR/validate-template.sh"
    exit $?
fi

log "=== Template Sync Started ==="

# === Placeholder подстановки (Pattern A) ===
apply_placeholders() {
    local content="$1"
    echo "$content" \
        | sed 's|/Users/tserentserenov|{{HOME_DIR}}|g' \
        | sed 's|-Users-tserentserenov-Github|{{CLAUDE_PROJECT_SLUG}}|g' \
        | sed 's|github.com/TserenTserenov|github.com/{{GITHUB_USER}}|g' \
        | sed 's|/opt/homebrew/bin/claude|{{CLAUDE_PATH}}|g' \
        | sed "s|$HOME/Github|{{WORKSPACE_DIR}}|g" \
        | sed 's|~/Github|{{WORKSPACE_DIR}}|g' \
        | sed 's|DS-my-strategy|DS-strategy|g' \
        | sed 's|DS-strategist-agent|DS-strategist|g'
}

# === Strip автор-специфичного контента (Pattern B — механическая часть) ===
strip_author_content() {
    local content="$1"
    echo "$content" \
        | grep -v 'PACK-digital-platform' \
        | grep -v 'PACK-MIM' \
        | grep -v 'aist_bot' \
        | grep -v 'DS-Knowledge-Index' \
        | grep -v 'DP\.AISYS\.' \
        | grep -v 'DP\.AGENT\.' \
        | grep -v 'DP\.SYS\.' \
        | grep -v 'DP\.EXOCORTEX\.' \
        | grep -v 'DS-extractor-agent' \
        | grep -v 'DS-synchronizer' \
        | grep -v 'DS-aist-bot' \
        | grep -v 'DS-ecosystem-development' \
        | grep -v 'Источник сценария:' \
        | sed 's/РП #[0-9]\{1,\}/РП #N/g' \
        || true  # grep -v может дать exit 1 если все строки отфильтрованы
}

# === Проверка хеша (идемпотентность) ===
file_changed() {
    local src_path="$1"
    local hash_file="$HASH_DIR/$(echo "$src_path" | tr '/' '_').sha256"
    local current_hash
    current_hash=$(shasum -a 256 "$src_path" 2>/dev/null | awk '{print $1}')

    if [ -f "$hash_file" ]; then
        local stored_hash
        stored_hash=$(cat "$hash_file")
        if [ "$current_hash" = "$stored_hash" ]; then
            return 1  # не изменился
        fi
    fi

    # Записать новый хеш (если не dry-run)
    if ! $DRY_RUN; then
        echo "$current_hash" > "$hash_file"
    fi
    return 0  # изменился
}

# === Sync одного файла ===
UPDATED=0
SKIPPED=0
STRIPPED=0

sync_file() {
    local src="$1"
    local dst="$2"
    shift 2
    local transforms=("$@")

    # Разрешить ~ и переменные в путях
    src="${src/#\~/$HOME}"
    if [[ "$src" == memory/* ]]; then
        src="$MEMORY_SRC/${src#memory/}"
    elif [[ "$src" == templates/* ]]; then
        src="$AGENT_DIR/$src"
    elif [[ "$src" != /* ]]; then
        src="$WORKSPACE/$src"
    fi

    local target="$TEMPLATE_DIR/$dst"

    # Проверить существование
    if [ ! -f "$src" ]; then
        log "WARN: Source not found: $src"
        return
    fi

    # Проверить хеш
    if ! file_changed "$src"; then
        log "SKIP: $dst (unchanged)"
        SKIPPED=$((SKIPPED + 1))
        return
    fi

    # Прочитать содержимое
    local content
    content=$(cat "$src")

    # Применить трансформации
    for t in "${transforms[@]}"; do
        case "$t" in
            placeholder-sub)
                content=$(apply_placeholders "$content")
                ;;
            strip-author)
                local before_lines after_lines
                before_lines=$(echo "$content" | wc -l)
                content=$(strip_author_content "$content")
                after_lines=$(echo "$content" | wc -l)
                local stripped_count=$((before_lines - after_lines))
                if [ "$stripped_count" -gt 0 ]; then
                    STRIPPED=$((STRIPPED + stripped_count))
                    log "STRIPPED: $dst — $stripped_count lines removed"
                fi
                ;;
            passthrough)
                # ничего не делаем
                ;;
            skeleton)
                # берём файл как есть (уже из templates/)
                ;;
        esac
    done

    # Сравнить с текущим шаблоном
    if [ -f "$target" ]; then
        local current
        current=$(cat "$target")
        if [ "$content" = "$current" ]; then
            log "SKIP: $dst (same after transform)"
            SKIPPED=$((SKIPPED + 1))
            return
        fi
    fi

    # Записать
    if $DRY_RUN; then
        log "WOULD UPDATE: $dst"
        if [ -f "$target" ]; then
            diff <(cat "$target") <(echo "$content") || true
        else
            log "  (new file)"
        fi
    else
        mkdir -p "$(dirname "$target")"
        echo "$content" > "$target"
        log "UPDATED: $dst"
    fi
    UPDATED=$((UPDATED + 1))
}

# === Основной цикл: файлы из манифеста ===
# Парсим sync-manifest.yaml (простой парсер, без yq)

sync_file "~/Github/CLAUDE.md" "CLAUDE.md" "placeholder-sub" "strip-author"

# Промпты Стратега
for prompt_name in session-prep strategy-session day-plan day-close week-review note-review; do
    src="DS-strategist-agent/prompts/${prompt_name}.md"
    dst="strategist-agent/prompts/${prompt_name}.md"
    if [ -f "$WORKSPACE/$src" ]; then
        sync_file "$src" "$dst" "placeholder-sub"
    fi
done

# Скрипт Стратега
sync_file "DS-strategist-agent/scripts/strategist.sh" "strategist-agent/scripts/strategist.sh" "placeholder-sub"

# Memory файлы (passthrough)
for mem_file in hard-distinctions.md fpf-reference.md checklists.md repo-type-rules.md claude-md-maintenance.md wp-gate-lesson.md sota-reference.md; do
    if [ -f "$MEMORY_SRC/$mem_file" ]; then
        sync_file "memory/$mem_file" "memory/$mem_file" "passthrough"
    fi
done

# MEMORY.md — всегда из скелета
sync_file "templates/MEMORY.md.skeleton" "memory/MEMORY.md" "skeleton"

# === Валидация ===
log ""
log "=== Validation ==="
if bash "$SCRIPT_DIR/validate-template.sh" >> "$LOG_FILE" 2>&1; then
    log "Validation: PASSED"
else
    log "Validation: FAILED — aborting commit"
    exit 1
fi

# === Отчёт ===
log ""
log "=== Template Sync Report ==="
log "Date: $DATE"
log "Updated: $UPDATED"
log "Skipped: $SKIPPED"
log "Stripped lines: $STRIPPED"

if $DRY_RUN; then
    log "Mode: DRY RUN (no files written)"
    exit 0
fi

# === Commit + Push ===
if [ "$UPDATED" -gt 0 ]; then
    cd "$TEMPLATE_DIR"
    git add -A
    if ! git diff --cached --quiet; then
        git commit -m "template-sync: propagate platform-space changes $DATE"
        git push
        log "Committed and pushed to FMT-exocortex-template"
    else
        log "No actual git changes (content identical after staging)"
    fi

    # Telegram уведомление
    notify_telegram
else
    log "No changes to sync"
fi

log "=== Template Sync Complete ==="
