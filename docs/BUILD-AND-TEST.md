# Build, installation and testing

## Requirements

- Windows with Warcraft III installed for runtime testing
- Node.js 20 or newer
- pnpm 11 (the repository declares `pnpm@11.19.0`)
- Python 3 with Pillow only when regenerating image assets

The normal map build uses the committed generated assets and does not require Python.

## Clean-checkout setup

```text
git clone <repository-url>
cd jamies-training-grounds
pnpm install --frozen-lockfile
pnpm run build:all
```

`build:all` creates and validates:

- `outputs/Jamies-Training-Grounds-v0.1.0.w3x`
- `outputs/Jamies-Training-Grounds-v0.1.0-dev.w3x`

The builder verifies Lua syntax, archive round-tripping, the immutable foundation hash, unchanged archive members, the development-tool boundary and shared-system invariants. A failed check stops the build.

## Installing a generated map

Copy the desired `.w3x` file into a folder beneath:

```text
Documents\Warcraft III\Maps\
```

A dedicated subfolder such as `Maps\JamiesTrainingGrounds\` keeps test versions separate. Launch Warcraft III, open Custom Games, browse to that folder and select the map. The map-selection title includes `-dev` for development builds.

## Choosing a build

- Use the release map for ordinary play and distribution. It contains no developer commands or collision diagnostic modules.
- Use the development map for lifecycle checks, collision experiments and implementation testing.

Development lifecycle commands:

- `-diag-lifecycle` starts the automated lifecycle test while no activity is active.
- `-diag-status` prints the most recent result.
- `-diag-cancel` stops a running check.

Collision commands and export formats are documented in [`COLLISION-OBSTRUCTION-RESEARCH.md`](COLLISION-OBSTRUCTION-RESEARCH.md) and [`../reference/diagnostics/README.md`](../reference/diagnostics/README.md).

## Asset preparation

- Run `tools/prepare-menu-art.py` after changing editable menu artwork.
- Run `tools/prepare-surround-overlays.py` after changing the player or enemy obstruction-square images.
- Navigation-dot and fine-grid PNG/DDS pairs are maintained directly under `src/assets/overlay/`.
- Run `tools/prepare-custom-keys.py` after changing the replaceable CustomKeys source files.

After regenerating assets, run `pnpm run build:all` again.

## Runtime acceptance

Automated checks cannot prove Warcraft-specific presentation and pathing. For a player-facing release, test at least:

1. root and category navigation;
2. every changed briefing page and toolbar;
3. activity start, Redo, Menu, Resume/Exit and re-entry;
4. result-card Replay/Retry/Next behavior;
5. save/load in every changed state;
6. Quest and F9 behavior;
7. the development lifecycle check;
8. the exact mechanic changed by the release.

Keep generated maps and validation reports in `outputs/`. Do not edit the accepted foundation or reference maps in place.
