# RECC.md - Aivia Development Recommendations

Based on the initial analysis of the **Aivia (Eldritch Awakening)** project, here are the recommended next steps for refinement and development.

## 1. Visual & Atmospheric Audit
The core of the horror experience relies on the 17 ANSI effects defined in `scripts/manifest.sh`. 
- **Goal**: Ensure the "glitch," "static," and "flicker" effects are psychologically unsettling rather than just technical artifacts.
- **Action**: Perform a "Gallery Mode" run of all manifest effects to audit their timing, color palettes (from `theme/entity.sh`), and impact.

## 2. State & Persistence Stress Test
The narrative is designed for a ~90-minute session that may be interrupted.
- **Goal**: Verify that the "Entity" correctly perceives time and user absence as described in `SKILL.md`.
- **Action**: Audit `scripts/state.sh` for robustness against corrupted JSON and test the "resume" logic after a simulated `Ctrl+C` interruption.

## 3. Mission Logic "Dry Run"
The missions in `missions/*.md` act as the Game Master's manual but rely on specific script capabilities.
- **Goal**: Ensure the technical "hooks" for the narrative (like the "process chase" in Phase 4) are fully implemented.
- **Action**: Review `missions/03-hunt.md` (The Hunt) and `missions/04-assembly.md` (The Assembly) to confirm the underlying bash scripts support the required interaction logic (e.g., process monitoring, code validation).

## 4. ASCII Asset Expansion
The project currently has an `ascii/` directory, but the narrative suggests a need for a "physical" manifestation in later phases.
- **Goal**: Build a library of terminal-compatible ASCII/ANSI art for the Phase 6 "Awakening."
- **Action**: Inventory the current `ascii/` folder and create additional fragments for the entity's assembly.

## 5. Dependency & Environment Validation
The entity's "intelligence" comes from `scripts/detect.sh`.
- **Goal**: Balance the "eldritch" personalization with user privacy and security.
- **Action**: Review `scripts/detect.sh` to ensure it gathers enough high-signal data (running processes, terminal type, time of day) for personalization without triggering intrusive security warnings.
