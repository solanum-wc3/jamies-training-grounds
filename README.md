# Jamie's Training Grounds

Jamie’s Training Grounds is a Warcraft III teaching and practice map. The successor project will combine beginner tutorials with focused exercises for advanced mechanics.

## Current status

The successor map now has an accepted playable foundation based on Twisted Meadows. A reusable northeastern practice district contains two connected empty arenas, while terrain and placed objects outside that district remain preserved. The map uses one player slot with a selectable race, the native Warcraft III interface and Quest window, normal fog of war, and no melee starting army or victory conditions.

The accepted baseline is `v0.0.1-alpha.5`. It has been tested in Warcraft III and successfully opened and saved by World Editor.

Version 0.92 of the inherited map remains the behavioral reference while its shared interface and exercise systems are documented and redesigned for modular migration.

The first planned beginner module is the camera-controls tutorial. Later subjects include unit controls, economy, base construction, heroes, creeping, combat, unit and damage types, and technology.

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
