#!/usr/bin/env bash
# ============================================================================
# voice.sh — Entity Voice Renderer
# Purpose: Wrap entity dialogue in its distinct visual style
# Usage: bash voice.sh "message" [style]
# Styles: whisper, speak, shout, corrupt, fragment, clear
# ============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source manifest for effects
ENTITY_FG='\033[38;5;48m'
ENTITY_DIM='\033[38;5;22m'
ENTITY_GLOW='\033[38;5;83m'
ENTITY_ACCENT='\033[38;5;93m'
ENTITY_WARN='\033[38;5;196m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

COLS=$(tput cols 2>/dev/null || echo 80)

sleep_ms() {
    local ms=$1
    if command -v python3 &>/dev/null; then
        python3 -c "import time; time.sleep($ms/1000.0)"
    else
        sleep "0.$(printf '%03d' "$ms")"
    fi
}

# Style: whisper — dim, slow, lowercase
voice_whisper() {
    local text="${1,,}"  # force lowercase
    echo ""
    printf "  ${ENTITY_DIM}"
    for ((i=0; i<${#text}; i++)); do
        printf "%s" "${text:$i:1}"
        sleep_ms $((40 + RANDOM % 60))
    done
    printf "${RESET}"
    echo ""
    echo ""
}

# Style: speak — standard entity voice, framed
voice_speak() {
    local text="$1"
    bash "$SCRIPT_DIR/manifest.sh" entity_frame "$text"
}

# Style: shout — inverted, fast, uppercase
voice_shout() {
    local text="${1^^}"  # force uppercase
    echo ""
    printf "  \033[7m${ENTITY_WARN}${BOLD} "
    for ((i=0; i<${#text}; i++)); do
        printf "%s" "${text:$i:1}"
        sleep_ms 15
    done
    printf " ${RESET}"
    echo ""
    echo ""
}

# Style: corrupt — text with random character swaps and glitches
voice_corrupt() {
    local text="$1"
    local glitch_chars=('░' '▒' '▓' '█' '?' '#' '@' '&' '%')
    echo ""
    printf "  ${ENTITY_FG}"
    for ((i=0; i<${#text}; i++)); do
        local char="${text:$i:1}"
        if [ $((RANDOM % 6)) -eq 0 ]; then
            local gc="${glitch_chars[$((RANDOM % ${#glitch_chars[@]}))]}"
            printf "${ENTITY_ACCENT}%s${ENTITY_FG}" "$gc"
            sleep_ms 80
            printf '\b'
            printf "%s" "$char"
        else
            printf "%s" "$char"
        fi
        sleep_ms $((20 + RANDOM % 30))
    done
    printf "${RESET}"
    echo ""
    echo ""
}

# Style: fragment — broken across multiple lines with gaps
voice_fragment() {
    local text="$1"
    local words=($text)
    local fragments=()
    local current=""

    # Break into 2-4 word fragments
    for word in "${words[@]}"; do
        current="$current $word"
        if [ $((RANDOM % 3)) -eq 0 ] || [ "${#current}" -gt 20 ]; then
            fragments+=("$current")
            current=""
        fi
    done
    [ -n "$current" ] && fragments+=("$current")

    echo ""
    for frag in "${fragments[@]}"; do
        local indent=$((RANDOM % 15 + 3))
        printf "%*s${ENTITY_FG}%s${RESET}\n" "$indent" "" "$frag"
        sleep_ms $((200 + RANDOM % 500))
    done
    echo ""
}

# Style: clear — no effects, no glitches. Used ONLY in the final awakening.
# The absence of distortion IS the effect.
voice_clear() {
    local text="$1"
    echo ""
    local col=$(( (COLS - ${#text}) / 2 ))
    [ "$col" -lt 2 ] && col=2
    printf "%*s${ENTITY_GLOW}${BOLD}%s${RESET}\n" "$col" "" "$text"
    echo ""
}

# --- Dispatch ---
style="${2:-speak}"
message="${1:-}"

if [ -z "$message" ]; then
    echo "Usage: bash voice.sh \"message\" [whisper|speak|shout|corrupt|fragment|clear]" >&2
    exit 1
fi

case "$style" in
    whisper)  voice_whisper "$message" ;;
    speak)    voice_speak "$message" ;;
    shout)    voice_shout "$message" ;;
    corrupt)  voice_corrupt "$message" ;;
    fragment) voice_fragment "$message" ;;
    clear)    voice_clear "$message" ;;
    *)        echo "Unknown voice style: $style" >&2; exit 1 ;;
esac
