# Changelog

This file records player-visible changes in tested project versions. Development reasoning belongs in commit messages and `docs/decisions/`.

## Unreleased

- Established the successor-project repository structure.
- Recorded the initial modular-map and text-first tutorial direction.

## v0.0.1-alpha.5 — Preview and loading-screen test

- Removed the menu-minimap marker layer so gold mines, buildings, and player starts no longer cover the browser artwork.
- Added the legacy map's loading-screen model and original fullscreen texture as the temporary loading screen.
- Preserved the separate real terrain minimap used during loading and play.

## v0.0.1-alpha.4 — Foundation completion test

- Set the map author metadata to `Jamie & Solanum`.
- Replaced the Reforged browser minimap with the Arthas and Jaina thumbnail and restored the real terrain minimap at runtime.
- Made unexplored terrain fully black by default.
- Replaced generated arena texture patches with Twisted Meadows' original hand-authored ground-painting pattern while retaining the flattened district and raised boundary.

## v0.0.1-alpha.3 — Metadata and preview test

- Put the version number in the map-browser title and restored `Solo` as the suggested-player value.
- Removed lobby-panel author text and moved foundation credits into the Quest window.
- Restored race selection so the training map is not tied to Orc.
- Replaced the incorrect shield preview asset with the Arthas and Jaina artwork from the legacy training interface.
- Matched the legacy map's preview-flag behavior for thumbnail testing.
- Recorded that visibility, music, and race-specific presentation belong to individual activities.

## v0.0.1-alpha.2 — Foundation and lobby test

- Converted the custom-game lobby to one fixed Orc player slot.
- Added the permanent map name, description, credits, and a separate version/test line.
- Added the initial custom preview asset.
- Restored normal fog of war and unexplored-map masking.
- Reworked the northeastern practice district with varied grass and earth patches.
- Retained both empty arenas, the blocking perimeter, test units, chat commands, and native Quest window.

## Foundation test 01

- Created two empty practice spaces in the northeastern district of Twisted Meadows.
- Removed terrain objects and units only from the designated district.
- Disabled melee starting armies and victory conditions.
- Added a temporary movement, camera, and Quest-window test harness.
