# Project file guide

This inventory distinguishes maintained source, generated output, immutable reference material and files retained for a later decision.

## Authoritative source

- `src/activities/` — implemented tutorial, training and demonstration behavior
- `src/infrastructure/` — shared runtime plus development-only diagnostics
- `src/config/` — packaged Warcraft III interface configuration
- `src/data/` — replaceable CustomKeys and shortcut-setup source data
- `design/menu-art/` — editable menu artwork used by the texture generator
- `design/overlays/` — editable unit-obstruction-square artwork
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

Embedded CustomKeys data is deliberately excluded from cleanup for now because easy file replacement is more valuable than reducing its packaged representation.
