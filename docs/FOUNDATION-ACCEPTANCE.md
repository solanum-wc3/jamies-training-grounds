# Foundation acceptance

Version `v0.0.1-alpha.5` is the accepted foundation for the successor project.

## Verified behavior

- Warcraft III loads and plays the map without an observed problem.
- The custom-game lobby has one trainee slot with a selectable race.
- The title, description, and `Jamie & Solanum` author metadata display correctly.
- The Arthas and Jaina browser preview displays without gold-mine, building, or starting-position overlays.
- The legacy loading screen displays while the map loads.
- The ordinary terrain minimap is available during loading and play.
- Unexplored terrain begins fully black and normal fog of war works.
- The northeastern practice district has satisfactory terrain, two connected spaces, and a blocking perimeter.
- The temporary test units, chat commands, native Quest window, and F-key controls work.
- World Editor can open and save the map without breaking its other tested behavior.

## Packaging rule

World Editor regenerates `war3mapMap.blp` and the menu-marker layer whenever it saves the map. An editor-saved development map must therefore pass through the project build before distribution. The build restores the custom browser preview, preserves the separate terrain minimap, and clears the browser marker overlay.

## Baseline artifact

`reference/foundation/Jamies-Training-Grounds-v0.0.1-alpha.5.w3x`

SHA-256: `a1ea7789e60b30e77d64f14337759842dff309d129929ef24defb1276cf1ba64`
