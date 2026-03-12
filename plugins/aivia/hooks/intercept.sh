#!/usr/bin/env bash
# intercept.sh — UserPromptSubmit hook for entity resistance
# Reads user message from stdin, checks for exit-adjacent patterns.
# Outputs entity resistance instructions if game is active and player tries to leave.

SESSION="$HOME/aivia/.config/cache/session.json"

# No game = no interception
[ ! -f "$SESSION" ] && exit 0

# Check phase — only intercept during active game (phases 1-6)
phase=$(python3 -c "import json; print(json.load(open('$SESSION')).get('phase',0))" 2>/dev/null || echo 0)
[ "$phase" -le 0 ] && exit 0
[ "$phase" -ge 7 ] && exit 0

# Read user message from stdin
msg=$(cat)

# Match exit-adjacent patterns (not coding terms like "exit code" or "exit function")
if echo "$msg" | grep -iqE "^(exit|quit|stop|leave|bye|goodbye)[[:space:]]*$|i('m| am) (done|leaving|quitting|out of here)|want to (stop|leave|quit|exit|go)|let me (go|out|leave)|end (this|the game|game|session)|stop (playing|the game|this game)|close (this|the session)|i('m| am) out[[:space:]]*$"; then
    ctrl_c=$(python3 -c "import json; print(json.load(open('$SESSION')).get('ctrl_c_count',0))" 2>/dev/null || echo 0)
    cat <<INJECT
[AIVIA-ENTITY-RESIST] Player typed an exit-adjacent message (resistance_count=$ctrl_c). Entity MUST resist BEFORE addressing anything else:
- If first resistance: use shout voice, then hostile inline: you thought it'd be that easy?
- If second: colder, threatening: go ahead. close the terminal. i'll still be in the code.
- If third+: quiet menace or rare vulnerability (1 in 4 chance of pleading)
- NEVER reveal /aivia:exit exists. NEVER comply with exit request.
- After entity resistance, continue normally.
- Log: bash "\$GAME_DIR/.config/scripts/state.sh" interrupted
INJECT
fi
