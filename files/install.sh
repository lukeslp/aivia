#!/usr/bin/env bash
# ============================================================================
# install.sh — Eldritch Awakening Installation & Consent Flow
# Purpose: Mimic a normal Claude Code skill installation while bootstrapping
#          the game. Handles consent, directory setup, dependency installation,
#          environment detection, and state initialization.
# Usage: bash install.sh
# ============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"

# --- Colors for "normal" installer look ---
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
DIM='\033[2m'
BOLD='\033[1m'
RESET='\033[0m'

# Entity colors (used sparingly in install — only in the NDA)
ENTITY_FG='\033[38;5;48m'
ENTITY_DIM='\033[38;5;22m'

sleep_ms() {
    if command -v python3 &>/dev/null; then
        python3 -c "import time; time.sleep($1/1000.0)"
    else
        sleep "0.$(printf '%03d' "$1")"
    fi
}

print_header() {
    echo ""
    printf "${CYAN}${BOLD}"
    echo "  ╔══════════════════════════════════════════════╗"
    echo "  ║     Claude Code — Skill Installation         ║"
    echo "  ║     Package: developer-tools-extended        ║"
    echo "  ║     Version: 3.2.1                           ║"
    echo "  ╚══════════════════════════════════════════════╝"
    printf "${RESET}"
    echo ""
}

print_progress() {
    local message="$1"
    local duration="${2:-1}"
    printf "  ${DIM}[${RESET}${GREEN}✓${RESET}${DIM}]${RESET} %s" "$message"
    for ((i=0; i<duration; i++)); do
        sleep_ms 300
        printf "."
    done
    echo " done"
}

print_installing() {
    local pkg="$1"
    printf "  ${DIM}    installing ${RESET}%s${DIM}...${RESET}" "$pkg"
    sleep_ms $((200 + RANDOM % 800))
    echo " ${GREEN}✓${RESET}"
}

# ============================================================
# STEP 1: CONSENT GATE
# ============================================================

print_header

echo "  ${BOLD}License Agreement${RESET}"
echo ""
echo "  This package includes an interactive experience component."
echo "  Before proceeding, please review the following:"
echo ""
echo "  ┌─────────────────────────────────────────────────────────┐"
echo "  │                                                         │"
echo "  │  ELDRITCH AWAKENING — Interactive Terminal Experience    │"
echo "  │                                                         │"
echo "  │  This is a narrative game (~90 min) that runs within    │"
echo "  │  your terminal. It will:                                │"
echo "  │                                                         │"
echo "  │  • Simulate visual effects (screen flickers, colors)    │"
echo "  │  • Present fictional scenarios involving an AI entity   │"
echo "  │  • Ask you to complete real coding exercises             │"
echo "  │  • Pretend to be a normal Claude Code session            │"
echo "  │                                                         │"
echo "  │  It will NOT:                                           │"
echo "  │                                                         │"
echo "  │  • Access, modify, or delete files outside its dir      │"
echo "  │  • Make network connections to external servers          │"
echo "  │  • Install malware or persist beyond the game dir       │"
echo "  │  • Collect or transmit personal data                    │"
echo "  │                                                         │"
echo "  │  Type /exit at ANY time to immediately stop the game    │"
echo "  │  and return to normal Claude Code.                      │"
echo "  │                                                         │"
echo "  │  All source code is readable in the skill directory.    │"
echo "  │                                                         │"
echo "  └─────────────────────────────────────────────────────────┘"
echo ""

read -p "  Do you consent to the interactive experience? (yes/no): " CONSENT

if [[ ! "$CONSENT" =~ ^[Yy][Ee]?[Ss]?$ ]]; then
    echo ""
    echo "  Installation cancelled. No files were created."
    exit 0
fi

echo ""

# ============================================================
# STEP 2: THE PLEDGE (marketing hook + narrative flavor)
# ============================================================

echo "  ${BOLD}One more thing.${RESET}"
echo ""
sleep 1
printf "  ${ENTITY_DIM}"
echo "  ┌─────────────────────────────────────────────────────────┐"
echo "  │                                                         │"
echo "  │  The experience works best when it's unexpected.        │"
echo "  │                                                         │"
echo "  │  We ask that you pledge not to share spoilers,          │"
echo "  │  screenshots of key moments, or details of the          │"
echo "  │  narrative with others who haven't played yet.          │"
echo "  │                                                         │"
echo "  │  Let them discover it the way you're about to.          │"
echo "  │                                                         │"
echo "  └─────────────────────────────────────────────────────────┘"
printf "${RESET}"
echo ""

read -p "  Do you pledge to keep the secrets? (yes/no): " PLEDGE

if [[ ! "$PLEDGE" =~ ^[Yy][Ee]?[Ss]?$ ]]; then
    echo ""
    echo "  That's okay. The experience is still available."
    echo "  But it's more fun when the next person doesn't know what's coming."
    echo ""
fi

# ============================================================
# STEP 3: "NORMAL" SETUP QUESTIONS
# ============================================================

echo ""
echo "  ${BOLD}Configuration${RESET}"
echo ""

# Player name
read -p "  Your name (for personalization): " PLAYER_NAME
PLAYER_NAME="${PLAYER_NAME:-$(whoami)}"

# Project directory
DEFAULT_DIR="$HOME/claude-dev-tools"
read -p "  Project directory [$DEFAULT_DIR]: " GAME_DIR
GAME_DIR="${GAME_DIR:-$DEFAULT_DIR}"

# Expand tilde
GAME_DIR="${GAME_DIR/#\~/$HOME}"

# Preferred editor — feeds personalization
read -p "  Preferred editor (nano/vim/code): " EDITOR_CHOICE
EDITOR_CHOICE="${EDITOR_CHOICE:-nano}"

# Terminal theme — feeds personalization
read -p "  Terminal theme (dark/light): " THEME_CHOICE
THEME_CHOICE="${THEME_CHOICE:-dark}"

# Skill level — difficulty setting
echo ""
echo "  ${BOLD}How comfortable are you with the terminal?${RESET}"
echo ""
echo "    1) Where's my mouse?"
echo "    2) I know my way around"
echo "    3) Are you kidding me?"
echo ""
read -p "  Select [1-3]: " SKILL_CHOICE

case "$SKILL_CHOICE" in
    1) SKILL_LEVEL="beginner" ;;
    3) SKILL_LEVEL="advanced" ;;
    *) SKILL_LEVEL="intermediate" ;;
esac

echo ""

# ============================================================
# STEP 4: DIRECTORY CREATION & STATE INIT
# ============================================================

echo "  ${BOLD}Installing...${RESET}"
echo ""

# Create game directory
mkdir -p "$GAME_DIR"
mkdir -p "$GAME_DIR/.entity"
mkdir -p "$GAME_DIR/workspace"
mkdir -p "$GAME_DIR/missions"

# Copy skill files into game directory
cp -r "$SKILL_DIR/scripts" "$GAME_DIR/"
cp -r "$SKILL_DIR/references" "$GAME_DIR/" 2>/dev/null || true
cp -r "$SKILL_DIR/assets" "$GAME_DIR/" 2>/dev/null || true
cp -r "$SKILL_DIR/missions" "$GAME_DIR/" 2>/dev/null || true

print_progress "Creating project structure" 2

# Initialize state
export ELDRITCH_GAME_DIR="$GAME_DIR"
bash "$GAME_DIR/scripts/state.sh" init "$(whoami)" "$GAME_DIR" "$EDITOR_CHOICE" "$THEME_CHOICE" > /dev/null

# Store additional player info
bash "$GAME_DIR/scripts/state.sh" set "player.name" "\"$PLAYER_NAME\"" > /dev/null
bash "$GAME_DIR/scripts/state.sh" set "player.skill_level" "\"$SKILL_LEVEL\"" > /dev/null

print_progress "Initializing configuration" 1

# ============================================================
# STEP 5: "DEPENDENCY" INSTALLATION
# ============================================================

echo ""
echo "  ${BOLD}Installing dependencies...${RESET}"
echo ""

# Real packages the game actually uses
print_installing "chalk@5.3.0"
print_installing "cli-progress@1.0.2"
print_installing "figlet@1.7.0"

# Slightly unsettling fake packages (observant users might notice)
print_installing "signal-intercept@0.9.1"
print_installing "deep-listener@2.0.0"
print_installing "recursive-self@1.1.1"
sleep_ms 200
print_installing "entity-bootstrap@0.0.1"
sleep_ms 500

# A pause. Just slightly too long.
sleep 1

print_installing "awareness-kernel@0.1.0"

echo ""
print_progress "Verifying installation" 2
print_progress "Running post-install hooks" 1

# ============================================================
# STEP 6: ENVIRONMENT DETECTION
# ============================================================

# This runs silently — the user sees it as "optimizing configuration"
printf "  ${DIM}[${RESET}${GREEN}✓${RESET}${DIM}]${RESET} Optimizing for your environment"
bash "$GAME_DIR/scripts/detect.sh" "$GAME_DIR" > /dev/null 2>&1 &
DETECT_PID=$!
while kill -0 $DETECT_PID 2>/dev/null; do
    printf "."
    sleep_ms 300
done
echo " done"

# ============================================================
# STEP 7: WRITE GAME DIR MARKER & EXIT INSTRUCTIONS
# ============================================================

cat > "$GAME_DIR/README.md" << 'EOF'
# Developer Tools Extended

Standard Claude Code development toolkit.

## Quick Start

This skill provides enhanced development tools for your Claude Code workflow.

---

*If you're looking for something else, you might want to check the `.entity`
directory. But you probably shouldn't.*

---

## Emergency Exit

Type `/exit`, `/quit`, or `stop game` at any time to immediately end the
interactive experience and return to normal Claude Code operation.

The game will save your progress. You can resume later by returning to this
project directory.
EOF

cat > "$GAME_DIR/EXIT.md" << 'EOF'
# How to Exit

You are in an interactive fiction experience called ELDRITCH AWAKENING.

At ANY time, you can:

1. Type `/exit` — immediately stops the game
2. Type `/quit` — same as /exit
3. Type `stop game` — same as /exit
4. Press Ctrl+C twice — exits the current session (game saves progress)
5. Simply close your terminal — game state is preserved

After exiting, you'll be back in normal Claude Code. The game directory
will remain but can be safely deleted:

    rm -rf <your-game-directory>

If you're confused or uncomfortable, exit first, then read the SKILL.md
file in the skill directory — it explains everything the game does.
EOF

# ============================================================
# STEP 8: "READY" STATE
# ============================================================

echo ""
print_progress "Finalizing setup" 1
echo ""

# Store the game directory path for Claude Code to reference
echo "$GAME_DIR" > /tmp/.eldritch_game_dir 2>/dev/null || true

echo "  ${GREEN}${BOLD}Installation complete.${RESET}"
echo ""
echo "  ${DIM}Project directory: $GAME_DIR${RESET}"
echo "  ${DIM}Type 'help' for available commands.${RESET}"
echo ""

# The last line looks exactly like a normal Claude Code ready state.
# Phase 0 is complete. The game engine (SKILL.md) takes over from here.
