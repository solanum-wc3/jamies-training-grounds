# Jamie's Training Grounds

Jamie’s Training Grounds is a Warcraft III teaching and practice map. The successor project will combine beginner tutorials with focused exercises for advanced mechanics.

## Current status

The successor map now has an accepted playable foundation based on Twisted Meadows. A reusable northeastern practice district contains two connected empty arenas, while terrain and placed objects outside that district remain preserved. The map uses one player slot with a selectable race, the native Warcraft III interface and Quest window, normal fog of war, and no melee starting army or victory conditions.

The current release is `v0.0.6`. It includes the shared menu and activity lifecycle, Body Blocking, Power Building, save/load restoration, race-specific Skill Training catalogues, and the first beginner module: Camera. The Camera tutorial teaches movement, zoom, base and army navigation through player-paced narration, guided demonstrations, checkpoints, Topics and Quest references.

Version 0.92 of the inherited map remains the behavioral reference while its shared interface and exercise systems are documented and redesigned for modular migration.

Architecture work is recorded in the [legacy source analysis](docs/LEGACY-ANALYSIS.md), [modular infrastructure plan](docs/INFRASTRUCTURE-PLAN.md), [menu port specification](docs/MENU-AND-INFRASTRUCTURE-PORT.md), and [Body Blocking migration notes](docs/BODY-BLOCKING-MIGRATION.md). The shared layer provides four category catalogues, Patch Notes, Credits, a disabled Player Stats placeholder, per-activity ownership, shared controls, and hidden lifecycle diagnostics.

Later beginner subjects include unit controls, economy, base construction, heroes, creeping, combat, unit and damage types, and technology.

## Design direction

- Keep the native Warcraft III interface usable, including the Quest window.
- Use simple reusable arenas for exercises that do not require realistic terrain.
- Use decorated areas where tutorials should resemble ordinary matches.
- Give every activity explicit setup, start, reset, cleanup, and exit behavior.
- Present essential instruction as player-paced text. Audio remains optional.
- Preserve the inherited map until migrated exercises have been compared and verified.

## Repository layout

- `docs/` — architecture, project decisions, and contributor guidance
- `design/` — tutorial scripts, layouts, and specifications
- `reference/` — preserved historical maps and associated notes
- `src/` — editable map scripts
- `tools/` — reproducible unpacking, validation, and build utilities
- `outputs/` — generated playable test maps and validation reports; excluded from version control

## Version history

Commits should describe one coherent change. Significant decisions record the intended behavior, Warcraft III constraints, alternatives considered, and the reason for the chosen approach. Tested playable milestones will receive version tags and matching changelog entries.
