# Project file guide

This inventory distinguishes maintained source, generated output, immutable reference material and files retained for a later decision.

## Authoritative source

- `src/activities/` — implemented tutorial, training and demonstration behavior
- `src/infrastructure/` — shared runtime plus development-only diagnostics
- `src/config/` — packaged Warcraft III interface configuration
- `src/data/` — CustomKeys inputs, native Hotkey/tech inventories, practice pools, Heroes data and development sound inventory
- `design/menu-art/` — editable menu artwork used by the texture generator
- `design/overlays/` — editable unit-obstruction-square artwork
- `design/tutorials/` — authored Economy/Heroes JSON, layout inputs and editable snapshots
- `design/exercises/editable/` — editable briefing files; Hotkey/Reflex text is authoritative and generated automatically, other files are manual-import work files
- `design/dodge-catalog.json` — native danger/dodger catalogue; activation measurements and timing audit JSON retain evidence
- `tools/` — build, extraction and asset-preparation utilities
- `docs/ARCHITECTURE.md` and `docs/ARCHITECTURE-TODO.md` — current architecture and backlog

## Generated or reproducible files

- `src/generated/custom-keys.lua` is generated from `src/data/` and intentionally committed so maps can be built without a separate generation step.
- `src/assets/menu/*.dds` is generated from `design/menu-art/` or retained as a packaged interface texture.
- `src/assets/overlay/*.dds` is the packaged form of the maintained overlay artwork.
- `outputs/` contains generated maps and validation reports and is ignored.
- `work/` contains temporary extraction and investigation material and is ignored.

## Immutable references

- `reference/foundation/` contains the accepted foundation used by current builds.
- `reference/twisted-meadows/` contains the untouched terrain source.
- `reference/legacy/` contains historical assets extracted from the inherited map.
- `reference/diagnostics/` preserves the earlier standalone Surrounds calibration source.

Reference files must not be edited in place. New experiments should use copies under `work/` or maintained diagnostic modules under `src/infrastructure/`.

## Historical documentation

`docs/archive/` contains completed migration plans, superseded checklists, early legacy analysis and implemented design drafts. These files remain useful for tracing decisions but are not instructions for current work.

## Retained review candidates

The following files are not used by the current packaged map but may still be useful as editable or historical material. Decide on them with a visual or provenance review before deletion:

- generated `*Hover.dds` files and `ButtonHover.dds` under `src/assets/menu/`;
- `TooltipGrey.dds` and `TooltipNative.dds`, which predate the current nine-piece tooltip;
- `src/foundation-test.lua`, retained to reproduce the accepted foundation;
- the large extracted legacy menu-asset collection under `reference/legacy/menu-assets/`;
- the archived Camera tutorial draft, whose implemented behavior now lives in `src/activities/camera-tutorial.lua`.

Embedded CustomKeys data remains committed, although player-facing exports are disabled. It can be replaced or regenerated from `src/data/`; it is not proof that arbitrary clean text export works.

`src/generated/economy-script.lua`, `economy-layout.lua` and `dodge-catalog.lua` are regenerated from maintained design inputs. `dodge-timing-methods.lua` and `melee-tech.lua` are generated/native-derived data; preserve them for clean-checkout builds.

`src/generated/exercise-briefings.lua` and `heroes-tutorial.lua` are refreshed by the build from maintained text/JSON. Hotkey catalogue and sound data have dedicated preparation tools. The two small Hotkey audit default tables support fresh development builds; local generated bindings/history under `work/` override them without becoming production inputs. Do not commit a player's diagnostic reports or local binding fixture merely to make a build succeed.

The maintained map-selection artwork is `design/map-preview/map-selection.png`. Run `tools/prepare-map-preview.py` to generate `src/assets/preview/war3mapMap.blp` (Reforged browser) and `war3mapPreview.tga` (preview fallback). The builder packages these explicitly. The original artwork remains immutable under `reference/legacy/`; `war3mapMap_ingame.blp` remains the foundation's terrain minimap and is restored separately in game. Artwork-only preparation does not replace a published release artifact.

Unused Camera settings screenshot textures and their generator/build entries were removed after their Quest icons changed to native Reveal and Peon icons. The distributed beta1 map is unchanged; subsequent builds omit these unused assets.
