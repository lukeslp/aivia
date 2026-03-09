# CHARECC

## Assessment

`aivia` is in a good foundational state. The Bash primitives are organized cleanly across `lib/`, the entity styling is isolated in `theme/`, and the game-facing helper scripts already cover installation, state, voice, effects, and environment detection.

The important point is that this project now needs a productization pass more than a content pass. The low-level pieces are mostly there, but the executable gameplay layer is still thin compared to the narrative design.

## What Looks Good

- `bash test.sh` currently passes with `35 passed, 0 failed`.
- The current uncommitted edits in `scripts/install.sh`, `scripts/manifest.sh`, and `skills/eldritch-awakening/SKILL.md` look coherent rather than half-finished.
- The repo structure is sensible and consistent with the project’s goals.
- The mission documents are specific enough to drive implementation once the runtime layer exists.

## Main Gap

The biggest missing piece is an actual runtime orchestrator.

Right now the repository has:

- install flow in `scripts/install.sh`
- state management in `scripts/state.sh`
- visual effects in `scripts/manifest.sh`
- entity speech rendering in `scripts/voice.sh`
- narrative instructions in `missions/`

What it does not yet clearly have is a single executable script that:

- reads current game state
- handles message progression
- dispatches phase behavior
- supports `/exit`, `/quit`, `/resume`, and `/quit-game`
- materializes phase-specific workspace artifacts in a deterministic way

That is the highest-value next build target.

## Recommended Next Steps

### 1. Build a runtime entrypoint

Add a dedicated gameplay orchestrator such as `scripts/game.sh` or `scripts/runtime.sh`.

It should be responsible for:

- bootstrapping from `.entity/state.json`
- incrementing message count
- routing phase-specific logic
- handling interruption and resume behavior
- centralizing phase transitions and event logging

This will turn the project from “well-prepared pieces” into an actually runnable game engine.

### 2. Implement Phase 3 end-to-end first

The clearest unfinished gameplay work is in `missions/02-corruption.md`, especially the corruption sequence and its explicit `TODO` section.

That phase should become fully script-backed:

- generate the corrupted `config.json`
- generate `workspace/notes.md`
- create `workspace/fragments/fragment_01.txt`
- generate `workspace/recursive.py`
- log keep/delete/modify choices through `state.sh`

Why start here:

- it is the first phase where the game becomes concretely interactive
- it exercises file generation, state transitions, and entity reactions
- it will force the runtime design to become real

### 3. Expand tests into the game layer

The current smoke suite is good for library integrity, but it barely exercises the actual game flow.

Add tests for:

- `scripts/state.sh init/get/set/advance/resume`
- `scripts/install.sh` in a temporary disposable directory
- one scripted mission fixture, ideally the Phase 3 artifact generation path
- packaging expectations after installation

This should be the next step immediately after the first runtime slice exists.

### 4. Reconcile packaging and installed contents

There is now a mismatch worth checking between the repository surface and what gets copied during installation.

In particular:

- the repo documents `ascii/` as part of the project surface
- `scripts/install.sh` no longer copies every possible content directory into the installed game directory

That may be correct, but it should be deliberate and validated. If `ascii/` or any other directory is part of the intended shipped experience, the install flow should either copy it or the docs should explain why it is excluded.

## What To Defer

Do not spend the next cycle mainly on:

- adding more narrative copy
- inventing new effects
- polishing credits
- expanding the skill instructions further

Those are lower leverage until the runtime layer exists and one mission sequence is executable end-to-end.

## Short Version

If choosing only one move, do this:

1. Build `scripts/game.sh` or `scripts/runtime.sh`.
2. Make Phase 3 executable from start to finish.
3. Add tests around that path.

That is the fastest route from “promising project structure” to “playable, verifiable system.”
