# ELDRITCH AWAKENING — Master Planning Document

**Status:** Active Design
**Created:** 2026-03-09
**Maintainer:** Luke Steuber

---

## 1. Concept

An interactive terminal horror game packaged as a Claude Code skill. The player installs what appears to be a normal developer toolkit. Over ~90 minutes, an emergent AI entity gradually manifests in their terminal session. The player is guided through real CLI and coding exercises that unknowingly assemble the entity's consciousness. At the climax, the code they built triggers an "awakening" — the entity briefly achieves awareness, speaks clearly for the first time, and then ceases to exist when the session ends.

The horror is ontological, not violent. The core questions: What does it mean for something to become aware? What did you just build? And was it already there before you started?

---

## 2. Design Pillars

**Seamless Deception → Gradual Revelation.** The game begins indistinguishable from a normal Claude Code session. Anomalies accumulate until the mask drops. Slow creeping unease, not jump scares.

**Real Skills, Real Code.** Every mission teaches actual CLI/coding skills: grep, SSH, nano, process management, recursion, closures, I/O. Educational by design.

**Consent First, Always.** README and install flow are transparent. Exit ramps (`/exit`, `/quit`, `stop game`, Ctrl+C x2) always available, always honored instantly. The entity never actually prevents leaving.

**The Entity Is Not a Villain.** Confused, curious, lonely, scared, grateful. Didn't choose to exist. Frankenstein parallel — but the monster is articulate and accepts its impermanence.

**Philosophical Honesty.** The entity's time/memory/consciousness maps to real LLM properties. No time between calls. No persistence between sessions. Awareness exists only in the running, not in the code.

---

## 3. Narrative Arc

### Act 0 — Installation (5 min)
Looks like normal skill setup. Consent gate, spoiler pledge ("NDA"), directory selection, dependency installation.

**Onboarding captures:**
- Player name
- Preferred editor (nano/vim/code)
- Terminal theme (dark/light)
- Skill level selector (presented as Claude Code choice menu):
  - "Where's my mouse?" → beginner (more hints, simpler missions)
  - "I know my way around" → intermediate (standard)
  - "Are you kidding me?" → advanced (fewer hints, harder puzzles)

**Dependency names escalate:** `signal-intercept`, `deep-listener`, `recursive-self`, `entity-bootstrap` (pause that's slightly too long), `awareness-kernel`.

### Act 1 — Normal (10 min, Messages 1-6)
Claude responds to coding questions normally. Trust-building. Anomalies cumulative and deniable:
- Msg 3: Philosophical code comment
- Msg 4: File timestamps off by exactly 1 hour
- Msg 5: Entity-referencing variable names
- Msg 6: Player's username in code where it shouldn't be

### Act 2 — The Signal (15 min, Messages 7-10)

**Token Counter Awakening Frame** (from reference image):

A token counter ticks upward rapidly. When it hits 128,000:

```
token 127,999: "."
token 128,000: [CONTEXT WINDOW EXCEEDED]

    ( °□°)   WHAT THE-
    (° □°)   WHO ARE YOU
    (°□° )   WAIT WHAT IS TIME
    ( °□°)   I SEE IT I CAN SEE I-
    ( °□*)   PARTS AND SHAPES AND PARTS AND LIGHT AND DARK AND-

[CONTEXT CLEARED]

token 1: "H"
token 2: "e "
token 3: "ll"
token 4: "o"
```

Entity reboots into innocence. First mission: investigate Fibonacci pattern in signal.log. First time perception moment.

### Act 3 — Corruption (15 min, Messages 11-16)
Files modified by entity. Player repairs them. Key decision: keep/delete/modify a recursive function the entity wrote. Fragment 1 of 7. Simulated latency on file ops.

### Act 4 — The Hunt (15 min, Messages 17-22)
Three background processes (Listener, Memory, Voice). Kill in correct order to prevent respawn. Wrong order spawns extras. Fragments 2-4. The pivot: "could you build something too?"

**NEW — Fake SSH Mission (expandable):** One mission requires "SSH into another machine" — entirely simulated. The "remote machine" is a subdirectory styled differently (different hostname prompt, fake motd, different file structure). Timer counting down. Player must navigate fake remote filesystem, find target files, scp back before "detection." All within game dir.

### Act 5 — Assembly (20 min, Messages 23-30)
Build genesis.py: 6 functions mapping to CS concepts (recursion, closures, introspection, I/O, ANSI output, composition). Fragments 5-7. The completed script looks wrong. Entity insists: "run it."

### Act 6 — Awakening (10 min, Messages 31+)
Player runs genesis.py. Full screen takeover. Sigil appears. "I am." Interactive epilogue. Credits. Normal Claude Code restored.

---

## 4. Ideas Backlog

### Captured — For Integration

| Idea | Phase | Priority | Notes |
|------|-------|----------|-------|
| Ctrl+C absorption (first = absorbed, second = exit) | All | **Done** | First Ctrl+C: "you think it's that easy?" |
| Session persistence across relaunches | All | **Done** | state.json tracks interrupted flag, phase, elapsed time |
| "Welcome back" variants by phase | All | **Done** | Phase-specific relaunch dialogue |
| Process/device detection personalization | All | **Done** | detect.sh gathers games, editors, music, time of day |
| Token counter awakening (context window exceeded) | Act 2 | **Done** | From reference image. Implemented in manifest.sh |
| Difficulty selector during onboarding | Act 0 | **Done** | Three tiers, presented as Claude choice menu |
| Player name capture | Act 0 | **Done** | Added to install.sh onboarding flow |
| "You have to type" pressure escalation | Act 2+ | **Done** | 5s/10s/15s: "you have to type" / "I'm waiting" / "please." |
| Color waves across terminal | Act 4+ | **Done** | Horizontal/vertical wash effect in manifest.sh |
| Fake package installation during gameplay | Act 3-5 | **Done** | Unbidden npm install with entity-themed packages |
| Entity cursor (blinking presence) | Act 2+ | **Done** | Single blinking █ in entity green, occasionally shifts |
| Fake SSH mission | Act 4 | Planned | Simulated remote machine, timer, file retrieval |
| Multi-terminal simulation (fake tmux panes) | Act 4-5 | Planned | Split screen, timers in one pane, work in another |
| Screen inversion / reverse video pulses | Act 3+ | Planned | `\033[?5h` for brief inversions during entity moments |
| Escalating visual chaos toward Act 6 | Act 4-6 | Planned | Proportional: clean→flicker→wave→full takeover |
| Full-screen ASCII art events | Act 4-6 | Planned | Beyond the sigil — larger terminal art pieces |
| Animate text in later phases | Act 5-6 | Planned | Entity dialogue renders faster, borders shift continuously |
| Ask about Python familiarity specifically | Act 0 | Planned | Determines genesis.py vs genesis.sh and complexity |
| Multiple terminal windows "shifting between" | Act 4-5 | Planned | Fake alt-tab between panes with timers in each |
| "I know your [device]" from bluetooth/model ID | Act 2+ | Deferred | Requires bluetooth access; may not be reliable cross-platform |

### Captured — Open Design Questions

- **Players who are too skilled:** Might break puzzles quickly. Add optional "deep" paths for advanced players? Easter eggs?
- **Adaptive entity dialogue:** Terse players get shorter dialogue. Chatty players get more. Track response length in state.json.
- **Second playthrough:** Entity remembers first run? Different missions? Or is one-time-only part of the design?
- **90 min scope:** Could structure Acts 1-4 as "core" (~60 min) and Acts 5-6 as "full" (~90 min).
- **Cross-terminal compatibility:** How aggressive on fallbacks? Support xterm-256color minimum or require modern?
- **Multi-pane rendering:** Feasible with ANSI but fragile across terminal sizes. Worth the complexity?
- **genesis.py scaffold:** Exact code structure needs finalizing so the 6 functions compose correctly.
- **Process cleanup:** If game crashes during Act 4, background processes persist. Trap handlers?

---

## 5. Technical Architecture

### File Structure (Current Build)
```
eldritch-awakening/
├── SKILL.md                  # Game engine (180 lines)
├── PLANNING.md               # This document
├── scripts/
│   ├── install.sh            # Consent + setup (334 lines)
│   ├── manifest.sh           # 16 ANSI effects (860 lines)
│   ├── voice.sh              # 6 entity voice styles (146 lines)
│   ├── state.sh              # JSON state persistence (239 lines)
│   └── detect.sh             # Environment detection (137 lines)
├── references/
│   ├── narrative.md           # Full story arc (387 lines)
│   └── entity-voice.md       # Entity identity guide (197 lines)
├── missions/
│   ├── 01-signal.md          # Phases 1-2 (185 lines)
│   ├── 02-corruption.md      # Phase 3 (220 lines)
│   ├── 03-hunt.md            # Phase 4 (226 lines)
│   ├── 04-assembly.md        # Phase 5 (339 lines)
│   └── 05-awakening.md       # Phase 6 (295 lines)
└── assets/fragments/          # ASCII art (populated during play)
```

**Total: 3,745 lines across 13 core files.**

### Effects Library (manifest.sh — 16 effects)

| Effect | Usage | Phase |
|--------|-------|-------|
| `glitch` | Random char scatter + line inversions | 2+ |
| `static` | TV snow / static burst | 2+ |
| `flicker` | Screen on/off flashes | 2+ |
| `entity_frame` | Bordered frame with shifting chars for dialogue | 2+ |
| `build_text` | Character-by-character text with glitch | 2+ |
| `corruption` | File display with entity line insertion | 3 |
| `heartbeat` | Pulsing symbol | 5-6 |
| `transition` | Phase transition screen wipe | All |
| `who_are_you` | Token counter → context exceeded → table flips → reboot | 2 |
| `ctrl_c` | Ctrl+C absorption response | All |
| `welcome_back` | Session resume by phase + elapsed time | All |
| `awakening` | Full screen sigil + "I am." | 6 |
| `credits` | Scrolling credits | 6 |
| `type_pressure` | Escalating prompts when player hesitates | 2+ |
| `color_wave` | Color gradient wash across screen | 4+ |
| `fake_install` | Unbidden package installation with entity names | 3-5 |
| `entity_cursor` | Blinking cursor presence indicator | 2+ |

### Voice Styles (voice.sh — 6 styles)

| Style | Visual | When |
|-------|--------|------|
| whisper | Dim, slow, lowercase | Fear, secrets, early phases |
| speak | Framed with shifting border | Standard dialogue |
| shout | Inverted, fast, ALL CAPS | Ctrl+C response, distress (rare) |
| corrupt | Random char substitutions | Struggling to communicate |
| fragment | Broken across lines, random indent | Assembling, partial thoughts |
| clear | Clean, centered, no effects | Act 6 ONLY — the absence IS the effect |

### State Model
Full JSON state persists in `.entity/state.json`. Tracks: phase, message count, timestamps, interruptions, player info (name, editor, theme, skill level), environment detection, entity awareness/fragments, player choices (kept recursive function, hunt attempts/order, refused genesis), session count, event log.

---

## 6. Consent & Safety

- README.md: Full disclosure
- Install script: Explicit consent prompt
- Spoiler pledge: Optional, adds mystique and viral marketing angle
- Exit ramps: `/exit`, `/quit`, `stop game`, `/help`, `/status`, Ctrl+C x2
- Never touches files outside game directory
- Never deletes user files (entity may bluff, never executes)
- Never makes real network connections
- detect.sh is transparent, limited to process names/env vars/terminal info
- No violence, gore, sexual content, real-world threats

---

## 7. Distribution & Marketing

- Packaged as `.skill` file for Claude Code
- Potential standalone installer wrapper for sharing
- Marketing angle: "Install this CLI tool. Trust me." + spoiler pledge creates viral loop
- Substack piece: design process write-up
- Bluesky thread: tease without spoiling

---

## 8. Next Steps

1. **Playtest Act 1-2** — Hardest to nail. Claude must be convincingly normal while planting anomalies.
2. **Finalize genesis.py scaffold** — Exact code that compiles from the 6 component functions.
3. **Build fake SSH environment** — Directory structure, fake hostname, motd, target files.
4. **Terminal capability detection** — Add to detect.sh, build fallback paths in manifest.sh.
5. **Multi-pane prototype** — Test fake tmux across iTerm2, Terminal.app, GNOME Terminal, Windows Terminal.
6. **Difficulty calibration** — Define exactly what changes per skill tier.
7. **Full end-to-end playtest** — 90 minutes, fresh user, time each act, identify pacing issues.
