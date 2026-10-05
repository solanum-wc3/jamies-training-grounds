# Jamie's Training Grounds

Jamie’s Training Grounds is a Warcraft III teaching and practice map. It combines beginner tutorials, mechanical exercises, demonstrations and reference material in one map with a shared interface.

## Current release

The current tested release is `v0.1.0`. It includes:

- Camera, Unit Controls and Hotkey Setup tutorials;
- Body Blocking, Mining Micro, Surrounds and Windwalk Pop training;
- the Power Building demonstration;
- shared menus, briefing pages, toolbars, result cards and activity cleanup;
- save/load restoration across supported menus and activities;
- separate release and development builds;
- development-only lifecycle and collision diagnostics;
- collision-square, snap-point and navigation-grid visualization in relevant exercises.

The map is built on the accepted `v0.0.1-alpha.5` Twisted Meadows foundation. The source foundation and historical references remain unchanged; current map behavior is implemented through the maintained modules under `src/`.

## Design direction

- Keep Warcraft III’s native interface and Quest window usable.
- Use reusable arenas where terrain is incidental.
- Use decorated match-like areas where terrain is part of the lesson.
- Give every activity explicit setup, start, reset, cleanup and exit behavior.
- Present essential instruction as player-paced text. Audio remains optional.
- Keep release builds free of developer tools while retaining reproducible development builds for diagnostics.

## Repository guide

- [`docs/`](docs/README.md) — current architecture, research, decisions and an archive of completed plans
- `design/` — editable source artwork and future design material
- `reference/` — immutable historical maps, accepted foundations and extracted reference assets
- `src/` — authoritative Lua modules, data and packaged assets
- `tools/` — reproducible build and asset-preparation utilities
- `outputs/` — generated maps and validation reports; excluded from version control
- `work/` — temporary investigation material; excluded from version control

## Building

```text
pnpm install --frozen-lockfile
pnpm run build:all
```

This produces `outputs/Jamies-Training-Grounds-v0.1.0.w3x` and `outputs/Jamies-Training-Grounds-v0.1.0-dev.w3x`. See [`tools/README.md`](tools/README.md) for diagnostics and build details.
