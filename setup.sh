#!/bin/bash
# Exocortex Setup Script
# Forks exocortex-template, configures placeholders, installs launchd agents
set -e

echo "=========================================="
echo "  Exocortex Setup"
echo "=========================================="
echo ""

# 1. Collect configuration
read -p "GitHub username: " GITHUB_USER
read -p "Workspace directory [~/Github]: " WORKSPACE_DIR
WORKSPACE_DIR="${WORKSPACE_DIR:-$HOME/Github}"

read -p "Claude CLI path [/opt/homebrew/bin/claude]: " CLAUDE_PATH
CLAUDE_PATH="${CLAUDE_PATH:-/opt/homebrew/bin/claude}"

read -p "Strategist launch hour (UTC, 0-23) [4]: " TIMEZONE_HOUR
TIMEZONE_HOUR="${TIMEZONE_HOUR:-4}"

read -p "Timezone description (e.g. '7:00 MSK') [${TIMEZONE_HOUR}:00 UTC]: " TIMEZONE_DESC
TIMEZONE_DESC="${TIMEZONE_DESC:-${TIMEZONE_HOUR}:00 UTC}"

HOME_DIR="$HOME"

echo ""
echo "Configuration:"
echo "  GitHub user:    $GITHUB_USER"
echo "  Workspace:      $WORKSPACE_DIR"
echo "  Claude path:    $CLAUDE_PATH"
echo "  Schedule hour:  $TIMEZONE_HOUR (UTC)"
echo "  Time desc:      $TIMEZONE_DESC"
echo "  Home dir:       $HOME_DIR"
echo ""
read -p "Continue? (y/n) " -n 1 -r
echo ""
[[ ! $REPLY =~ ^[Yy]$ ]] && exit 1

# 2. Fork template
echo ""
echo "[1/7] Forking exocortex-template..."
cd "$WORKSPACE_DIR"

if [ -d "exocortex-template" ]; then
    echo "  Directory already exists, skipping fork."
else
    gh repo fork TserenTserenov/exocortex-template --clone --remote
fi

TEMPLATE_DIR="$WORKSPACE_DIR/exocortex-template"

# 3. Substitute placeholders
echo "[2/7] Configuring placeholders..."

# Find all text files and replace placeholders
find "$TEMPLATE_DIR" -type f \( -name "*.md" -o -name "*.json" -o -name "*.sh" -o -name "*.plist" \) | while read file; do
    sed -i '' \
        -e "s|{{GITHUB_USER}}|$GITHUB_USER|g" \
        -e "s|{{WORKSPACE_DIR}}|$WORKSPACE_DIR|g" \
        -e "s|{{CLAUDE_PATH}}|$CLAUDE_PATH|g" \
        -e "s|{{TIMEZONE_HOUR}}|$TIMEZONE_HOUR|g" \
        -e "s|{{TIMEZONE_DESC}}|$TIMEZONE_DESC|g" \
        -e "s|{{HOME_DIR}}|$HOME_DIR|g" \
        "$file"
done

echo "  Placeholders substituted."

# 4. Copy CLAUDE.md to workspace root
echo "[3/7] Installing CLAUDE.md..."
cp "$TEMPLATE_DIR/CLAUDE.md" "$WORKSPACE_DIR/CLAUDE.md"
echo "  Copied to $WORKSPACE_DIR/CLAUDE.md"

# 5. Copy memory to Claude projects directory
echo "[4/7] Installing memory..."
CLAUDE_MEMORY_DIR="$HOME/.claude/projects/-$(echo "$WORKSPACE_DIR" | tr '/' '-')/memory"
mkdir -p "$CLAUDE_MEMORY_DIR"
cp "$TEMPLATE_DIR/memory/"*.md "$CLAUDE_MEMORY_DIR/"
echo "  Copied to $CLAUDE_MEMORY_DIR"

# 6. Copy .claude settings
echo "[5/7] Installing Claude settings..."
mkdir -p "$WORKSPACE_DIR/.claude"
cp "$TEMPLATE_DIR/.claude/settings.local.json" "$WORKSPACE_DIR/.claude/settings.local.json"
echo "  Copied to $WORKSPACE_DIR/.claude/settings.local.json"

# 7. Install launchd agents
echo "[6/7] Installing strategist launchd agents..."
chmod +x "$TEMPLATE_DIR/strategist-agent/scripts/strategist.sh"
chmod +x "$TEMPLATE_DIR/strategist-agent/install.sh"
bash "$TEMPLATE_DIR/strategist-agent/install.sh"

# 8. Create my-strategy repo
echo "[7/7] Setting up my-strategy..."
MY_STRATEGY_DIR="$WORKSPACE_DIR/my-strategy"

if [ -d "$MY_STRATEGY_DIR/.git" ]; then
    echo "  my-strategy already exists as git repo."
else
    # Move my-strategy out of template into its own repo
    cp -r "$TEMPLATE_DIR/my-strategy" "$MY_STRATEGY_DIR.tmp"
    rm -rf "$TEMPLATE_DIR/my-strategy"

    mv "$MY_STRATEGY_DIR.tmp" "$MY_STRATEGY_DIR"
    cd "$MY_STRATEGY_DIR"
    git init
    git add -A
    git commit -m "Initial exocortex: my-strategy governance hub"

    # Create GitHub repo
    gh repo create "$GITHUB_USER/my-strategy" --private --source=. --push 2>/dev/null || \
        echo "  GitHub repo my-strategy already exists or creation skipped."
fi

echo ""
echo "=========================================="
echo "  Setup Complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "  1. cd $MY_STRATEGY_DIR"
echo "  2. claude"
echo "  3. Ask Claude to run your first strategy session"
echo ""
echo "Strategist will run automatically:"
echo "  - Morning ($TIMEZONE_DESC): strategy (Mon) / day-plan (Tue-Sun)"
echo "  - Sunday night: week review"
echo ""
echo "Update from upstream:"
echo "  cd $TEMPLATE_DIR && git pull upstream main"
