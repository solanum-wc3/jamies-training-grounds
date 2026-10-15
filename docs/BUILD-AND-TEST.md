# Build, installation and testing

## Requirements

- Windows with Warcraft III installed for runtime testing

- Node.js 20 or newer

- pnpm 11 (the repository declares `pnpm@11.19.0`)

- Python 3 with Pillow when regenerating image assets; `lupa` when running Lua regression fixtures

The normal map build uses committed generated assets and does not require Python. It refreshes Hotkey/Reflex briefing Lua and Heroes narration/data from maintained author inputs using Node.js. Author files are never overwritten. Development builds use empty audit defaults on a fresh checkout; explicitly prepared local Hotkey binding/history files under `work/` override those defaults.

## Clean-checkout setup

```text

git clone <repository-url>

cd jamies-training-grounds

pnpm install --frozen-lockfile

pnpm run build:all

```

`build:all` creates and validates:

- `outputs/Jamies-Training-Grounds-<version>.w3x`

- `outputs/Jamies-Training-Grounds-<version>-dev.w3x`

`<version>` is configured in `tools/build-infrastructure.cjs`; it is independent of the published beta release. `--mode=release` selects packaging without development tools and does not publish anything.

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

Alpha58 adds `-heroes-audio-control` (isolated three-second shared-control probe), `-heroes-audio-no-control` (Heroes opening without that one setting), and `-heroes-terrain` (exports the bounded terrain cleanup history to `JTG-Heroes-Terrain.pld`). Stop the A/B entry with `-heroes-audio-stop`. See [alpha58 testing](ALPHA58-TESTING.md).

Heroes audio isolation is available in development builds: from no active activity, use `-heroes-audio-start`, then `-heroes-audio-stop`. The latter exports `JTG-Heroes-Audio.pld` with native XP/food and placement records. `-heroes-audio-sounds` compares labelled PauseGame, GlueScreenClick and UpkeepLevel cues three seconds apart. See [alpha57 testing](ALPHA57-TESTING.md). The export is diagnostic preload output; never execute it as a script.

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

## Source checks without packaging

```text

pnpm run check:lua

python -m pip install lupa

pnpm run test:reliability

```

The fixtures use an installed `lupa`, or the existing local copy under ignored `work/lua-test-runtime`. They check routing and lifecycle, not the native engine. Python and Node must be available on PATH for these commands.

Economy diagnostics in development builds: `-economy-orders` writes `JTG-Economy-Orders.pld`, and `-export-layout` writes `JTG-Economy-Layout.pld` to Warcraft III’s `CustomMapData`. Dodging diagnostics are listed in [DODGE-TEST-BENCH.md](DODGE-TEST-BENCH.md). These exports intentionally contain native wrappers; never execute them as scripts.

See [release status](RELEASE-STATUS.md) for recorded beta1 acceptance. A maintenance check does not require distributing another alpha.

## Maintenance packaging

Use an isolated output directory when checking a cleanup against an already distributed milestone:

```text
node tools/build-infrastructure.cjs --mode=release --output-dir=work/maintenance-build
node tools/build-infrastructure.cjs --mode=development --output-dir=work/maintenance-build
```

This runs the same archive validations without replacing the files in `outputs/`. The default builder behavior remains unchanged.

## Checkpoint and audit reproducibility

`pnpm run test:reliability` includes generated-text, Heroes-data, clean-build-input checks and 42 Lua fixture files. `lupa` must be installed in the Python environment; the runner also accepts an existing local runtime under ignored `work/lua-test-runtime`.

Fresh development builds do not require player-specific audit files. For automated Hotkey comparisons, first run `python tools/prepare-hotkey-comparison.py <CustomKeys.txt>` with the layout the tester will use. This creates `work/hotkey-comparison-bindings.lua`. Without it, normal training and manual diagnostics remain available, but no automated keyboard sequence is assumed. Audit exclusions/history are optional and may be prepared separately. See [Hotkey comparison](HOTKEY-COMPARISON.md) and [full audit](HOTKEY-FULL-AUDIT.md).

Current source/acceptance state is tracked in [development status](DEVELOPMENT-STATUS.md); the published release's historical evidence remains in [release status](RELEASE-STATUS.md).
