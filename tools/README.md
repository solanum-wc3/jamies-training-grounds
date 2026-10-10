# Project tools

`build-foundation.cjs` reproduces the preserved playable foundation from the preserved Twisted Meadows reference map. It changes only the designated northeastern practice district, map metadata, the temporary test harness, and the files required for the lobby preview. It fails if the reference-map hash or expected binary layouts change.

`foundation-minimap.py` updates the matching region of the minimap and preserves the remaining pixels. Run it after the build script's `--prepare` step and before the final build.

`build-infrastructure.cjs` creates release and development maps directly from the accepted alpha.5 foundation. It assembles the selected Lua modules, editor trigger metadata, version string, menu assets and native interface overrides. It verifies the accepted source hash, parses the assembled Lua, round-trips all changed members, and proves all other listed archive members remain byte-identical.

Install the locked dependencies and build with:

```text
pnpm install --frozen-lockfile
pnpm run build:release
```

The release map contains no developer commands or diagnostic activities. The
matching internal build uses the same version with a `-dev` suffix. During
development, the version may additionally carry an incrementing alpha suffix.
Build the development map with:

```text
pnpm run build:development
```

In the development map, enter `-diag-lifecycle` while no activity is active to
automatically check start, reset, activity replacement, exit, resource disposal
post-disposal final cleanup and stale-callback protection. Collision diagnostic
commands are also development-only and are documented in
[collision research](../docs/COLLISION-OBSTRUCTION-RESEARCH.md). Enter `-diag-status` for the latest result or
`-diag-cancel` to stop a running check. `pnpm run build:all` produces and
validates both variants. The older `build:infrastructure` command remains an
alias for the release build.

The current reproducibility check uses Node.js 24 and pnpm 11. The two direct dependencies and their transitive packages are pinned in `pnpm-lock.yaml`.

`extract-legacy-menu-assets.cjs` reads the authoritative v0.92 map without modifying it and extracts the exact custom textures and frame definitions used by its training-path and course-card menus. It refuses an archive whose SHA-256 differs from the recorded source. The extracted files and their manifest live under `reference/legacy/menu-assets/`.

`prepare-menu-art.py` converts editable transparent successor artwork into power-of-two DXT5 textures while preserving separate background, artwork, border, text, and hover layers. Run it before packaging whenever a source image changes.

`prepare-surround-overlays.py` converts the editable player and enemy obstruction-square PNG files under `design/overlays/` into packaged DXT5 textures. The navigation-dot and fine-grid PNG/DDS pairs are maintained under `src/assets/overlay/` because they are direct authored map assets.

Temporary investigation files remain in `work/` and are excluded from version control. Generated maps and validation reports remain in `outputs/`.

## Maintained generators and checks

Economy layout and narration are authored in `design/tutorials/economy-layout.json` and `economy-script.json`; their preparation tools regenerate the corresponding checked-in Lua. Dodging uses `prepare-dodge-catalog.py` and `audit-dodge-timing.py`. The timing inventory lists raw fields; archived native reports contain the runtime measurements. `extract-tutorial-texts.cjs` creates the review snapshot for all four tutorials, excluding disabled export instructions.

Run `pnpm run check:lua` and `pnpm run test:reliability` after lifecycle or progression changes. Python checks require `lupa`; artwork preparation requires Pillow. Player-facing file exports remain disabled; development diagnostic exports use Warcraft's preload wrappers.

To validate packaging without replacing a distributed map, run:

```text
node tools/build-infrastructure.cjs --mode=release --output-dir=work/maintenance-build
node tools/build-infrastructure.cjs --mode=development --output-dir=work/maintenance-build
```

The default output remains `outputs/`. See [build and test](../docs/BUILD-AND-TEST.md) and [release status](../docs/RELEASE-STATUS.md) before distributing a new version.
