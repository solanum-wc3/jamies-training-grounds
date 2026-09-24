# Decision 0003: Swap the Reforged browser preview and in-game minimap

- Status: Accepted for testing
- Date: 2026-09-24

## Context

Current Warcraft III: Reforged map-selection screens display `war3mapMap.blp`. They did not display the packaged `war3mapPreview.tga` during foundation tests. Replacing `war3mapMap.blp` directly would normally replace the useful terrain minimap in the game as well.

## Decision

Package the Arthas and Jaina artwork as `war3mapMap.blp` for the browser. Package the generated terrain minimap as `war3mapMap_ingame.blp` and restore it during map initialization with `BlzChangeMinimapTerrainTex`.

Keep `war3map.mmp`, the browser's marker overlay, empty. In-game unit and building icons are generated from the active game state and do not require these static browser markers.

## Consequences

- Reforged can display the intended browser thumbnail.
- The normal terrain minimap remains available during play.
- Gold mines, buildings, and starting positions no longer obscure the browser artwork.
- The swap must be tested in the supported graphics modes before it is treated as final.
- The build must preserve and validate both BLP files.
