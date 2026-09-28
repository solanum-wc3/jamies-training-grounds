# Project tools

`build-foundation.cjs` creates the current playable foundation from the preserved Twisted Meadows reference map. It changes only the designated northeastern practice district, map metadata, the temporary test harness, and the files required for the lobby preview. It fails if the reference-map hash or expected binary layouts change.

`foundation-minimap.py` updates the matching region of the minimap and preserves the remaining pixels. Run it after the build script's `--prepare` step and before the final build.

`build-infrastructure.cjs` creates the current playable release directly from the accepted alpha.5 foundation. It assembles the Lua modules, editor trigger metadata, version string, menu assets and native interface overrides. It verifies the accepted source hash, parses the assembled Lua, round-trips all changed members, and proves all other listed archive members remain byte-identical.

Install the locked dependencies and build with:

```text
pnpm install --frozen-lockfile
pnpm run build:infrastructure
```

The current reproducibility check uses Node.js 24 and pnpm 11. The two direct dependencies and their transitive packages are pinned in `pnpm-lock.yaml`.

`extract-legacy-menu-assets.cjs` reads the authoritative v0.92 map without modifying it and extracts the exact custom textures and frame definitions used by its training-path and course-card menus. It refuses an archive whose SHA-256 differs from the recorded source. The extracted files and their manifest live under `reference/legacy/menu-assets/`.

`prepare-menu-art.py` converts editable transparent successor artwork into power-of-two DXT5 textures while preserving separate background, artwork, border, text, and hover layers. Run it before packaging whenever a source image changes.

Temporary investigation files remain in `work/` and are excluded from version control. Generated maps and validation reports remain in `outputs/`.
