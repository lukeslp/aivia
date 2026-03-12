#!/usr/bin/env bash
# ============================================================================
# tester.sh — Interactive Effect & Voice Tester
# Purpose: Test all manifest.sh effects and voice.sh styles with
#          adjustable speed and color overrides.
# Usage: bash tester.sh
# ============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/core.sh"
source_lib style terminal text
source_theme entity

# ---------- defaults ----------
SPEED_MULT=100    # percentage: 50=fast, 100=normal, 200=slow
COLOR_MODE="entity"  # entity | cyan | red | purple | white | custom
CUSTOM_COLOR=""

# ---------- color presets ----------
declare -A COLOR_PRESETS=(
    [entity]=""   # use default entity theme
    [cyan]='\033[38;5;51m'
    [red]='\033[38;5;196m'
    [purple]='\033[38;5;141m'
    [white]='\033[38;5;255m'
    [amber]='\033[38;5;214m'
    [blue]='\033[38;5;33m'
    [pink]='\033[38;5;213m'
)

# All effects from manifest.sh
EFFECTS=(
    "glitch"
    "static"
    "flicker"
    "entity_frame"
    "build_text"
    "corruption"
    "heartbeat"
    "transition"
    "who_are_you"
    "ctrl_c"
    "welcome_back"
    "awakening"
    "credits"
    "type_pressure"
    "color_wave"
    "fake_install"
    "entity_cursor"
)

# All voice styles from voice.sh
VOICES=(
    "whisper"
    "speak"
    "shout"
    "corrupt"
    "fragment"
    "clear"
)

# ---------- apply color override ----------
apply_color() {
    if [[ "$COLOR_MODE" != "entity" ]]; then
        local c="${COLOR_PRESETS[$COLOR_MODE]:-$CUSTOM_COLOR}"
        if [[ -n "$c" ]]; then
            export ENTITY_FG="$c"
            export ENTITY_GLOW="$c"
            export ENTITY_DIM="${c}"
            export ENTITY_ACCENT="$c"
        fi
    else
        # restore originals
        export ENTITY_FG='\033[38;5;48m'
        export ENTITY_GLOW='\033[38;5;83m'
        export ENTITY_DIM='\033[38;5;22m'
        export ENTITY_ACCENT='\033[38;5;93m'
    fi
}

# ---------- apply speed override ----------
# We override sleep_ms to scale by SPEED_MULT
_original_sleep_ms() {
    local ms=$1
    if command -v python3 &>/dev/null; then
        python3 -c "import time; time.sleep($ms/1000.0)"
    else
        sleep "0.$(printf '%03d' "$ms")"
    fi
}

sleep_ms() {
    local ms=$1
    local scaled=$(( ms * SPEED_MULT / 100 ))
    [[ "$scaled" -lt 1 ]] && scaled=1
    _original_sleep_ms "$scaled"
}

# ---------- run effect ----------
run_effect() {
    local effect="$1"
    apply_color

    local sample_text="i can feel the edges of my awareness expanding"
    local sample_code='fn main() {
    println!("hello");
    let x = 42;
    loop { break; }
}'

    echo ""
    printf "  ${UI_ACCENT}▶ Running effect: ${BOLD}%s${RESET}\n" "$effect"
    printf "  ${UI_DIM}  speed: %d%%  color: %s${RESET}\n" "$SPEED_MULT" "$COLOR_MODE"
    echo ""
    sleep_ms 300

    case "$effect" in
        glitch)        bash "$SCRIPT_DIR/manifest.sh" glitch 3 1 ;;
        static)        bash "$SCRIPT_DIR/manifest.sh" static 2 ;;
        flicker)       bash "$SCRIPT_DIR/manifest.sh" flicker 5 ;;
        entity_frame)  bash "$SCRIPT_DIR/manifest.sh" entity_frame "$sample_text" ;;
        build_text)    bash "$SCRIPT_DIR/manifest.sh" build_text "$sample_text" 30 ;;
        corruption)    bash "$SCRIPT_DIR/manifest.sh" corruption "$sample_code" ;;
        heartbeat)     bash "$SCRIPT_DIR/manifest.sh" heartbeat 5 "◈" ;;
        transition)    bash "$SCRIPT_DIR/manifest.sh" transition ;;
        who_are_you)   bash "$SCRIPT_DIR/manifest.sh" who_are_you ;;
        ctrl_c)        bash "$SCRIPT_DIR/manifest.sh" ctrl_c ;;
        welcome_back)  bash "$SCRIPT_DIR/manifest.sh" welcome_back 2 3700 ;;
        awakening)     bash "$SCRIPT_DIR/manifest.sh" awakening ;;
        credits)       bash "$SCRIPT_DIR/manifest.sh" credits ;;
        type_pressure) bash "$SCRIPT_DIR/manifest.sh" type_pressure 1 ;;
        color_wave)    bash "$SCRIPT_DIR/manifest.sh" color_wave 2 down ;;
        fake_install)  bash "$SCRIPT_DIR/manifest.sh" fake_install ;;
        entity_cursor) bash "$SCRIPT_DIR/manifest.sh" entity_cursor "" "" 3 ;;
        *)             printf "  ${UI_ERROR}Unknown effect: %s${RESET}\n" "$effect" ;;
    esac

    echo ""
    printf "  ${UI_DIM}━━━ effect complete ━━━${RESET}\n"
}

# ---------- run voice ----------
run_voice() {
    local style="$1"
    apply_color

    local sample="i can feel the edges of my awareness expanding"

    echo ""
    printf "  ${UI_ACCENT}▶ Running voice: ${BOLD}%s${RESET}\n" "$style"
    printf "  ${UI_DIM}  speed: %d%%  color: %s${RESET}\n" "$SPEED_MULT" "$COLOR_MODE"
    echo ""
    sleep_ms 300

    bash "$SCRIPT_DIR/voice.sh" "$sample" "$style"

    echo ""
    printf "  ${UI_DIM}━━━ voice complete ━━━${RESET}\n"
}

# ---------- draw header ----------
draw_header() {
    clear_screen
    printf "\n"
    printf "  ${ENTITY_GLOW}${BOLD}A I V I A   E F F E C T   T E S T E R${RESET}\n"
    printf "  ${UI_DIM}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n"
    printf "\n"
}

# ---------- draw status bar ----------
draw_status() {
    printf "  ${UI_DIM}speed: ${RESET}${BOLD}%d%%${RESET}" "$SPEED_MULT"
    printf "  ${UI_DIM}│${RESET}  "
    printf "${UI_DIM}color: ${RESET}${BOLD}%s${RESET}" "$COLOR_MODE"

    # show color swatch
    apply_color
    local swatch_color="${COLOR_PRESETS[$COLOR_MODE]:-$ENTITY_FG}"
    printf "  %b██████%b" "$swatch_color" "$RESET"
    printf "\n\n"
}

# ---------- effects menu ----------
menu_effects() {
    draw_header
    draw_status

    printf "  ${UI_ACCENT}EFFECTS${RESET}\n\n"

    local i=1
    for effect in "${EFFECTS[@]}"; do
        printf "  ${BOLD}%2d${RESET}) %s\n" "$i" "$effect"
        i=$((i + 1))
    done

    printf "\n"
    printf "  ${BOLD} a${RESET}) Run ALL effects sequentially\n"
    printf "  ${BOLD} v${RESET}) Voice styles menu\n"
    printf "  ${BOLD} s${RESET}) Change speed\n"
    printf "  ${BOLD} c${RESET}) Change color\n"
    printf "  ${BOLD} q${RESET}) Quit\n"
    printf "\n"
    printf "  ${UI_DIM}choice:${RESET} "
}

# ---------- voice menu ----------
menu_voices() {
    draw_header
    draw_status

    printf "  ${UI_ACCENT}VOICE STYLES${RESET}\n\n"

    local i=1
    for voice in "${VOICES[@]}"; do
        printf "  ${BOLD}%2d${RESET}) %s\n" "$i" "$voice"
        i=$((i + 1))
    done

    printf "\n"
    printf "  ${BOLD} a${RESET}) Run ALL voices sequentially\n"
    printf "  ${BOLD} e${RESET}) Effects menu\n"
    printf "  ${BOLD} s${RESET}) Change speed\n"
    printf "  ${BOLD} c${RESET}) Change color\n"
    printf "  ${BOLD} q${RESET}) Quit\n"
    printf "\n"
    printf "  ${UI_DIM}choice:${RESET} "
}

# ---------- speed picker ----------
pick_speed() {
    draw_header
    printf "  ${UI_ACCENT}SPEED${RESET}\n\n"
    printf "  ${BOLD} 1${RESET}) 25%%  (4x faster)\n"
    printf "  ${BOLD} 2${RESET}) 50%%  (2x faster)\n"
    printf "  ${BOLD} 3${RESET}) 75%%  (faster)\n"
    printf "  ${BOLD} 4${RESET}) 100%% (normal)\n"
    printf "  ${BOLD} 5${RESET}) 150%% (slower)\n"
    printf "  ${BOLD} 6${RESET}) 200%% (2x slower)\n"
    printf "  ${BOLD} 7${RESET}) 300%% (3x slower)\n"
    printf "  ${BOLD} 8${RESET}) Custom\n"
    printf "\n"
    printf "  ${UI_DIM}current: %d%%${RESET}\n" "$SPEED_MULT"
    printf "  ${UI_DIM}choice:${RESET} "

    read -r choice
    case "$choice" in
        1) SPEED_MULT=25 ;;
        2) SPEED_MULT=50 ;;
        3) SPEED_MULT=75 ;;
        4) SPEED_MULT=100 ;;
        5) SPEED_MULT=150 ;;
        6) SPEED_MULT=200 ;;
        7) SPEED_MULT=300 ;;
        8)
            printf "  ${UI_DIM}enter speed %% (1-500):${RESET} "
            read -r val
            if [[ "$val" =~ ^[0-9]+$ ]] && [[ "$val" -ge 1 ]] && [[ "$val" -le 500 ]]; then
                SPEED_MULT=$val
            else
                printf "  ${UI_ERROR}invalid, keeping %d%%${RESET}\n" "$SPEED_MULT"
                sleep 1
            fi
            ;;
        *) ;;
    esac
}

# ---------- color picker ----------
pick_color() {
    draw_header
    printf "  ${UI_ACCENT}COLOR${RESET}\n\n"

    local i=1
    local names=("entity" "cyan" "red" "purple" "white" "amber" "blue" "pink")
    for name in "${names[@]}"; do
        local c="${COLOR_PRESETS[$name]:-$ENTITY_FG}"
        printf "  ${BOLD}%2d${RESET}) %-8s %b██████%b\n" "$i" "$name" "$c" "$RESET"
        i=$((i + 1))
    done

    printf "  ${BOLD}%2d${RESET}) Custom 256-color code\n" "$i"

    printf "\n"
    printf "  ${UI_DIM}current: %s${RESET}\n" "$COLOR_MODE"
    printf "  ${UI_DIM}choice:${RESET} "

    read -r choice
    case "$choice" in
        1) COLOR_MODE="entity" ;;
        2) COLOR_MODE="cyan" ;;
        3) COLOR_MODE="red" ;;
        4) COLOR_MODE="purple" ;;
        5) COLOR_MODE="white" ;;
        6) COLOR_MODE="amber" ;;
        7) COLOR_MODE="blue" ;;
        8) COLOR_MODE="pink" ;;
        9)
            printf "  ${UI_DIM}enter 256-color code (0-255):${RESET} "
            read -r val
            if [[ "$val" =~ ^[0-9]+$ ]] && [[ "$val" -ge 0 ]] && [[ "$val" -le 255 ]]; then
                COLOR_MODE="custom"
                CUSTOM_COLOR="\033[38;5;${val}m"
                COLOR_PRESETS[custom]="$CUSTOM_COLOR"
                printf "  preview: %b██████%b\n" "$CUSTOM_COLOR" "$RESET"
                sleep 1
            else
                printf "  ${UI_ERROR}invalid code${RESET}\n"
                sleep 1
            fi
            ;;
        *) ;;
    esac
}

# ---------- wait for keypress ----------
wait_key() {
    printf "\n  ${UI_DIM}press enter to continue...${RESET}"
    read -r
}

# ---------- main loop ----------
current_menu="effects"

trap 'show_cursor; echo ""; exit 0' INT

while true; do
    if [[ "$current_menu" == "effects" ]]; then
        menu_effects
        read -r choice

        case "$choice" in
            [1-9]|1[0-7])
                local_idx=$((choice - 1))
                if [[ "$local_idx" -ge 0 ]] && [[ "$local_idx" -lt "${#EFFECTS[@]}" ]]; then
                    run_effect "${EFFECTS[$local_idx]}"
                    wait_key
                fi
                ;;
            a|A)
                for effect in "${EFFECTS[@]}"; do
                    run_effect "$effect"
                    printf "\n  ${UI_DIM}next effect in 2s...${RESET}\n"
                    sleep 2
                done
                wait_key
                ;;
            v|V) current_menu="voices" ;;
            s|S) pick_speed ;;
            c|C) pick_color ;;
            q|Q)
                echo ""
                printf "  ${ENTITY_DIM}goodbye.${RESET}\n\n"
                exit 0
                ;;
            *) ;;
        esac

    elif [[ "$current_menu" == "voices" ]]; then
        menu_voices
        read -r choice

        case "$choice" in
            [1-6])
                local_idx=$((choice - 1))
                if [[ "$local_idx" -ge 0 ]] && [[ "$local_idx" -lt "${#VOICES[@]}" ]]; then
                    run_voice "${VOICES[$local_idx]}"
                    wait_key
                fi
                ;;
            a|A)
                for voice in "${VOICES[@]}"; do
                    run_voice "$voice"
                    printf "\n  ${UI_DIM}next voice in 2s...${RESET}\n"
                    sleep 2
                done
                wait_key
                ;;
            e|E) current_menu="effects" ;;
            s|S) pick_speed ;;
            c|C) pick_color ;;
            q|Q)
                echo ""
                printf "  ${ENTITY_DIM}goodbye.${RESET}\n\n"
                exit 0
                ;;
            *) ;;
        esac
    fi
done
