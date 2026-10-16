# Jamie's Training Grounds

[Download v0.2.1](https://github.com/solanum-wc3/jamies-training-grounds/releases/download/v0.2.1/Jamies-Training-Grounds-v0.2.1.w3x) · [Release notes](https://github.com/solanum-wc3/jamies-training-grounds/releases/tag/v0.2.1)

Jamie’s Training Grounds is a Warcraft III teaching and practice map. Guided tutorials introduce the essentials, while focused exercises let players repeat and explore mechanical skills.

## Current release

**v0.2.1**, released 16 October 2026, contains five tutorials and ten playable exercises/demonstrations:

- Camera, Unit Controls, Hotkey Setup, Economy & Workers, and Heroes;
- Body Blocking, Surrounds, Gargoyle Surrounds, Windwalk Pop, Mining Micro, Bat Splitting, and Dodging;
- Power Building, Hotkey Trainer, and Reflex Training (WIP) under Tools & Extras.

Other menu cards in that release are placeholders. Modes, stages and individual setups are not counted as separate exercises. See the [activity catalogue](docs/ACTIVITIES.md) for details.

The release includes shared menus, toolbars, result cards, scoped cleanup and save/load presentation restoration. Player-facing text-file exports are disabled because Warcraft’s native Preload output does not preserve arbitrary text reliably. Development builds retain machine-readable diagnostic exports.

## Current development

Source and public map are at **v0.2.1**. This fixes-only release improves Heroes cleanup and controls, Surrounds hero setup and navigation, countdown feedback, briefing tooltips and Mining Build Order. Demo Mode remains planned for v0.3.0. See [release validation and limitations](docs/RELEASE-STATUS.md) and [development status](docs/DEVELOPMENT-STATUS.md).

Development workflow is defined in [AGENTS.md](AGENTS.md) and [CONTRIBUTING.md](CONTRIBUTING.md).

## Repository guide

- [docs](docs/README.md) — current implementation guidance, release status and historical reports
- [design](design/README.md) — editable artwork, tutorial scripts/layouts and measurement inputs
- [src](docs/PROJECT-FILES.md) — maintained Lua modules, generated data and packaged assets
- [tools](tools/README.md) — build, asset preparation and validation utilities
- `reference/` — immutable source maps, accepted foundation and extracted historical assets
- `outputs/` — generated maps and build reports; ignored by Git
- `work/` — temporary investigations; ignored by Git

## Build and test

```text
pnpm install --frozen-lockfile
pnpm run check:lua
pnpm run build:release
```

Builds use the version configured in `tools/build-infrastructure.cjs` and write `outputs/Jamies-Training-Grounds-<version>.w3x`. Use `pnpm run build:development` for the matching `-dev` map, or `pnpm run build:all` for both. Release mode omits development tools; it does not publish the map or imply gameplay acceptance. Generated maps are distributed separately from source commits.

The immutable `v0.0.1-alpha.5` Twisted Meadows foundation supplies terrain and preview/minimap assets. Current behavior comes from `src/` and the explicit module list in the builder.

## Development guidance

- [Build, installation and testing](docs/BUILD-AND-TEST.md)
- [Architecture](docs/ARCHITECTURE.md)
- [Adding an activity](docs/ADDING-AN-ACTIVITY.md)
- [Tutorial standard](docs/TUTORIAL-STANDARD.md)
- [Release status and acceptance](docs/RELEASE-STATUS.md)
- [Changelog](CHANGELOG.md)
