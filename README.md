# Jamie's Training Grounds

Jamie’s Training Grounds is a Warcraft III teaching and practice map. The successor project will combine beginner tutorials with focused exercises for advanced mechanics.

## Current status

The project is in its planning and repository-setup phase. Version 0.92 of the inherited map remains the behavioral reference while a smaller, modular successor map is designed.

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
- `src/` — editable map scripts and source assets once the successor map begins
- `tools/` — reproducible unpacking, validation, and build utilities
- `build/` — generated playable maps; excluded from version control

## Version history

Commits should describe one coherent change. Significant decisions record the intended behavior, Warcraft III constraints, alternatives considered, and the reason for the chosen approach. Tested playable milestones will receive version tags and matching changelog entries.
