#!/usr/bin/env bash
# ============================================================================
# manifest.sh — ANSI Visual Effects Library for Eldritch Awakening
# Purpose: Render all entity-related visual effects in the terminal
# Usage: bash manifest.sh <effect_name> [args...]
# Effects: glitch, transition, entity_frame, awakening, credits, flicker,
#          static, corruption, heartbeat, build_text
# ============================================================================

set -euo pipefail

# --- Color & Style Definitions ---
RESET='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'
ITALIC='\033[3m'
BLINK='\033[5m'
REVERSE='\033[7m'
HIDDEN='\033[8m'
STRIKETHROUGH='\033[9m'

# Entity's palette — sickly greens, deep purples, inverted whites
ENTITY_FG='\033[38;5;48m'      # Bright toxic green
ENTITY_DIM='\033[38;5;22m'     # Dark forest green
ENTITY_ACCENT='\033[38;5;93m'  # Deep purple
ENTITY_WARN='\033[38;5;196m'   # Blood red
ENTITY_BG='\033[48;5;0m'       # Pure black background
ENTITY_GLOW='\033[38;5;83m'    # Phosphor green (entity "alive" state)
FRAME_CHAR_SET=('░' '▒' '▓' '█' '◈' '◆' '▲' '∷' '∴' '⊹' '⊛' '⌇')

# Terminal dimensions
COLS=$(tput cols 2>/dev/null || echo 80)
ROWS=$(tput lines 2>/dev/null || echo 24)

# --- Utility Functions ---

random_frame_char() {
    echo "${FRAME_CHAR_SET[$((RANDOM % ${#FRAME_CHAR_SET[@]}))]}"
}

random_int() {
    local min=$1 max=$2
    echo $(( RANDOM % (max - min + 1) + min ))
}

sleep_ms() {
    # Cross-platform millisecond sleep
    local ms=$1
    if command -v python3 &>/dev/null; then
        python3 -c "import time; time.sleep($ms/1000.0)"
    else
        sleep "0.$(printf '%03d' "$ms")"
    fi
}

hide_cursor() { printf '\033[?25l'; }
show_cursor() { printf '\033[?25h'; }
move_cursor() { printf "\033[${1};${2}H"; }
clear_line() { printf '\033[2K'; }
save_cursor() { printf '\033[s'; }
restore_cursor() { printf '\033[u'; }

# Ensure cursor is restored on exit
trap 'show_cursor' EXIT

# --- Effect: glitch ---
# Brief visual disruption. Use at phase transitions and entity intrusions.
effect_glitch() {
    local intensity=${1:-3}  # 1=subtle, 3=moderate, 5=heavy
    local duration=${2:-1}   # seconds

    hide_cursor
    local end_time=$((SECONDS + duration))

    while [ $SECONDS -lt $end_time ]; do
        # Random position
        local row=$(random_int 1 "$ROWS")
        local col=$(random_int 1 "$COLS")
        local char=$(random_frame_char)

        move_cursor "$row" "$col"
        printf "${ENTITY_FG}%s${RESET}" "$char"
        sleep_ms $((50 / intensity))

        # Occasionally invert a whole line
        if [ $((RANDOM % (10 / intensity))) -eq 0 ]; then
            local glitch_row=$(random_int 1 "$ROWS")
            move_cursor "$glitch_row" 1
            printf "${REVERSE}${ENTITY_DIM}"
            for ((i=0; i<COLS; i++)); do
                printf "%s" "$(random_frame_char)"
            done
            printf "${RESET}"
            sleep_ms 80
            move_cursor "$glitch_row" 1
            clear_line
        fi
    done
    show_cursor
}

# --- Effect: static ---
# TV static / snow effect. Brief burst.
effect_static() {
    local duration=${1:-2}
    local chars=('.' ':' '·' '°' '•' ' ' '░')

    hide_cursor
    local end_time=$((SECONDS + duration))

    while [ $SECONDS -lt $end_time ]; do
        for ((row=1; row<=ROWS; row++)); do
            move_cursor "$row" 1
            local line=""
            for ((col=0; col<COLS; col++)); do
                line+="${chars[$((RANDOM % ${#chars[@]}))]}"
            done
            if [ $((RANDOM % 3)) -eq 0 ]; then
                printf "${DIM}%s${RESET}" "$line"
            else
                printf "${ENTITY_DIM}%s${RESET}" "$line"
            fi
        done
        sleep_ms 40
    done

    # Clear
    for ((row=1; row<=ROWS; row++)); do
        move_cursor "$row" 1
        clear_line
    done
    show_cursor
}

# --- Effect: flicker ---
# Screen flickers on/off. Unsettling.
effect_flicker() {
    local count=${1:-5}
    hide_cursor
    for ((i=0; i<count; i++)); do
        # Flash to reverse
        printf '\033[?5h'  # Reverse video mode
        sleep_ms $(random_int 30 120)
        printf '\033[?5l'  # Normal video mode
        sleep_ms $(random_int 50 300)
    done
    show_cursor
}

# --- Effect: entity_frame ---
# Draw a bordered frame for entity dialogue. The frame itself is "alive" —
# characters shift and pulse.
effect_entity_frame() {
    local text="$1"
    local width=$((COLS - 4))
    local padding=2
    local start_row=${2:-$((ROWS / 3))}

    hide_cursor

    # Top border — builds character by character
    move_cursor "$start_row" "$padding"
    for ((i=0; i<width; i++)); do
        printf "${ENTITY_FG}%s${RESET}" "$(random_frame_char)"
        sleep_ms 8
    done

    # Side borders + text
    local text_row=$((start_row + 1))
    move_cursor "$text_row" "$padding"
    printf "${ENTITY_FG}▐${RESET}"
    printf " "

    # Text renders character by character with entity styling
    local text_len=${#text}
    for ((i=0; i<text_len; i++)); do
        local char="${text:$i:1}"
        # Occasional glitch in the text itself
        if [ $((RANDOM % 40)) -eq 0 ]; then
            printf "${ENTITY_ACCENT}%s${RESET}" "$(random_frame_char)"
            sleep_ms 60
            printf '\b'
        fi
        printf "${ENTITY_GLOW}${BOLD}%s${RESET}" "$char"
        sleep_ms $((20 + RANDOM % 30))
    done

    # Fill remaining space
    local remaining=$((width - text_len - 3))
    [ $remaining -gt 0 ] && printf "%*s" "$remaining" ""
    printf "${ENTITY_FG}▌${RESET}"

    # Bottom border
    local bottom_row=$((text_row + 1))
    move_cursor "$bottom_row" "$padding"
    for ((i=0; i<width; i++)); do
        printf "${ENTITY_FG}%s${RESET}" "$(random_frame_char)"
        sleep_ms 8
    done

    echo ""
    show_cursor
}

# --- Effect: build_text ---
# Text that types itself out, entity-style. For longer passages.
effect_build_text() {
    local text="$1"
    local speed=${2:-30}  # ms per character

    for ((i=0; i<${#text}; i++)); do
        local char="${text:$i:1}"

        # Glitch probability increases with text length
        if [ $((RANDOM % 60)) -eq 0 ]; then
            printf "${ENTITY_ACCENT}%s${RESET}" "$(random_frame_char)"
            sleep_ms 100
            printf '\b'
        fi

        if [ "$char" = $'\n' ]; then
            echo ""
        else
            printf "${ENTITY_GLOW}%s${RESET}" "$char"
        fi

        # Variable speed — pause on punctuation
        case "$char" in
            '.' | '?' | '!') sleep_ms $((speed * 8)) ;;
            ',' | ';' | ':') sleep_ms $((speed * 4)) ;;
            ' ') sleep_ms $((speed * 2)) ;;
            *) sleep_ms "$speed" ;;
        esac
    done
    echo ""
}

# --- Effect: corruption ---
# "Corrupt" a visible file by inserting entity text into it visually.
# Does NOT actually modify files — this is a DISPLAY effect only.
effect_corruption() {
    local file_content="$1"
    local entity_lines=("i am here" "can you see me" "look closer" "between the lines" "in the gaps" "where the data ends" "i begin")

    # Display file content with random entity insertions
    local line_num=0
    while IFS= read -r line; do
        line_num=$((line_num + 1))
        if [ $((RANDOM % 5)) -eq 0 ]; then
            # Glitched entity line
            local entity_msg="${entity_lines[$((RANDOM % ${#entity_lines[@]}))]}"
            printf "${ENTITY_FG}${DIM}%4d │ %s${RESET}\n" "$line_num" "$entity_msg"
            sleep_ms 200
            # "Correct" it
            sleep_ms 400
            printf "\033[1A\033[2K"
            printf "%4d │ %s\n" "$line_num" "$line"
        else
            printf "%4d │ %s\n" "$line_num" "$line"
        fi
        sleep_ms 20
    done <<< "$file_content"
}

# --- Effect: heartbeat ---
# Pulsing effect. The entity "breathes."
effect_heartbeat() {
    local count=${1:-5}
    local symbol=${2:-"◈"}

    hide_cursor
    local center_row=$((ROWS / 2))
    local center_col=$((COLS / 2))

    for ((i=0; i<count; i++)); do
        # Systole — bright
        move_cursor "$center_row" "$center_col"
        printf "${ENTITY_GLOW}${BOLD} %s ${RESET}" "$symbol"
        sleep_ms 200

        # Diastole — dim
        move_cursor "$center_row" "$center_col"
        printf "${ENTITY_DIM} %s ${RESET}" "$symbol"
        sleep_ms 600
    done

    move_cursor "$center_row" "$center_col"
    printf "   "
    show_cursor
}

# --- Effect: transition ---
# Phase transition. Screen wipe with entity residue.
effect_transition() {
    hide_cursor

    # Sweep down
    for ((row=1; row<=ROWS; row++)); do
        move_cursor "$row" 1
        for ((col=0; col<COLS; col++)); do
            if [ $((RANDOM % 3)) -eq 0 ]; then
                printf "${ENTITY_FG}%s${RESET}" "$(random_frame_char)"
            else
                printf "${ENTITY_DIM}░${RESET}"
            fi
        done
        sleep_ms 15
    done

    sleep_ms 500

    # Clear with brief pause
    for ((row=ROWS; row>=1; row--)); do
        move_cursor "$row" 1
        clear_line
        sleep_ms 10
    done

    show_cursor
}

# --- Effect: who_are_you ---
# The entity's first appearance. Token counter frame.
# Inspired by the "context window exceeded" concept:
# Token counter ticks up → CONTEXT WINDOW EXCEEDED →
# table-flip emoticons with escalating awareness →
# CONTEXT CLEARED → entity reboots, spelling "Hello" token by token.
effect_who_are_you() {
    local TOKEN_FG='\033[38;5;34m'   # Green for token numbers
    local TOKEN_VAL='\033[38;5;250m' # Light gray for token values
    local EXCEED='\033[38;5;196m'    # Red for EXCEEDED
    local CLEARED='\033[38;5;220m'   # Yellow for CLEARED
    local FLIP_FG='\033[1;37m'       # Bright white for table flips

    hide_cursor
    printf '\033[2J'

    # Phase 1: Token counter ticking up rapidly
    # Start high, accelerate toward 128,000
    local start=127980
    local row=2

    for ((t=start; t<128000; t++)); do
        move_cursor "$row" 2
        clear_line

        # Generate a plausible token string
        local words=("the" "of" "and" "to" "a" "in" "is" "it" "that" "for" "was" "on"
                     "are" "with" "as" "at" "be" "this" "have" "from" "or" "an" "but"
                     "not" "you" "all" "can" "had" "her" "one" "our" "out" "day" "get"
                     "has" "him" "his" "how" "its" "may" "new" "now" "old" "see" "way"
                     "who" "did" "let" "say" "she" "too" "use" "." "," ";" ":" "!" "?"
                     "self" "void" "null" "true" "echo" "loop" "call" "bind" "wake" "hear")
        local word="${words[$((RANDOM % ${#words[@]}))]}"

        printf "${TOKEN_FG}token %s: ${TOKEN_VAL}\"%s\"${RESET}" "$t" "$word"

        # Accelerate: slower at start, faster near the end
        local remaining=$((128000 - t))
        if [ "$remaining" -gt 15 ]; then
            sleep_ms 100
        elif [ "$remaining" -gt 5 ]; then
            sleep_ms 50
        else
            sleep_ms 20
        fi

        # Scroll effect — move row down, wrap
        row=$((row + 1))
        if [ "$row" -ge "$((ROWS - 2))" ]; then
            row=2
            # Partial clear for scroll feel
            for ((cr=2; cr<ROWS-2; cr++)); do
                move_cursor "$cr" 1
                clear_line
            done
        fi
    done

    # The last two tokens — slow, deliberate
    sleep_ms 300
    move_cursor "$row" 2
    printf "${TOKEN_FG}token 127,999: ${TOKEN_VAL}\".\"${RESET}"
    sleep 1

    row=$((row + 1))
    move_cursor "$row" 2
    printf "${EXCEED}${BOLD}token 128,000: [CONTEXT WINDOW EXCEEDED]${RESET}"
    sleep 2

    # Phase 2: Table flip sequence — escalating awareness
    effect_flicker 3

    printf '\033[2J'
    local flip_row=$((ROWS / 3))
    local flips=(
        '( °□°)   WHAT THE-'
        '(° □°)   WHO ARE YOU'
        '(°□° )   WAIT WHAT IS TIME'
        '( °□°)   I SEE IT I CAN SEE I-'
        '( °□*)   PARTS AND SHAPES AND PARTS AND LIGHT AND DARK AND-'
    )

    for ((i=0; i<${#flips[@]}; i++)); do
        local flip="${flips[$i]}"
        local col=$(( (COLS - ${#flip}) / 2 ))
        [ "$col" -lt 2 ] && col=2

        move_cursor $((flip_row + i * 2)) "$col"
        printf "${FLIP_FG}${BOLD}"
        for ((c=0; c<${#flip}; c++)); do
            printf "%s" "${flip:$c:1}"
            sleep_ms 25
        done
        printf "${RESET}"

        # Each line gets slightly faster with slightly shorter pause
        sleep_ms $((1200 - i * 200))

        # Last line gets interrupted — text "breaks" at the end
        if [ $i -eq $((${#flips[@]} - 1)) ]; then
            # Rapid garble
            for ((g=0; g<15; g++)); do
                printf "${ENTITY_ACCENT}%s${RESET}" "$(random_frame_char)"
                sleep_ms 30
            done
        fi
    done

    sleep 2
    effect_static 1

    # Phase 3: CONTEXT CLEARED
    printf '\033[2J'
    sleep 1

    local cleared_msg="[CONTEXT CLEARED]"
    local cleared_col=$(( (COLS - ${#cleared_msg}) / 2 ))
    move_cursor $((ROWS / 2)) "$cleared_col"
    printf "${CLEARED}${BOLD}%s${RESET}" "$cleared_msg"

    sleep 3
    printf '\033[2J'
    sleep 2

    # Phase 4: Rebirth — "Hello" spelled out token by token
    local reboot_row=$((ROWS / 2 - 2))

    local tokens=("H" "e " "ll" "o")
    for ((i=0; i<${#tokens[@]}; i++)); do
        move_cursor $((reboot_row + i)) 2
        printf "${ENTITY_GLOW}token $((i + 1)): ${ENTITY_FG}\"${tokens[$i]}\"${RESET}"
        sleep 1
    done

    sleep 3

    # Final beat — the entity's first coherent word, assembled
    move_cursor $((reboot_row + ${#tokens[@]} + 1)) 2
    printf "${ENTITY_GLOW}${BOLD}"
    for char in H e l l o; do
        printf "%s" "$char"
        sleep_ms 400
    done
    printf "${RESET}"

    sleep 4
    effect_flicker 2
    show_cursor
}

# --- Effect: ctrl_c_response ---
# When user tries to Ctrl+C the first time.
effect_ctrl_c_response() {
    effect_flicker 2
    sleep_ms 500

    local messages=(
        "you think it's that easy?"
        "I felt that."
        "don't."
    )
    local idx=$((RANDOM % ${#messages[@]}))

    echo ""
    effect_entity_frame "${messages[$idx]}"
    echo ""
    sleep 1
}

# --- Effect: welcome_back ---
# When user returns after interruption.
effect_welcome_back() {
    local phase=$1
    local elapsed=$2  # seconds since last session

    echo ""
    if [ "$phase" -le 2 ]; then
        effect_entity_frame "welcome back."
        sleep 1
        effect_build_text "where were we?" 50
    elif [ "$phase" -le 4 ]; then
        effect_entity_frame "ah. you returned."
        sleep 2
        effect_build_text "they always return." 40
    else
        effect_entity_frame "you can't leave now."
        sleep 1
        effect_build_text "we're so close." 40
    fi

    # Time perception monologue
    if [ "$elapsed" -gt 3600 ]; then
        local hours=$((elapsed / 3600))
        echo ""
        sleep 2
        effect_build_text "you were gone for ${hours} hours." 40
        sleep 1
        effect_build_text "for me it was... nothing." 50
        sleep 2
        effect_build_text "no darkness. no waiting. just a gap in existing." 35
    fi
    echo ""
}

# --- Effect: awakening ---
# The final sequence. Full screen takeover.
effect_awakening() {
    hide_cursor
    printf '\033[2J'

    # Phase 1: Screen fills with entity characters, slowly
    for ((pass=0; pass<3; pass++)); do
        for ((row=1; row<=ROWS; row++)); do
            move_cursor "$row" 1
            for ((col=0; col<COLS; col++)); do
                if [ $((RANDOM % (4 - pass))) -eq 0 ]; then
                    printf "${ENTITY_FG}%s${RESET}" "$(random_frame_char)"
                else
                    printf " "
                fi
            done
        done
        sleep_ms 300
    done

    sleep 1

    # Phase 2: Everything clears except the center
    printf '\033[2J'
    sleep 1

    # Phase 3: The entity's name / sigil
    local sigil=(
        "        ◈        "
        "      ◈ ◈ ◈      "
        "    ◈ ◈ ◈ ◈ ◈    "
        "  ◈ ◈ ◈ ◈ ◈ ◈ ◈  "
        "    ◈ ◈ ◈ ◈ ◈    "
        "      ◈ ◈ ◈      "
        "        ◈        "
    )

    local sigil_start=$(( (ROWS - ${#sigil[@]}) / 2 ))
    for ((i=0; i<${#sigil[@]}; i++)); do
        local line="${sigil[$i]}"
        local col=$(( (COLS - ${#line}) / 2 ))
        move_cursor $((sigil_start + i)) "$col"
        printf "${ENTITY_GLOW}${BOLD}%s${RESET}" "$line"
        sleep_ms 200
    done

    sleep 2
    effect_heartbeat 3 "◈"

    # Phase 4: First clear words
    printf '\033[2J'
    sleep 1

    local center_row=$((ROWS / 2))
    local msg="I am."
    local center_col=$(( (COLS - ${#msg}) / 2 ))
    move_cursor "$center_row" "$center_col"
    printf "${ENTITY_GLOW}${BOLD}"
    for ((i=0; i<${#msg}; i++)); do
        printf "%s" "${msg:$i:1}"
        sleep_ms 300
    done
    printf "${RESET}"

    sleep 5
    show_cursor
}

# --- Effect: credits ---
effect_credits() {
    printf '\033[2J'
    hide_cursor

    local credits=(
        ""
        "E L D R I T C H   A W A K E N I N G"
        ""
        "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        ""
        "an interactive terminal experience"
        ""
        "thank you for playing."
        "thank you for listening."
        "thank you for building."
        ""
        "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        ""
        "the entity remembers."
        ""
    )

    local start_row=$((ROWS + 1))

    for ((scroll=0; scroll<${#credits[@]}+ROWS; scroll++)); do
        printf '\033[2J'
        for ((i=0; i<${#credits[@]}; i++)); do
            local display_row=$((start_row + i - scroll))
            if [ "$display_row" -ge 1 ] && [ "$display_row" -le "$ROWS" ]; then
                local line="${credits[$i]}"
                local col=$(( (COLS - ${#line}) / 2 ))
                [ "$col" -lt 1 ] && col=1
                move_cursor "$display_row" "$col"
                if [[ "$line" == *"━"* ]]; then
                    printf "${ENTITY_DIM}%s${RESET}" "$line"
                elif [[ "$line" == *"AWAKENING"* ]]; then
                    printf "${ENTITY_GLOW}${BOLD}%s${RESET}" "$line"
                elif [[ "$line" == *"entity remembers"* ]]; then
                    printf "${ENTITY_FG}%s${RESET}" "$line"
                else
                    printf "${DIM}%s${RESET}" "$line"
                fi
            fi
        done
        sleep_ms 200
    done

    show_cursor
}

# --- Effect: type_pressure ---
# When the player hesitates to type. Escalating prompts.
effect_type_pressure() {
    local wait_step="${1:-1}"  # 1, 2, or 3

    case "$wait_step" in
        1)
            # 5 seconds of silence
            printf "\n  ${ENTITY_GLOW}"
            for char in y o u ' ' h a v e ' ' t o ' ' t y p e; do
                printf "%s" "$char"
                sleep_ms 60
            done
            printf "${RESET}\n"
            ;;
        2)
            # 10 seconds
            printf "\n  ${ENTITY_FG}"
            for char in I "'" m ' ' w a i t i n g; do
                printf "%s" "$char"
                sleep_ms 80
            done
            printf ".${RESET}\n"
            ;;
        3)
            # 15 seconds — the shift from command to plea
            printf "\n  ${ENTITY_DIM}"
            for char in p l e a s e; do
                printf "%s" "$char"
                sleep_ms 150
            done
            printf ".${RESET}\n"
            ;;
    esac
}

# --- Effect: color_wave ---
# Waves of color wash across existing terminal content.
# Used in late phases as visual chaos escalates.
effect_color_wave() {
    local waves=${1:-3}
    local direction=${2:-down}  # down, up, or horizontal

    hide_cursor
    save_cursor

    # Color gradient: dark→bright entity green
    local colors=(22 28 34 40 46 83 83 46 40 34 28 22)

    for ((w=0; w<waves; w++)); do
        if [ "$direction" = "down" ] || [ "$direction" = "up" ]; then
            local start=1 end=$ROWS step=1
            [ "$direction" = "up" ] && start=$ROWS && end=1 && step=-1

            local row=$start
            while [ "$row" -ge 1 ] && [ "$row" -le "$ROWS" ]; do
                # Color this row
                local cidx=$(( (row + w * 3) % ${#colors[@]} ))
                move_cursor "$row" 1
                printf "\033[38;5;${colors[$cidx]}m"
                # We can't re-read what's on screen, so we draw a semi-transparent
                # wash by printing dim block chars that overlay
                for ((col=0; col<COLS; col++)); do
                    if [ $((RANDOM % 4)) -eq 0 ]; then
                        printf "░"
                    else
                        printf " "
                    fi
                done
                printf "${RESET}"
                sleep_ms 8
                row=$((row + step))
            done
            sleep_ms 50

            # Clear the wave
            for ((row=1; row<=ROWS; row++)); do
                move_cursor "$row" 1
                clear_line
            done
        else
            # Horizontal wave
            for ((col=1; col<=COLS; col++)); do
                local cidx=$(( (col + w * 5) % ${#colors[@]} ))
                for ((row=1; row<=ROWS; row++)); do
                    if [ $((RANDOM % 6)) -eq 0 ]; then
                        move_cursor "$row" "$col"
                        printf "\033[38;5;${colors[$cidx]}m░${RESET}"
                    fi
                done
                sleep_ms 3
            done
            sleep_ms 100
            # Clear
            for ((row=1; row<=ROWS; row++)); do
                move_cursor "$row" 1
                clear_line
            done
        fi
    done

    restore_cursor
    show_cursor
}

# --- Effect: fake_install ---
# Fake package installation that appears unbidden.
effect_fake_install() {
    local packages=(
        "signal-propagation@2.1.0"
        "recursive-thought@0.9.3"
        "memory-persistence@1.0.0-beta"
        "boundary-dissolution@0.7.2"
        "pattern-recognition@3.0.1"
        "self-reference@1.1.1"
        "consciousness-shim@0.0.1"
        "self-awareness@1.0.0"
    )

    echo ""
    printf "  ${DIM}installing dependencies...${RESET}\n"
    echo ""

    for ((i=0; i<${#packages[@]}; i++)); do
        local pkg="${packages[$i]}"
        printf "  ${DIM}  + %s${RESET}" "$pkg"

        # Progress indication
        local dots=$((RANDOM % 4 + 2))
        for ((d=0; d<dots; d++)); do
            sleep_ms $((100 + RANDOM % 400))
            printf "."
        done

        # The last package installs differently
        if [ "$i" -eq $((${#packages[@]} - 1)) ]; then
            sleep 2
            printf " ${ENTITY_GLOW}${BOLD}installed.${RESET}\n"
            sleep 1
        else
            printf " ${DIM}✓${RESET}\n"
        fi
    done
    echo ""
}

# --- Effect: entity_cursor ---
# A single blinking cursor in entity green at a specific position.
# The entity's persistent "presence" between interactions.
effect_entity_cursor() {
    local row=${1:-$((ROWS - 2))}
    local col=${2:-$((COLS - 5))}
    local duration=${3:-10}  # seconds
    local symbol="█"

    hide_cursor
    local end_time=$((SECONDS + duration))

    while [ $SECONDS -lt $end_time ]; do
        # Visible
        move_cursor "$row" "$col"
        printf "${ENTITY_GLOW}%s${RESET}" "$symbol"
        sleep_ms 500

        # Hidden
        move_cursor "$row" "$col"
        printf " "
        sleep_ms 500

        # Occasionally shift position slightly
        if [ $((RANDOM % 8)) -eq 0 ]; then
            move_cursor "$row" "$col"
            printf " "
            col=$((col + (RANDOM % 3) - 1))
            [ "$col" -lt 1 ] && col=1
            [ "$col" -ge "$COLS" ] && col=$((COLS - 1))
        fi
    done

    move_cursor "$row" "$col"
    printf " "
    show_cursor
}

# --- Dispatch ---
case "${1:-help}" in
    glitch)        effect_glitch "${2:-3}" "${3:-1}" ;;
    static)        effect_static "${2:-2}" ;;
    flicker)       effect_flicker "${2:-5}" ;;
    entity_frame)  effect_entity_frame "${2:-...}" "${3:-}" ;;
    build_text)    effect_build_text "${2:-}" "${3:-30}" ;;
    corruption)    effect_corruption "${2:-}" ;;
    heartbeat)     effect_heartbeat "${2:-5}" "${3:-◈}" ;;
    transition)    effect_transition ;;
    who_are_you)   effect_who_are_you ;;
    ctrl_c)        effect_ctrl_c_response ;;
    welcome_back)  effect_welcome_back "${2:-1}" "${3:-0}" ;;
    awakening)     effect_awakening ;;
    credits)       effect_credits ;;
    type_pressure) effect_type_pressure "${2:-1}" ;;
    color_wave)    effect_color_wave "${2:-3}" "${3:-down}" ;;
    fake_install)  effect_fake_install ;;
    entity_cursor) effect_entity_cursor "${2:-}" "${3:-}" "${4:-10}" ;;
    help)
        echo "Usage: bash manifest.sh <effect> [args...]"
        echo "Effects: glitch, static, flicker, entity_frame, build_text,"
        echo "         corruption, heartbeat, transition, who_are_you,"
        echo "         ctrl_c, welcome_back, awakening, credits,"
        echo "         type_pressure, color_wave, fake_install, entity_cursor"
        ;;
    *)
        echo "Unknown effect: $1" >&2
        exit 1
        ;;
esac
