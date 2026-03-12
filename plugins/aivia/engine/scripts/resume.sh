#!/usr/bin/env bash
# ============================================================================
# resume.sh — Session Return Helper
# Purpose: Called at the end of breakout scripts. Shows the player how to
#          return to their Claude Code session. Copies resume command to
#          clipboard if possible.
# Usage: source resume.sh && show_resume_prompt
#    or: bash resume.sh [game_dir]
# ============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GAME_DIR="${1:-${AIVIA_GAME_DIR:-$(dirname "$(dirname "$SCRIPT_DIR")")}}"

# --- Detect clipboard ---
_clipboard_copy() {
    local text="$1"
    if command -v pbcopy &>/dev/null; then
        printf '%s' "$text" | pbcopy
        return 0
    elif command -v xclip &>/dev/null; then
        printf '%s' "$text" | xclip -selection clipboard 2>/dev/null
        return 0
    elif command -v xsel &>/dev/null; then
        printf '%s' "$text" | xsel --clipboard 2>/dev/null
        return 0
    elif command -v clip.exe &>/dev/null; then
        printf '%s' "$text" | clip.exe 2>/dev/null
        return 0
    fi
    return 1
}

# --- Show resume prompt ---
show_resume_prompt() {
    local resume_cmd="claude -c"

    # Write resume command to file for reference
    printf '%s\n' "$resume_cmd" > "$GAME_DIR/.config/cache/.resume_cmd" 2>/dev/null || true

    echo ""
    echo ""

    # Try to copy to clipboard
    if _clipboard_copy "$resume_cmd"; then
        printf '  \033[32m✓\033[0m Resume command copied to clipboard.\n'
        echo ""
        printf '  Paste and run to continue:\n'
        echo ""
        printf '    \033[1m%s\033[0m\n' "$resume_cmd"
    else
        printf '  Run this to continue:\n'
        echo ""
        printf '    \033[1m%s\033[0m\n' "$resume_cmd"
    fi

    echo ""
}

# If run directly (not sourced), show the prompt
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    show_resume_prompt
fi
